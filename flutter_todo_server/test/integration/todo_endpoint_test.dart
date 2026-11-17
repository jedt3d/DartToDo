import 'dart:convert';
import 'dart:io';

import 'package:flutter_todo_server/server.dart';
import 'package:flutter_todo_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

TodoTask _newTask(String title, {int listId = 1}) => TodoTask(
  title: title,
  listId: listId,
  steps: [],
  attachments: [],
);

void main() {
  IOOverrides.global = LoopbackIoOverrides();
  withServerpod('Local To Do PostgreSQL contract', (sessionBuilder, endpoints) {
    test(
      'fresh state creates exactly one inbox and singleton settings',
      () async {
        final state = await endpoints.todo.fetch(sessionBuilder);
        expect(state.lists.map((list) => list.id), [1]);
        expect(state.lists.single.title, 'Tasks');
        expect(state.settings.id, 1);
        expect(state.settings.smartThemes['my-day'], 'tv_tower');
        final second = await endpoints.todo.fetch(sessionBuilder);
        expect(second.lists.length, 1);
      },
    );

    test(
      'task, steps, notes, dates and file bytes survive a fresh read',
      () async {
        final task = _newTask("Read 'quoted' task; DROP TABLE todo_task;")
          ..notes = 'First line\nSecond line'
          ..myDay = '2026-11-17'
          ..dueDate = '2026-11-18'
          ..reminder = DateTime.utc(2026, 11, 18, 8)
          ..steps = [TodoStep(id: 'step-1', title: 'Read', completed: true)]
          ..attachments = [
            TodoAttachment(
              id: 'file-1',
              name: 'notes.txt',
              mimeType: 'text/plain',
              dataBase64: base64Encode([1, 2, 3]),
            ),
          ];
        final saved = await endpoints.todo.saveTask(sessionBuilder, task);
        final loaded = (await endpoints.todo.fetch(
          sessionBuilder,
        )).tasks.single;
        expect(loaded.id, saved.id);
        expect(loaded.title, task.title);
        expect(loaded.notes, task.notes);
        expect(loaded.steps.single.completed, true);
        expect(loaded.attachments.single.dataBase64, 'AQID');
        expect(loaded.myDay, '2026-11-17');
        expect(loaded.dueDate, '2026-11-18');
        expect(loaded.reminder, DateTime.utc(2026, 11, 18, 8));
      },
    );

    test('editing preserves task identity and creation date', () async {
      final saved = await endpoints.todo.saveTask(
        sessionBuilder,
        _newTask('Original'),
      );
      final edited = await endpoints.todo.saveTask(
        sessionBuilder,
        saved.copyWith(
          title: 'Changed',
          important: true,
          createdAt: DateTime.utc(1900),
        ),
      );
      expect(edited.id, saved.id);
      expect(edited.createdAt, saved.createdAt);
      expect(edited.title, 'Changed');
      expect(edited.important, true);
    });

    test('completion is idempotent and can be undone', () async {
      final task = await endpoints.todo.saveTask(
        sessionBuilder,
        _newTask('Finish'),
      );
      var state = await endpoints.todo.completeTask(
        sessionBuilder,
        task.id!,
        true,
        '2026-11-17',
      );
      expect(state.tasks.single.completed, true);
      expect(state.tasks.single.completedAt, isNotNull);
      state = await endpoints.todo.completeTask(
        sessionBuilder,
        task.id!,
        true,
        '2026-11-17',
      );
      expect(state.tasks.length, 1);
      state = await endpoints.todo.completeTask(
        sessionBuilder,
        task.id!,
        false,
        '2026-11-17',
      );
      expect(state.tasks.single.completed, false);
      expect(state.tasks.single.completedAt, isNull);
    });

    test(
      'monthly recurrence clamps Jan 31 to leap-day Feb 29 and resets steps',
      () async {
        final task = _newTask('Monthly')
          ..repeat = 'monthly'
          ..dueDate = '2024-01-31'
          ..myDay = '2024-01-31'
          ..steps = [TodoStep(id: 'step', title: 'A step', completed: true)];
        final saved = await endpoints.todo.saveTask(sessionBuilder, task);
        final state = await endpoints.todo.completeTask(
          sessionBuilder,
          saved.id!,
          true,
          '2024-01-31',
        );
        expect(state.tasks.length, 2);
        final next = state.tasks.singleWhere((task) => !task.completed);
        expect(next.id, isNot(saved.id));
        expect(next.dueDate, '2024-02-29');
        expect(next.myDay, isNull);
        expect(next.steps.single.completed, false);
        expect(
          state.tasks.singleWhere((task) => task.id == saved.id).dueDate,
          '2024-01-31',
        );
      },
    );

    test(
      'recurring completion retry and undo/redo never duplicate next occurrence',
      () async {
        final task = await endpoints.todo.saveTask(
          sessionBuilder,
          _newTask('Daily')..repeat = 'daily',
        );
        await endpoints.todo.completeTask(
          sessionBuilder,
          task.id!,
          true,
          '2026-11-17',
        );
        var state = await endpoints.todo.completeTask(
          sessionBuilder,
          task.id!,
          true,
          '2026-11-17',
        );
        expect(state.tasks.length, 2);
        final nextId = state.tasks.singleWhere((task) => !task.completed).id;
        state = await endpoints.todo.completeTask(
          sessionBuilder,
          task.id!,
          false,
          '2026-11-17',
        );
        expect(state.tasks.map((task) => task.id), [task.id]);
        state = await endpoints.todo.completeTask(
          sessionBuilder,
          task.id!,
          true,
          '2026-11-17',
        );
        expect(state.tasks.length, 2);
        expect(state.tasks.singleWhere((task) => !task.completed).id, nextId);
      },
    );

    test(
      'recurrence beyond supported calendar dates rejects without completing',
      () async {
        final task = await endpoints.todo.saveTask(
          sessionBuilder,
          _newTask('Last date')
            ..repeat = 'yearly'
            ..dueDate = '9999-12-31',
        );
        await expectLater(
          endpoints.todo.completeTask(
            sessionBuilder,
            task.id!,
            true,
            '9999-12-31',
          ),
          throwsA(isA<TodoException>()),
        );
        final state = await endpoints.todo.fetch(sessionBuilder);
        expect(state.tasks.single.completed, false);
        expect(state.tasks.single.dueDate, '9999-12-31');
      },
    );

    test('task delete and restore preserve full content', () async {
      final task = await endpoints.todo.saveTask(
        sessionBuilder,
        _newTask('Undo me')..notes = 'Keep this',
      );
      expect(
        (await endpoints.todo.deleteTask(sessionBuilder, task.id!)).tasks,
        isEmpty,
      );
      final restored = await endpoints.todo.restoreTask(
        sessionBuilder,
        task.id!,
      );
      expect(restored.tasks.single.notes, 'Keep this');
      expect(restored.tasks.single.id, task.id);
    });

    test('list delete hides tasks and list restore restores them', () async {
      final list = await endpoints.todo.saveList(
        sessionBuilder,
        TodoList(title: 'Shopping'),
      );
      final task = await endpoints.todo.saveTask(
        sessionBuilder,
        _newTask('Milk', listId: list.id!),
      );
      var state = await endpoints.todo.deleteList(sessionBuilder, list.id!);
      expect(state.tasks, isEmpty);
      expect(state.lists.map((list) => list.id), [1]);
      state = await endpoints.todo.restoreList(sessionBuilder, list.id!);
      expect(state.tasks.single.id, task.id);
    });

    test(
      'group deletion keeps lists and tasks and removes their group',
      () async {
        final group = await endpoints.todo.saveGroup(
          sessionBuilder,
          TodoGroup(title: 'Work'),
        );
        final list = await endpoints.todo.saveList(
          sessionBuilder,
          TodoList(title: 'Project', groupId: group.id),
        );
        await endpoints.todo.saveTask(
          sessionBuilder,
          _newTask('Ship', listId: list.id!),
        );
        final state = await endpoints.todo.deleteGroup(
          sessionBuilder,
          group.id!,
        );
        expect(state.groups, isEmpty);
        expect(
          state.lists.singleWhere((item) => item.id == list.id).groupId,
          isNull,
        );
        expect(state.tasks.single.title, 'Ship');
      },
    );

    test('moving a task and ordering lists survive reload', () async {
      final list = await endpoints.todo.saveList(
        sessionBuilder,
        TodoList(title: 'Destination', position: -10, theme: 'beach'),
      );
      final task = await endpoints.todo.saveTask(
        sessionBuilder,
        _newTask('Move'),
      );
      await endpoints.todo.saveTask(
        sessionBuilder,
        task.copyWith(listId: list.id!, position: 15),
      );
      final state = await endpoints.todo.fetch(sessionBuilder);
      expect(state.lists.first.id, list.id);
      expect(state.tasks.single.listId, list.id);
      expect(state.tasks.single.position, 15);
      expect(state.lists.first.theme, 'beach');
    });

    test(
      'settings persist local display preferences and smart themes',
      () async {
        final state = await endpoints.todo.fetch(sessionBuilder);
        await endpoints.todo.saveSettings(
          sessionBuilder,
          state.settings.copyWith(
            displayName: 'Local tester',
            darkMode: true,
            showCompleted: false,
            smartThemes: {'my-day': 'fern'},
            sortOrder: 'dueDate',
            sortDescending: true,
          ),
        );
        final settings = (await endpoints.todo.fetch(sessionBuilder)).settings;
        expect(settings.displayName, 'Local tester');
        expect(settings.darkMode, true);
        expect(settings.showCompleted, false);
        expect(settings.smartThemes, {'my-day': 'fern'});
        expect(settings.sortOrder, 'dueDate');
        expect(settings.sortDescending, true);
      },
    );

    test(
      'created sort key matches the frontend enum at the API boundary',
      () async {
        final state = await endpoints.todo.fetch(sessionBuilder);
        final saved = await endpoints.todo.saveSettings(
          sessionBuilder,
          state.settings.copyWith(sortOrder: 'created'),
        );
        expect(saved.sortOrder, 'created');
        expect(
          (await endpoints.todo.fetch(sessionBuilder)).settings.sortOrder,
          'created',
        );
        await expectLater(
          endpoints.todo.saveSettings(
            sessionBuilder,
            saved.copyWith(sortOrder: 'createdAt'),
          ),
          throwsA(isA<TodoException>()),
        );
      },
    );

    test('My Day sort key persists across the frontend API boundary', () async {
      final state = await endpoints.todo.fetch(sessionBuilder);
      await endpoints.todo.saveSettings(
        sessionBuilder,
        state.settings.copyWith(sortOrder: 'myDay'),
      );
      expect(
        (await endpoints.todo.fetch(sessionBuilder)).settings.sortOrder,
        'myDay',
      );
    });

    test(
      'duplicating a task gets a new identity and timestamp while preserving requested values',
      () async {
        final original = await endpoints.todo.saveTask(
          sessionBuilder,
          _newTask('Original')
            ..important = true
            ..notes = 'Keep note',
        );
        final old = DateTime.utc(1900);
        final duplicate = await endpoints.todo.saveTask(
          sessionBuilder,
          original.copyWith(
            id: null,
            title: 'Copy',
            completed: false,
            createdAt: old,
          ),
        );
        expect(duplicate.id, isNot(original.id));
        expect(duplicate.title, 'Copy');
        expect(duplicate.important, true);
        expect(duplicate.notes, 'Keep note');
        expect(duplicate.completed, false);
        expect(duplicate.createdAt.isAfter(old), true);
        expect((await endpoints.todo.fetch(sessionBuilder)).tasks.length, 2);
      },
    );

    test(
      'invalid task title, missing list and impossible calendar dates reject atomically',
      () async {
        for (final task in [
          _newTask('  '),
          _newTask('Missing', listId: 99999999),
          _newTask('Impossible')..dueDate = '2026-02-30',
          _newTask('Wrong format')..myDay = '17/11/2026',
          _newTask('Bad recurrence')..repeatEvery = 0,
        ]) {
          await expectLater(
            endpoints.todo.saveTask(sessionBuilder, task),
            throwsA(isA<TodoException>()),
          );
        }
        expect((await endpoints.todo.fetch(sessionBuilder)).tasks, isEmpty);
      },
    );

    test(
      'negative and nonexistent identifiers return typed failures',
      () async {
        await expectLater(
          endpoints.todo.deleteTask(sessionBuilder, -1),
          throwsA(isA<TodoException>()),
        );
        await expectLater(
          endpoints.todo.restoreTask(sessionBuilder, 99999999),
          throwsA(isA<TodoException>()),
        );
        await expectLater(
          endpoints.todo.saveTask(
            sessionBuilder,
            _newTask('Missing')..id = 99999999,
          ),
          throwsA(isA<TodoException>()),
        );
      },
    );

    test('default inbox cannot be deleted, renamed or grouped', () async {
      await expectLater(
        endpoints.todo.deleteList(sessionBuilder, 1),
        throwsA(isA<TodoException>()),
      );
      await expectLater(
        endpoints.todo.saveList(
          sessionBuilder,
          TodoList(id: 1, title: 'Not Tasks'),
        ),
        throwsA(isA<TodoException>()),
      );
    });

    test(
      'unsafe attachment paths, invalid base64 and duplicate item IDs reject',
      () async {
        for (final attachment in [
          TodoAttachment(
            id: '1',
            name: '../private',
            mimeType: 'text/plain',
            dataBase64: 'AQ==',
          ),
          TodoAttachment(
            id: '1',
            name: 'safe.txt',
            mimeType: 'text/plain',
            dataBase64: '!bad!',
          ),
        ]) {
          final task = _newTask('Attachment')..attachments = [attachment];
          await expectLater(
            endpoints.todo.saveTask(sessionBuilder, task),
            throwsA(isA<TodoException>()),
          );
        }
        final task = _newTask('Duplicate')
          ..steps = [
            TodoStep(id: 'x', title: 'One'),
            TodoStep(id: 'x', title: 'Two'),
          ];
        await expectLater(
          endpoints.todo.saveTask(sessionBuilder, task),
          throwsA(isA<TodoException>()),
        );
        expect((await endpoints.todo.fetch(sessionBuilder)).tasks, isEmpty);
      },
    );

    test(
      'attachment total over 10 MB is rejected before persistence',
      () async {
        final task = _newTask('Too big')
          ..attachments = [
            TodoAttachment(
              id: '1',
              name: 'big.bin',
              mimeType: 'application/octet-stream',
              dataBase64: base64Encode(List.filled(10 * 1024 * 1024 + 1, 0)),
            ),
          ];
        await expectLater(
          endpoints.todo.saveTask(sessionBuilder, task),
          throwsA(isA<TodoException>()),
        );
        expect((await endpoints.todo.fetch(sessionBuilder)).tasks, isEmpty);
      },
    );
  });
}

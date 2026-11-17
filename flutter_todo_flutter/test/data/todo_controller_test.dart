import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:flutter_todo_flutter/data/task_queries.dart';
import 'package:flutter_todo_flutter/data/todo_controller.dart';
import 'package:flutter_todo_flutter/data/todo_repository.dart';

import 'fixtures.dart';

void main() {
  late FakeTodoRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeTodoRepository(
      snapshot(tasks: [task(id: 1, title: 'Keep me')]),
    );
    container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  test('repository closes its owned generated client', () {
    final client = _TrackingClient();
    ServerpodTodoRepository(client: client).close();
    expect(client.closeCalls, 1);
  });

  Future<TodoController> ready() async {
    await container.read(todoControllerProvider.future);
    return container.read(todoControllerProvider.notifier);
  }

  test(
    'rapid moves append in queue order using the latest destination state',
    () async {
      repository.data = snapshot(
        tasks: [
          task(id: 31),
          task(id: 21),
          task(id: 7, listId: 2, position: 4),
        ],
      );
      final controller = await ready();
      repository.saveGate = Completer<void>();
      final first = controller.moveTask(31, 2);
      final second = controller.moveTask(21, 2);
      await Future<void>.delayed(Duration.zero);
      repository.saveGate!.complete();
      final moved = await Future.wait([first, second]);
      expect(moved.map((task) => task.position), [5, 6]);
      expect(repository.maximumActiveWrites, 1);
      final ordered = [...repository.data.tasks]
        ..sort((a, b) => a.position.compareTo(b.position));
      expect(ordered.map((task) => task.id), [7, 31, 21]);
    },
  );

  test(
    'queued moves reject unavailable destinations without changing the task',
    () async {
      final controller = await ready();
      await expectLater(controller.moveTask(1, 3), throwsStateError);
      expect(repository.saveCalls, 0);
      expect(repository.data.tasks.single.listId, 1);
      final moved = await controller.moveTask(1, 2);
      expect(moved.position, 0);
      final before = repository.saveCalls;
      await controller.moveTask(1, 2);
      expect(repository.saveCalls, before);
    },
  );

  test(
    'initial failures require explicit retry and successful load replaces error',
    () async {
      repository.fetchError = StateError('Server unavailable');
      await expectLater(
        container.read(todoControllerProvider.future),
        throwsStateError,
      );
      expect(container.read(todoControllerProvider).hasError, isTrue);
      expect(repository.fetchCalls, 1);
      repository.fetchError = null;
      await container.read(todoControllerProvider.notifier).load();
      expect(
        container.read(todoControllerProvider).requireValue.tasks.single.title,
        'Keep me',
      );
      expect(repository.fetchCalls, 2);
    },
  );

  test(
    'write progress retains visible content and returns the saved task',
    () async {
      final controller = await ready();
      repository.saveGate = Completer<void>();
      final operation = controller.createTask('New task');
      await Future<void>.delayed(Duration.zero);
      expect(container.read(todoControllerProvider).isLoading, isFalse);
      expect(
        container.read(todoControllerProvider).requireValue.tasks.single.title,
        'Keep me',
      );
      expect(container.read(mutationStatusProvider).pending, 1);
      repository.saveGate!.complete();
      final saved = await operation;
      expect(saved.id, 2);
      expect(saved.title, 'New task');
      expect(
        container.read(todoControllerProvider).requireValue.tasks.length,
        2,
      );
      expect(container.read(mutationStatusProvider).pending, 0);
    },
  );

  test(
    'a failed mutation retains data and does not poison the following queue',
    () async {
      final controller = await ready();
      repository.saveError = StateError('Write failed');
      await expectLater(controller.createTask('Failed task'), throwsStateError);
      expect(
        container.read(todoControllerProvider).requireValue.tasks.single.title,
        'Keep me',
      );
      expect(container.read(mutationStatusProvider).error, isA<StateError>());
      expect(container.read(mutationStatusProvider).pending, 0);
      repository.saveError = null;
      await controller.createTask('Retry task');
      expect(
        container.read(todoControllerProvider).requireValue.tasks.last.title,
        'Retry task',
      );
      expect(container.read(mutationStatusProvider).error, isNull);
    },
  );

  test(
    'serialized field edits merge against the newest task snapshot',
    () async {
      final controller = await ready();
      repository.saveGate = Completer<void>();
      final important = controller.updateTask(
        1,
        (task) => task.copyWith(important: true),
      );
      final note = controller.updateTask(
        1,
        (task) => task.copyWith(notes: 'Do not lose this'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(repository.saveCalls, 1);
      expect(container.read(mutationStatusProvider).pending, 2);
      repository.saveGate!.complete();
      await Future.wait([important, note]);
      final saved = container
          .read(todoControllerProvider)
          .requireValue
          .tasks
          .single;
      expect(saved.important, isTrue);
      expect(saved.notes, 'Do not lose this');
      expect(repository.maximumActiveWrites, 1);
      expect(container.read(mutationStatusProvider).pending, 0);
    },
  );

  test(
    'queued creates use unique increasing positions and requested smart fields',
    () async {
      final controller = await ready();
      await Future.wait([
        controller.createTask('First', myDay: true, important: true),
        controller.createTask('Second'),
      ]);
      expect(repository.savedPositions, [1, 2]);
      final first = repository.data.tasks.firstWhere(
        (task) => task.title == 'First',
      );
      expect(first.important, isTrue);
      expect(first.myDay, localDateKey(DateTime.now()));
      expect(first.listId, 1);
      expect(first.steps, isEmpty);
      expect(first.attachments, isEmpty);
    },
  );

  test(
    'completion toggles the latest task and passes the local calendar date',
    () async {
      final controller = await ready();
      final oldTask = container
          .read(todoControllerProvider)
          .requireValue
          .tasks
          .single;
      await Future.wait([
        controller.completeTask(oldTask),
        controller.completeTask(oldTask),
      ]);
      expect(repository.data.tasks.single.completed, isFalse);
      expect(repository.completionDates, [
        localDateKey(DateTime.now()),
        localDateKey(DateTime.now()),
      ]);
    },
  );

  test('delete and restore preserve a task for undo', () async {
    final controller = await ready();
    await controller.deleteTask(1);
    expect(
      container.read(todoControllerProvider).requireValue.tasks.single.deleted,
      isTrue,
    );
    await controller.restoreTask(1);
    expect(
      container.read(todoControllerProvider).requireValue.tasks.single.deleted,
      isFalse,
    );
  });

  test('refresh failure retains current data and can be retried', () async {
    final controller = await ready();
    repository.fetchError = StateError('Disconnected');
    await expectLater(controller.refresh(), throwsStateError);
    expect(container.read(todoControllerProvider).hasValue, isTrue);
    expect(container.read(todoControllerProvider).hasError, isFalse);
    expect(container.read(mutationStatusProvider).error, isA<StateError>());
    repository.fetchError = null;
    repository.data = repository.data.copyWith(
      tasks: [task(id: 2, title: 'Updated elsewhere')],
    );
    await controller.refresh();
    expect(
      container.read(todoControllerProvider).requireValue.tasks.single.title,
      'Updated elsewhere',
    );
    expect(container.read(mutationStatusProvider).error, isNull);
  });

  test(
    'list group and settings operations publish fresh persistent snapshots',
    () async {
      final controller = await ready();
      final group = await controller.saveGroup(TodoGroup(title: 'Projects'));
      final list = await controller.saveList(
        TodoList(title: 'Local project', groupId: group.id),
      );
      expect(list.id, isNotNull);
      await controller.deleteList(list.id!);
      expect(
        container.read(todoControllerProvider).requireValue.lists.last.deleted,
        isTrue,
      );
      await controller.restoreList(list.id!);
      expect(
        container.read(todoControllerProvider).requireValue.lists.last.deleted,
        isFalse,
      );
      await controller.deleteGroup(group.id!);
      expect(
        container.read(todoControllerProvider).requireValue.groups,
        isEmpty,
      );
      expect(
        container.read(todoControllerProvider).requireValue.lists.last.groupId,
        isNull,
      );
      final settings = repository.data.settings.copyWith(
        displayName: 'On this Mac',
      );
      await controller.saveSettings(settings);
      expect(
        container
            .read(todoControllerProvider)
            .requireValue
            .settings
            .displayName,
        'On this Mac',
      );
    },
  );

  test(
    'disposing while a write is pending does not update disposed providers',
    () async {
      final controller = await ready();
      repository.saveGate = Completer<void>();
      final operation = controller.createTask('Finishing write');
      await Future<void>.delayed(Duration.zero);
      container.dispose();
      repository.saveGate!.complete();
      expect((await operation).title, 'Finishing write');
      expect(repository.fetchCalls, 1);
    },
  );
}

final class _TrackingClient extends Client {
  _TrackingClient() : super('http://127.0.0.1:8870/');

  int closeCalls = 0;

  @override
  void close() {
    closeCalls++;
    super.close();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:flutter_todo_flutter/data/task_queries.dart';
import 'package:flutter_todo_flutter/data/todo_controller.dart';
import 'package:flutter_todo_flutter/services/reminders.dart';
import 'package:flutter_todo_flutter/ui/todo_app.dart';

import '../data/fixtures.dart';
import 'support.dart';

const _iPadLandscape = Size(1194, 834);
const _iPadPortrait = Size(834, 1194);

String _text(WidgetTester tester, String key) =>
    tester.widget<TextField>(find.byKey(Key(key))).controller!.text;

TodoTask _richTask() =>
    task(
      id: 11,
      title: 'Move this task',
      myDay: localDateKey(DateTime.now()),
      important: true,
      dueDate: '2030-03-14',
      notes: 'Original note with Unicode 日本語',
      steps: [
        TodoStep(id: 's1', title: 'First step', completed: true),
        TodoStep(id: 's2', title: 'Second step'),
      ],
    ).copyWith(
      repeat: 'weekly',
      repeatEvery: 2,
      reminder: DateTime.utc(2030, 3, 14, 9),
      attachments: [
        TodoAttachment(
          id: 'f1',
          name: 'résumé.txt',
          mimeType: 'text/plain',
          dataBase64: base64Encode([0, 1, 2, 127, 255]),
        ),
      ],
    );

TodoSnapshot _moveData() => uiData(
  tasks: [
    _richTask(),
    task(id: 21, title: 'Existing Work task', listId: 2, position: 9),
  ],
);

Map<String, dynamic> _contentWithoutLocation(TodoTask task) => task.toJson()
  ..remove('listId')
  ..remove('position');

Future<void> _moveByGesture(
  WidgetTester tester, {
  required bool touch,
  int taskId = 11,
  int destinationId = 2,
}) async {
  final handle = find.byKey(ValueKey('move-task-$taskId'));
  expect(handle.hitTestable(), findsOneWidget);
  if (touch) {
    expect(tester.widget(handle), isA<LongPressDraggable>());
  } else {
    expect(tester.widget(handle), isA<Draggable>());
    expect(tester.widget(handle), isNot(isA<LongPressDraggable>()));
  }
  final gesture = await tester.startGesture(
    tester.getCenter(handle),
    kind: touch ? PointerDeviceKind.touch : PointerDeviceKind.mouse,
  );
  if (touch) {
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
  } else {
    await gesture.moveBy(const Offset(-12, 0));
    await tester.pump();
  }
  final target = find.byKey(ValueKey('drop-list-$destinationId'));
  expect(target.hitTestable(), findsOneWidget);
  await gesture.moveTo(tester.getCenter(target));
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _closeDetails(WidgetTester tester) async {
  final close = find.byTooltip('Close details').first;
  await tester.ensureVisible(close);
  await tester.tap(close);
  await tester.pumpAndSettle();
}

Future<void> _editNotes(WidgetTester tester, String notes) async {
  final field = find.byKey(const Key('task-notes'));
  await tester.ensureVisible(field);
  await tester.enterText(field, notes);
}

Future<void> _refresh(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(TodoApp)),
  );
  await container.read(todoControllerProvider.notifier).refresh();
  await tester.pumpAndSettle();
}

final class _ReminderCapture {
  ValueChanged<int>? select;
  int creations = 0;

  ReminderService create(ValueChanged<int> callback) {
    creations++;
    select = callback;
    return ReminderService(onTaskSelected: callback);
  }
}

Future<_ReminderCapture> _pumpReminderApp(
  WidgetTester tester,
  FakeTodoRepository repository, {
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 800);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  final capture = _ReminderCapture();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [repositoryProvider.overrideWithValue(repository)],
      child: TodoApp(
        platformServices: false,
        reminderServiceFactory: capture.create,
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
  expect(capture.select, isNotNull, reason: 'Register routing while mounted.');
  expect(capture.creations, 1);
  return capture;
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets(
    'iPad landscape opens the first sorted visible task after initial load',
    (tester) async {
      final today = localDateKey(DateTime.now());
      final data = uiData(
        tasks: [
          task(id: 1, title: 'A completed', completed: true, myDay: today),
          task(id: 2, title: 'Zulu active', position: 1, myDay: today),
          task(id: 3, title: 'Bravo active', position: 2, myDay: today),
        ],
      );
      final repository = FakeTodoRepository(
        data.copyWith(
          settings: data.settings.copyWith(
            sortOrder: 'alphabetical',
            showCompleted: false,
          ),
        ),
      )..fetchGate = Completer<void>();
      await pumpApp(
        tester,
        size: _iPadLandscape,
        repository: repository,
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('task-title')), findsNothing);
      repository.fetchGate!.complete();
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Bravo active');
      expect(find.byKey(const Key('add-task')), findsOneWidget);
      expect(find.text('A completed'), findsNothing);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'iPad hidden completed tasks leave an empty inspector until shown',
    (tester) async {
      final data = uiData(
        tasks: [
          task(
            id: 1,
            title: 'Finished task',
            completed: true,
            myDay: localDateKey(DateTime.now()),
          ),
        ],
      );
      await pumpApp(
        tester,
        size: _iPadLandscape,
        data: data.copyWith(
          settings: data.settings.copyWith(showCompleted: false),
        ),
      );
      expect(find.text('No task selected'), findsOneWidget);
      expect(find.byKey(const Key('task-title')), findsNothing);
      await tester.tap(find.byKey(const Key('list-options')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Completed Tasks'));
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Finished task');
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'iPad inspector stays closed after refresh and reopens on landscape entry',
    (tester) async {
      await pumpApp(tester, size: _iPadLandscape);
      expect(_text(tester, 'task-title'), 'Focus task');
      await _closeDetails(tester);
      await _refresh(tester);
      expect(find.byKey(const Key('task-title')), findsNothing);
      expect(find.text('No task selected'), findsNothing);
      tester.view.physicalSize = _iPadPortrait;
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('task-title')), findsNothing);
      tester.view.physicalSize = _iPadLandscape;
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Focus task');
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'iPad selection survives portrait and landscape layout changes',
    (tester) async {
      await pumpApp(tester, size: _iPadLandscape);
      tester.view.physicalSize = _iPadPortrait;
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Focus task');
      expect(find.byKey(const Key('add-task')), findsNothing);
      tester.view.physicalSize = _iPadLandscape;
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Focus task');
      expect(find.byKey(const Key('add-task')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'iPad list navigation selects its own first task and handles empty lists',
    (tester) async {
      final data = _moveData();
      await pumpApp(
        tester,
        size: _iPadLandscape,
        data: data.copyWith(
          lists: [
            ...data.lists,
            TodoList(id: 4, title: 'Empty'),
          ],
        ),
      );
      expect(_text(tester, 'task-title'), 'Move this task');
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Existing Work task');
      await tester.tap(find.text('Empty'));
      await tester.pumpAndSettle();
      expect(find.text('No task selected'), findsOneWidget);
      expect(find.byKey(const Key('task-title')), findsNothing);
      await tester.tap(find.text('My Day').first);
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Move this task');
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  for (final device in [
    (
      name: 'desktop',
      platform: TargetPlatform.macOS,
      size: Size(1200, 800),
      touch: false,
    ),
    (
      name: 'phone',
      platform: TargetPlatform.iOS,
      size: Size(390, 844),
      touch: true,
    ),
  ]) {
    testWidgets(
      '${device.name} dedicated drag handle moves a task without changing its content',
      (tester) async {
        final original = _richTask();
        final repository = await pumpApp(
          tester,
          size: device.size,
          data: _moveData(),
        );
        expect(find.byKey(const Key('task-title')), findsNothing);
        await _moveByGesture(tester, touch: device.touch);
        final moved = repository.data.tasks.singleWhere(
          (task) => task.id == original.id,
        );
        expect(moved.listId, 2);
        expect(moved.position, 10);
        expect(
          _contentWithoutLocation(moved),
          _contentWithoutLocation(original),
        );
        expect(_text(tester, 'task-title'), original.title);
        expect(repository.data.tasks.length, 2);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(device.platform),
    );
  }

  testWidgets(
    'dragging preserves a failed dirty editor and retries the save before moving',
    (tester) async {
      final repository = await pumpApp(
        tester,
        size: const Size(1200, 800),
        data: _moveData(),
      );
      await openDetails(tester, title: 'Move this task');
      repository.saveError = StateError('Write unavailable');
      await _editNotes(tester, 'Unsaved note must survive');
      await _moveByGesture(tester, touch: false);
      expect(
        repository.data.tasks.singleWhere((task) => task.id == 11).listId,
        1,
      );
      expect(_text(tester, 'task-notes'), 'Unsaved note must survive');
      expect(find.textContaining('Could not save.'), findsWidgets);
      repository.saveError = null;
      await _moveByGesture(tester, touch: false);
      final moved = repository.data.tasks.singleWhere((task) => task.id == 11);
      expect(moved.listId, 2);
      expect(moved.notes, 'Unsaved note must survive');
      expect(
        moved.steps.map((step) => step.toJson()),
        _richTask().steps.map((step) => step.toJson()),
      );
      expect(
        moved.attachments.single.dataBase64,
        _richTask().attachments.single.dataBase64,
      );
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets(
    'a rejected move write keeps task content and can be retried',
    (tester) async {
      final repository = await pumpApp(
        tester,
        size: const Size(1200, 800),
        data: _moveData(),
      );
      final original = repository.data.tasks.singleWhere(
        (task) => task.id == 11,
      );
      repository.saveError = StateError('Move unavailable');
      await _moveByGesture(tester, touch: false);
      expect(
        repository.data.tasks.singleWhere((task) => task.id == 11).toJson(),
        original.toJson(),
      );
      expect(find.textContaining('Could not save.'), findsOneWidget);
      expect(find.byKey(const Key('task-title')), findsNothing);
      repository.saveError = null;
      await _moveByGesture(tester, touch: false);
      final moved = repository.data.tasks.singleWhere((task) => task.id == 11);
      expect(moved.listId, 2);
      expect(_contentWithoutLocation(moved), _contentWithoutLocation(original));
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets(
    'reminder factory registers routing while platform services are disabled',
    (tester) async {
      final capture = await _pumpReminderApp(
        tester,
        FakeTodoRepository(_moveData()),
      );
      capture.select!(21);
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Existing Work task');
      await tester.pumpWidget(const SizedBox());
      expect(capture.creations, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a reminder received during loading opens its task after the snapshot arrives',
    (tester) async {
      final repository = FakeTodoRepository(_moveData())
        ..fetchGate = Completer<void>();
      final capture = await _pumpReminderApp(tester, repository, settle: false);
      capture.select!(11);
      capture.select!(21);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      repository.fetchGate!.complete();
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Existing Work task');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'latest reminder wins when callbacks arrive before navigation finishes',
    (tester) async {
      final data = _moveData();
      final capture = await _pumpReminderApp(
        tester,
        FakeTodoRepository(
          data.copyWith(
            tasks: [
              ...data.tasks,
              task(id: 31, title: 'Latest reminder target', listId: 2),
            ],
          ),
        ),
      );
      capture.select!(21);
      capture.select!(31);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('task-title')), findsOneWidget);
      expect(_text(tester, 'task-title'), 'Latest reminder target');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'missing and deleted reminder tasks report unavailable without changing selection',
    (tester) async {
      final data = _moveData();
      final capture = await _pumpReminderApp(
        tester,
        FakeTodoRepository(
          data.copyWith(tasks: [...data.tasks, task(id: 31, deleted: true)]),
        ),
      );
      await openDetails(tester, title: 'Move this task');
      capture.select!(999);
      await tester.pumpAndSettle();
      expect(
        find.text('This reminder’s task is no longer available.'),
        findsOneWidget,
      );
      expect(_text(tester, 'task-title'), 'Move this task');
      capture.select!(31);
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Move this task');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reminder navigation retains a dirty editor on failure and retries after refresh',
    (tester) async {
      final repository = FakeTodoRepository(_moveData());
      final capture = await _pumpReminderApp(tester, repository);
      await openDetails(tester, title: 'Move this task');
      repository.saveError = StateError('Write unavailable');
      await _editNotes(tester, 'Keep this notification draft');
      capture.select!(21);
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Move this task');
      expect(_text(tester, 'task-notes'), 'Keep this notification draft');
      expect(
        repository.data.tasks.singleWhere((task) => task.id == 11).notes,
        _richTask().notes,
      );
      repository.saveError = null;
      await _refresh(tester);
      expect(_text(tester, 'task-title'), 'Existing Work task');
      expect(
        repository.data.tasks.singleWhere((task) => task.id == 11).notes,
        'Keep this notification draft',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'pending reminder routing survives an initial load failure and explicit retry',
    (tester) async {
      final repository = FakeTodoRepository(_moveData())
        ..fetchError = StateError('Service stopped');
      final capture = await _pumpReminderApp(tester, repository);
      capture.select!(21);
      await tester.pumpAndSettle();
      expect(
        find.text('Couldn’t connect to your local server'),
        findsOneWidget,
      );
      repository.fetchError = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(_text(tester, 'task-title'), 'Existing Work task');
      expect(tester.takeException(), isNull);
    },
  );
}

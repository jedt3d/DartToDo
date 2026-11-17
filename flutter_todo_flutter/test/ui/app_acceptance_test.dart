import 'dart:async';
import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:flutter_todo_flutter/data/task_queries.dart';

import '../data/fixtures.dart';
import 'support.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets('loading becomes the empty local My Day without login', (
    tester,
  ) async {
    final repository = FakeTodoRepository(uiData(tasks: []))
      ..fetchGate = Completer<void>();
    await pumpApp(tester, repository: repository, settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    repository.fetchGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('My Day'), findsNWidgets(2));
    expect(find.byKey(const Key('add-task')), findsOneWidget);
    expect(find.textContaining('Sign in'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a disconnected local service shows a working explicit retry', (
    tester,
  ) async {
    final repository = FakeTodoRepository(uiData())
      ..fetchError = StateError('Service is stopped');
    await pumpApp(tester, repository: repository);
    expect(find.text('Couldn’t connect to your local server'), findsOneWidget);
    repository.fetchError = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Focus task'), findsOneWidget);
    expect(repository.fetchCalls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'new tasks persist their My Day importance and completion changes',
    (tester) async {
      final repository = await pumpApp(tester, data: uiData(tasks: []));
      await addTask(tester, 'Write a local task');
      expect(repository.data.tasks.single.title, 'Write a local task');
      expect(repository.data.tasks.single.myDay, localDateKey(DateTime.now()));
      await tester.tap(find.byTooltip('Mark as important'));
      await tester.pumpAndSettle();
      expect(repository.data.tasks.single.important, isTrue);
      await tester.tap(find.byTooltip('Complete Write a local task'));
      await tester.pumpAndSettle();
      expect(repository.data.tasks.single.completed, isTrue);
      expect(find.text('Completed 1'), findsOneWidget);
      await tester.tap(find.byTooltip('Mark Write a local task incomplete'));
      await tester.pumpAndSettle();
      expect(repository.data.tasks.single.completed, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed task creation keeps the draft and can be retried', (
    tester,
  ) async {
    final repository = await pumpApp(tester, data: uiData(tasks: []));
    repository.saveError = StateError('Database unavailable');
    await addTask(tester, 'Keep this draft');
    expect(repository.data.tasks, isEmpty);
    expect(find.textContaining('Could not add task.'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('add-task')))
          .controller!
          .text,
      'Keep this draft',
    );
    repository.saveError = null;
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(repository.data.tasks.single.title, 'Keep this draft');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'new lists contain their own tasks and rename through list options',
    (tester) async {
      final repository = await pumpApp(tester, data: uiData(tasks: []));
      await tester.tap(find.byKey(const Key('new-list')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('name-input')), 'Garden');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();
      await addTask(tester, 'Water the plants');
      final list = repository.data.lists.singleWhere(
        (list) => list.title == 'Garden',
      );
      expect(repository.data.tasks.single.listId, list.id);
      expect(repository.data.tasks.single.myDay, isNull);
      await tester.tap(find.byKey(const Key('list-options')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename List'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('name-input')),
        'Home garden',
      );
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();
      expect(
        repository.data.lists.singleWhere((item) => item.id == list.id).title,
        'Home garden',
      );
      expect(find.text('Water the plants'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('sidebar search finds notes and steps across lists', (
    tester,
  ) async {
    await pumpApp(
      tester,
      data: uiData(
        tasks: [
          task(id: 1, title: 'Release plan', notes: 'Daffodil note', listId: 2),
          task(
            id: 2,
            title: 'Errands',
            steps: [TodoStep(id: 's', title: 'Buy daffodil bulbs')],
          ),
          task(id: 3, title: 'Unrelated task'),
        ],
      ),
    );
    await tester.enterText(find.byKey(const Key('search-tasks')), 'DAFFODIL');
    await tester.pumpAndSettle();
    expect(find.text('Release plan'), findsOneWidget);
    expect(find.text('Errands'), findsOneWidget);
    expect(find.text('Unrelated task'), findsNothing);
    await tester.enterText(
      find.byKey(const Key('search-tasks')),
      'no such phrase',
    );
    await tester.pumpAndSettle();
    expect(find.text('No results'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'task details save notes steps due dates reminders and custom repeat',
    (tester) async {
      final repository = await pumpApp(tester);
      await openDetails(tester);
      await tester.enterText(
        find.byKey(const Key('add-step')),
        'Inspect the result',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(
        repository.data.tasks.single.steps.single.title,
        'Inspect the result',
      );
      await tester.tap(find.byTooltip('Complete step Inspect the result'));
      await tester.pumpAndSettle();
      expect(repository.data.tasks.single.steps.single.completed, isTrue);
      await tester.ensureVisible(find.byKey(const Key('task-notes')));
      await tester.enterText(
        find.byKey(const Key('task-notes')),
        'A note that survives closing details',
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(
        repository.data.tasks.single.notes,
        'A note that survives closing details',
      );
      await tester.ensureVisible(find.byTooltip('Choose due date'));
      await tester.tap(find.byTooltip('Choose due date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(
        repository.data.tasks.single.dueDate,
        localDateKey(DateTime.now()),
      );
      await tester.tap(find.byTooltip('Choose reminder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tomorrow · 9:00 AM'));
      await tester.pumpAndSettle();
      final reminder = repository.data.tasks.single.reminder!.toLocal();
      expect(
        localDateKey(reminder),
        localDateKey(DateTime.now().add(const Duration(days: 1))),
      );
      expect(reminder.hour, 9);
      await tester.tap(find.byTooltip('Choose repeat'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Custom…'));
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Custom…'),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        '3',
      );
      await tester.tap(find.byKey(const Key('repeat-unit')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('months').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();
      expect(repository.data.tasks.single.repeat, 'monthly');
      expect(repository.data.tasks.single.repeatEvery, 3);
      await tester.tap(find.byTooltip('Close details'));
      await tester.pumpAndSettle();
      await openDetails(tester);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('task-notes')))
            .controller!
            .text,
        'A note that survives closing details',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('rapid note edits survive switching tasks and lists', (
    tester,
  ) async {
    final today = localDateKey(DateTime.now());
    final repository = await pumpApp(
      tester,
      data: uiData(
        tasks: [
          task(id: 1, title: 'First focus', myDay: today),
          task(id: 2, title: 'Second focus', myDay: today),
        ],
      ),
    );
    await openDetails(tester, title: 'First focus');
    await tester.ensureVisible(find.byKey(const Key('task-notes')));
    await tester.enterText(
      find.byKey(const Key('task-notes')),
      'Immediate first note',
    );
    await tester.tap(find.text('Second focus').first);
    await tester.pumpAndSettle();
    expect(
      repository.data.tasks.singleWhere((task) => task.id == 1).notes,
      'Immediate first note',
    );
    expect(
      repository.data.tasks.singleWhere((task) => task.id == 2).notes,
      isEmpty,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('task-title')))
          .controller!
          .text,
      'Second focus',
    );
    await tester.enterText(
      find.byKey(const Key('task-notes')),
      'Immediate second note',
    );
    await tester.tap(find.text('Tasks').first);
    await tester.pumpAndSettle();
    expect(
      repository.data.tasks.singleWhere((task) => task.id == 2).notes,
      'Immediate second note',
    );
    expect(find.byKey(const Key('task-notes')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete confirmation and undo restore the same task', (
    tester,
  ) async {
    final repository = await pumpApp(tester);
    await openDetails(tester);
    await tester.tap(find.byTooltip('Delete task'));
    await tester.pumpAndSettle();
    expect(find.text('Delete task?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(repository.data.tasks.single.deleted, isFalse);
    await tester.tap(find.byTooltip('Delete task'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(repository.data.tasks.single.deleted, isTrue);
    expect(find.text('Focus task'), findsNothing);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(repository.data.tasks.single.deleted, isFalse);
    expect(repository.data.tasks.single.id, 1);
    expect(find.text('Focus task'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings persist the local display name and dark appearance', (
    tester,
  ) async {
    final repository = await pumpApp(tester);
    await tester.tap(find.text('Local user'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('display-name')),
      'My local workspace',
    );
    await tester.tap(find.text('Dark appearance'));
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(repository.data.settings.displayName, 'My local workspace');
    expect(repository.data.settings.darkMode, isTrue);
    expect(find.text('My local workspace'), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(tester.takeException(), isNull);
  });

  for (final device in const [
    ('desktop', Size(1100, 720)),
    ('iPad', Size(834, 1194)),
    ('iPhone', Size(390, 844)),
  ]) {
    testWidgets(
      '${device.$1} navigation and details remain usable at enlarged text',
      (tester) async {
        await pumpApp(tester, size: device.$2, textScale: 1.5);
        if (device.$1 == 'iPhone') {
          expect(find.byKey(const Key('search-tasks')), findsNothing);
          await tester.tap(find.text('Lists'));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('search-tasks')), findsOneWidget);
          await tester.tap(find.text('Tasks'));
          await tester.pumpAndSettle();
        }
        await openDetails(tester);
        expect(find.byTooltip('Close details'), findsOneWidget);
        await tester.ensureVisible(find.byKey(const Key('task-notes')));
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Close details'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('add-task')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('manual task drag persists the changed order', (tester) async {
    final today = localDateKey(DateTime.now());
    final repository = await pumpApp(
      tester,
      data: uiData(
        tasks: [
          task(id: 1, title: 'First item', myDay: today, position: 0),
          task(id: 2, title: 'Second item', myDay: today, position: 1),
        ],
      ),
    );
    await tester.drag(
      find.byTooltip('Drag to reorder').first,
      const Offset(0, 120),
    );
    await tester.pumpAndSettle();
    final tasks = repository.data.tasks.toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    expect(tasks.map((task) => task.title), ['Second item', 'First item']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('list and group order controls persist the chosen order', (
    tester,
  ) async {
    final data = uiData(tasks: []);
    data.lists = [
      TodoList(id: 1, title: 'Tasks'),
      TodoList(id: 2, title: 'Garden', position: 0),
      TodoList(id: 3, title: 'Kitchen', position: 1),
    ];
    data.groups = [
      TodoGroup(id: 1, title: 'First group', position: 0),
      TodoGroup(id: 2, title: 'Second group', position: 1),
    ];
    final repository = await pumpApp(tester, data: data);
    await tester.tap(find.byTooltip('List options for Garden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move list down'));
    await tester.pumpAndSettle();
    final lists = repository.data.lists.where((list) => list.id != 1).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    expect(lists.map((list) => list.title), ['Kitchen', 'Garden']);
    await tester.tap(find.byTooltip('Group options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move group down'));
    await tester.pumpAndSettle();
    final groups = repository.data.groups.toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    expect(groups.map((group) => group.title), ['Second group', 'First group']);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'print action sends the current task list to the native print adapter',
    (tester) async {
      MethodCall? printCall;
      const channel = MethodChannel('darttodo/native');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            printCall = call;
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('list-options')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Print List…'));
      await tester.pumpAndSettle();
      expect(printCall?.method, 'printList');
      expect((printCall!.arguments as Map)['body'], '[ ] Focus task');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('iPhone controls meet the iOS tap target guideline', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await pumpApp(tester, size: const Size(390, 844));
      final failures = <String>[];
      Future<void> check(String view) async {
        final result = await iOSTapTargetGuideline.evaluate(tester);
        if (!result.passed) {
          failures.add('$view: ${result.reason}');
        }
      }

      await check('task list');
      await tester.tap(find.text('Lists'));
      await tester.pumpAndSettle();
      await check('sidebar');
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      await openDetails(tester);
      await check('task details');
      expect(failures, isEmpty);
    } finally {
      handle.dispose();
    }
  });

  testWidgets(
    'task completion and navigation expose checked and selected semantics',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await pumpApp(tester);
        final completion = tester.getSemantics(
          find.bySemanticsLabel(RegExp('Complete Focus task')).first,
        );
        expect(completion.flagsCollection.isChecked, CheckedState.isFalse);
        final navigation = tester.getSemantics(
          find.bySemanticsLabel(RegExp('My Day, 1 tasks')).first,
        );
        expect(navigation.flagsCollection.isSelected, Tristate.isTrue);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      } finally {
        handle.dispose();
      }
    },
  );
}

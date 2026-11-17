import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:flutter_todo_flutter/ui/todo_app.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final client = Client('http://127.0.0.1:8870/');
  late TodoList trialList;
  late TodoList destination;

  setUpAll(() async {
    trialList = await client.todo.saveList(
      TodoList(title: 'Native trial ${DateTime.now().microsecondsSinceEpoch}'),
    );
    destination = await client.todo.saveList(
      TodoList(title: 'Native move ${DateTime.now().microsecondsSinceEpoch}'),
    );
  });
  tearDownAll(() async {
    try {
      await client.todo.deleteList(trialList.id!);
      await client.todo.deleteList(destination.id!);
    } finally {
      client.close();
    }
  });

  testWidgets(
    'native UI persists task, notes, steps, importance and completion',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: TodoApp(platformServices: false)),
      );
      await waitFor(tester, find.byKey(const Key('add-task')));
      if (tester.view.physicalSize.width / tester.view.devicePixelRatio < 720) {
        await tester.tap(find.text('Lists'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(trialList.title));
      await tester.pumpAndSettle();
      const title = 'Verify native PostgreSQL persistence';
      await tester.enterText(find.byKey(const Key('add-task')), title);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      final savedTitle = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == title,
      );
      await waitFor(tester, savedTitle);
      await tester.tap(savedTitle);
      await waitFor(tester, find.byKey(const Key('task-notes')));
      await tester.enterText(
        find.byKey(const Key('task-notes')),
        'Saved through the actual native UI and local Serverpod.',
      );
      await tester.enterText(
        find.byKey(const Key('add-step')),
        'Read back through an independent generated client',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await waitFor(
        tester,
        find.text('Read back through an independent generated client'),
      );
      await tester.tap(find.byTooltip('Mark as important').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Mark completed'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close details'));
      await tester.pumpAndSettle();
      final snapshot = await client.todo.fetch();
      final task = snapshot.tasks.singleWhere(
        (task) => task.listId == trialList.id,
      );
      expect(task.title, title);
      expect(
        task.notes,
        'Saved through the actual native UI and local Serverpod.',
      );
      expect(
        task.steps.single.title,
        'Read back through an independent generated client',
      );
      expect(task.important, isTrue);
      expect(task.completed, isTrue);
      expect(task.completedAt, isNotNull);
    },
  );
  testWidgets(
    'native task drag persists identity and content in destination list',
    (tester) async {
      final original = await client.todo.saveTask(
        TodoTask(
          title: 'Move this native task',
          listId: trialList.id!,
          notes: 'Preserve native drag content',
          important: true,
          steps: [TodoStep(id: 'keep', title: 'Keep this step')],
          attachments: [],
        ),
      );
      await tester.pumpWidget(
        const ProviderScope(child: TodoApp(platformServices: false)),
      );
      await waitFor(tester, find.byKey(const Key('add-task')));
      final size = tester.view.physicalSize / tester.view.devicePixelRatio;
      final phone = size.shortestSide < 600 || size.width < 720;
      if (phone) {
        await tester.tap(find.text('Lists'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(trialList.title));
      await waitFor(tester, find.byKey(ValueKey('move-task-${original.id}')));
      final source = find.byKey(ValueKey('move-task-${original.id}'));
      final touch =
          Theme.of(tester.element(source)).platform != TargetPlatform.macOS;
      final gesture = await tester.startGesture(
        tester.getCenter(source),
        kind: touch ? PointerDeviceKind.touch : PointerDeviceKind.mouse,
      );
      if (touch) {
        await tester.pump(
          kLongPressTimeout + const Duration(milliseconds: 100),
        );
      } else {
        await gesture.moveBy(const Offset(8, 0));
        await tester.pump();
      }
      final target = find.byKey(ValueKey('drop-list-${destination.id}'));
      await waitFor(tester, target);
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(target));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await waitFor(tester, find.byKey(const Key('task-title')));
      await tester.pumpAndSettle();
      final saved = (await client.todo.fetch()).tasks.singleWhere(
        (task) => task.id == original.id,
      );
      expect(saved.listId, destination.id);
      expect(saved.notes, original.notes);
      expect(saved.steps.single.title, original.steps.single.title);
      expect(saved.important, isTrue);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('task-title')))
            .controller!
            .text,
        original.title,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Native view did not reach expected state: $finder');
}

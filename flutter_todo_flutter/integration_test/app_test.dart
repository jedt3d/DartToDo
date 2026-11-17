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

  setUpAll(() async {
    trialList = await client.todo.saveList(
      TodoList(title: 'Native trial ${DateTime.now().microsecondsSinceEpoch}'),
    );
  });
  tearDownAll(() async {
    try {
      await client.todo.deleteList(trialList.id!);
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
}

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Native view did not reach expected state: $finder');
}

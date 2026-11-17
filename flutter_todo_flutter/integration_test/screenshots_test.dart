import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:flutter_todo_flutter/data/task_queries.dart';
import 'package:flutter_todo_flutter/ui/todo_app.dart';
import 'package:integration_test/integration_test.dart';

import 'app_test.dart' show waitFor;

/// Captures the running native app, with synthetic tasks in a disposable list.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final client = Client('http://127.0.0.1:8870/');
  late TodoList list;

  setUpAll(() async {
    list = await client.todo.saveList(TodoList(title: 'A focused day'));
    final today = localDateKey(DateTime.now());
    await client.todo.saveTask(
      TodoTask(
        title: 'Make room for what matters',
        listId: list.id!,
        attachments: [],
        myDay: today,
        important: true,
        dueDate: today,
        notes:
            'Leave space for the things that matter.\n\nChoose a few priorities and enjoy the progress.',
        steps: [
          TodoStep(
            id: 'priorities',
            title: 'Choose three priorities',
            completed: true,
          ),
          TodoStep(id: 'focus', title: 'Make time for focused work'),
        ],
      ),
    );
    await client.todo.saveTask(
      TodoTask(
        steps: [],
        attachments: [],
        title: 'Take a walk outside',
        listId: list.id!,
        myDay: today,
      ),
    );
    await client.todo.saveTask(
      TodoTask(
        steps: [],
        attachments: [],
        title: 'Read a chapter',
        listId: list.id!,
        myDay: today,
      ),
    );
    await client.todo.saveTask(
      TodoTask(
        steps: [],
        attachments: [],
        title: 'Prepare for tomorrow',
        listId: list.id!,
      ),
    );
  });

  tearDownAll(() async {
    try {
      await client.todo.deleteList(list.id!);
    } finally {
      client.close();
    }
  });

  testWidgets('capture native My Day and usable navigation panels', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TodoApp()));
    await waitFor(tester, find.byKey(const Key('add-task')));
    // Allow the real photo request/decode to finish, without waiting on the
    // app's periodic refresh timer via pumpAndSettle.
    for (var i = 0; i < 120; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      if (find.text('on Unsplash').evaluate().isNotEmpty) break;
    }
    expect(find.text('on Unsplash'), findsOneWidget);
    final photoBox = find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).image?.image is MemoryImage,
    );
    expect(photoBox, findsOneWidget);
    final image =
        (tester.widget<DecoratedBox>(photoBox).decoration as BoxDecoration)
            .image!
            .image;
    await tester.runAsync(() => precacheImage(image, tester.element(photoBox)));
    await tester.pumpAndSettle();
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final device = width < 720 ? 'iphone' : 'ipad';
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await binding.takeScreenshot('$device-$name');
    }

    await capture('my-day');
    await tester.tap(find.byTooltip('Suggestions'));
    await tester.pumpAndSettle();
    expect(find.text('Prepare for tomorrow'), findsOneWidget);
    await capture('suggestions');
    await tester.tap(find.byTooltip('Add Prepare for tomorrow to My Day'));
    await tester.pumpAndSettle();
    expect(find.text('Prepare for tomorrow'), findsNothing);
    final updated = await client.todo.fetch();
    expect(
      updated.tasks
          .singleWhere(
            (task) =>
                task.listId == list.id && task.title == 'Prepare for tomorrow',
          )
          .myDay,
      localDateKey(DateTime.now()),
    );
    await tester.tap(find.byTooltip('Close suggestions'));
    await tester.pumpAndSettle();
    final title = find.byWidgetPredicate(
      (widget) => widget is Text && widget.data == 'Make room for what matters',
    );
    await tester.tap(title.last);
    await waitFor(tester, find.byKey(const Key('task-notes')));
    await capture('details');
    await tester.tap(find.byKey(const Key('task-notes')));
    await tester.pumpAndSettle();
    await capture('details-keyboard');
    await tester.tap(find.byTooltip('Close details'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('add-task')), findsOneWidget);
    if (device == 'iphone') {
      await tester.tap(find.text('Lists'));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const Key('search-tasks')), findsOneWidget);
    await capture('lists');
    expect(tester.takeException(), isNull);
  });
}

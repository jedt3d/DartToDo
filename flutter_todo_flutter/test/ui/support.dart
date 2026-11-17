import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:flutter_todo_flutter/data/task_queries.dart';
import 'package:flutter_todo_flutter/data/todo_controller.dart';
import 'package:flutter_todo_flutter/ui/todo_app.dart';

import '../data/fixtures.dart';

TodoSnapshot uiData({List<TodoTask>? tasks}) {
  final data = snapshot(
    tasks:
        tasks ??
        [task(id: 1, title: 'Focus task', myDay: localDateKey(DateTime.now()))],
  );
  return data.copyWith(
    settings: data.settings.copyWith(smartThemes: {'my-day': 'blue'}),
  );
}

Future<FakeTodoRepository> pumpApp(
  WidgetTester tester, {
  Size size = const Size(1100, 720),
  TodoSnapshot? data,
  FakeTodoRepository? repository,
  bool settle = true,
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  final store = repository ?? FakeTodoRepository(data ?? uiData());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [repositoryProvider.overrideWithValue(store)],
      child: const TodoApp(platformServices: false),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
  return store;
}

Future<void> addTask(WidgetTester tester, String title) async {
  await tester.enterText(find.byKey(const Key('add-task')), title);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

Future<void> openDetails(
  WidgetTester tester, {
  String title = 'Focus task',
}) async {
  await tester.tap(find.text(title).first);
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('task-title')), findsOneWidget);
}

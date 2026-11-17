import 'dart:async';

import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:flutter_todo_flutter/data/todo_repository.dart';

TodoTask task({
  required int id,
  String? title,
  int listId = 1,
  bool completed = false,
  bool important = false,
  String? myDay,
  String? dueDate,
  String notes = '',
  int position = 0,
  bool deleted = false,
  DateTime? createdAt,
  List<TodoStep> steps = const [],
}) => TodoTask(
  id: id,
  title: title ?? 'Task $id',
  listId: listId,
  completed: completed,
  important: important,
  myDay: myDay,
  dueDate: dueDate,
  notes: notes,
  position: position,
  deleted: deleted,
  createdAt: createdAt ?? DateTime.utc(2026, 11, 17),
  steps: steps,
  attachments: [],
);

TodoSnapshot snapshot({List<TodoTask> tasks = const []}) => TodoSnapshot(
  tasks: tasks,
  lists: [
    TodoList(id: 1, title: 'Tasks'),
    TodoList(id: 2, title: 'Work'),
    TodoList(id: 3, title: 'Deleted list', deleted: true),
  ],
  groups: [],
  settings: TodoSettings.fromJson({'smartThemes': <String, String>{}}),
);

/// An isolated store for controller tests, without a real service or database.
final class FakeTodoRepository implements TodoRepository {
  FakeTodoRepository(this.data);

  TodoSnapshot data;
  Object? fetchError;
  Object? saveError;
  Completer<void>? saveGate;
  Completer<void>? fetchGate;
  int fetchCalls = 0;
  int saveCalls = 0;
  int closeCalls = 0;
  int activeWrites = 0;
  int maximumActiveWrites = 0;
  final List<int> savedPositions = [];
  final List<String> completionDates = [];

  TodoSnapshot _copy() => TodoSnapshot.fromJson(data.toJson());

  @override
  Future<TodoSnapshot> fetch() async {
    fetchCalls++;
    if (fetchGate case final gate?) await gate.future;
    if (fetchError case final error?) throw error;
    return _copy();
  }

  @override
  Future<TodoTask> saveTask(TodoTask value) async {
    saveCalls++;
    activeWrites++;
    if (activeWrites > maximumActiveWrites) {
      maximumActiveWrites = activeWrites;
    }
    try {
      if (saveGate case final gate?) await gate.future;
      if (saveError case final error?) throw error;
      final nextId = data.tasks.fold<int>(
        0,
        (maximum, task) => task.id! > maximum ? task.id! : maximum,
      );
      final saved = value.copyWith(id: value.id ?? nextId + 1);
      savedPositions.add(saved.position);
      data = data.copyWith(
        tasks: [
          for (final task in data.tasks)
            if (task.id != saved.id) task,
          saved,
        ],
      );
      return saved.copyWith();
    } finally {
      activeWrites--;
    }
  }

  @override
  Future<TodoSnapshot> completeTask(
    int id,
    bool completed,
    String localDate,
  ) async {
    completionDates.add(localDate);
    data = data.copyWith(
      tasks: [
        for (final task in data.tasks)
          task.id == id ? task.copyWith(completed: completed) : task,
      ],
    );
    return _copy();
  }

  @override
  Future<TodoSnapshot> deleteTask(int id) async {
    data = data.copyWith(
      tasks: [
        for (final task in data.tasks)
          task.id == id ? task.copyWith(deleted: true) : task,
      ],
    );
    return _copy();
  }

  @override
  Future<TodoSnapshot> restoreTask(int id) async {
    data = data.copyWith(
      tasks: [
        for (final task in data.tasks)
          task.id == id ? task.copyWith(deleted: false) : task,
      ],
    );
    return _copy();
  }

  @override
  Future<TodoList> saveList(TodoList value) async {
    final saved = value.copyWith(id: value.id ?? data.lists.length + 1);
    data = data.copyWith(
      lists: [
        for (final list in data.lists)
          if (list.id != saved.id) list,
        saved,
      ],
    );
    return saved;
  }

  @override
  Future<TodoSnapshot> deleteList(int id) async {
    data = data.copyWith(
      lists: [
        for (final list in data.lists)
          list.id == id ? list.copyWith(deleted: true) : list,
      ],
    );
    return _copy();
  }

  @override
  Future<TodoSnapshot> restoreList(int id) async {
    data = data.copyWith(
      lists: [
        for (final list in data.lists)
          list.id == id ? list.copyWith(deleted: false) : list,
      ],
    );
    return _copy();
  }

  @override
  Future<TodoGroup> saveGroup(TodoGroup value) async {
    final saved = value.copyWith(id: value.id ?? data.groups.length + 1);
    data = data.copyWith(
      groups: [
        for (final group in data.groups)
          if (group.id != saved.id) group,
        saved,
      ],
    );
    return saved;
  }

  @override
  Future<TodoSnapshot> deleteGroup(int id) async {
    data = data.copyWith(
      groups: [
        for (final group in data.groups)
          if (group.id != id) group,
      ],
      lists: [
        for (final list in data.lists)
          list.groupId == id ? list.copyWith(groupId: null) : list,
      ],
    );
    return _copy();
  }

  @override
  Future<TodoSettings> saveSettings(TodoSettings settings) async {
    data = data.copyWith(settings: settings.copyWith());
    return settings;
  }

  @override
  void close() => closeCalls++;
}

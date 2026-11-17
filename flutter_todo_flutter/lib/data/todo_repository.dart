import 'package:flutter_todo_client/flutter_todo_client.dart';

/// The application's typed local persistence boundary.
abstract interface class TodoRepository {
  Future<TodoSnapshot> fetch();
  Future<TodoTask> saveTask(TodoTask task);
  Future<TodoSnapshot> completeTask(int id, bool completed, String localDate);
  Future<TodoSnapshot> deleteTask(int id);
  Future<TodoSnapshot> restoreTask(int id);
  Future<TodoList> saveList(TodoList list);
  Future<TodoSnapshot> deleteList(int id);
  Future<TodoSnapshot> restoreList(int id);
  Future<TodoGroup> saveGroup(TodoGroup group);
  Future<TodoSnapshot> deleteGroup(int id);
  Future<TodoSettings> saveSettings(TodoSettings settings);
  void close();
}

/// Uses the generated Serverpod API, reachable only on this computer.
final class ServerpodTodoRepository implements TodoRepository {
  ServerpodTodoRepository({Client? client})
    : _client = client ?? Client('http://127.0.0.1:8870/');

  final Client _client;

  @override
  Future<TodoSnapshot> fetch() => _client.todo.fetch();

  @override
  Future<TodoTask> saveTask(TodoTask task) => _client.todo.saveTask(task);

  @override
  Future<TodoSnapshot> completeTask(int id, bool completed, String localDate) =>
      _client.todo.completeTask(id, completed, localDate);

  @override
  Future<TodoSnapshot> deleteTask(int id) => _client.todo.deleteTask(id);

  @override
  Future<TodoSnapshot> restoreTask(int id) => _client.todo.restoreTask(id);

  @override
  Future<TodoList> saveList(TodoList list) => _client.todo.saveList(list);

  @override
  Future<TodoSnapshot> deleteList(int id) => _client.todo.deleteList(id);

  @override
  Future<TodoSnapshot> restoreList(int id) => _client.todo.restoreList(id);

  @override
  Future<TodoGroup> saveGroup(TodoGroup group) => _client.todo.saveGroup(group);

  @override
  Future<TodoSnapshot> deleteGroup(int id) => _client.todo.deleteGroup(id);

  @override
  Future<TodoSettings> saveSettings(TodoSettings settings) =>
      _client.todo.saveSettings(settings);

  @override
  void close() => _client.close();
}

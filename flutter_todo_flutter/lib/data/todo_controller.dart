import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';

import 'task_queries.dart';
import 'todo_repository.dart';

final repositoryProvider = Provider<TodoRepository>((ref) {
  final repository = ServerpodTodoRepository();
  ref.onDispose(repository.close);
  return repository;
});

final todoControllerProvider =
    AsyncNotifierProvider<TodoController, TodoSnapshot>(
      TodoController.new,
      retry: (_, _) => null,
    );

final mutationStatusProvider =
    NotifierProvider<MutationStatusNotifier, MutationStatus>(
      MutationStatusNotifier.new,
    );

/// In-flight activity and the latest recoverable write or refresh failure.
final class MutationStatus {
  const MutationStatus({this.pending = 0, this.error});

  final int pending;
  final Object? error;
}

final class MutationStatusNotifier extends Notifier<MutationStatus> {
  @override
  MutationStatus build() => const MutationStatus();

  void begin() => state = MutationStatus(pending: state.pending + 1);

  void finish({Object? error}) => state = MutationStatus(
    pending: state.pending > 0 ? state.pending - 1 : 0,
    error: error,
  );

  void clearError() => state = MutationStatus(pending: state.pending);
}

/// Serializes writes and retains the visible snapshot during recoverable work.
final class TodoController extends AsyncNotifier<TodoSnapshot> {
  Future<void> _tail = Future<void>.value();

  @override
  Future<TodoSnapshot> build() => ref.watch(repositoryProvider).fetch();

  Future<T> _enqueue<T>(
    Future<T> Function(TodoRepository repository) action, {
    bool fetchAfter = true,
  }) {
    final result = Completer<T>();
    if (!ref.mounted) {
      return Future.error(StateError('This task view has been closed.'));
    }
    ref.read(mutationStatusProvider.notifier).begin();
    _tail = _tail.then((_) async {
      if (!ref.mounted) {
        result.completeError(StateError('This task view has been closed.'));
        return;
      }
      Object? error;
      try {
        if (!state.hasValue) {
          await future;
        }
        if (!ref.mounted) {
          throw StateError('This task view has been closed.');
        }
        final repository = ref.read(repositoryProvider);
        final value = await action(repository);
        final snapshot = fetchAfter && ref.mounted
            ? await repository.fetch()
            : null;
        if (ref.mounted && snapshot != null) {
          state = AsyncData(snapshot);
        }
        result.complete(value);
      } catch (failure, stack) {
        error = failure;
        result.completeError(failure, stack);
      } finally {
        if (ref.mounted) {
          ref.read(mutationStatusProvider.notifier).finish(error: error);
        }
      }
    });
    return result.future;
  }

  /// Retries initial loading, or refreshes existing content without hiding it.
  Future<void> load() => refresh();

  Future<void> refresh() {
    if (!state.hasValue) {
      return _retryInitialLoad();
    }
    return _enqueue((repository) async {
      final snapshot = await repository.fetch();
      if (ref.mounted) {
        state = AsyncData(snapshot);
      }
    }, fetchAfter: false);
  }

  Future<void> _retryInitialLoad() async {
    if (!ref.mounted) {
      return;
    }
    state = const AsyncLoading();
    try {
      final snapshot = await ref.read(repositoryProvider).fetch();
      if (ref.mounted) {
        state = AsyncData(snapshot);
      }
    } catch (error, stack) {
      if (ref.mounted) {
        state = AsyncError(error, stack);
      }
      rethrow;
    }
  }

  Future<TodoTask> createTask(
    String title, {
    int listId = 1,
    bool myDay = false,
    bool important = false,
  }) => _enqueue((repository) {
    final now = DateTime.now();
    final tasks = state.requireValue.tasks.where(
      (task) => task.listId == listId && !task.deleted,
    );
    final position = tasks.fold<int>(
      -1,
      (maximum, task) => task.position > maximum ? task.position : maximum,
    );
    return repository.saveTask(
      TodoTask(
        title: title,
        listId: listId,
        myDay: myDay ? localDateKey(now) : null,
        important: important,
        position: position + 1,
        createdAt: now.toUtc(),
        steps: [],
        attachments: [],
      ),
    );
  });

  Future<TodoTask> saveTask(TodoTask task) =>
      _enqueue((repository) => repository.saveTask(task));

  /// Applies a field edit to the latest queued task, preventing stale UI writes.
  Future<TodoTask> updateTask(
    int id,
    TodoTask Function(TodoTask task) update,
  ) => _enqueue((repository) {
    final task = state.requireValue.tasks.firstWhere((task) => task.id == id);
    return repository.saveTask(update(task.copyWith()));
  });

  /// Moves against the latest queued snapshot so rapid drops append in order.
  Future<TodoTask> moveTask(int id, int listId) => _enqueue((repository) {
    final data = state.requireValue;
    if (!data.lists.any((list) => list.id == listId && !list.deleted)) {
      throw StateError('The destination list is no longer available.');
    }
    final task = data.tasks.firstWhere(
      (task) => task.id == id && !task.deleted,
    );
    if (task.listId == listId) return Future.value(task);
    final position =
        data.tasks
            .where((task) => task.listId == listId && !task.deleted)
            .fold<int>(
              -1,
              (maximum, task) =>
                  task.position > maximum ? task.position : maximum,
            ) +
        1;
    return repository.saveTask(
      task.copyWith(listId: listId, position: position),
    );
  });

  Future<void> completeTask(TodoTask task) => _enqueue((repository) async {
    final current = state.requireValue.tasks.firstWhere(
      (candidate) => candidate.id == task.id,
    );
    final snapshot = await repository.completeTask(
      current.id!,
      !current.completed,
      localDateKey(DateTime.now()),
    );
    if (ref.mounted) {
      state = AsyncData(snapshot);
    }
  }, fetchAfter: false);

  Future<void> deleteTask(int id) => _snapshotAction(
    (repository) => repository.deleteTask(id),
  );

  Future<void> restoreTask(int id) => _snapshotAction(
    (repository) => repository.restoreTask(id),
  );

  Future<TodoList> saveList(TodoList list) =>
      _enqueue((repository) => repository.saveList(list));

  Future<void> deleteList(int id) => _snapshotAction(
    (repository) => repository.deleteList(id),
  );

  Future<void> restoreList(int id) => _snapshotAction(
    (repository) => repository.restoreList(id),
  );

  Future<TodoGroup> saveGroup(TodoGroup group) =>
      _enqueue((repository) => repository.saveGroup(group));

  Future<void> deleteGroup(int id) => _snapshotAction(
    (repository) => repository.deleteGroup(id),
  );

  Future<TodoSettings> saveSettings(TodoSettings settings) =>
      _enqueue((repository) => repository.saveSettings(settings));

  Future<void> _snapshotAction(
    Future<TodoSnapshot> Function(TodoRepository repository) action,
  ) => _enqueue((repository) async {
    final snapshot = await action(repository);
    if (ref.mounted) {
      state = AsyncData(snapshot);
    }
  }, fetchAfter: false);
}

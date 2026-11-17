import 'package:flutter_todo_client/flutter_todo_client.dart';

enum TaskSort { manual, importance, alphabetical, dueDate, created, myDay }

/// A local calendar date, independent of UTC offsets and time of day.
String localDateKey(DateTime date) {
  final local = date.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

/// Searches globally when [query] is nonempty; otherwise selects [viewId].
///
/// Completed tasks are retained so the caller can render a completed section.
List<TodoTask> filteredTasks(
  TodoSnapshot snapshot,
  String viewId, {
  String query = '',
  TaskSort sort = TaskSort.manual,
  DateTime? now,
}) {
  final today = localDateKey(now ?? DateTime.now());
  final terms = query.trim().toLowerCase().split(RegExp(r'\s+'));
  final searching = terms.first.isNotEmpty;
  final visibleLists = snapshot.lists
      .where((list) => !list.deleted)
      .map((list) => list.id)
      .toSet();
  final tasks = snapshot.tasks.where((task) {
    if (task.deleted || !visibleLists.contains(task.listId)) {
      return false;
    }
    if (searching) {
      final text = [
        task.title,
        task.notes,
        ...task.steps.map((step) => step.title),
      ].join(' ').toLowerCase();
      return terms.every(text.contains);
    }
    return switch (viewId) {
      'my-day' => task.myDay == today,
      'important' => task.important,
      'planned' => task.dueDate != null,
      'all' => true,
      'completed' => task.completed,
      'inbox' => task.listId == 1,
      _ =>
        viewId.startsWith('list:') &&
            task.listId == int.tryParse(viewId.substring(5)),
    };
  }).toList();

  int comparePosition(TodoTask a, TodoTask b) {
    final position = a.position.compareTo(b.position);
    return position != 0 ? position : (a.id ?? 0).compareTo(b.id ?? 0);
  }

  tasks.sort((a, b) {
    final comparison = switch (sort) {
      TaskSort.manual => 0,
      TaskSort.importance => (b.important ? 1 : 0).compareTo(
        a.important ? 1 : 0,
      ),
      TaskSort.alphabetical => a.title.toLowerCase().compareTo(
        b.title.toLowerCase(),
      ),
      TaskSort.dueDate => (a.dueDate ?? '9999-12-31').compareTo(
        b.dueDate ?? '9999-12-31',
      ),
      TaskSort.created => b.createdAt.compareTo(a.createdAt),
      TaskSort.myDay => (b.myDay ?? '').compareTo(a.myDay ?? ''),
    };
    return comparison != 0 ? comparison : comparePosition(a, b);
  });
  return tasks;
}

/// Unfinished tasks outside today's focus list, with due tasks first.
List<TodoTask> suggestedTasks(TodoSnapshot snapshot, {DateTime? now}) {
  final today = localDateKey(now ?? DateTime.now());
  final tasks = filteredTasks(
    snapshot,
    'all',
    now: now,
  ).where((task) => !task.completed && task.myDay != today).toList();
  int priority(TodoTask task) {
    if (task.dueDate != null && task.dueDate!.compareTo(today) <= 0) {
      return 0;
    }
    if (task.myDay != null && task.myDay!.compareTo(today) < 0) {
      return 1;
    }
    return task.important ? 2 : 3;
  }

  tasks.sort((a, b) {
    final rank = priority(a).compareTo(priority(b));
    if (rank != 0) {
      return rank;
    }
    final position = a.position.compareTo(b.position);
    return position != 0 ? position : (a.id ?? 0).compareTo(b.id ?? 0);
  });
  return tasks;
}

/// Counts open tasks, or completed tasks in the completed sidebar view.
int taskCount(TodoSnapshot snapshot, String viewId, {DateTime? now}) =>
    filteredTasks(
      snapshot,
      viewId,
      now: now,
    ).where((task) => viewId == 'completed' || !task.completed).length;

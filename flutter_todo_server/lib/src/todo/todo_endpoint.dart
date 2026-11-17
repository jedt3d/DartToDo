import 'dart:convert';
import 'dart:math' as math;

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Persistent task operations for the one local OS user.
///
/// A database advisory transaction lock makes compound operations, including
/// recurrence and list deletion, atomic across desktop and simulator clients.
class TodoEndpoint extends Endpoint {
  Future<TodoSnapshot> fetch(Session session) =>
      _change(session, (transaction) => _snapshot(session, transaction));

  Future<TodoTask> saveTask(Session session, TodoTask task) =>
      _change(session, (transaction) async {
        _validateTask(task);
        await _activeList(session, task.listId, transaction);
        if (task.id == null) {
          return TodoTask.db.insertRow(
            session,
            task.copyWith(
              title: task.title.trim(),
              completed: false,
              completedAt: null,
              deleted: false,
              createdAt: DateTime.now().toUtc(),
              nextOccurrenceId: null,
            ),
            transaction: transaction,
          );
        }
        final old = await _task(session, task.id!, transaction);
        if (old.deleted) _fail('Restore this task before editing it.');
        return TodoTask.db.updateRow(
          session,
          task.copyWith(
            title: task.title.trim(),
            completed: old.completed,
            completedAt: old.completedAt,
            createdAt: old.createdAt,
            deleted: false,
            nextOccurrenceId: old.nextOccurrenceId,
          ),
          transaction: transaction,
        );
      });

  Future<TodoSnapshot> completeTask(
    Session session,
    int id,
    bool completed,
    String localDate,
  ) => _change(session, (transaction) async {
    final date = _date(localDate);
    final task = await _task(session, id, transaction);
    if (task.deleted) _fail('This task has been deleted.');
    await _activeList(session, task.listId, transaction);
    if (task.completed != completed) {
      task.completed = completed;
      task.completedAt = completed ? DateTime.now().toUtc() : null;
      await TodoTask.db.updateRow(session, task, transaction: transaction);
      if (completed && task.repeat != 'none') {
        final due = task.dueDate == null ? date : _date(task.dueDate!);
        final anchor = due.isAfter(date) ? due : date;
        final next = nextOccurrence(anchor, task.repeat, task.repeatEvery);
        if (next.year > 9999) {
          _fail('The next occurrence is outside supported calendar dates.');
        }
        final existing = task.nextOccurrenceId == null
            ? null
            : await TodoTask.db.findById(
                session,
                task.nextOccurrenceId!,
                transaction: transaction,
              );
        if (existing != null) {
          await TodoTask.db.updateRow(
            session,
            existing.copyWith(deleted: false),
            transaction: transaction,
          );
        } else {
          final occurrence = await TodoTask.db.insertRow(
            session,
            task.copyWith(
              id: null,
              nextOccurrenceId: null,
              completed: false,
              completedAt: null,
              myDay: null,
              dueDate: _dateString(next),
              reminder: task.reminder?.add(next.difference(due)),
              createdAt: DateTime.now().toUtc(),
              steps: task.steps
                  .map((step) => step.copyWith(completed: false))
                  .toList(),
            ),
            transaction: transaction,
          );
          task.nextOccurrenceId = occurrence.id;
          await TodoTask.db.updateRow(session, task, transaction: transaction);
        }
      } else if (!completed && task.nextOccurrenceId != null) {
        final next = await TodoTask.db.findById(
          session,
          task.nextOccurrenceId!,
          transaction: transaction,
        );
        if (next != null && !next.completed) {
          await TodoTask.db.updateRow(
            session,
            next.copyWith(deleted: true),
            transaction: transaction,
          );
        }
      }
    }
    return _snapshot(session, transaction);
  });

  Future<TodoSnapshot> deleteTask(Session session, int id) =>
      _change(session, (transaction) async {
        final task = await _task(session, id, transaction);
        await TodoTask.db.updateRow(
          session,
          task.copyWith(deleted: true),
          transaction: transaction,
        );
        return _snapshot(session, transaction);
      });

  Future<TodoSnapshot> restoreTask(Session session, int id) =>
      _change(session, (transaction) async {
        final task = await _task(session, id, transaction);
        await _activeList(session, task.listId, transaction);
        await TodoTask.db.updateRow(
          session,
          task.copyWith(deleted: false),
          transaction: transaction,
        );
        return _snapshot(session, transaction);
      });

  Future<TodoList> saveList(Session session, TodoList list) =>
      _change(session, (transaction) async {
        _title(list.title, 256);
        _position(list.position);
        if (!_themes.contains(list.theme)) {
          _fail('Choose a supported list theme.');
        }
        if (list.groupId != null) {
          await _activeGroup(session, list.groupId!, transaction);
        }
        if (list.id == null) {
          return TodoList.db.insertRow(
            session,
            list.copyWith(title: list.title.trim(), deleted: false),
            transaction: transaction,
          );
        }
        await _activeList(session, list.id!, transaction);
        if (list.id == 1 && (list.title != 'Tasks' || list.groupId != null)) {
          _fail('The default Tasks list cannot be renamed or grouped.');
        }
        return TodoList.db.updateRow(
          session,
          list.copyWith(title: list.title.trim(), deleted: false),
          transaction: transaction,
        );
      });

  Future<TodoSnapshot> deleteList(Session session, int id) =>
      _change(session, (transaction) async {
        if (id == 1) _fail('The default Tasks list cannot be deleted.');
        final list = await _activeList(session, id, transaction);
        await TodoList.db.updateRow(
          session,
          list.copyWith(deleted: true),
          transaction: transaction,
        );
        return _snapshot(session, transaction);
      });

  Future<TodoSnapshot> restoreList(Session session, int id) =>
      _change(session, (transaction) async {
        _id(id);
        final list = await TodoList.db.findById(
          session,
          id,
          transaction: transaction,
        );
        if (list == null) _fail('List not found.');
        if (list.groupId != null) {
          final group = await TodoGroup.db.findById(
            session,
            list.groupId!,
            transaction: transaction,
          );
          if (group == null || group.deleted) list.groupId = null;
        }
        await TodoList.db.updateRow(
          session,
          list.copyWith(deleted: false),
          transaction: transaction,
        );
        return _snapshot(session, transaction);
      });

  Future<TodoGroup> saveGroup(Session session, TodoGroup group) =>
      _change(session, (transaction) async {
        _title(group.title, 256);
        _position(group.position);
        if (group.id == null) {
          return TodoGroup.db.insertRow(
            session,
            group.copyWith(title: group.title.trim(), deleted: false),
            transaction: transaction,
          );
        }
        await _activeGroup(session, group.id!, transaction);
        return TodoGroup.db.updateRow(
          session,
          group.copyWith(title: group.title.trim(), deleted: false),
          transaction: transaction,
        );
      });

  Future<TodoSnapshot> deleteGroup(Session session, int id) =>
      _change(session, (transaction) async {
        final group = await _activeGroup(session, id, transaction);
        final lists = await TodoList.db.find(
          session,
          where: (list) => list.groupId.equals(id),
          transaction: transaction,
        );
        for (final list in lists) {
          await TodoList.db.updateRow(
            session,
            list.copyWith(groupId: null),
            transaction: transaction,
          );
        }
        await TodoGroup.db.updateRow(
          session,
          group.copyWith(deleted: true),
          transaction: transaction,
        );
        return _snapshot(session, transaction);
      });

  Future<TodoSettings> saveSettings(Session session, TodoSettings settings) =>
      _change(session, (transaction) async {
        _title(settings.displayName, 256);
        if (!{
          'manual',
          'importance',
          'alphabetical',
          'dueDate',
          'created',
          'myDay',
        }.contains(settings.sortOrder)) {
          _fail('Choose a supported sort order.');
        }
        if (settings.smartThemes.length > 12 ||
            settings.smartThemes.entries.any(
              (entry) =>
                  !{
                    'my-day',
                    'important',
                    'planned',
                    'tasks',
                    'all',
                    'completed',
                  }.contains(entry.key) ||
                  !_themes.contains(entry.value),
            )) {
          _fail('Choose supported smart-list themes.');
        }
        return TodoSettings.db.updateRow(
          session,
          settings.copyWith(id: 1, displayName: settings.displayName.trim()),
          transaction: transaction,
        );
      });

  Future<T> _change<T>(
    Session session,
    Future<T> Function(Transaction) action,
  ) => session.db.transaction((transaction) async {
    // A fixed local namespace; user input never enters this SQL.
    await session.db.unsafeQuery(
      'SELECT pg_advisory_xact_lock(77224411)',
      transaction: transaction,
    );
    if (await TodoList.db.findById(session, 1, transaction: transaction) ==
        null) {
      await TodoList.db.insertRow(
        session,
        TodoList(id: 1, title: 'Tasks'),
        transaction: transaction,
      );
      await session.db.unsafeQuery(
        "SELECT setval(pg_get_serial_sequence('todo_list', 'id'), GREATEST((SELECT MAX(id) FROM todo_list), 1))",
        transaction: transaction,
      );
    }
    if (await TodoSettings.db.findById(session, 1, transaction: transaction) ==
        null) {
      await TodoSettings.db.insertRow(
        session,
        TodoSettings(
          id: 1,
          smartThemes: {
            'my-day': 'tv_tower',
            'important': 'rose',
            'planned': 'teal',
          },
        ),
        transaction: transaction,
      );
    }
    return action(transaction);
  });

  Future<TodoSnapshot> _snapshot(
    Session session,
    Transaction transaction,
  ) async {
    final lists = await TodoList.db.find(
      session,
      where: (list) => list.deleted.equals(false),
      orderBy: (list) => list.position,
      transaction: transaction,
    );
    final ids = lists.map((list) => list.id!).toSet();
    final tasks = await TodoTask.db.find(
      session,
      where: (task) => task.deleted.equals(false),
      orderBy: (task) => task.position,
      transaction: transaction,
    );
    return TodoSnapshot(
      tasks: tasks.where((task) => ids.contains(task.listId)).toList(),
      lists: lists,
      groups: await TodoGroup.db.find(
        session,
        where: (group) => group.deleted.equals(false),
        orderBy: (group) => group.position,
        transaction: transaction,
      ),
      settings: (await TodoSettings.db.findById(
        session,
        1,
        transaction: transaction,
      ))!,
    );
  }

  Future<TodoTask> _task(
    Session session,
    int id,
    Transaction transaction,
  ) async {
    _id(id);
    final task = await TodoTask.db.findById(
      session,
      id,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (task == null) _fail('Task not found.');
    return task;
  }

  Future<TodoList> _activeList(
    Session session,
    int id,
    Transaction transaction,
  ) async {
    _id(id);
    final list = await TodoList.db.findById(
      session,
      id,
      transaction: transaction,
    );
    if (list == null || list.deleted) _fail('List not found.');
    return list;
  }

  Future<TodoGroup> _activeGroup(
    Session session,
    int id,
    Transaction transaction,
  ) async {
    _id(id);
    final group = await TodoGroup.db.findById(
      session,
      id,
      transaction: transaction,
    );
    if (group == null || group.deleted) _fail('Group not found.');
    return group;
  }

  void _validateTask(TodoTask task) {
    if (task.id != null) _id(task.id!);
    _title(task.title, 1000);
    _position(task.position);
    if (task.notes.length > 100000) {
      _fail('Notes must be at most 100,000 characters.');
    }
    if (task.myDay != null) _date(task.myDay!);
    if (task.dueDate != null) _date(task.dueDate!);
    if (!_repeatKinds.contains(task.repeat) ||
        task.repeatEvery < 1 ||
        task.repeatEvery > 999) {
      _fail('Choose a supported recurrence and an interval from 1 to 999.');
    }
    if (task.steps.length > 1000 || task.attachments.length > 100) {
      _fail('Too many steps or files.');
    }
    final stepIds = <String>{};
    for (final step in task.steps) {
      _title(step.title, 1000);
      _itemId(step.id);
      if (!stepIds.add(step.id)) _fail('Step identifiers must be unique.');
    }
    var bytes = 0;
    final attachmentIds = <String>{};
    for (final attachment in task.attachments) {
      _itemId(attachment.id);
      if (!attachmentIds.add(attachment.id)) {
        _fail('File identifiers must be unique.');
      }
      if (attachment.name.trim().isEmpty ||
          attachment.name.length > 255 ||
          attachment.name.contains(RegExp(r'[/\\\x00-\x1f\x7f-\x9f]')) ||
          attachment.name == '.' ||
          attachment.name == '..') {
        _fail('Choose a file with a valid filename.');
      }
      if (attachment.mimeType.length > 255 ||
          attachment.mimeType.contains(RegExp(r'[\x00-\x1f\x7f-\x9f]'))) {
        _fail('Invalid file type.');
      }
      try {
        bytes += base64Decode(attachment.dataBase64).length;
      } on FormatException {
        _fail('Invalid file contents.');
      }
      if (bytes > 10 * 1024 * 1024) {
        _fail('Files attached to a task must total 10 MB or less.');
      }
    }
  }

  void _itemId(String value) {
    if (value.isEmpty ||
        value.length > 128 ||
        value.contains(RegExp(r'[\x00-\x1f]'))) {
      _fail('Invalid item identifier.');
    }
  }

  void _title(String value, int max) {
    if (value.trim().isEmpty ||
        value.length > max ||
        value.contains('\u0000')) {
      _fail('Enter a title from 1 to $max characters.');
    }
  }

  void _position(int value) {
    if (value.abs() > 1000000000) _fail('Invalid item position.');
  }

  void _id(int value) {
    if (value <= 0) _fail('Invalid identifier.');
  }

  Never _fail(String message) => throw TodoException(message: message);

  static const _themes = {
    'blue',
    'purple',
    'pink',
    'red',
    'orange',
    'green',
    'teal',
    'dark',
    'mountain',
    'beach',
    'seattle',
    'colors',
    'sky',
    'stars',
    'cabin',
    'rose',
    'grey',
    'tv_tower',
    'desert',
    'fern',
    'field',
    'gradient',
    'lighthouse',
    'safari',
    'sea',
  };
  static const _repeatKinds = {
    'none',
    'daily',
    'weekdays',
    'weekly',
    'monthly',
    'yearly',
    'custom',
  };
}

DateTime _date(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw TodoException(message: 'Use a date in YYYY-MM-DD format.');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null ||
      _dateString(parsed) != value ||
      parsed.year < 1 ||
      parsed.year > 9999) {
    throw TodoException(message: 'Choose a valid calendar date.');
  }
  return parsed;
}

String _dateString(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

/// Returns the next recurrence using calendar arithmetic, clamping month ends.
DateTime nextOccurrence(DateTime date, String repeat, int interval) {
  switch (repeat) {
    case 'daily':
    case 'custom':
      return DateTime(date.year, date.month, date.day + interval);
    case 'weekdays':
      var next = DateTime(date.year, date.month, date.day + 1);
      while (next.weekday == DateTime.saturday ||
          next.weekday == DateTime.sunday) {
        next = DateTime(next.year, next.month, next.day + 1);
      }
      return next;
    case 'weekly':
      return DateTime(date.year, date.month, date.day + interval * 7);
    case 'monthly':
      final first = DateTime(date.year, date.month + interval);
      return DateTime(
        first.year,
        first.month,
        math.min(date.day, DateTime(first.year, first.month + 1, 0).day),
      );
    case 'yearly':
      final year = date.year + interval;
      return DateTime(
        year,
        date.month,
        math.min(date.day, DateTime(year, date.month + 1, 0).day),
      );
    default:
      throw TodoException(message: 'Choose a supported recurrence.');
  }
}

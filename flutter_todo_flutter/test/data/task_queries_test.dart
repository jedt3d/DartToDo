import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:flutter_todo_flutter/data/task_queries.dart';

import 'fixtures.dart';

void main() {
  final today = DateTime(2026, 11, 17, 23, 59);

  test('local date keys zero-pad calendar fields', () {
    expect(localDateKey(DateTime(2026, 1, 2, 23, 59)), '2026-01-02');
  });

  test('My Day membership changes at midnight without deleting tasks', () {
    final data = snapshot(
      tasks: [
        task(id: 1, myDay: '2026-11-17'),
        task(id: 2, myDay: '2026-11-18'),
        task(id: 3, myDay: '2026-11-17', completed: true),
      ],
    );
    expect(
      filteredTasks(data, 'my-day', now: today).map((task) => task.id),
      [1, 3],
    );
    expect(
      filteredTasks(
        data,
        'my-day',
        now: today.add(const Duration(minutes: 1)),
      ).map((task) => task.id),
      [2],
    );
    expect(data.tasks.length, 3);
  });

  test('search matches title notes and steps globally, ignoring case', () {
    final data = snapshot(
      tasks: [
        task(id: 1, title: 'Plan RELEASE', listId: 2),
        task(id: 2, notes: 'Release checklist'),
        task(
          id: 3,
          steps: [TodoStep(id: 's', title: 'Release the build')],
        ),
        task(id: 4, title: 'Release', deleted: true),
        task(id: 5, title: 'Release', listId: 3),
        task(id: 6, title: 'Unrelated'),
      ],
    );
    expect(
      filteredTasks(
        data,
        'my-day',
        query: '  release  ',
        now: today,
      ).map((task) => task.id),
      [1, 2, 3],
    );
    expect(
      filteredTasks(
        data,
        'inbox',
        query: 'RELEASE build',
      ).map((task) => task.id),
      [3],
    );
  });

  test('whitespace-only search preserves the selected view', () {
    final data = snapshot(tasks: [task(id: 1), task(id: 2, listId: 2)]);
    expect(
      filteredTasks(data, 'inbox', query: ' \n\t ').map((task) => task.id),
      [1],
    );
  });

  test('all smart and custom views use real fields and exclude deletions', () {
    final data = snapshot(
      tasks: [
        task(id: 1, important: true, dueDate: '2026-11-18'),
        task(id: 2, listId: 2, completed: true),
        task(id: 3, listId: 3, important: true),
        task(id: 4, deleted: true),
      ],
    );
    final expectations = <String, List<int>>{
      'all': [1, 2],
      'important': [1],
      'planned': [1],
      'completed': [2],
      'inbox': [1],
      'list:2': [2],
      'list:3': [],
      'list:invalid': [],
      'unknown': [],
    };
    for (final entry in expectations.entries) {
      expect(
        filteredTasks(data, entry.key).map((task) => task.id),
        entry.value,
        reason: entry.key,
      );
    }
  });

  test(
    'sort modes have deterministic ties and dates with missing values last',
    () {
      final data = snapshot(
        tasks: [
          task(
            id: 1,
            title: 'Zulu',
            position: 2,
            important: true,
            createdAt: DateTime.utc(2026, 1, 1),
            myDay: '2026-11-16',
          ),
          task(
            id: 2,
            title: 'alpha',
            position: 1,
            dueDate: '2026-11-20',
            createdAt: DateTime.utc(2026, 1, 3),
            myDay: '2026-11-17',
          ),
          task(
            id: 3,
            title: 'Alpha',
            position: 1,
            dueDate: '2026-11-18',
            createdAt: DateTime.utc(2026, 1, 2),
          ),
        ],
      );
      final expectations = <TaskSort, List<int>>{
        TaskSort.manual: [2, 3, 1],
        TaskSort.importance: [1, 2, 3],
        TaskSort.alphabetical: [2, 3, 1],
        TaskSort.dueDate: [3, 2, 1],
        TaskSort.created: [2, 3, 1],
        TaskSort.myDay: [2, 1, 3],
      };
      for (final entry in expectations.entries) {
        expect(
          filteredTasks(data, 'all', sort: entry.key).map((task) => task.id),
          entry.value,
          reason: entry.key.name,
        );
      }
      expect(data.tasks.map((task) => task.id), [1, 2, 3]);
    },
  );

  test(
    'suggestions prioritize due tasks and unfinished previous My Day tasks',
    () {
      final data = snapshot(
        tasks: [
          task(id: 1),
          task(id: 2, important: true),
          task(id: 3, myDay: '2026-11-16'),
          task(id: 4, dueDate: '2026-11-17'),
          task(id: 5, myDay: '2026-11-17'),
          task(id: 6, completed: true),
          task(id: 7, deleted: true),
          task(id: 8, listId: 3),
        ],
      );
      expect(
        suggestedTasks(data, now: today).map((task) => task.id),
        [4, 3, 2, 1],
      );
    },
  );

  test(
    'sidebar counts open tasks and completed view counts completed tasks',
    () {
      final data = snapshot(
        tasks: [
          task(id: 1),
          task(id: 2, completed: true),
          task(id: 3, deleted: true),
          task(id: 4, completed: true, listId: 2),
          task(id: 5, completed: true, deleted: true),
          task(id: 6, completed: true, listId: 3),
        ],
      );
      expect(taskCount(data, 'all'), 1);
      expect(filteredTasks(data, 'completed').length, 2);
      expect(taskCount(data, 'completed'), 2);
      expect(taskCount(data, 'inbox'), 1);
    },
  );
}

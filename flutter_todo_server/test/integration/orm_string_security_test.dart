import 'dart:io';

import 'package:flutter_todo_server/server.dart';
import 'package:flutter_todo_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  IOOverrides.global = LoopbackIoOverrides();
  withServerpod('ORM text remains data', (sessionBuilder, endpoints) {
    test(
      'decode markers roundtrip literally through inserts updates and filters',
      () async {
        // Harmless base64 constants expose type confusion without destructive SQL.
        const markers = [
          "decode('c2FmZQ==', 'base64')",
          "decode('TydCcmllbg==', 'base64')",
        ];
        final ordinary = await endpoints.todo.saveTask(
          sessionBuilder,
          TodoTask(
            title: "O'Brien's ordinary task",
            listId: 1,
            steps: [],
            attachments: [],
          ),
        );
        expect(ordinary.title, "O'Brien's ordinary task");
        for (final marker in markers) {
          final task = await endpoints.todo.saveTask(
            sessionBuilder,
            TodoTask(
              title: marker,
              notes: marker,
              listId: 1,
              steps: [],
              attachments: [],
            ),
          );
          expect(task.title, marker);
          expect(task.notes, marker);
          final updated = await endpoints.todo.saveTask(
            sessionBuilder,
            task.copyWith(title: '$marker updated', notes: marker),
          );
          expect(updated.title, '$marker updated');
          expect(updated.notes, marker);
          final session = sessionBuilder.build();
          try {
            final exact = await TodoTask.db.find(
              session,
              where: (row) => row.notes.equals(marker),
            );
            expect(exact.map((row) => row.id), [task.id]);
          } finally {
            await session.close();
          }
          final list = await endpoints.todo.saveList(
            sessionBuilder,
            TodoList(title: marker),
          );
          final group = await endpoints.todo.saveGroup(
            sessionBuilder,
            TodoGroup(title: marker),
          );
          final snapshot = await endpoints.todo.fetch(sessionBuilder);
          final settings = await endpoints.todo.saveSettings(
            sessionBuilder,
            snapshot.settings.copyWith(displayName: marker),
          );
          expect(list.title, marker);
          expect(group.title, marker);
          expect(settings.displayName, marker);
        }
        final state = await endpoints.todo.fetch(sessionBuilder);
        expect(state.tasks.length, 3);
        expect(
          state.tasks.singleWhere((task) => task.id == ordinary.id).title,
          ordinary.title,
        );
      },
    );
  });
}

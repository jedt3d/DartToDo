import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_todo_client/flutter_todo_client.dart' as client;
import 'package:flutter_todo_server/server.dart';
import 'package:flutter_todo_server/src/generated/endpoints.dart';
import 'package:flutter_todo_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

// Run separately with `dart test tool/attachment_http_test.dart`: HTTP sessions
// commit independently of the rollback transactions used by the main suite.
void main() {
  test(
    'generated client roundtrips a 25 MiB attachment over real loopback HTTP',
    () async {
      IOOverrides.global = LoopbackIoOverrides();
      final pod = Serverpod(
        ['--mode', 'test', '--apply-migrations'],
        Protocol(),
        Endpoints(),
        configOverride: (configuration) {
          if (configuration.database?.name != 'flutter_todo_test' ||
              configuration.apiServer.port != 0) {
            throw StateError(
              'HTTP attachment test requires its isolated configuration.',
            );
          }
          return configuration;
        },
        httpResponseHeaders: Headers.empty(),
        httpOptionsResponseHeaders: Headers.empty(),
      );
      pod.server.addMiddleware(localRequestsOnly);
      client.Client? api;
      Session? cleanupSession;
      int? taskId;
      int? listId;
      try {
        expect(pod.config.maxRequestSize, 40 * 1024 * 1024);
        await pod.start();
        api = client.Client('http://127.0.0.1:${pod.server.port}/');
        cleanupSession = await pod.createSession(enableLogging: false);
        final list = await api.todo.saveList(
          client.TodoList(title: 'HTTP attachment boundary test'),
        );
        listId = list.id!;
        final bytes = Uint8List(25 * 1024 * 1024);
        for (var index = 0; index < bytes.length; index++) {
          bytes[index] = index % 251;
        }
        final encoded = base64Encode(bytes);
        // This payload exceeds the former 16,000,000-byte request bound.
        expect(encoded.length, greaterThan(16000000));
        final saved = await api.todo.saveTask(
          client.TodoTask(
            title: 'Exact 25 MiB HTTP payload',
            listId: listId,
            steps: [],
            attachments: [
              client.TodoAttachment(
                id: 'http-file',
                name: 'boundary.bin',
                mimeType: 'application/octet-stream',
                dataBase64: encoded,
              ),
            ],
          ),
        );
        taskId = saved.id!;
        expect(saved.attachments.single.dataBase64 == encoded, isTrue);
        final snapshot = await api.todo.fetch();
        final loaded = snapshot.tasks.singleWhere((task) => task.id == taskId);
        expect(loaded.attachments.single.dataBase64 == encoded, isTrue);
        final decoded = base64Decode(loaded.attachments.single.dataBase64);
        expect(decoded.length, 26214400);
        expect(
          decoded.indexed.every((item) => item.$2 == item.$1 % 251),
          isTrue,
        );
      } finally {
        api?.close();
        try {
          final session = cleanupSession;
          if (session != null) {
            // HTTP sessions commit independently. Remove only this test's rows.
            if (listId != null) {
              await TodoTask.db.deleteWhere(
                session,
                where: (task) => task.listId.equals(listId),
              );
            }
            if (listId != null) {
              await TodoList.db.deleteWhere(
                session,
                where: (list) => list.id.equals(listId),
              );
            }
          }
        } finally {
          await cleanupSession?.close();
          await pod.shutdown(exitProcess: false);
        }
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

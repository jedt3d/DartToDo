import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:flutter_todo_flutter/ui/todo_app.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // CUA may enable native accessibility while the print dialog is open. Set
  // that mode before testWidgets records its semantics-handle baseline.
  setUpAll(() {
    binding.platformDispatcher.semanticsEnabledTestValue = true;
  });
  tearDownAll(binding.platformDispatcher.clearSemanticsEnabledTestValue);

  testWidgets(
    'the real list menu invokes and returns from the native print interface',
    (tester) async {
      expect(Platform.isMacOS || Platform.isIOS, isTrue);
      expect(binding.platformDispatcher.semanticsEnabled, isTrue);
      const definedLongTrial = bool.fromEnvironment('PRINT_TRIAL_LONG');
      final longTrial =
          definedLongTrial ||
          Platform.environment['PRINT_TRIAL_LONG'] == 'true';
      final count = longTrial ? 120 : 3;
      final client = Client('http://127.0.0.1:8870/');
      const channel = MethodChannel('darttodo/native');
      final messenger = binding.defaultBinaryMessenger;
      final evidence = <String, Object?>{
        'platform': Platform.operatingSystem,
        'longTrial': longTrial,
        'taskCount': count,
        'stage': 'creating-own-fixture',
        'actionInvoked': false,
        'invocationCount': 0,
        'argumentsVerified': false,
        'forwardedToNative': false,
        'nativeReturned': false,
        'fixtureDeleted': false,
        'completed': false,
        'scope': 'native-interface-only; no paper-output assertion',
      };
      binding.reportData = {'printing': evidence};
      TodoList? fixture;
      Object? nativeError;
      var invocationCount = 0;
      var nativeReturned = false;

      void stage(String value) {
        evidence['stage'] = value;
        debugPrint('PRINT_STAGE $value');
      }

      try {
        fixture = await client.todo.saveList(
          TodoList(
            title:
                'DartToDo print trial ${DateTime.now().microsecondsSinceEpoch}',
            position: -999999999,
            theme: 'blue',
          ),
        );
        final list = fixture;
        final expectedLines = <String>[];
        for (var index = 0; index < count; index++) {
          final title = longTrial
              ? 'PRINT TRIAL ${(index + 1).toString().padLeft(3, '0')} of $count — '
                    'Synthetic pagination content: preserve every task through the final page.'
              : [
                  'PRINT TRIAL — Plan a focused day',
                  'PRINT TRIAL — Review the local task list',
                  'PRINT TRIAL — Finish the verification',
                ][index];
          final saved = await client.todo.saveTask(
            TodoTask(
              title: title,
              listId: list.id!,
              position: index,
              steps: [],
              attachments: [],
            ),
          );
          final completed = index == 1;
          if (completed) {
            await client.todo.completeTask(saved.id!, true, _localDate());
          }
          expectedLines.add('${completed ? '[x]' : '[ ]'} $title');
        }
        evidence['listId'] = list.id;
        evidence['expectedLineCount'] = expectedLines.length;
        final expectedBody = expectedLines.join('\n');

        // Observe the real UI call without replacing the native implementation:
        // the unchanged bytes go directly to the engine messenger delegate.
        messenger.setMockMessageHandler(channel.name, (message) async {
          if (message == null) {
            throw const FormatException('Missing native method message.');
          }
          final call = channel.codec.decodeMethodCall(message);
          if (call.method != 'printList') {
            return messenger.delegate.send(channel.name, message);
          }
          invocationCount++;
          evidence['invocationCount'] = invocationCount;
          evidence['actionInvoked'] = true;
          try {
            expect(
              invocationCount,
              1,
              reason: 'Invoke only one native print job.',
            );
            expect(call.arguments, {'title': list.title, 'body': expectedBody});
            evidence['argumentsVerified'] = true;
            evidence['forwardedToNative'] = true;
            stage('waiting-for-os-print-dialog');
            final response = messenger.delegate.send(channel.name, message);
            if (response == null) {
              throw MissingPluginException('Native print handler absent.');
            }
            final reply = await response.timeout(const Duration(seconds: 180));
            if (reply == null) {
              throw MissingPluginException('Native print handler absent.');
            }
            channel.codec.decodeEnvelope(reply);
            nativeReturned = true;
            evidence['nativeReturned'] = true;
            stage('native-call-returned');
            return reply;
          } catch (error) {
            nativeError = error;
            evidence['nativeErrorType'] = error.runtimeType.toString();
            rethrow;
          }
        });

        await tester.pumpWidget(
          const ProviderScope(child: TodoApp(platformServices: false)),
        );
        await _waitFor(tester, find.byKey(const Key('add-task')));
        final size = tester.view.physicalSize / tester.view.devicePixelRatio;
        if (size.width < 720 || size.shortestSide < 600) {
          await tester.tap(find.text('Lists'));
          await tester.pumpAndSettle();
        }
        final listTitle = find.text(list.title);
        await tester.scrollUntilVisible(
          listTitle,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(listTitle);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('list-options')), findsOneWidget);
        stage('opening-real-list-menu');
        await tester.tap(find.byKey(const Key('list-options')));
        await tester.pumpAndSettle();
        final printAction = find.text('Print List…');
        await tester.ensureVisible(printAction);
        expect(printAction.hitTestable(), findsOneWidget);
        await tester.tap(printAction);
        await tester.pump();

        final deadline = DateTime.now().add(const Duration(seconds: 185));
        while (!nativeReturned &&
            nativeError == null &&
            DateTime.now().isBefore(deadline)) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 250)),
          );
          await tester.pump();
        }
        expect(
          invocationCount,
          1,
          reason: 'The real menu must invoke printList.',
        );
        expect(
          nativeError,
          isNull,
          reason: 'The native print call must return without error.',
        );
        expect(
          nativeReturned,
          isTrue,
          reason:
              'Dismiss, save or submit the OS print interface within 180 seconds.',
        );
        expect(tester.takeException(), isNull);
      } finally {
        messenger.setMockMessageHandler(channel.name, null);
        try {
          final listId = fixture?.id;
          if (listId != null) {
            stage('soft-deleting-own-fixture');
            final remaining = await client.todo.deleteList(listId);
            expect(remaining.lists.any((list) => list.id == listId), isFalse);
            expect(
              remaining.tasks.any((task) => task.listId == listId),
              isFalse,
            );
            evidence['fixtureDeleted'] = true;
          }
        } finally {
          client.close();
        }
      }
      evidence['completed'] = true;
      stage('complete');
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}

String _localDate() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Native print trial did not reach expected state: $finder');
}

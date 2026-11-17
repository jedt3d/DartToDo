import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_flutter/services/reminders.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'OS delivers a scheduled reminder to Notification Center',
    (
      tester,
    ) async {
      expect(Platform.isMacOS || Platform.isIOS, isTrue);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Center(
                child: Text(
                  'DartToDo notification delivery trial\n'
                  'Allow notifications when the operating system asks.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
      final selected = <int>[];
      final reminders = ReminderService(onTaskSelected: selected.add);
      final plugin = FlutterLocalNotificationsPlugin();
      // A reserved synthetic ID keeps cleanup away from local database tasks.
      final id = 0x60000000 + DateTime.now().microsecondsSinceEpoch % 0xfffffff;
      final title = 'DartToDo OS delivery trial $id';
      binding.reportData = {
        'notificationDelivery': {
          'platform': Platform.operatingSystem,
          'id': id,
          'permissionGranted': null,
          'delivered': false,
          'completed': false,
          'stage': 'initializing',
        },
      };
      final evidence = binding.reportData!['notificationDelivery'] as Map;
      void stage(String value) {
        evidence['stage'] = value;
        debugPrint('NOTIFICATION_STAGE $value id=$id');
      }

      Future<void> diagnostics(String label) async {
        final pending = await plugin.pendingNotificationRequests().timeout(
          const Duration(seconds: 5),
        );
        final data = <String, Object?>{
          'pendingOwnRequest': pending.any((request) => request.id == id),
        };
        if (Platform.isIOS) {
          data['native'] = await const MethodChannel('darttodo/native')
              .invokeMapMethod<String, dynamic>(
                'notificationDiagnostics',
                {'id': id},
              )
              .timeout(const Duration(seconds: 5));
        }
        evidence[label] = data;
        debugPrint('NOTIFICATION_DIAGNOSTICS $label ${jsonEncode(data)}');
      }

      try {
        await reminders.initialize().timeout(const Duration(seconds: 10));
        stage('requesting-permission');
        final granted = await reminders.requestPermission().timeout(
          const Duration(seconds: 90),
        );
        evidence['permissionGranted'] = granted;
        expect(
          granted,
          isTrue,
          reason: 'OS notification permission must be granted for delivery.',
        );
        final when = tz.TZDateTime.now(tz.UTC).add(const Duration(seconds: 3));
        final payload = jsonEncode({
          'version': 1,
          'taskId': id,
          'scheduledAt': when.toUtc().toIso8601String(),
        });
        evidence['scheduledAt'] = when.toIso8601String();
        stage('scheduling');
        // Use the real plugin transport without sync(), which reconciles all
        // pending task reminders. This probe must leave other reminders intact.
        await plugin
            .zonedSchedule(
              id: id,
              title: title,
              body: 'Synthetic notification; no task data is sent or changed.',
              scheduledDate: when,
              notificationDetails: const NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBanner: true,
                  presentList: true,
                ),
                macOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBanner: true,
                  presentList: true,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              payload: payload,
            )
            .timeout(const Duration(seconds: 10));
        await diagnostics('afterScheduling');
        stage('waiting-for-delivery');
        ActiveNotification? delivered;
        final deadline = DateTime.now().add(const Duration(seconds: 25));
        while (DateTime.now().isBefore(deadline) && delivered == null) {
          // On both Darwin implementations this calls UNUserNotificationCenter's
          // getDeliveredNotifications, rather than its pending requests API.
          final active = await plugin.getActiveNotifications().timeout(
            const Duration(seconds: 5),
          );
          for (final notification in active) {
            if (notification.id == id) delivered = notification;
          }
          if (delivered == null) {
            await Future<void>.delayed(const Duration(milliseconds: 250));
          }
        }
        evidence['delivered'] = delivered != null;
        evidence['observedAt'] = DateTime.now().toUtc().toIso8601String();
        await diagnostics('afterDeliveryWait');
        expect(
          delivered,
          isNotNull,
          reason: 'A pending request alone is not evidence of OS delivery.',
        );
        expect(delivered!.title, title);
        expect(delivered.payload, payload);
        final pending = await plugin.pendingNotificationRequests().timeout(
          const Duration(seconds: 5),
        );
        expect(pending.where((request) => request.id == id), isEmpty);
        const verifyTap = bool.fromEnvironment('VERIFY_NOTIFICATION_TAP');
        evidence['tapRequired'] = verifyTap;
        evidence['tapVerification'] = verifyTap ? 'waiting' : 'not-requested';
        if (verifyTap) {
          stage('waiting-for-tap');
          final tapDeadline = DateTime.now().add(const Duration(seconds: 90));
          while (selected.isEmpty && DateTime.now().isBefore(tapDeadline)) {
            await Future<void>.delayed(const Duration(milliseconds: 250));
          }
          expect(selected, [id], reason: 'Tap the synthetic OS notification.');
          evidence['tapVerification'] = 'actual-platform-callback';
        }
      } finally {
        try {
          await plugin.cancel(id: id).timeout(const Duration(seconds: 5));
        } finally {
          reminders.dispose();
        }
      }
      evidence['completed'] = true;
      stage('complete');
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}

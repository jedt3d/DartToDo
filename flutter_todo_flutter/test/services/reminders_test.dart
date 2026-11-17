import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_flutter/services/reminders.dart';

import '../data/fixtures.dart';

const _channel = MethodChannel('dexterous.com/flutter/local_notifications');

String _payload(int id, DateTime date) => jsonEncode({
  'version': 1,
  'taskId': id,
  'scheduledAt': date.toUtc().toIso8601String(),
});

Map<String, Object?> _response(String? payload, {int? id = 7, int type = 0}) =>
    {
      'notificationId': id,
      'notificationResponseType': type,
      'payload': payload,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Unit-test isolates do not run the native generated plugin registrant.
  FlutterLocalNotificationsPlatform.instance =
      MacOSFlutterLocalNotificationsPlugin();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late FlutterLocalNotificationsPlatform originalPlatform;
  late List<MethodCall> calls;
  late List<Map<String, Object?>> pending;
  late Map<String, Object?> launch;
  late List<ReminderService> services;
  Completer<void>? initializationGate;
  var initializationFailures = 0;
  var scheduleFailures = 0;
  var permissionGranted = true;

  ReminderService service(List<int> selected) {
    final result = ReminderService(onTaskSelected: selected.add);
    services.add(result);
    return result;
  }

  Future<void> tap(Map<String, Object?> response) async {
    final result = await messenger.handlePlatformMessage(
      _channel.name,
      _channel.codec.encodeMethodCall(
        MethodCall('didReceiveNotificationResponse', response),
      ),
      null,
    );
    if (result != null) _channel.codec.decodeEnvelope(result);
  }

  setUp(() {
    originalPlatform = FlutterLocalNotificationsPlatform.instance;
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    FlutterLocalNotificationsPlatform.instance =
        MacOSFlutterLocalNotificationsPlugin();
    calls = [];
    pending = [];
    launch = {'notificationLaunchedApp': false};
    services = [];
    initializationGate = null;
    initializationFailures = 0;
    scheduleFailures = 0;
    permissionGranted = true;
    messenger.setMockMethodCallHandler(_channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'initialize':
          await initializationGate?.future;
          if (initializationFailures > 0) {
            initializationFailures--;
            throw PlatformException(code: 'fixture-initialization');
          }
          return true;
        case 'getNotificationAppLaunchDetails':
          return launch;
        case 'requestPermissions':
          return permissionGranted;
        case 'pendingNotificationRequests':
          return pending;
        case 'zonedSchedule':
          if (scheduleFailures > 0) {
            scheduleFailures--;
            throw PlatformException(code: 'fixture-schedule');
          }
          final arguments = Map<String, Object?>.from(call.arguments as Map);
          pending.removeWhere((item) => item['id'] == arguments['id']);
          pending.add({
            'id': arguments['id'],
            'title': arguments['title'],
            'body': arguments['body'],
            'payload': arguments['payload'],
          });
          return null;
        case 'cancel':
          pending.removeWhere((item) => item['id'] == call.arguments);
          return null;
        default:
          throw StateError('Unexpected notification method ${call.method}');
      }
    });
  });

  tearDown(() {
    for (final service in services) {
      service.dispose();
    }
    messenger.setMockMethodCallHandler(_channel, null);
    FlutterLocalNotificationsPlatform.instance = originalPlatform;
    debugDefaultTargetPlatformOverride = null;
  });

  for (final platform in [TargetPlatform.macOS, TargetPlatform.iOS]) {
    test(
      '$platform delivers a cold-launch selection once, including live replay',
      () async {
        debugDefaultTargetPlatformOverride = platform;
        FlutterLocalNotificationsPlatform.instance =
            platform == TargetPlatform.iOS
            ? IOSFlutterLocalNotificationsPlugin()
            : MacOSFlutterLocalNotificationsPlugin();
        final selected = <int>[];
        final payload = _payload(7, DateTime.utc(2030));
        launch = {
          'notificationLaunchedApp': true,
          'notificationResponse': _response(payload),
        };
        final reminders = service(selected);
        await Future.wait([reminders.initialize(), reminders.initialize()]);
        await tap(_response(payload));
        expect(selected, [7]);
        expect(
          calls.where((call) => call.method == 'initialize'),
          hasLength(1),
        );
        expect(
          calls.where(
            (call) => call.method == 'getNotificationAppLaunchDetails',
          ),
          hasLength(1),
        );
        final settings = calls.first.arguments as Map;
        expect(settings['requestAlertPermission'], isFalse);
        expect(settings['requestBadgePermission'], isFalse);
        expect(settings['requestSoundPermission'], isFalse);
      },
    );

    test(
      '$platform requests real alert badge and sound permission explicitly',
      () async {
        debugDefaultTargetPlatformOverride = platform;
        FlutterLocalNotificationsPlatform.instance =
            platform == TargetPlatform.iOS
            ? IOSFlutterLocalNotificationsPlugin()
            : MacOSFlutterLocalNotificationsPlugin();
        final reminders = service([]);
        expect(await reminders.requestPermission(), isTrue);
        final arguments =
            calls
                    .singleWhere((call) => call.method == 'requestPermissions')
                    .arguments
                as Map;
        expect(arguments['alert'], isTrue);
        expect(arguments['badge'], isTrue);
        expect(arguments['sound'], isTrue);
        permissionGranted = false;
        expect(await reminders.requestPermission(), isFalse);
      },
    );
  }

  test(
    'live callback before launch-query response is not delivered twice',
    () async {
      final selected = <int>[];
      initializationGate = Completer<void>();
      launch = {
        'notificationLaunchedApp': true,
        'notificationResponse': _response('7'),
      };
      final initialized = service(selected).initialize();
      await tap(_response('7'));
      initializationGate!.complete();
      await initialized;
      expect(selected, [7]);
    },
  );

  test(
    'ordinary startup ignores stale launch response and accepts a later tap',
    () async {
      final selected = <int>[];
      launch = {
        'notificationLaunchedApp': false,
        'notificationResponse': _response('7'),
      };
      await service(selected).initialize();
      expect(selected, isEmpty);
      await tap(_response('7'));
      await tap(_response('7'));
      expect(selected, [7]);
    },
  );

  test(
    'rescheduled occurrences of the same task remain independently actionable',
    () async {
      final selected = <int>[];
      await service(selected).initialize();
      final first = _payload(7, DateTime.utc(2030));
      final second = _payload(7, DateTime.utc(2030, 1, 2));
      await tap(_response(first));
      await tap(_response(first));
      await tap(_response(second));
      await tap(_response(first));
      expect(selected, [7, 7]);
    },
  );

  test('malformed mismatched and dismissed payloads do not navigate', () async {
    final selected = <int>[];
    await service(selected).initialize();
    for (final payload in <String?>[
      null,
      '',
      '0',
      '-1',
      '+7',
      ' 7 ',
      '2147483648',
      '999999999999999999999999999',
      'broken json',
      '[]',
      '{"taskId":7}',
      '{"version":2,"taskId":7,"scheduledAt":"2030-01-01T00:00:00.000Z"}',
      '{"version":1,"taskId":7.0,"scheduledAt":"2030-01-01T00:00:00.000Z"}',
      '{"version":1,"taskId":7,"scheduledAt":"2030-02-31T00:00:00.000Z"}',
      '{"version":1,"taskId":7,"scheduledAt":"not a date"}',
      '7' * 513,
    ]) {
      await tap(_response(payload));
    }
    await tap(_response('8'));
    await tap(_response('7', type: 2));
    expect(selected, isEmpty);
    await tap(_response('7'));
    expect(selected, [7]);
  });

  test(
    'a foreground notification action opens its valid owning task',
    () async {
      final selected = <int>[];
      await service(selected).initialize();
      await tap(_response('7', type: 1));
      expect(selected, [7]);
    },
  );

  test('dispose ignores late callbacks and cold-launch completion', () async {
    final selected = <int>[];
    initializationGate = Completer<void>();
    launch = {
      'notificationLaunchedApp': true,
      'notificationResponse': _response('7'),
    };
    final reminders = service(selected);
    final initialized = reminders.initialize();
    reminders.dispose();
    initializationGate!.complete();
    await initialized;
    await tap(_response('7'));
    expect(selected, isEmpty);
    await expectLater(reminders.initialize(), throwsStateError);
    expect(calls.where((call) => call.method == 'cancel'), isEmpty);
  });

  test(
    'disposing a retired owner does not remove the current owner callback',
    () async {
      final first = <int>[], second = <int>[];
      final retired = service(first);
      await retired.initialize();
      await service(second).initialize();
      retired.dispose();
      await tap(_response('7'));
      expect(first, isEmpty);
      expect(second, [7]);
    },
  );

  test(
    'native initialization failures can be retried by the same owner',
    () async {
      final selected = <int>[];
      initializationFailures = 1;
      final reminders = service(selected);
      await expectLater(
        reminders.initialize(),
        throwsA(isA<PlatformException>()),
      );
      await reminders.initialize();
      await tap(_response('7'));
      expect(selected, [7]);
      expect(calls.where((call) => call.method == 'initialize'), hasLength(2));
    },
  );

  test(
    'sync schedules future active tasks with distinct occurrence payloads',
    () async {
      final reminders = service([]);
      final when = DateTime.now().toUtc().add(const Duration(days: 1));
      final active = task(
        id: 7,
        title: 'A local reminder',
      ).copyWith(reminder: when);
      pending.add({'id': 99, 'title': 'Removed fixture', 'payload': '99'});
      final tasks = [
        active,
        task(id: 8, completed: true).copyWith(reminder: when),
        task(id: 9, deleted: true).copyWith(reminder: when),
        task(id: 10).copyWith(reminder: DateTime.utc(2000)),
        task(id: 11),
      ];
      await Future.wait([reminders.sync(tasks), reminders.sync(tasks)]);
      final schedule = calls.singleWhere(
        (call) => call.method == 'zonedSchedule',
      );
      final arguments = schedule.arguments as Map;
      expect(arguments['id'], 7);
      expect(arguments['title'], 'A local reminder');
      expect(arguments['timeZoneName'], 'Etc/UTC');
      expect(jsonDecode(arguments['payload'] as String), {
        'version': 1,
        'taskId': 7,
        'scheduledAt': when.toIso8601String(),
      });
      expect(
        calls.singleWhere((call) => call.method == 'cancel').arguments,
        99,
      );
      await reminders.sync([
        active.copyWith(reminder: when.add(const Duration(hours: 1))),
      ]);
      expect(
        calls.where((call) => call.method == 'zonedSchedule'),
        hasLength(2),
      );
    },
  );

  test(
    'a failed schedule remains retryable instead of being remembered as saved',
    () async {
      final reminders = service([]);
      final active = task(id: 7).copyWith(
        reminder: DateTime.now().toUtc().add(const Duration(days: 1)),
      );
      scheduleFailures = 1;
      await expectLater(
        reminders.sync([active]),
        throwsA(isA<PlatformException>()),
      );
      await reminders.sync([active]);
      expect(pending.single['id'], 7);
      expect(
        calls.where((call) => call.method == 'zonedSchedule'),
        hasLength(2),
      );
    },
  );
}

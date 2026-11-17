import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:timezone/data/latest.dart' as timezones;
import 'package:timezone/timezone.dart' as tz;

/// Owns native scheduled notifications for this app's local task reminders.
final class ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;
  Future<void> _tail = Future<void>.value();
  final _scheduled = <int, String>{};

  Future<void> initialize() => _initialization ??= _initialize();
  Future<void> _initialize() async {
    timezones.initializeTimeZones();
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(iOS: darwin, macOS: darwin),
    );
  }

  Future<bool> requestPermission() async {
    await initialize();
    final mac = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (mac != null) {
      return await mac.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  Future<void> sync(List<TodoTask> tasks) {
    final result = _tail.catchError((Object _) {}).then((_) => _sync(tasks));
    _tail = result;
    return result;
  }

  Future<void> _sync(List<TodoTask> tasks) async {
    await initialize();
    final desired = {
      for (final task in tasks)
        if (task.id != null &&
            !task.deleted &&
            !task.completed &&
            task.reminder != null &&
            task.reminder!.isAfter(DateTime.now()))
          task.id!: task,
    };
    for (final pending in await _plugin.pendingNotificationRequests()) {
      if (!desired.containsKey(pending.id)) {
        await _plugin.cancel(id: pending.id);
        _scheduled.remove(pending.id);
      }
    }
    for (final entry in desired.entries) {
      final task = entry.value;
      final signature = '${task.title}\n${task.reminder!.toIso8601String()}';
      if (_scheduled[entry.key] == signature) continue;
      await _plugin.zonedSchedule(
        id: entry.key,
        title: task.title,
        body: 'DartToDo reminder',
        scheduledDate: tz.TZDateTime.from(task.reminder!, tz.UTC),
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: entry.key.toString(),
      );
      _scheduled[entry.key] = signature;
    }
  }
}

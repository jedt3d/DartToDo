import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:timezone/data/latest.dart' as timezones;
import 'package:timezone/timezone.dart' as tz;

/// Owns native scheduled notifications for this app's local task reminders.
final class ReminderService {
  ReminderService({
    void Function(int taskId)? onTaskSelected,
    FlutterLocalNotificationsPlugin? plugin,
  }) : _onTaskSelected = onTaskSelected,
       _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  void Function(int taskId)? _onTaskSelected;
  static ReminderService? _callbackOwner;
  bool _disposed = false;
  Future<void>? _initialization;
  Future<void> _tail = Future<void>.value();
  final _scheduled = <int, String>{};
  final _delivered = <String>{};

  Future<void> initialize() {
    if (_disposed) return Future.error(StateError('ReminderService disposed'));
    return _initialization ??= _initialize().catchError((Object error) {
      _initialization = null;
      if (identical(_callbackOwner, this)) _callbackOwner = null;
      throw error;
    });
  }

  Future<void> _initialize() async {
    timezones.initializeTimeZones();
    _callbackOwner = this;
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(iOS: darwin, macOS: darwin),
      onDidReceiveNotificationResponse: _notificationResponse,
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final response = launch?.notificationResponse;
    if (identical(_callbackOwner, this) &&
        launch?.didNotificationLaunchApp == true &&
        response != null) {
      _handleResponse(response);
    }
  }

  static void _notificationResponse(NotificationResponse response) =>
      _callbackOwner?._handleResponse(response);

  void _handleResponse(NotificationResponse response) {
    if (_disposed ||
        _onTaskSelected == null ||
        response.notificationResponseType ==
            NotificationResponseType.notificationDismissed) {
      return;
    }
    final payload = response.payload;
    if (payload == null || payload.length > 512) return;
    int? taskId;
    String occurrence;
    if (RegExp(r'^[1-9]\d*$').hasMatch(payload)) {
      taskId = int.tryParse(payload);
      occurrence = 'legacy:$taskId';
    } else {
      try {
        final value = jsonDecode(payload);
        if (value is! Map<String, dynamic> ||
            value['version'] != 1 ||
            value['taskId'] is! int ||
            value['scheduledAt'] is! String) {
          return;
        }
        taskId = value['taskId'] as int;
        final dateText = value['scheduledAt'] as String;
        final date = DateTime.tryParse(dateText);
        if (date == null || !date.isUtc || date.toIso8601String() != dateText) {
          return;
        }
        occurrence = '$taskId@$dateText';
      } on FormatException {
        return;
      }
    }
    if (taskId == null ||
        taskId <= 0 ||
        taskId > 0x7fffffff ||
        (response.id != null && response.id != taskId) ||
        !_delivered.add(occurrence)) {
      return;
    }
    // Bound process-local replay history while retaining recent occurrences.
    if (_delivered.length > 256) _delivered.remove(_delivered.first);
    _onTaskSelected!(taskId);
  }

  /// Releases this UI owner's callback without deleting native reminders.
  void dispose() {
    _disposed = true;
    _onTaskSelected = null;
    if (identical(_callbackOwner, this)) _callbackOwner = null;
    _delivered.clear();
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
        payload: jsonEncode({
          'version': 1,
          'taskId': entry.key,
          'scheduledAt': task.reminder!.toUtc().toIso8601String(),
        }),
      );
      _scheduled[entry.key] = signature;
    }
  }
}

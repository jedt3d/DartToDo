import 'dart:io';

import 'package:flutter_todo_server/server.dart';
import 'package:flutter_todo_server/src/todo/todo_endpoint.dart';
import 'package:test/test.dart';

void main() {
  test('monthly recurrence handles nonleap February and year boundary', () {
    expect(
      nextOccurrence(DateTime(2025, 1, 31), 'monthly', 1),
      DateTime(2025, 2, 28),
    );
    expect(
      nextOccurrence(DateTime(2026, 12, 31), 'monthly', 1),
      DateTime(2027, 1, 31),
    );
  });
  test('yearly recurrence clamps leap day', () {
    expect(
      nextOccurrence(DateTime(2024, 2, 29), 'yearly', 1),
      DateTime(2025, 2, 28),
    );
  });
  test('weekdays skip Saturday and Sunday', () {
    expect(
      nextOccurrence(DateTime(2026, 11, 20), 'weekdays', 1),
      DateTime(2026, 11, 23),
    );
    expect(
      nextOccurrence(DateTime(2026, 11, 21), 'weekdays', 1),
      DateTime(2026, 11, 23),
    );
  });
  test('custom interval and weekly interval use calendar days', () {
    expect(
      nextOccurrence(DateTime(2026, 11, 17), 'custom', 3),
      DateTime(2026, 11, 20),
    );
    expect(
      nextOccurrence(DateTime(2026, 11, 17), 'weekly', 2),
      DateTime(2026, 12, 1),
    );
  });
  test(
    'socket binding is loopback even when caller requests all interfaces',
    () async {
      final overrides = LoopbackIoOverrides();
      final socket = await overrides.serverSocketBind(
        InternetAddress.anyIPv6,
        0,
        v6Only: true,
      );
      try {
        expect(socket.address.address, '127.0.0.1');
        expect(socket.address.isLoopback, true);
      } finally {
        await socket.close();
      }
    },
  );
}

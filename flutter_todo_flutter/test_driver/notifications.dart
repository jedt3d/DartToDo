import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  writeResponseOnFailure: true,
  responseDataCallback: (data) async {
    // The caller's private command log retains bounded synthetic OS evidence.
    // No application database content or unrelated notifications are exported.
    stdout.writeln('NOTIFICATION_OS_EVIDENCE ${jsonEncode(data)}');
    final evidence = data?['notificationDelivery'];
    if (evidence is! Map ||
        evidence['completed'] != true ||
        evidence['permissionGranted'] != true ||
        evidence['delivered'] != true ||
        (evidence['tapRequired'] == true &&
            evidence['tapVerification'] != 'actual-platform-callback')) {
      throw StateError('Native notification delivery evidence is incomplete.');
    }
  },
);

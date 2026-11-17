import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  timeout: const Duration(minutes: 5),
  writeResponseOnFailure: true,
  responseDataCallback: (data) async {
    // Only bounded synthetic fixture metadata is emitted. The test never treats
    // native completion as evidence that paper was physically printed.
    stdout.writeln('PRINT_NATIVE_EVIDENCE ${jsonEncode(data)}');
    final evidence = data?['printing'];
    if (evidence is! Map ||
        evidence['completed'] != true ||
        evidence['actionInvoked'] != true ||
        evidence['invocationCount'] != 1 ||
        evidence['argumentsVerified'] != true ||
        evidence['forwardedToNative'] != true ||
        evidence['nativeReturned'] != true ||
        evidence['fixtureDeleted'] != true ||
        evidence['nativeErrorType'] != null) {
      throw StateError(
        'Native print invocation/return evidence is incomplete.',
      );
    }
  },
);

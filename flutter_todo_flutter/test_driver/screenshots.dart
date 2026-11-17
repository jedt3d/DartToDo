import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final output = Directory('../docs/screenshots');
  await output.create(recursive: true);
  final received = <String>{};
  await integrationDriver(
    onScreenshot: (name, bytes, [arguments]) async {
      if (!RegExp(
        r'^(iphone|ipad|ipad-landscape|macos)-[a-z-]+$',
      ).hasMatch(name)) {
        throw StateError('Unexpected capture name');
      }
      await File('${output.path}/$name.png').writeAsBytes(bytes);
      received.add(name);
      return true;
    },
    // Do not duplicate all PNG bytes in an unbounded JSON report.
    responseDataCallback: (data) async {
      final capture = data?['capture'];
      if (capture is! Map || capture['completed'] != true) {
        throw StateError('Native capture flow did not complete');
      }
      final prefix = capture['prefix'];
      final expected = {
        '$prefix-my-day',
        '$prefix-details',
        '$prefix-details-keyboard',
        '$prefix-lists',
        '$prefix-suggestions',
        if (prefix == 'ipad-landscape') '$prefix-auto-details',
      };
      final declared = capture['captures'];
      if (declared is! List ||
          declared.length != expected.length ||
          !expected.every(
            (name) => received.contains(name) && declared.contains(name),
          )) {
        throw StateError('Native capture files/evidence are incomplete');
      }
      stdout.writeln('NATIVE_CAPTURE_EVIDENCE $capture');
    },
  );
}

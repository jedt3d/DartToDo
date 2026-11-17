import 'dart:io';

import 'package:flutter_todo_client/flutter_todo_client.dart';

/// Checks live typed background responses while preserving freshness status.
Future<void> main() async {
  final client = Client('http://127.0.0.1:8870/');
  try {
    final first = await client.background.featured();
    final second = await client.background.featured(previousId: first?.id);
    if (first == null || second == null || first.id == second.id) {
      throw StateError('Background service did not return distinct photos.');
    }
    if (Uri.parse(first.imageUrl).host != 'images.unsplash.com' ||
        Uri.parse(first.photographerUrl).host != 'unsplash.com') {
      throw StateError('Background attribution/host validation failed.');
    }
    stdout.writeln(
      'Typed background HTTP passed: '
      '${first.id} source=${first.source} cached=${first.fromCache}; '
      '${second.id} source=${second.source} cached=${second.fromCache}.',
    );
  } finally {
    client.close();
  }
}

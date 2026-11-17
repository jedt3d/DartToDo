import 'dart:io';

import 'package:flutter_todo_server/src/background/unsplash_service.dart';

/// Checks actual public homepage retrieval and records public provenance only.
Future<void> main() async {
  final service = UnsplashService(accessKey: '');
  try {
    final first = await service.featured();
    final second = await service.featured(previousId: first?.id);
    if (first == null || second == null) {
      throw StateError('No validated public Featured photo is available.');
    }
    if (first.id == second.id) {
      throw StateError('Consecutive opens repeated the same photo.');
    }
    stdout.writeln(
      'Selected distinct photos ${first.id} / ${second.id}; '
      'source=${first.source}, fromCache=${first.fromCache}; '
      'secondSource=${second.source}, secondFromCache=${second.fromCache}.',
    );
    if ((first.source != 'homepage' || first.fromCache) &&
        (second.source != 'homepage' || second.fromCache)) {
      throw StateError(
        'Fallback selection works, but live homepage retrieval is not verified.',
      );
    }
  } finally {
    service.close();
  }
}

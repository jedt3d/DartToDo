import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'unsplash_service.dart';

/// Optional public-photo metadata; it has no access to task contents.
class BackgroundEndpoint extends Endpoint {
  final _photos = UnsplashService();

  @override
  bool get logSessions => false;

  Future<BackgroundPhoto?> featured(Session session, {String? previousId}) =>
      _photos.featured(previousId: previousId);
}

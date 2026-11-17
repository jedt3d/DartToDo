import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../generated/protocol.dart';
import 'unsplash_transport.dart';

/// Selects public Featured seed or official Editorial API photos on app open.
///
/// The API key remains in the server process. Only sanitized public metadata is
/// cached; image content is hotlinked from images.unsplash.com by the client.
final class UnsplashService {
  UnsplashService({
    String? accessKey,
    UnsplashTransport? transport,
    Random? random,
    DateTime Function()? now,
    File? cacheFile,
    File? seedFile,
    this.requestTimeout = const Duration(seconds: 5),
    this.cacheLifetime = const Duration(minutes: 15),
  }) : _accessKey =
           (accessKey ?? Platform.environment['UNSPLASH_ACCESS_KEY'] ?? '')
               .trim(),
       _transport = transport ?? UnsplashHttpTransport(),
       _random = random ?? Random.secure(),
       _now = now ?? DateTime.now,
       _cacheFile =
           cacheFile ?? File('../.dartnflutter/unsplash/editorial-cache.json'),
       _seedFile = seedFile ?? File('config/unsplash_featured_seed.json');

  static const maxMetadataBytes = 2 * 1024 * 1024;
  static const maxHomepageBytes = 3 * 1024 * 1024;
  final String _accessKey;
  final UnsplashTransport _transport;
  final Random _random;
  final DateTime Function() _now;
  final File _cacheFile;
  final File _seedFile;
  final Duration requestTimeout;
  final Duration cacheLifetime;
  final _closedSignal = Completer<void>();
  Future<void> _tail = Future<void>.value();
  bool _loaded = false;
  bool _closed = false;
  List<_Photo> _photos = [];
  DateTime? _fetchedAt;
  DateTime? _retryAfter;
  String? _lastSelected;

  /// Returns null when no validated metadata is available.
  Future<BackgroundPhoto?> featured({String? previousId}) {
    final result = Completer<BackgroundPhoto?>();
    _tail = _tail.then((_) async {
      try {
        result.complete(_closed ? null : await _select(previousId));
      } catch (_) {
        // An optional background must not expose credentials or block task use.
        result.complete(null);
      }
    });
    return result.future;
  }

  Future<BackgroundPhoto?> _select(String? previousId) async {
    if (!_loaded) {
      _loaded = true;
      await _load();
    }
    if (_closed) return null;
    final now = _now().toUtc();
    var refreshed = false;
    final stale =
        _fetchedAt == null ||
        now.difference(_fetchedAt!) >= cacheLifetime ||
        _photos.any((photo) => photo.photo.source == 'featured-seed');
    if ((_accessKey.isEmpty || stale) &&
        (_retryAfter == null || !now.isBefore(_retryAfter!))) {
      refreshed = _accessKey.isEmpty
          ? await _refreshHomepage(now)
          : await _refresh(now);
    }
    if (_closed || _photos.isEmpty) return null;
    final avoid = _validId(previousId) ? previousId : _lastSelected;
    var candidates = _photos.where((photo) => photo.photo.id != avoid).toList();
    if (candidates.isEmpty) candidates = _photos;
    final withoutLast = candidates
        .where((photo) => photo.photo.id != _lastSelected)
        .toList();
    if (withoutLast.isNotEmpty) candidates = withoutLast;
    final selected = candidates[_random.nextInt(candidates.length)];
    _lastSelected = selected.photo.id;
    await _save();
    if (_closed) return null;
    if (_accessKey.isNotEmpty && selected.downloadLocation != null) {
      // Unsplash requires a download event when a photo becomes a background.
      // Metadata is returned even if tracking is temporarily unavailable.
      await _track(selected.downloadLocation!);
    }
    return _closed ? null : selected.photo.copyWith(fromCache: !refreshed);
  }

  Future<bool> _refreshHomepage(DateTime now) async {
    try {
      final response = await _get(
        Uri.https('unsplash.com', '/'),
        maxBytes: maxHomepageBytes,
      );
      if (response.statusCode != 200) {
        _retryAfter = now.add(const Duration(minutes: 1));
        return false;
      }
      final results = featuredHomepageResults(response.body);
      final ids = <String>{};
      final photos = <_Photo>[];
      for (final item in results.take(150)) {
        if (item['premium'] != false ||
            item['sponsorship'] != null ||
            item['promoted_at'] is! String ||
            DateTime.tryParse(item['promoted_at'] as String) == null) {
          continue;
        }
        final urls = item['urls'];
        final links = item['links'];
        final user = item['user'];
        if (urls is! Map ||
            links is! Map ||
            user is! Map ||
            user['links'] is! Map) {
          continue;
        }
        final photo = _parsePhoto({
          'id': item['id'],
          'imageUrl': urls['raw'],
          'photographer': user['name'],
          'photographerUrl': (user['links'] as Map)['html'],
          'photoUrl': links['html'],
          'downloadLocation': links['download_location'],
        }, 'homepage');
        if (photo != null && ids.add(photo.photo.id)) photos.add(photo);
      }
      if (photos.isEmpty) {
        throw const FormatException('No supported Featured photos.');
      }
      if (_closed) return false;
      _photos = photos;
      _fetchedAt = now;
      _retryAfter = null;
      return true;
    } catch (_) {
      _retryAfter = now.add(const Duration(minutes: 1));
      return false;
    }
  }

  Future<bool> _refresh(DateTime now) async {
    try {
      final uri = Uri.https('api.unsplash.com', '/photos', {
        'per_page': '30',
        'page': '${_random.nextInt(5) + 1}',
      });
      final reply = await _get(uri);
      if (reply.statusCode != 200) {
        final seconds = int.tryParse(reply.headers['retry-after'] ?? '');
        _retryAfter = now.add(
          Duration(seconds: seconds == null ? 900 : seconds.clamp(1, 3600)),
        );
        return false;
      }
      final decoded = jsonDecode(reply.body);
      if (decoded is! List) {
        throw const FormatException('Invalid editorial feed.');
      }
      final ids = <String>{};
      final photos = <_Photo>[];
      for (final item in decoded.take(30)) {
        if (item is! Map<String, dynamic> ||
            item['premium'] == true ||
            item['sponsorship'] != null) {
          continue;
        }
        final urls = item['urls'];
        final links = item['links'];
        final user = item['user'];
        if (urls is! Map ||
            links is! Map ||
            user is! Map ||
            user['links'] is! Map) {
          continue;
        }
        final photo = _parsePhoto({
          'id': item['id'],
          'imageUrl': urls['raw'],
          'photographer': user['name'],
          'photographerUrl': (user['links'] as Map)['html'],
          'photoUrl': links['html'],
          'downloadLocation': links['download_location'],
        }, 'editorial');
        if (photo != null &&
            photo.downloadLocation != null &&
            ids.add(photo.photo.id)) {
          photos.add(photo);
        }
      }
      if (photos.isEmpty) {
        throw const FormatException('No supported editorial photos.');
      }
      if (_closed) return false;
      _photos = photos;
      _fetchedAt = now;
      _retryAfter = null;
      return true;
    } catch (_) {
      _retryAfter = now.add(const Duration(minutes: 1));
      return false;
    }
  }

  Future<UnsplashReply> _get(Uri uri, {int maxBytes = maxMetadataBytes}) async {
    final result = await Future.any<UnsplashReply>([
      _transport.get(
        uri,
        headers: {
          if (uri.host == 'api.unsplash.com') ...{
            'Authorization': 'Client-ID $_accessKey',
            'Accept-Version': 'v1',
            'Accept': 'application/json',
          } else ...{
            'Accept': 'text/html',
            'User-Agent': 'DartToDo/1.0',
          },
        },
        timeout: requestTimeout,
        maxBytes: maxBytes,
      ),
      _closedSignal.future.then<UnsplashReply>(
        (_) => throw StateError('Photo service closed.'),
      ),
    ]).timeout(requestTimeout);
    if (utf8.encode(result.body).length > maxBytes) {
      throw const FormatException('Photo metadata exceeds the size limit.');
    }
    return result;
  }

  Future<void> _track(Uri uri) async {
    try {
      await _get(uri);
    } catch (_) {
      // Tracking outages never prevent local task work or expose API errors.
    }
  }

  Future<void> _load() async {
    final cache = await _readJson(_cacheFile);
    if (cache != null &&
        cache['schemaVersion'] == 1 &&
        cache['photos'] is List) {
      _lastSelected = cache['lastSelected'] is String
          ? cache['lastSelected'] as String
          : null;
      _fetchedAt = DateTime.tryParse('${cache['fetchedAt']}')?.toUtc();
      _photos = _parseStored(cache['photos'] as List, seed: false);
    }
    if (_photos.isNotEmpty) return;
    final seed = await _readJson(_seedFile);
    if (seed == null ||
        seed['schemaVersion'] != 1 ||
        seed['sourceUrl'] != 'https://unsplash.com/' ||
        seed['photos'] is! List) {
      return;
    }
    _fetchedAt = DateTime.tryParse('${seed['capturedAt']}')?.toUtc();
    _photos = _parseStored(seed['photos'] as List, seed: true);
  }

  List<_Photo> _parseStored(List values, {required bool seed}) {
    final ids = <String>{};
    return values
        .take(150)
        .map((item) {
          if (item is! Map<String, dynamic>) return null;
          if (seed &&
              (item['premium'] != false ||
                  item['promotedAt'] is! String ||
                  DateTime.tryParse(item['promotedAt'] as String) == null)) {
            return null;
          }
          final source = seed ? 'featured-seed' : item['source'];
          if (source != 'featured-seed' &&
              source != 'editorial' &&
              source != 'homepage') {
            return null;
          }
          final photo = _parsePhoto(item, source as String);
          return photo != null && ids.add(photo.photo.id) ? photo : null;
        })
        .whereType<_Photo>()
        .toList();
  }

  Future<Map<String, dynamic>?> _readJson(File file) async {
    try {
      if (!await file.exists() || await file.length() > maxMetadataBytes) {
        return null;
      }
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    try {
      if (_closed) return;
      await _cacheFile.parent.create(recursive: true);
      final temporary = File('${_cacheFile.path}.tmp');
      await temporary.writeAsString(
        jsonEncode({
          'schemaVersion': 1,
          'fetchedAt': _fetchedAt?.toIso8601String(),
          'lastSelected': _lastSelected,
          'photos': _photos
              .map(
                (photo) => {
                  ...photo.photo.toJson(),
                  'downloadLocation': photo.downloadLocation?.toString(),
                },
              )
              .toList(),
        }),
        flush: true,
      );
      await temporary.rename(_cacheFile.path);
    } catch (_) {
      // A read-only cache directory must not break local task functionality.
    }
  }

  /// Cancels pending network work and prevents further selection.
  void close() {
    if (_closed) return;
    _closed = true;
    _closedSignal.complete();
    _transport.close();
  }
}

final class _Photo {
  const _Photo(this.photo, this.downloadLocation);
  final BackgroundPhoto photo;
  final Uri? downloadLocation;
}

bool _validId(String? id) =>
    id != null && RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(id);

_Photo? _parsePhoto(Map<String, dynamic> item, String source) {
  final id = item['id'];
  final name = item['photographer'];
  if (id is! String ||
      !_validId(id) ||
      name is! String ||
      name.trim().isEmpty ||
      name.length > 200 ||
      name.contains(RegExp(r'[\x00-\x1f]'))) {
    return null;
  }
  Uri? url(String key, String host) {
    final value = item[key];
    if (value is! String || value.length > 4096) return null;
    final uri = Uri.tryParse(value);
    return uri != null && isUnsplashHttps(uri, host) ? uri : null;
  }

  final image = url('imageUrl', 'images.unsplash.com');
  final photographer = url('photographerUrl', 'unsplash.com');
  final photo = url('photoUrl', 'unsplash.com');
  if (image == null ||
      image.path.isEmpty ||
      photographer == null ||
      !photographer.path.startsWith('/@') ||
      photo == null ||
      !photo.path.startsWith('/photos/')) {
    return null;
  }
  final download = url('downloadLocation', 'api.unsplash.com');
  final validDownload =
      download != null && download.path == '/photos/$id/download'
      ? download
      : null;
  Uri attribution(Uri uri) => uri.replace(
    queryParameters: {
      ...uri.queryParametersAll,
      'utm_source': ['darttodo'],
      'utm_medium': ['referral'],
    },
  );
  return _Photo(
    BackgroundPhoto(
      id: id,
      imageUrl: image
          .replace(
            queryParameters: {
              ...image.queryParametersAll,
              'w': ['2400'],
              'auto': ['format'],
            },
          )
          .toString(),
      photographer: name.trim(),
      photographerUrl: attribution(photographer).toString(),
      photoUrl: attribution(photo).toString(),
      source: source,
    ),
    validDownload,
  );
}

/// Reads the homepage's serialized public Featured feed without running scripts.
///
/// The private webpage shape is guarded deliberately. A changed marker/query
/// shape produces no photos, allowing the caller to use last-good metadata.
List<Map<String, dynamic>> featuredHomepageResults(String html) {
  if (utf8.encode(html).length > UnsplashService.maxHomepageBytes) return [];
  final marker = RegExp(r'window\.__DEHYDRATED_DATA__\s*=\s*').firstMatch(html);
  if (marker == null || marker.end >= html.length || html[marker.end] != '"') {
    return [];
  }
  final start = marker.end;
  var escaped = false;
  for (var index = start + 1; index < html.length; index++) {
    final character = html[index];
    if (escaped) {
      escaped = false;
    } else if (character == r'\') {
      escaped = true;
    } else if (character == '"') {
      try {
        final serialized = jsonDecode(html.substring(start, index + 1));
        if (serialized is! String) return [];
        final decoded = jsonDecode(serialized);
        if (decoded is! Map || decoded['queryClientCache'] is! Map) return [];
        final queries = (decoded['queryClientCache'] as Map)['queries'];
        if (queries is! List) return [];
        final results = <Map<String, dynamic>>[];
        for (final query in queries.take(100)) {
          if (query is! Map || query['queryKey'] is! List) continue;
          final key = query['queryKey'] as List;
          if (key.length != 2 ||
              key[0] != 'featured-photos-feed' ||
              key[1] != null) {
            continue;
          }
          final state = query['state'];
          if (state is! Map || state['data'] is! Map) continue;
          final pages = (state['data'] as Map)['pages'];
          if (pages is! List) continue;
          for (final page in pages.take(5)) {
            if (page is Map && page['results'] is List) {
              results.addAll(
                (page['results'] as List)
                    .take(30)
                    .whereType<Map<String, dynamic>>(),
              );
            }
          }
        }
        return results;
      } catch (_) {
        return [];
      }
    }
  }
  return [];
}

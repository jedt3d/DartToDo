import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_todo_server/src/background/unsplash_service.dart';
import 'package:flutter_todo_server/src/background/unsplash_transport.dart';
import 'package:test/test.dart';

Map<String, dynamic> _photo(String id) => {
  'id': id,
  'premium': false,
  'promoted_at': '2026-11-17T00:00:00Z',
  'sponsorship': null,
  'urls': {
    'raw': 'https://images.unsplash.com/photo-$id?ixid=fixture&keep=a&keep=b',
  },
  'links': {
    'html': 'https://unsplash.com/photos/$id',
    'download_location':
        'https://api.unsplash.com/photos/$id/download?ixid=fixture',
  },
  'user': {
    'name': 'Photographer "$id"',
    'links': {'html': 'https://unsplash.com/@$id'},
  },
};

String _homepage(
  List<Map<String, dynamic>> photos, {
  List<Object?> key = const ['featured-photos-feed', null],
}) {
  final data = {
    'queryClientCache': {
      'queries': [
        {
          'queryKey': key,
          'state': {
            'data': {
              'pages': [
                {'results': photos},
              ],
            },
          },
        },
        {
          'queryKey': ['irrelevant-photos'],
          'state': {
            'data': {
              'pages': [
                {
                  'results': [_photo('not-featured')],
                },
              ],
            },
          },
        },
      ],
    },
  };
  return '<html><script>window.__DEHYDRATED_DATA__ = ${jsonEncode(jsonEncode(data))};window.doNotExecute="side effect";</script></html>';
}

Map<String, dynamic> _seedPhoto(String id) => {
  'id': id,
  'imageUrl': 'https://images.unsplash.com/photo-$id?ixid=seed',
  'photographer': 'Seed photographer',
  'photographerUrl': 'https://unsplash.com/@seed',
  'photoUrl': 'https://unsplash.com/photos/$id',
  'downloadLocation': 'https://api.unsplash.com/photos/$id/download?ixid=seed',
  'premium': false,
  'promotedAt': '2026-11-17T00:00:00Z',
};

final class _Request {
  _Request(this.uri, this.headers, this.maxBytes);
  final Uri uri;
  final Map<String, String> headers;
  final int maxBytes;
}

final class _Transport implements UnsplashTransport {
  _Transport(this.respond);
  final FutureOr<UnsplashReply> Function(Uri) respond;
  final requests = <_Request>[];
  bool closed = false;
  @override
  Future<UnsplashReply> get(
    Uri uri, {
    required Map<String, String> headers,
    required Duration timeout,
    required int maxBytes,
  }) async {
    requests.add(_Request(uri, Map.of(headers), maxBytes));
    return respond(uri);
  }

  @override
  void close() => closed = true;
}

void main() {
  late Directory directory;
  late File cache;
  late File seed;
  final services = <UnsplashService>[];
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('darttodo-unsplash-');
    cache = File('${directory.path}/cache.json');
    seed = File('${directory.path}/seed.json');
  });
  tearDown(() async {
    for (final service in services) {
      service.close();
    }
    services.clear();
    await directory.delete(recursive: true);
  });
  UnsplashService service(
    _Transport transport, {
    String key = '',
    DateTime Function()? now,
    Duration timeout = const Duration(seconds: 1),
  }) {
    final value = UnsplashService(
      accessKey: key,
      transport: transport,
      random: Random(7),
      now: now,
      cacheFile: cache,
      seedFile: seed,
      requestTimeout: timeout,
    );
    services.add(value);
    return value;
  }

  Future<void> writeSeed(List<Map<String, dynamic>> photos) =>
      seed.writeAsString(
        jsonEncode({
          'schemaVersion': 1,
          'sourceUrl': 'https://unsplash.com/',
          'capturedAt': '2026-11-17T00:00:00Z',
          'photos': photos,
        }),
      );

  test(
    'homepage parser decodes escaped JSON string without executing JavaScript',
    () {
      final results = featuredHomepageResults(_homepage([_photo('one')]));
      expect(results.single['id'], 'one');
      expect((results.single['user'] as Map)['name'], 'Photographer "one"');
    },
  );

  test(
    'homepage parser selects only exact Featured query and fails closed on changes',
    () {
      expect(
        featuredHomepageResults(
          _homepage([_photo('one')], key: ['other-feed', null]),
        ),
        isEmpty,
      );
      expect(
        featuredHomepageResults('window.__DEHYDRATED_DATA__ = doSomething();'),
        isEmpty,
      );
      expect(
        featuredHomepageResults('window.__DEHYDRATED_DATA__ = "unterminated'),
        isEmpty,
      );
      expect(
        featuredHomepageResults('<script>window.doSomething()</script>'),
        isEmpty,
      );
    },
  );

  test(
    'no-key homepage request filters premium, ads and unpromoted photos',
    () async {
      final premium = _photo('premium')..['premium'] = true;
      final ad = _photo('ad')..['sponsorship'] = {'sponsor': 'Example'};
      final unpromoted = _photo('unpromoted')..['promoted_at'] = null;
      final transport = _Transport(
        (_) => UnsplashReply(
          200,
          _homepage([premium, ad, unpromoted, _photo('one')]),
        ),
      );
      final result = await service(transport).featured();
      expect(result!.id, 'one');
      expect(result.source, 'homepage');
      expect(result.fromCache, false);
      expect(transport.requests.single.uri.toString(), 'https://unsplash.com/');
      expect(
        transport.requests.single.headers.containsKey('Authorization'),
        false,
      );
      expect(transport.requests.single.headers['Accept'], 'text/html');
      expect(transport.requests.single.maxBytes, 3 * 1024 * 1024);
    },
  );

  test(
    'each app-open request refreshes homepage and avoids previous photo',
    () async {
      final transport = _Transport(
        (_) => UnsplashReply(200, _homepage([_photo('one'), _photo('two')])),
      );
      final photos = service(transport);
      final first = await photos.featured();
      final second = await photos.featured(previousId: first!.id);
      expect(second!.id, isNot(first.id));
      expect(transport.requests.length, 2);
      expect(
        transport.requests.every(
          (request) => request.uri.host == 'unsplash.com',
        ),
        true,
      );
    },
  );

  test(
    'image query and attribution retain provenance without API credentials',
    () async {
      final transport = _Transport(
        (_) => UnsplashReply(200, _homepage([_photo('one')])),
      );
      final photo = (await service(transport).featured())!;
      final image = Uri.parse(photo.imageUrl);
      expect(image.host, 'images.unsplash.com');
      expect(image.queryParameters['ixid'], 'fixture');
      expect(image.queryParametersAll['keep'], ['a', 'b']);
      expect(image.queryParameters['w'], '2400');
      expect(
        Uri.parse(photo.photographerUrl).queryParameters['utm_source'],
        'darttodo',
      );
      expect(
        Uri.parse(photo.photoUrl).queryParameters['utm_medium'],
        'referral',
      );
      expect(await cache.readAsString(), isNot(contains('Authorization')));
    },
  );

  test(
    'unsafe image and attribution hosts never enter returned metadata',
    () async {
      final badImage = _photo('bad-image')
        ..['urls'] = {'raw': 'https://images.unsplash.com.evil.example/image'};
      final badAuthor = _photo('bad-author')
        ..['user'] = {
          'name': 'A',
          'links': {'html': 'http://unsplash.com/@person'},
        };
      final badPhoto = _photo('bad-photo')
        ..['links'] = {'html': 'https://127.0.0.1/private'};
      final transport = _Transport(
        (_) => UnsplashReply(200, _homepage([badImage, badAuthor, badPhoto])),
      );
      expect(await service(transport).featured(), isNull);
      expect(transport.requests.length, 1);
    },
  );

  test('changed homepage uses last-good cache with clear provenance', () async {
    var broken = false;
    final transport = _Transport(
      (_) => UnsplashReply(
        200,
        broken
            ? '<html>new layout</html>'
            : _homepage([_photo('one'), _photo('two')]),
      ),
    );
    final photos = service(transport);
    final first = (await photos.featured())!;
    broken = true;
    final fallback = (await photos.featured(previousId: first.id))!;
    expect(fallback.id, isNot(first.id));
    expect(fallback.fromCache, true);
    expect(fallback.source, 'homepage');
  });

  test(
    'cache survives service restart and preserves no-repeat selection',
    () async {
      final firstService = service(
        _Transport(
          (_) => UnsplashReply(200, _homepage([_photo('one'), _photo('two')])),
        ),
      );
      final first = (await firstService.featured())!;
      firstService.close();
      final reopened = service(
        _Transport((_) => const UnsplashReply(503, 'unavailable')),
      );
      final second = (await reopened.featured())!;
      expect(second.id, isNot(first.id));
      expect(second.fromCache, true);
      expect(second.source, 'homepage');
    },
  );

  test(
    'dated seed is offline fallback and never makes unauthenticated API calls',
    () async {
      await writeSeed([_seedPhoto('seed-one'), _seedPhoto('seed-two')]);
      final transport = _Transport((_) => const UnsplashReply(503, 'offline'));
      final photos = service(transport);
      final first = (await photos.featured())!;
      final second = (await photos.featured(previousId: first.id))!;
      expect(first.source, 'featured-seed');
      expect(first.fromCache, true);
      expect(second.id, isNot(first.id));
      expect(transport.requests.length, 1);
      expect(transport.requests.single.uri.host, 'unsplash.com');
    },
  );

  test('premium and unpromoted seed entries are rejected', () async {
    await writeSeed([
      _seedPhoto('premium')..['premium'] = true,
      _seedPhoto('not-promoted')..['promotedAt'] = null,
    ]);
    expect(
      await service(
        _Transport((_) => const UnsplashReply(503, 'offline')),
      ).featured(),
      isNull,
    );
  });

  test('rate failure backs off and retains cached metadata', () async {
    var now = DateTime.utc(2026, 11, 17);
    await writeSeed([_seedPhoto('one'), _seedPhoto('two')]);
    final transport = _Transport((_) => const UnsplashReply(429, 'rate limit'));
    final photos = service(transport, now: () => now);
    expect(await photos.featured(), isNotNull);
    expect(await photos.featured(), isNotNull);
    expect(transport.requests.length, 1);
    now = now.add(const Duration(minutes: 2));
    expect(await photos.featured(), isNotNull);
    expect(transport.requests.length, 2);
  });

  test(
    'missing key with no seed and unavailable homepage returns null without raw errors',
    () async {
      final transport = _Transport(
        (_) => throw const SocketException('raw transport detail'),
      );
      expect(await service(transport).featured(), isNull);
    },
  );

  test(
    'oversized homepage is rejected before parsing and falls back safely',
    () async {
      await writeSeed([_seedPhoto('one')]);
      final transport = _Transport(
        (_) => UnsplashReply(200, 'x' * (UnsplashService.maxHomepageBytes + 1)),
      );
      expect((await service(transport).featured())!.source, 'featured-seed');
    },
  );

  test(
    'timeout finishes optional request without blocking task work',
    () async {
      final pending = Completer<UnsplashReply>();
      final transport = _Transport((_) => pending.future);
      expect(
        await service(
          transport,
          timeout: const Duration(milliseconds: 10),
        ).featured(),
        isNull,
      );
    },
  );

  test(
    'closing cancels pending request and closes its owned transport',
    () async {
      final started = Completer<void>();
      final pending = Completer<UnsplashReply>();
      final transport = _Transport((_) {
        started.complete();
        return pending.future;
      });
      final photos = service(transport);
      final result = photos.featured();
      await started.future;
      photos.close();
      expect(await result.timeout(const Duration(seconds: 1)), isNull);
      expect(transport.closed, true);
      expect(await photos.featured(), isNull);
      expect(transport.requests.length, 1);
    },
  );

  test(
    'optional authenticated API uses official feed and tracks selected download',
    () async {
      final transport = _Transport(
        (uri) => uri.path.endsWith('/download')
            ? const UnsplashReply(200, '{}')
            : UnsplashReply(200, jsonEncode([_photo('one'), _photo('two')])),
      );
      final photos = service(transport, key: 'test-key-only');
      final first = (await photos.featured())!;
      final second = (await photos.featured(previousId: first.id))!;
      expect(second.id, isNot(first.id));
      expect(first.source, 'editorial');
      expect(first.fromCache, false);
      expect(second.fromCache, true);
      expect(transport.requests.first.uri.path, '/photos');
      expect(transport.requests.first.uri.queryParameters['per_page'], '30');
      expect(
        int.parse(transport.requests.first.uri.queryParameters['page']!),
        inInclusiveRange(1, 5),
      );
      expect(
        transport.requests.first.headers['Authorization'],
        'Client-ID test-key-only',
      );
      expect(transport.requests.first.headers['Accept-Version'], 'v1');
      expect(
        transport.requests
            .where((request) => request.uri.path.endsWith('/download'))
            .length,
        2,
      );
      expect(transport.requests.last.uri.queryParameters['ixid'], 'fixture');
      expect(await cache.readAsString(), isNot(contains('test-key-only')));
      expect(first.toJson().toString(), isNot(contains('test-key-only')));
    },
  );

  test(
    'real transport rejects unsafe hosts and remains closed after disposal',
    () async {
      final transport = UnsplashHttpTransport();
      await expectLater(
        transport.get(
          Uri.parse('https://example.com/'),
          headers: {},
          timeout: const Duration(seconds: 1),
          maxBytes: 10,
        ),
        throwsA(isA<FormatException>()),
      );
      transport.close();
      await expectLater(
        transport.get(
          Uri.parse('https://unsplash.com/'),
          headers: {},
          timeout: const Duration(seconds: 1),
          maxBytes: 10,
        ),
        throwsA(isA<StateError>()),
      );
    },
  );
}

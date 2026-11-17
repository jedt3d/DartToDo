import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:flutter_todo_flutter/services/backgrounds.dart';

BackgroundPhoto photo(String id, {String? url}) => BackgroundPhoto(
  id: id,
  imageUrl: url ?? 'https://images.unsplash.com/$id',
  photographer: 'Photographer $id',
  photographerUrl: 'https://unsplash.com/',
  photoUrl: 'https://unsplash.com/',
);

// Static synthetic PNG fixtures exercise the actual engine decoder.
final _firstPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAEklEQVR4nGNQK837jw8zjAwFALxmggGs1llpAAAAAElFTkSuQmCC',
);
final _secondPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'darttodo-background-test-',
    );
  });
  tearDown(() async => directory.delete(recursive: true));

  Future<void> cache(BackgroundPhoto value, List<int> bytes) =>
      File('${directory.path}/background.json').writeAsString(
        jsonEncode({
          'metadata': value.toJson(),
          'bytes': base64Encode(bytes),
        }),
      );

  test(
    'fresh image bytes and attribution persist together across launches',
    () async {
      var fetches = 0, downloads = 0;
      final first = await BackgroundService(
        cacheDirectory: directory,
        fetchPhoto: (previous) async {
          expect(previous, isNull);
          fetches++;
          return photo('first');
        },
        downloadImage: (uri) async {
          downloads++;
          expect(uri.host, 'images.unsplash.com');
          return _firstPng;
        },
      ).load();
      expect(first!.photo.id, 'first');
      expect(first.bytes, _firstPng);
      expect(fetches, 1);
      expect(downloads, 1);
      final record =
          jsonDecode(
                await File('${directory.path}/background.json').readAsString(),
              )
              as Map;
      expect((record['metadata'] as Map)['photographer'], 'Photographer first');
      expect(base64Decode(record['bytes'] as String), _firstPng);
      expect(await File('${directory.path}/background.tmp').exists(), isFalse);

      String? previousId;
      BackgroundSelection? shownCached;
      final cacheShown = Completer<void>();
      final fresh = Completer<BackgroundPhoto?>();
      final pending =
          BackgroundService(
            cacheDirectory: directory,
            fetchPhoto: (previous) {
              previousId = previous;
              return fresh.future;
            },
            downloadImage: (_) async => _secondPng,
          ).load(
            onCached: (selection) {
              shownCached = selection;
              cacheShown.complete();
            },
          );
      await cacheShown.future;
      expect(shownCached!.photo.id, 'first');
      expect(shownCached!.photo.fromCache, isTrue);
      expect(shownCached!.bytes, _firstPng);
      expect(previousId, 'first');
      fresh.complete(photo('second'));
      final second = await pending;
      expect(second!.photo.id, 'second');
      expect(second.bytes, _secondPng);
      final replaced =
          jsonDecode(
                await File('${directory.path}/background.json').readAsString(),
              )
              as Map;
      expect(
        (replaced['metadata'] as Map)['photographer'],
        'Photographer second',
      );
      expect(base64Decode(replaced['bytes'] as String), _secondPng);
    },
  );

  test(
    'fetch or download failures preserve cached image and its photographer',
    () async {
      await cache(photo('cached'), _firstPng);
      for (final downloadFails in [false, true]) {
        final selection = await BackgroundService(
          cacheDirectory: directory,
          fetchPhoto: (_) async {
            if (!downloadFails) {
              throw const SocketException('Offline fixture');
            }
            return photo('new');
          },
          downloadImage: (_) async =>
              throw const SocketException('Download fixture failure'),
        ).load();
        expect(selection!.photo.id, 'cached');
        expect(selection.photo.photographer, 'Photographer cached');
        expect(selection.bytes, _firstPng);
      }
    },
  );

  test(
    'empty response and absent cache leave tasks free to use a plain background',
    () async {
      final selection = await BackgroundService(
        cacheDirectory: directory,
        fetchPhoto: (_) async => null,
        downloadImage: (_) async => throw StateError('Must not download'),
      ).load();
      expect(selection, isNull);
    },
  );

  test('unsafe network image URLs are rejected before download', () async {
    var downloads = 0;
    for (final url in [
      'http://images.unsplash.com/a',
      'https://images.unsplash.com.evil.invalid/a',
      'https://fixture@images.unsplash.com/a',
      'https://images.unsplash.com:8443/a',
      'file:///tmp/a',
    ]) {
      final selection = await BackgroundService(
        cacheDirectory: directory,
        fetchPhoto: (_) async => photo('unsafe', url: url),
        downloadImage: (_) async {
          downloads++;
          return Uint8List.fromList([1]);
        },
      ).load();
      expect(selection, isNull, reason: url);
    }
    expect(downloads, 0);
  });

  test(
    'unsafe cached image URLs are ignored before reporting a previous photo',
    () async {
      for (final url in [
        'http://images.unsplash.com/a',
        'https://images.unsplash.com.evil.invalid/a',
        'https://fixture@images.unsplash.com/a',
        'https://images.unsplash.com:8443/a',
      ]) {
        await cache(photo('unsafe-cache', url: url), [1]);
        String? previousId;
        var shown = false;
        final selection = await BackgroundService(
          cacheDirectory: directory,
          fetchPhoto: (previous) async {
            previousId = previous;
            return null;
          },
          downloadImage: (_) async => throw StateError('Must not download'),
        ).load(onCached: (_) => shown = true);
        expect(selection, isNull, reason: url);
        expect(previousId, isNull);
        expect(shown, isFalse);
      }
    },
  );

  test(
    'empty and oversized downloads cannot overwrite a valid cache',
    () async {
      await cache(photo('cached'), _firstPng);
      for (final bytes in [Uint8List(0), Uint8List(8 * 1024 * 1024 + 1)]) {
        final selection = await BackgroundService(
          cacheDirectory: directory,
          fetchPhoto: (_) async => photo('oversize'),
          downloadImage: (_) async => bytes,
        ).load();
        expect(selection!.photo.id, 'cached');
        expect(selection.bytes, _firstPng);
        final saved =
            jsonDecode(
                  await File(
                    '${directory.path}/background.json',
                  ).readAsString(),
                )
                as Map;
        expect((saved['metadata'] as Map)['id'], 'cached');
      }
    },
  );

  test(
    'malformed fresh images preserve the last decoded image and attribution',
    () async {
      await cache(photo('last-good'), _firstPng);
      final record = File('${directory.path}/background.json');
      final originalRecord = await record.readAsString();
      for (final malformed in [
        Uint8List.fromList(utf8.encode('Not an image despite HTTP 200')),
        Uint8List.sublistView(_secondPng, 0, 40),
      ]) {
        BackgroundSelection? cachedShown;
        final selection = await BackgroundService(
          cacheDirectory: directory,
          fetchPhoto: (previous) async {
            expect(previous, 'last-good');
            return photo('bad-fresh');
          },
          downloadImage: (_) async => malformed,
        ).load(onCached: (cached) => cachedShown = cached);
        expect(cachedShown!.photo.id, 'last-good');
        expect(selection!.photo.id, 'last-good');
        expect(selection.photo.photographer, 'Photographer last-good');
        expect(selection.photo.fromCache, isTrue);
        expect(selection.bytes, _firstPng);
        expect(await record.readAsString(), originalRecord);
        expect(
          await File('${directory.path}/background.tmp').exists(),
          isFalse,
        );
      }
    },
  );

  test(
    'malformed image cache is not displayed or used as previous photo',
    () async {
      await cache(photo('invalid-image'), [1, 2, 3]);
      var shownCached = false;
      final selection = await BackgroundService(
        cacheDirectory: directory,
        fetchPhoto: (previous) async {
          expect(previous, isNull);
          return photo('decoded-fresh');
        },
        downloadImage: (_) async => _secondPng,
      ).load(onCached: (_) => shownCached = true);
      expect(shownCached, isFalse);
      expect(selection!.photo.id, 'decoded-fresh');
      expect(selection.bytes, _secondPng);
    },
  );

  test(
    'malformed download without a good cache leaves no image record',
    () async {
      final selection = await BackgroundService(
        cacheDirectory: directory,
        fetchPhoto: (_) async => photo('invalid-image'),
        downloadImage: (_) async => Uint8List.fromList([1, 2, 3]),
      ).load();
      expect(selection, isNull);
      expect(await File('${directory.path}/background.json').exists(), isFalse);
    },
  );

  test('corrupt cache formats and bytes do not prevent a fresh load', () async {
    final file = File('${directory.path}/background.json');
    final malformed = [
      'not json',
      '{}',
      jsonEncode({'metadata': photo('bad').toJson(), 'bytes': 'invalid!'}),
      jsonEncode({'metadata': photo('bad').toJson(), 'bytes': ''}),
    ];
    for (final text in malformed) {
      await file.writeAsString(text);
      String? previousId;
      final selection = await BackgroundService(
        cacheDirectory: directory,
        fetchPhoto: (previous) async {
          previousId = previous;
          return photo('fresh');
        },
        downloadImage: (_) async => _secondPng,
      ).load();
      expect(previousId, isNull);
      expect(selection!.photo.id, 'fresh');
      expect(selection.bytes, _secondPng);
    }
  });

  test(
    'oversized cache files and metadata are ignored without downloading',
    () async {
      final file = await File(
        '${directory.path}/background.json',
      ).open(mode: FileMode.write);
      await file.truncate(12 * 1024 * 1024 + 1);
      await file.close();
      final hugeMetadata = photo('large').copyWith(photographer: 'x' * 21000);
      for (var i = 0; i < 2; i++) {
        if (i == 1) {
          await cache(hugeMetadata, [1]);
        }
        final selection = await BackgroundService(
          cacheDirectory: directory,
          fetchPhoto: (previous) async {
            expect(previous, isNull);
            return null;
          },
          downloadImage: (_) async => throw StateError('Must not download'),
        ).load();
        expect(selection, isNull);
      }
    },
  );

  test(
    'an unwritable cache location still returns the fetched background',
    () async {
      final blocked = File('${directory.path}/blocked');
      await blocked.writeAsString('A file, not a directory');
      final selection = await BackgroundService(
        cacheDirectory: Directory(blocked.path),
        fetchPhoto: (_) async => photo('fresh'),
        downloadImage: (_) async => _secondPng,
      ).load();
      expect(selection!.photo.id, 'fresh');
      expect(selection.bytes, _secondPng);
      expect(await blocked.readAsString(), 'A file, not a directory');
    },
  );
}

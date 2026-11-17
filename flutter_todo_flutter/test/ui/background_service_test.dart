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

void main() {
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
          return Uint8List.fromList([1, 2, 3]);
        },
      ).load();
      expect(first!.photo.id, 'first');
      expect(first.bytes, [1, 2, 3]);
      expect(fetches, 1);
      expect(downloads, 1);
      final record =
          jsonDecode(
                await File('${directory.path}/background.json').readAsString(),
              )
              as Map;
      expect((record['metadata'] as Map)['photographer'], 'Photographer first');
      expect(base64Decode(record['bytes'] as String), [1, 2, 3]);
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
            downloadImage: (_) async => Uint8List.fromList([4, 5]),
          ).load(
            onCached: (selection) {
              shownCached = selection;
              cacheShown.complete();
            },
          );
      await cacheShown.future;
      expect(shownCached!.photo.id, 'first');
      expect(shownCached!.photo.fromCache, isTrue);
      expect(shownCached!.bytes, [1, 2, 3]);
      expect(previousId, 'first');
      fresh.complete(photo('second'));
      final second = await pending;
      expect(second!.photo.id, 'second');
      expect(second.bytes, [4, 5]);
      final replaced =
          jsonDecode(
                await File('${directory.path}/background.json').readAsString(),
              )
              as Map;
      expect(
        (replaced['metadata'] as Map)['photographer'],
        'Photographer second',
      );
      expect(base64Decode(replaced['bytes'] as String), [4, 5]);
    },
  );

  test(
    'fetch or download failures preserve cached image and its photographer',
    () async {
      await cache(photo('cached'), [7, 8]);
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
        expect(selection.bytes, [7, 8]);
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
      await cache(photo('cached'), [9]);
      for (final bytes in [Uint8List(0), Uint8List(8 * 1024 * 1024 + 1)]) {
        final selection = await BackgroundService(
          cacheDirectory: directory,
          fetchPhoto: (_) async => photo('oversize'),
          downloadImage: (_) async => bytes,
        ).load();
        expect(selection!.photo.id, 'cached');
        expect(selection.bytes, [9]);
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
        downloadImage: (_) async => Uint8List.fromList([5]),
      ).load();
      expect(previousId, isNull);
      expect(selection!.photo.id, 'fresh');
      expect(selection.bytes, [5]);
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
        downloadImage: (_) async => Uint8List.fromList([6]),
      ).load();
      expect(selection!.photo.id, 'fresh');
      expect(selection.bytes, [6]);
      expect(await blocked.readAsString(), 'A file, not a directory');
    },
  );
}

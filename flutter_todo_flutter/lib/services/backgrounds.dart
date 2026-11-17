import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_todo_client/flutter_todo_client.dart';

/// One displayed photo and its attribution, retained together in the cache.
final class BackgroundSelection {
  const BackgroundSelection(this.photo, this.bytes);
  final BackgroundPhoto photo;
  final Uint8List bytes;
}

/// Selects once per app launch; background failure never blocks local tasks.
final class BackgroundService {
  BackgroundService({
    Future<BackgroundPhoto?> Function(String?)? fetchPhoto,
    Future<Uint8List> Function(Uri)? downloadImage,
    Directory? cacheDirectory,
  }) : _fetchPhoto = fetchPhoto ?? _fetch,
       _downloadImage = downloadImage ?? _download,
       _directory =
           cacheDirectory ??
           Directory('${Directory.systemTemp.path}/darttodo-featured');

  final Future<BackgroundPhoto?> Function(String?) _fetchPhoto;
  final Future<Uint8List> Function(Uri) _downloadImage;
  final Directory _directory;
  static const _imageLimit = 8 * 1024 * 1024;

  static bool _validPhoto(BackgroundPhoto photo) {
    bool safe(String value, Set<String> hosts) {
      final uri = Uri.tryParse(value);
      return uri != null &&
          uri.scheme == 'https' &&
          hosts.contains(uri.host) &&
          uri.userInfo.isEmpty &&
          uri.port == 443;
    }

    return safe(photo.imageUrl, {'images.unsplash.com'}) &&
        safe(photo.photographerUrl, {'unsplash.com', 'www.unsplash.com'}) &&
        safe(photo.photoUrl, {'unsplash.com', 'www.unsplash.com'});
  }

  Future<BackgroundSelection?> load({
    void Function(BackgroundSelection)? onCached,
  }) async {
    final cached = await _readCache();
    if (cached != null) onCached?.call(cached);
    try {
      final photo = await _fetchPhoto(
        cached?.photo.id,
      ).timeout(const Duration(seconds: 12));
      if (photo == null) return cached;
      if (!_validPhoto(photo)) {
        return cached;
      }
      final uri = Uri.parse(photo.imageUrl);
      final bytes = await _downloadImage(uri);
      if (bytes.isEmpty || bytes.length > _imageLimit) return cached;
      final selected = BackgroundSelection(photo, bytes);
      try {
        await _directory.create(recursive: true);
        // One atomic record keeps attribution attached to the correct image.
        final record = jsonEncode({
          'metadata': photo.toJson(),
          'bytes': base64Encode(bytes),
        });
        await File(
          '${_directory.path}/background.tmp',
        ).writeAsString(record, flush: true);
        await File(
          '${_directory.path}/background.tmp',
        ).rename('${_directory.path}/background.json');
      } on FileSystemException {
        // A read-only/full cache must not prevent displaying the fetched photo.
      }
      return selected;
    } on Object {
      return cached;
    }
  }

  Future<BackgroundSelection?> _readCache() async {
    try {
      final record = File('${_directory.path}/background.json');
      if (await record.length() > 12 * 1024 * 1024) {
        return null;
      }
      final data =
          jsonDecode(await record.readAsString()) as Map<String, dynamic>;
      final metadata = data['metadata'] as Map<String, dynamic>;
      if (jsonEncode(metadata).length > 20000) {
        return null;
      }
      final photo = BackgroundPhoto.fromJson(metadata);
      if (!_validPhoto(photo)) {
        return null;
      }
      final bytes = base64Decode(data['bytes'] as String);
      return bytes.isEmpty || bytes.length > _imageLimit
          ? null
          : BackgroundSelection(photo.copyWith(fromCache: true), bytes);
    } on Object {
      return null;
    }
  }

  static Future<BackgroundPhoto?> _fetch(String? previousId) async {
    final client = Client('http://127.0.0.1:8870/');
    try {
      return await client.background.featured(previousId: previousId);
    } finally {
      client.close();
    }
  }

  static Future<Uint8List> _download(Uri uri) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      request.headers.set(
        HttpHeaders.acceptHeader,
        'image/jpeg,image/png,image/webp',
      );
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode != 200 ||
          response.headers.contentType?.primaryType != 'image' ||
          response.contentLength > _imageLimit) {
        throw const FormatException('Photo unavailable');
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in response.timeout(const Duration(seconds: 8))) {
        if (bytes.length + chunk.length > _imageLimit) {
          throw const FormatException('Photo too large');
        }
        bytes.add(chunk);
      }
      return bytes.takeBytes();
    } finally {
      client.close(force: true);
    }
  }
}

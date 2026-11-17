import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// A bounded metadata response; image bytes are hotlinked by the frontend.
final class UnsplashReply {
  const UnsplashReply(this.statusCode, this.body, {this.headers = const {}});
  final int statusCode;
  final String body;
  final Map<String, String> headers;
}

/// The service's injectable HTTP boundary. Closing aborts outstanding requests.
abstract interface class UnsplashTransport {
  Future<UnsplashReply> get(
    Uri uri, {
    required Map<String, String> headers,
    required Duration timeout,
    required int maxBytes,
  });
  void close();
}

/// Uses trusted Unsplash HTTPS hosts without following redirects with a key.
final class UnsplashHttpTransport implements UnsplashTransport {
  final _active = <HttpClient>{};
  bool _closed = false;

  @override
  Future<UnsplashReply> get(
    Uri uri, {
    required Map<String, String> headers,
    required Duration timeout,
    required int maxBytes,
  }) async {
    if (_closed) throw StateError('Photo transport is closed.');
    if (!(isUnsplashHttps(uri, 'api.unsplash.com') ||
        (isUnsplashHttps(uri, 'unsplash.com') &&
            uri.path == '/' &&
            !uri.hasQuery))) {
      throw const FormatException('Unsupported photo metadata host.');
    }
    final client = HttpClient()..connectionTimeout = timeout;
    _active.add(client);
    try {
      return await (() async {
        final request = await client.getUrl(uri);
        request.followRedirects = false;
        headers.forEach(request.headers.set);
        final response = await request.close();
        final body = BytesBuilder(copy: false);
        await for (final chunk in response) {
          if (body.length + chunk.length > maxBytes) {
            throw const FormatException(
              'Photo metadata exceeds the size limit.',
            );
          }
          body.add(chunk);
        }
        return UnsplashReply(
          response.statusCode,
          utf8.decode(body.takeBytes()),
          headers: {
            'retry-after': ?response.headers.value('retry-after'),
          },
        );
      })().timeout(
        timeout,
        onTimeout: () {
          client.close(force: true);
          throw TimeoutException('Photo metadata request timed out.');
        },
      );
    } finally {
      _active.remove(client);
      client.close(force: true);
    }
  }

  @override
  void close() {
    _closed = true;
    for (final client in _active.toList()) {
      client.close(force: true);
    }
    _active.clear();
  }
}

/// Exact HTTPS host validation shared by metadata, attribution and cache input.
bool isUnsplashHttps(Uri uri, String host) =>
    uri.scheme == 'https' &&
    uri.host == host &&
    uri.userInfo.isEmpty &&
    (!uri.hasPort || uri.port == 443) &&
    !uri.hasFragment;

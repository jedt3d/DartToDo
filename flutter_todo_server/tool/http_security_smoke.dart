import 'dart:io';

/// Checks the running native-only API without reading or logging task data.
Future<void> main() async {
  final client = HttpClient();
  final uri = Uri.parse('http://127.0.0.1:8870/todo');
  Future<void> check(
    String method,
    Map<String, String> headers,
    int expected, {
    String path = '/todo',
  }) async {
    final request = await client.openUrl(method, uri.replace(path: path));
    headers.forEach(request.headers.set);
    if (method == 'POST') request.write('{"method":"fetch"}');
    final response = await request.close();
    await response.drain<void>();
    if (response.statusCode != expected) {
      throw StateError(
        '$method expected $expected, received ${response.statusCode}.',
      );
    }
    if (response.headers.value('access-control-allow-origin') != null) {
      throw StateError('API still permits browser CORS.');
    }
  }

  try {
    await check('POST', {'origin': 'https://untrusted.example'}, 403);
    await check('POST', {'host': 'untrusted.example'}, 403);
    await check('GET', {}, 403);
    await check('GET', {}, 403, path: '/background');
    await check(
      'POST',
      {'origin': 'https://untrusted.example'},
      403,
      path: '/background',
    );
    await check('OPTIONS', {'origin': 'https://untrusted.example'}, 200);
    stdout.writeln(
      'Local API browser-origin, host and method restrictions passed.',
    );
  } finally {
    client.close(force: true);
  }
}

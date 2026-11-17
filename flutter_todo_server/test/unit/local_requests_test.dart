import 'dart:io';

import 'package:flutter_todo_server/server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  late RelicServer server;
  late HttpClient client;
  late Uri url;
  setUpAll(() async {
    final app = RelicApp()
      ..use('/', localRequestsOnly)
      ..any('/**', (request) => Response.ok());
    server = await app.serve(address: InternetAddress.loopbackIPv4, port: 0);
    client = HttpClient();
    url = Uri.parse('http://127.0.0.1:${server.port}/todo/fetch');
  });
  tearDownAll(() async {
    client.close(force: true);
    await server.close();
  });
  Future<int> send(
    String method, {
    Map<String, String> headers = const {},
  }) async {
    final request = await client.openUrl(method, url);
    headers.forEach(request.headers.set);
    final response = await request.close();
    await response.drain<void>();
    return response.statusCode;
  }

  test('native loopback POST remains allowed', () async {
    expect(await send('POST'), 200);
  });
  test('browser origin is rejected', () async {
    expect(
      await send('POST', headers: {'origin': 'https://untrusted.example'}),
      403,
    );
  });
  test('DNS rebinding host is rejected', () async {
    expect(await send('POST', headers: {'host': 'untrusted.example'}), 403);
  });
  test('GET cannot invoke a task operation', () async {
    expect(await send('GET'), 403);
  });
  test('GET cannot invoke a background operation', () async {
    final response = await client.getUrl(url.replace(path: '/background'));
    final result = await response.close();
    await result.drain<void>();
    expect(result.statusCode, 403);
  });
}

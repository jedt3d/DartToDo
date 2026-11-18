import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_todo_server/src/background/unsplash_transport.dart';
import 'package:test/test.dart';

final _api = Uri.parse('https://api.unsplash.com/photos');

void main() {
  test(
    'trusted metadata preserves UTF-8, headers and the exact byte cap',
    () async {
      final bytes = utf8.encode('A☃Z');
      final response = _Response(
        Stream.fromIterable([bytes.sublist(0, 2), bytes.sublist(2)]),
        fields: {'retry-after': '5'},
      );
      final client = _Client(_Request(() async => response));
      await _withClients([client], (transport) async {
        final reply = await transport.get(
          _api,
          headers: {
            'Authorization': 'Client-ID fixture-key',
            'Accept': 'application/json',
          },
          timeout: const Duration(seconds: 1),
          maxBytes: bytes.length,
        );
        expect(reply.statusCode, 200);
        expect(reply.body, 'A☃Z');
        expect(reply.headers, {'retry-after': '5'});
        expect(client.urls, [_api]);
        expect(client.request.followRedirects, isFalse);
        expect(
          client.request.headers.value('authorization'),
          'Client-ID fixture-key',
        );
        expect(client.request.headers.value('accept'), 'application/json');
        expect(client.connectionTimeout, const Duration(seconds: 1));
        expect(client.closeForces, isNotEmpty);
        expect(client.closeForces.every((force) => force), isTrue);
      });
    },
  );

  test(
    'homepage redirects are returned without enabling redirect following',
    () async {
      final response = _Response(
        Stream.value(utf8.encode('redirect')),
        statusCode: 302,
        fields: {'location': 'https://untrusted.example/'},
      );
      final client = _Client(_Request(() async => response));
      await _withClients([client], (transport) async {
        final homepage = Uri.parse('https://unsplash.com/');
        final reply = await transport.get(
          homepage,
          headers: {'Accept': 'text/html'},
          timeout: const Duration(seconds: 1),
          maxBytes: 20,
        );
        expect(reply.statusCode, 302);
        expect(client.request.followRedirects, isFalse);
        expect(client.urls, [homepage]);
        expect(client.closed, isTrue);
      });
    },
  );

  test(
    'metadata over the byte cap stops the body and closes the client',
    () async {
      final response = _Response(
        Stream.fromIterable([
          utf8.encode('ab'),
          utf8.encode('cd'),
          utf8.encode('unread'),
        ]),
      );
      final client = _Client(_Request(() async => response));
      await _withClients([client], (transport) async {
        await expectLater(
          transport.get(
            _api,
            headers: {},
            timeout: const Duration(seconds: 1),
            maxBytes: 3,
          ),
          throwsA(isA<FormatException>()),
        );
        expect(response.chunksDelivered, 2);
        expect(client.closed, isTrue);
        expect(client.closeForces, everyElement(isTrue));
      });
    },
  );

  test('invalid UTF-8 is rejected and releases its client', () async {
    final client = _Client(
      _Request(() async => _Response(Stream.value([255]))),
    );
    await _withClients([client], (transport) async {
      await expectLater(
        transport.get(
          _api,
          headers: {},
          timeout: const Duration(seconds: 1),
          maxBytes: 10,
        ),
        throwsA(isA<FormatException>()),
      );
      expect(client.closed, isTrue);
    });
  });

  test(
    'connection errors are preserved and release the allocated client',
    () async {
      const failure = SocketException('fixture connection failed');
      final client = _Client(
        _Request(() async => _Response(const Stream.empty())),
        openError: failure,
      );
      await _withClients([client], (transport) async {
        await expectLater(
          transport.get(
            _api,
            headers: {},
            timeout: const Duration(seconds: 1),
            maxBytes: 10,
          ),
          throwsA(same(failure)),
        );
        expect(client.closed, isTrue);
        expect(client.closeForces, everyElement(isTrue));
      });
    },
  );

  test(
    'response stream errors are preserved and release their client',
    () async {
      final failure = StateError('fixture body failed');
      final response = _Response(Stream.error(failure));
      final client = _Client(_Request(() async => response));
      await _withClients([client], (transport) async {
        await expectLater(
          transport.get(
            _api,
            headers: {},
            timeout: const Duration(seconds: 1),
            maxBytes: 10,
          ),
          throwsA(same(failure)),
        );
        expect(client.closed, isTrue);
      });
    },
  );

  test(
    'request timeout aborts the pending client and reports a timeout',
    () async {
      final response = Completer<HttpClientResponse>();
      final client = _Client(
        _Request(() => response.future),
        onClose: () {
          if (!response.isCompleted) {
            response.completeError(StateError('fixture abort'));
          }
        },
      );
      await _withClients([client], (transport) async {
        await expectLater(
          transport.get(
            _api,
            headers: {},
            timeout: const Duration(milliseconds: 20),
            maxBytes: 10,
          ),
          throwsA(isA<TimeoutException>()),
        );
        expect(response.isCompleted, isTrue);
        expect(client.closed, isTrue);
        expect(client.closeForces, everyElement(isTrue));
      });
    },
  );

  test(
    'disposing closes every active client and rejects later requests',
    () async {
      final responses = [
        Completer<HttpClientResponse>(),
        Completer<HttpClientResponse>(),
      ];
      final clients = [
        for (final response in responses)
          _Client(
            _Request(() => response.future),
            onClose: () {
              if (!response.isCompleted) {
                response.completeError(StateError('fixture abort'));
              }
            },
          ),
      ];
      await _withClients(clients, (transport) async {
        final first = transport.get(
          _api,
          headers: {},
          timeout: const Duration(seconds: 1),
          maxBytes: 10,
        );
        final second = transport.get(
          _api,
          headers: {},
          timeout: const Duration(seconds: 1),
          maxBytes: 10,
        );
        final aborted = expectLater(
          Future.wait([first, second]),
          throwsA(isA<StateError>()),
        );
        transport.close();
        await aborted;
        expect(clients.every((client) => client.closed), isTrue);
        expect(
          clients.expand((client) => client.closeForces),
          everyElement(isTrue),
        );
        await expectLater(
          transport.get(
            _api,
            headers: {},
            timeout: const Duration(seconds: 1),
            maxBytes: 10,
          ),
          throwsA(isA<StateError>()),
        );
        transport.close();
      });
    },
  );
}

Future<void> _withClients(
  List<_Client> clients,
  Future<void> Function(UnsplashHttpTransport) body,
) {
  var next = 0;
  return HttpOverrides.runZoned<Future<void>>(
    () async {
      final transport = UnsplashHttpTransport();
      try {
        await body(transport);
      } finally {
        transport.close();
      }
      expect(next, clients.length);
    },
    createHttpClient: (_) {
      final index = next++;
      if (index >= clients.length) throw StateError('Unexpected HTTP client');
      return clients[index];
    },
  );
}

final class _Client implements HttpClient {
  _Client(this.request, {this.openError, this.onClose});

  final _Request request;
  final Object? openError;
  final void Function()? onClose;
  final urls = <Uri>[];
  final closeForces = <bool>[];
  bool closed = false;

  @override
  Duration? connectionTimeout;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    urls.add(url);
    if (openError case final error?) throw error;
    return request;
  }

  @override
  void close({bool force = false}) {
    closeForces.add(force);
    if (closed) return;
    closed = true;
    onClose?.call();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Request implements HttpClientRequest {
  _Request(this.respond);
  final Future<HttpClientResponse> Function() respond;

  @override
  bool followRedirects = true;

  @override
  final headers = _Headers();

  @override
  Future<HttpClientResponse> close() => respond();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Response extends Stream<List<int>> implements HttpClientResponse {
  _Response(
    this.stream, {
    this.statusCode = 200,
    Map<String, String> fields = const {},
  }) : headers = _Headers(fields);

  final Stream<List<int>> stream;
  int chunksDelivered = 0;

  @override
  final int statusCode;

  @override
  final _Headers headers;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => stream
      .map((chunk) {
        chunksDelivered++;
        return chunk;
      })
      .listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Headers implements HttpHeaders {
  _Headers([Map<String, String> fields = const {}])
    : values = {
        for (final entry in fields.entries)
          entry.key.toLowerCase(): entry.value,
      };

  final Map<String, String> values;

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name.toLowerCase()] = value.toString();
  }

  @override
  String? value(String name) => values[name.toLowerCase()];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

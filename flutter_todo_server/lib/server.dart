import 'dart:io';

import 'package:serverpod/serverpod.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';

/// Restricts every Serverpod HTTP listener to this machine.
///
/// Serverpod 3.4.5 binds anyIPv6 regardless of publicHost. The Dart SDK's
/// documented socket override enforces the local-only application boundary.
final class LoopbackIoOverrides extends IOOverrides {
  @override
  Future<ServerSocket> serverSocketBind(
    dynamic address,
    int port, {
    int backlog = 0,
    bool v6Only = false,
    bool shared = false,
  }) => super.serverSocketBind(
    InternetAddress.loopbackIPv4,
    port,
    backlog: backlog,
    shared: shared,
  );
}

/// Starts the single-user local backend. No account providers are registered.
Future<void> run(List<String> args) async {
  IOOverrides.global = LoopbackIoOverrides();
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    httpResponseHeaders: Headers.empty(),
    httpOptionsResponseHeaders: Headers.empty(),
  );
  pod.server.addMiddleware(localRequestsOnly);
  await pod.start();
}

/// Rejects browser-origin traffic and DNS rebinding to the native-only API.
Handler localRequestsOnly(Handler next) => (request) async {
  if (request.headers.containsKey('origin') ||
      !{'127.0.0.1', 'localhost', '::1'}.contains(request.url.host) ||
      ((request.url.path.startsWith('/todo') ||
              request.url.path.startsWith('/background')) &&
          request.method != Method.post)) {
    return Response.forbidden();
  }
  return next(request);
};

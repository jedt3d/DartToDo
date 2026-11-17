import 'package:flutter_todo_client/flutter_todo_client.dart';

/// Exercises generated-client decoding against the running loopback server.
Future<void> main() async {
  final client = Client('http://127.0.0.1:8870/');
  try {
    final snapshot = await client.todo.fetch();
    if (!snapshot.lists.any((list) => list.id == 1 && list.title == 'Tasks') ||
        snapshot.settings.id != 1) {
      throw StateError(
        'The local service did not return its required defaults.',
      );
    }
    // No task titles, notes or file data are printed.
    print('Local generated-client HTTP smoke passed.');
  } finally {
    client.close();
  }
}

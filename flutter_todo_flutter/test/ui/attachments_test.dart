import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';

import '../data/fixtures.dart';
import 'support.dart';

const _limit = 26214400;

TodoAttachment _existing() => TodoAttachment(
  id: 'existing',
  name: 'kept.bin',
  mimeType: 'application/octet-stream',
  dataBase64: base64Encode([1, 2, 3]),
);

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  late FilePickerPlatform original;
  late _Picker picker;

  setUp(() {
    original = FilePickerPlatform.instance;
    picker = _Picker();
    FilePickerPlatform.instance = picker;
  });

  tearDown(() => FilePickerPlatform.instance = original);

  Future<FakeTodoRepository> showTask(
    WidgetTester tester, {
    List<TodoAttachment> attachments = const [],
  }) async {
    final data = uiData();
    final repository = await pumpApp(
      tester,
      size: const Size(1100, 1000),
      data: data.copyWith(
        tasks: [data.tasks.single.copyWith(attachments: attachments)],
      ),
    );
    await openDetails(tester);
    return repository;
  }

  Future<void> addFile(WidgetTester tester) async {
    final add = find.text('Add File');
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<void> exportFile(WidgetTester tester) async {
    final file = find.text('kept.bin');
    await tester.ensureVisible(file);
    await tester.tap(file);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('attachment import preserves bytes and removal detaches it', (
    tester,
  ) async {
    picker.choose = () async => _MemoryFile('résumé.bin', [
      Uint8List.fromList([0, 1, 127, 255]),
    ]);
    final repository = await showTask(tester);
    await addFile(tester);

    final saved = repository.data.tasks.single;
    expect(saved.id, 1);
    expect(saved.title, 'Focus task');
    final attachment = saved.attachments.single;
    expect(attachment.id, isNotEmpty);
    expect(attachment.name, 'résumé.bin');
    expect(base64Decode(attachment.dataBase64), [0, 1, 127, 255]);
    expect(find.text('résumé.bin'), findsOneWidget);

    final remove = find.byTooltip('Remove résumé.bin');
    await tester.ensureVisible(remove);
    await tester.tap(remove);
    await tester.pumpAndSettle();
    expect(repository.data.tasks.single.id, saved.id);
    expect(repository.data.tasks.single.attachments, isEmpty);
    expect(find.text('résumé.bin'), findsNothing);
    expect(repository.saveCalls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending and canceled attachment selection can be retried', (
    tester,
  ) async {
    final selection = Completer<PlatformFile?>();
    picker.choose = () => selection.future;
    final repository = await showTask(tester, attachments: [_existing()]);
    await addFile(tester);
    expect(find.text('Adding file…'), findsOneWidget);
    await tester.tap(find.text('Adding file…'));
    await tester.pump();
    expect(picker.pickCalls, 1);

    selection.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Add File'), findsOneWidget);
    expect(repository.saveCalls, 0);
    expect(
      repository.data.tasks.single.attachments.single.toJson(),
      _existing().toJson(),
    );

    picker.choose = () async => _MemoryFile('retry.bin', [
      Uint8List.fromList([4]),
    ]);
    await addFile(tester);
    expect(picker.pickCalls, 2);
    expect(repository.data.tasks.single.attachments.map((file) => file.name), [
      'kept.bin',
      'retry.bin',
    ]);
  });

  testWidgets('attachment exactly 25 MiB is accepted through the detail UI', (
    tester,
  ) async {
    final bytes = Uint8List(_limit)
      ..first = 17
      ..last = 239;
    picker.choose = () async => _MemoryFile('boundary.bin', [bytes]);
    final repository = await showTask(tester);
    await addFile(tester);

    final attachment = repository.data.tasks.single.attachments.single;
    final decoded = base64Decode(attachment.dataBase64);
    expect(decoded.length, _limit);
    expect(decoded.first, 17);
    expect(decoded.last, 239);
    expect(attachment.name, 'boundary.bin');
    expect(repository.saveCalls, 1);
    expect(find.textContaining('Could not attach file.'), findsNothing);
  });

  testWidgets('aggregate attachment excess keeps existing files and task', (
    tester,
  ) async {
    picker.choose = () async => _MemoryFile('too-large.bin', [
      Uint8List(_limit - 3),
      Uint8List.fromList([4]),
    ]);
    final repository = await showTask(tester, attachments: [_existing()]);
    final before = repository.data.tasks.single.toJson();
    await addFile(tester);

    expect(find.textContaining('25 MB or smaller'), findsOneWidget);
    expect(repository.saveCalls, 0);
    expect(repository.data.tasks.single.toJson(), before);
    expect(find.text('kept.bin'), findsOneWidget);
    expect(find.text('too-large.bin'), findsNothing);
    expect(find.text('Add File'), findsOneWidget);
  });

  testWidgets('failed attachment stream preserves data and permits retry', (
    tester,
  ) async {
    picker.choose = () async => _MemoryFile(
      'unreadable.bin',
      [
        Uint8List.fromList([9]),
      ],
      readError: StateError('fixture read failed'),
    );
    final repository = await showTask(tester, attachments: [_existing()]);
    final before = repository.data.tasks.single.toJson();
    await addFile(tester);

    expect(find.textContaining('Could not attach file.'), findsOneWidget);
    expect(repository.data.tasks.single.toJson(), before);
    expect(repository.saveCalls, 0);

    picker.choose = () async => _MemoryFile('recovered.bin', [
      Uint8List.fromList([0, 255]),
    ]);
    await addFile(tester);
    expect(repository.data.tasks.single.attachments.map((file) => file.name), [
      'kept.bin',
      'recovered.bin',
    ]);
    expect(
      base64Decode(repository.data.tasks.single.attachments.last.dataBase64),
      [0, 255],
    );
    expect(repository.saveCalls, 1);
  });

  testWidgets('attachment export sends original filename and decoded bytes', (
    tester,
  ) async {
    final repository = await showTask(tester, attachments: [_existing()]);
    final before = repository.data.tasks.single.toJson();
    await exportFile(tester);

    expect(picker.saveCalls, 1);
    expect(picker.savedName, 'kept.bin');
    expect(picker.savedBytes, [1, 2, 3]);
    expect(picker.savedDialogTitle, 'Save attachment');
    expect(find.text('Attachment saved'), findsOneWidget);
    expect(repository.saveCalls, 0);
    expect(repository.data.tasks.single.toJson(), before);
  });

  testWidgets('canceling attachment export leaves the task unchanged', (
    tester,
  ) async {
    picker.write = () async => null;
    final repository = await showTask(tester, attachments: [_existing()]);
    final before = repository.data.tasks.single.toJson();
    await exportFile(tester);

    expect(picker.saveCalls, 1);
    expect(find.text('Attachment saved'), findsNothing);
    expect(find.textContaining('Could not save attachment.'), findsNothing);
    expect(repository.saveCalls, 0);
    expect(repository.data.tasks.single.toJson(), before);
  });

  testWidgets('attachment export failure can be retried without losing data', (
    tester,
  ) async {
    picker.write = () async => throw PlatformException(code: 'fixture-save');
    final repository = await showTask(tester, attachments: [_existing()]);
    final before = repository.data.tasks.single.toJson();
    await exportFile(tester);
    expect(find.textContaining('Could not save attachment.'), findsOneWidget);
    expect(repository.data.tasks.single.toJson(), before);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    picker.write = () async => Uri(scheme: 'fixture', path: 'saved');
    await exportFile(tester);
    expect(picker.saveCalls, 2);
    expect(picker.savedName, 'kept.bin');
    expect(picker.savedBytes, [1, 2, 3]);
    expect(find.text('Attachment saved'), findsOneWidget);
    expect(repository.saveCalls, 0);
    expect(repository.data.tasks.single.toJson(), before);
  });
}

final class _MemoryFile extends PlatformFile {
  _MemoryFile(this.name, this.chunks, {this.readError});

  @override
  final String name;
  final List<Uint8List> chunks;
  final Object? readError;

  @override
  Uri get uri => Uri(scheme: 'fixture', path: name);

  @override
  Never get xFile => throw UnsupportedError('Fixture supplies a byte stream.');

  @override
  int lengthSync() => chunks.fold(0, (total, chunk) => total + chunk.length);

  @override
  Future<int> length() async => lengthSync();

  @override
  Future<Uint8List> readAsBytes() async =>
      Uint8List.fromList([for (final chunk in chunks) ...chunk]);

  @override
  Stream<Uint8List> readAsByteStream() async* {
    for (final chunk in chunks) {
      yield chunk;
    }
    if (readError case final error?) throw error;
  }
}

final class _Picker extends FilePickerPlatform {
  Future<PlatformFile?> Function() choose = () async => null;
  Future<Uri?> Function() write = () async =>
      Uri(scheme: 'fixture', path: 'saved');
  int pickCalls = 0;
  int saveCalls = 0;
  String? savedName;
  String? savedDialogTitle;
  Uint8List? savedBytes;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    void Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) {
    pickCalls++;
    return choose();
  }

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    void Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) {
    saveCalls++;
    savedName = fileName;
    savedBytes = Uint8List.fromList(bytes);
    savedDialogTitle = dialogTitle;
    return write();
  }
}

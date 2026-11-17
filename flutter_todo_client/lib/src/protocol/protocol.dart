/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'background/background_photo.dart' as _i2;
import 'todo/todo_attachment.dart' as _i3;
import 'todo/todo_exception.dart' as _i4;
import 'todo/todo_group.dart' as _i5;
import 'todo/todo_list.dart' as _i6;
import 'todo/todo_settings.dart' as _i7;
import 'todo/todo_snapshot.dart' as _i8;
import 'todo/todo_step.dart' as _i9;
import 'todo/todo_task.dart' as _i10;
export 'background/background_photo.dart';
export 'todo/todo_attachment.dart';
export 'todo/todo_exception.dart';
export 'todo/todo_group.dart';
export 'todo/todo_list.dart';
export 'todo/todo_settings.dart';
export 'todo/todo_snapshot.dart';
export 'todo/todo_step.dart';
export 'todo/todo_task.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.BackgroundPhoto) {
      return _i2.BackgroundPhoto.fromJson(data) as T;
    }
    if (t == _i3.TodoAttachment) {
      return _i3.TodoAttachment.fromJson(data) as T;
    }
    if (t == _i4.TodoException) {
      return _i4.TodoException.fromJson(data) as T;
    }
    if (t == _i5.TodoGroup) {
      return _i5.TodoGroup.fromJson(data) as T;
    }
    if (t == _i6.TodoList) {
      return _i6.TodoList.fromJson(data) as T;
    }
    if (t == _i7.TodoSettings) {
      return _i7.TodoSettings.fromJson(data) as T;
    }
    if (t == _i8.TodoSnapshot) {
      return _i8.TodoSnapshot.fromJson(data) as T;
    }
    if (t == _i9.TodoStep) {
      return _i9.TodoStep.fromJson(data) as T;
    }
    if (t == _i10.TodoTask) {
      return _i10.TodoTask.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.BackgroundPhoto?>()) {
      return (data != null ? _i2.BackgroundPhoto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.TodoAttachment?>()) {
      return (data != null ? _i3.TodoAttachment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.TodoException?>()) {
      return (data != null ? _i4.TodoException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.TodoGroup?>()) {
      return (data != null ? _i5.TodoGroup.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.TodoList?>()) {
      return (data != null ? _i6.TodoList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.TodoSettings?>()) {
      return (data != null ? _i7.TodoSettings.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.TodoSnapshot?>()) {
      return (data != null ? _i8.TodoSnapshot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.TodoStep?>()) {
      return (data != null ? _i9.TodoStep.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.TodoTask?>()) {
      return (data != null ? _i10.TodoTask.fromJson(data) : null) as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == List<_i10.TodoTask>) {
      return (data as List).map((e) => deserialize<_i10.TodoTask>(e)).toList()
          as T;
    }
    if (t == List<_i6.TodoList>) {
      return (data as List).map((e) => deserialize<_i6.TodoList>(e)).toList()
          as T;
    }
    if (t == List<_i5.TodoGroup>) {
      return (data as List).map((e) => deserialize<_i5.TodoGroup>(e)).toList()
          as T;
    }
    if (t == List<_i9.TodoStep>) {
      return (data as List).map((e) => deserialize<_i9.TodoStep>(e)).toList()
          as T;
    }
    if (t == List<_i3.TodoAttachment>) {
      return (data as List)
              .map((e) => deserialize<_i3.TodoAttachment>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.BackgroundPhoto => 'BackgroundPhoto',
      _i3.TodoAttachment => 'TodoAttachment',
      _i4.TodoException => 'TodoException',
      _i5.TodoGroup => 'TodoGroup',
      _i6.TodoList => 'TodoList',
      _i7.TodoSettings => 'TodoSettings',
      _i8.TodoSnapshot => 'TodoSnapshot',
      _i9.TodoStep => 'TodoStep',
      _i10.TodoTask => 'TodoTask',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'flutter_todo.',
        '',
      );
    }

    switch (data) {
      case _i2.BackgroundPhoto():
        return 'BackgroundPhoto';
      case _i3.TodoAttachment():
        return 'TodoAttachment';
      case _i4.TodoException():
        return 'TodoException';
      case _i5.TodoGroup():
        return 'TodoGroup';
      case _i6.TodoList():
        return 'TodoList';
      case _i7.TodoSettings():
        return 'TodoSettings';
      case _i8.TodoSnapshot():
        return 'TodoSnapshot';
      case _i9.TodoStep():
        return 'TodoStep';
      case _i10.TodoTask():
        return 'TodoTask';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'BackgroundPhoto') {
      return deserialize<_i2.BackgroundPhoto>(data['data']);
    }
    if (dataClassName == 'TodoAttachment') {
      return deserialize<_i3.TodoAttachment>(data['data']);
    }
    if (dataClassName == 'TodoException') {
      return deserialize<_i4.TodoException>(data['data']);
    }
    if (dataClassName == 'TodoGroup') {
      return deserialize<_i5.TodoGroup>(data['data']);
    }
    if (dataClassName == 'TodoList') {
      return deserialize<_i6.TodoList>(data['data']);
    }
    if (dataClassName == 'TodoSettings') {
      return deserialize<_i7.TodoSettings>(data['data']);
    }
    if (dataClassName == 'TodoSnapshot') {
      return deserialize<_i8.TodoSnapshot>(data['data']);
    }
    if (dataClassName == 'TodoStep') {
      return deserialize<_i9.TodoStep>(data['data']);
    }
    if (dataClassName == 'TodoTask') {
      return deserialize<_i10.TodoTask>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}

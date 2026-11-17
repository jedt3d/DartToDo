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
import '../todo/todo_step.dart' as _i2;
import '../todo/todo_attachment.dart' as _i3;
import 'package:flutter_todo_client/src/protocol/protocol.dart' as _i4;

abstract class TodoTask implements _i1.SerializableModel {
  TodoTask._({
    this.id,
    required this.title,
    required this.listId,
    bool? completed,
    bool? important,
    this.myDay,
    this.dueDate,
    this.reminder,
    String? repeat,
    int? repeatEvery,
    String? notes,
    int? position,
    DateTime? createdAt,
    this.completedAt,
    bool? deleted,
    required this.steps,
    required this.attachments,
  }) : completed = completed ?? false,
       important = important ?? false,
       repeat = repeat ?? 'none',
       repeatEvery = repeatEvery ?? 1,
       notes = notes ?? '',
       position = position ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       deleted = deleted ?? false;

  factory TodoTask({
    int? id,
    required String title,
    required int listId,
    bool? completed,
    bool? important,
    String? myDay,
    String? dueDate,
    DateTime? reminder,
    String? repeat,
    int? repeatEvery,
    String? notes,
    int? position,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? deleted,
    required List<_i2.TodoStep> steps,
    required List<_i3.TodoAttachment> attachments,
  }) = _TodoTaskImpl;

  factory TodoTask.fromJson(Map<String, dynamic> jsonSerialization) {
    return TodoTask(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      listId: jsonSerialization['listId'] as int,
      completed: jsonSerialization['completed'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['completed']),
      important: jsonSerialization['important'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['important']),
      myDay: jsonSerialization['myDay'] as String?,
      dueDate: jsonSerialization['dueDate'] as String?,
      reminder: jsonSerialization['reminder'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['reminder']),
      repeat: jsonSerialization['repeat'] as String?,
      repeatEvery: jsonSerialization['repeatEvery'] as int?,
      notes: jsonSerialization['notes'] as String?,
      position: jsonSerialization['position'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      deleted: jsonSerialization['deleted'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
      steps: _i4.Protocol().deserialize<List<_i2.TodoStep>>(
        jsonSerialization['steps'],
      ),
      attachments: _i4.Protocol().deserialize<List<_i3.TodoAttachment>>(
        jsonSerialization['attachments'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String title;

  int listId;

  bool completed;

  bool important;

  String? myDay;

  String? dueDate;

  DateTime? reminder;

  String repeat;

  int repeatEvery;

  String notes;

  int position;

  DateTime createdAt;

  DateTime? completedAt;

  bool deleted;

  List<_i2.TodoStep> steps;

  List<_i3.TodoAttachment> attachments;

  /// Returns a shallow copy of this [TodoTask]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TodoTask copyWith({
    int? id,
    String? title,
    int? listId,
    bool? completed,
    bool? important,
    String? myDay,
    String? dueDate,
    DateTime? reminder,
    String? repeat,
    int? repeatEvery,
    String? notes,
    int? position,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? deleted,
    List<_i2.TodoStep>? steps,
    List<_i3.TodoAttachment>? attachments,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TodoTask',
      if (id != null) 'id': id,
      'title': title,
      'listId': listId,
      'completed': completed,
      'important': important,
      if (myDay != null) 'myDay': myDay,
      if (dueDate != null) 'dueDate': dueDate,
      if (reminder != null) 'reminder': reminder?.toJson(),
      'repeat': repeat,
      'repeatEvery': repeatEvery,
      'notes': notes,
      'position': position,
      'createdAt': createdAt.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'deleted': deleted,
      'steps': steps.toJson(valueToJson: (v) => v.toJson()),
      'attachments': attachments.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TodoTaskImpl extends TodoTask {
  _TodoTaskImpl({
    int? id,
    required String title,
    required int listId,
    bool? completed,
    bool? important,
    String? myDay,
    String? dueDate,
    DateTime? reminder,
    String? repeat,
    int? repeatEvery,
    String? notes,
    int? position,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? deleted,
    required List<_i2.TodoStep> steps,
    required List<_i3.TodoAttachment> attachments,
  }) : super._(
         id: id,
         title: title,
         listId: listId,
         completed: completed,
         important: important,
         myDay: myDay,
         dueDate: dueDate,
         reminder: reminder,
         repeat: repeat,
         repeatEvery: repeatEvery,
         notes: notes,
         position: position,
         createdAt: createdAt,
         completedAt: completedAt,
         deleted: deleted,
         steps: steps,
         attachments: attachments,
       );

  /// Returns a shallow copy of this [TodoTask]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TodoTask copyWith({
    Object? id = _Undefined,
    String? title,
    int? listId,
    bool? completed,
    bool? important,
    Object? myDay = _Undefined,
    Object? dueDate = _Undefined,
    Object? reminder = _Undefined,
    String? repeat,
    int? repeatEvery,
    String? notes,
    int? position,
    DateTime? createdAt,
    Object? completedAt = _Undefined,
    bool? deleted,
    List<_i2.TodoStep>? steps,
    List<_i3.TodoAttachment>? attachments,
  }) {
    return TodoTask(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      listId: listId ?? this.listId,
      completed: completed ?? this.completed,
      important: important ?? this.important,
      myDay: myDay is String? ? myDay : this.myDay,
      dueDate: dueDate is String? ? dueDate : this.dueDate,
      reminder: reminder is DateTime? ? reminder : this.reminder,
      repeat: repeat ?? this.repeat,
      repeatEvery: repeatEvery ?? this.repeatEvery,
      notes: notes ?? this.notes,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      deleted: deleted ?? this.deleted,
      steps: steps ?? this.steps.map((e0) => e0.copyWith()).toList(),
      attachments:
          attachments ?? this.attachments.map((e0) => e0.copyWith()).toList(),
    );
  }
}

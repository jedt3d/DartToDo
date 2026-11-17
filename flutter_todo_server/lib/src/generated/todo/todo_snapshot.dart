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

import 'package:serverpod/serverpod.dart' as _i1;
import '../todo/todo_task.dart' as _i2;
import '../todo/todo_list.dart' as _i3;
import '../todo/todo_group.dart' as _i4;
import '../todo/todo_settings.dart' as _i5;
import 'package:flutter_todo_server/src/generated/protocol.dart' as _i6;

abstract class TodoSnapshot
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  TodoSnapshot._({
    required this.tasks,
    required this.lists,
    required this.groups,
    required this.settings,
  });

  factory TodoSnapshot({
    required List<_i2.TodoTask> tasks,
    required List<_i3.TodoList> lists,
    required List<_i4.TodoGroup> groups,
    required _i5.TodoSettings settings,
  }) = _TodoSnapshotImpl;

  factory TodoSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return TodoSnapshot(
      tasks: _i6.Protocol().deserialize<List<_i2.TodoTask>>(
        jsonSerialization['tasks'],
      ),
      lists: _i6.Protocol().deserialize<List<_i3.TodoList>>(
        jsonSerialization['lists'],
      ),
      groups: _i6.Protocol().deserialize<List<_i4.TodoGroup>>(
        jsonSerialization['groups'],
      ),
      settings: _i6.Protocol().deserialize<_i5.TodoSettings>(
        jsonSerialization['settings'],
      ),
    );
  }

  List<_i2.TodoTask> tasks;

  List<_i3.TodoList> lists;

  List<_i4.TodoGroup> groups;

  _i5.TodoSettings settings;

  /// Returns a shallow copy of this [TodoSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TodoSnapshot copyWith({
    List<_i2.TodoTask>? tasks,
    List<_i3.TodoList>? lists,
    List<_i4.TodoGroup>? groups,
    _i5.TodoSettings? settings,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TodoSnapshot',
      'tasks': tasks.toJson(valueToJson: (v) => v.toJson()),
      'lists': lists.toJson(valueToJson: (v) => v.toJson()),
      'groups': groups.toJson(valueToJson: (v) => v.toJson()),
      'settings': settings.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TodoSnapshot',
      'tasks': tasks.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'lists': lists.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'groups': groups.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'settings': settings.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TodoSnapshotImpl extends TodoSnapshot {
  _TodoSnapshotImpl({
    required List<_i2.TodoTask> tasks,
    required List<_i3.TodoList> lists,
    required List<_i4.TodoGroup> groups,
    required _i5.TodoSettings settings,
  }) : super._(
         tasks: tasks,
         lists: lists,
         groups: groups,
         settings: settings,
       );

  /// Returns a shallow copy of this [TodoSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TodoSnapshot copyWith({
    List<_i2.TodoTask>? tasks,
    List<_i3.TodoList>? lists,
    List<_i4.TodoGroup>? groups,
    _i5.TodoSettings? settings,
  }) {
    return TodoSnapshot(
      tasks: tasks ?? this.tasks.map((e0) => e0.copyWith()).toList(),
      lists: lists ?? this.lists.map((e0) => e0.copyWith()).toList(),
      groups: groups ?? this.groups.map((e0) => e0.copyWith()).toList(),
      settings: settings ?? this.settings.copyWith(),
    );
  }
}

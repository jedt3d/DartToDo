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

abstract class TodoList implements _i1.SerializableModel {
  TodoList._({
    this.id,
    required this.title,
    this.groupId,
    String? theme,
    int? position,
    bool? deleted,
  }) : theme = theme ?? 'blue',
       position = position ?? 0,
       deleted = deleted ?? false;

  factory TodoList({
    int? id,
    required String title,
    int? groupId,
    String? theme,
    int? position,
    bool? deleted,
  }) = _TodoListImpl;

  factory TodoList.fromJson(Map<String, dynamic> jsonSerialization) {
    return TodoList(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      groupId: jsonSerialization['groupId'] as int?,
      theme: jsonSerialization['theme'] as String?,
      position: jsonSerialization['position'] as int?,
      deleted: jsonSerialization['deleted'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String title;

  int? groupId;

  String theme;

  int position;

  bool deleted;

  /// Returns a shallow copy of this [TodoList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TodoList copyWith({
    int? id,
    String? title,
    int? groupId,
    String? theme,
    int? position,
    bool? deleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TodoList',
      if (id != null) 'id': id,
      'title': title,
      if (groupId != null) 'groupId': groupId,
      'theme': theme,
      'position': position,
      'deleted': deleted,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TodoListImpl extends TodoList {
  _TodoListImpl({
    int? id,
    required String title,
    int? groupId,
    String? theme,
    int? position,
    bool? deleted,
  }) : super._(
         id: id,
         title: title,
         groupId: groupId,
         theme: theme,
         position: position,
         deleted: deleted,
       );

  /// Returns a shallow copy of this [TodoList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TodoList copyWith({
    Object? id = _Undefined,
    String? title,
    Object? groupId = _Undefined,
    String? theme,
    int? position,
    bool? deleted,
  }) {
    return TodoList(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      groupId: groupId is int? ? groupId : this.groupId,
      theme: theme ?? this.theme,
      position: position ?? this.position,
      deleted: deleted ?? this.deleted,
    );
  }
}

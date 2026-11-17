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

abstract class TodoGroup implements _i1.SerializableModel {
  TodoGroup._({
    this.id,
    required this.title,
    int? position,
    bool? deleted,
  }) : position = position ?? 0,
       deleted = deleted ?? false;

  factory TodoGroup({
    int? id,
    required String title,
    int? position,
    bool? deleted,
  }) = _TodoGroupImpl;

  factory TodoGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return TodoGroup(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
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

  int position;

  bool deleted;

  /// Returns a shallow copy of this [TodoGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TodoGroup copyWith({
    int? id,
    String? title,
    int? position,
    bool? deleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TodoGroup',
      if (id != null) 'id': id,
      'title': title,
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

class _TodoGroupImpl extends TodoGroup {
  _TodoGroupImpl({
    int? id,
    required String title,
    int? position,
    bool? deleted,
  }) : super._(
         id: id,
         title: title,
         position: position,
         deleted: deleted,
       );

  /// Returns a shallow copy of this [TodoGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TodoGroup copyWith({
    Object? id = _Undefined,
    String? title,
    int? position,
    bool? deleted,
  }) {
    return TodoGroup(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      position: position ?? this.position,
      deleted: deleted ?? this.deleted,
    );
  }
}

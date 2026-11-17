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

abstract class TodoAttachment implements _i1.SerializableModel {
  TodoAttachment._({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.dataBase64,
  });

  factory TodoAttachment({
    required String id,
    required String name,
    required String mimeType,
    required String dataBase64,
  }) = _TodoAttachmentImpl;

  factory TodoAttachment.fromJson(Map<String, dynamic> jsonSerialization) {
    return TodoAttachment(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      mimeType: jsonSerialization['mimeType'] as String,
      dataBase64: jsonSerialization['dataBase64'] as String,
    );
  }

  String id;

  String name;

  String mimeType;

  String dataBase64;

  /// Returns a shallow copy of this [TodoAttachment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TodoAttachment copyWith({
    String? id,
    String? name,
    String? mimeType,
    String? dataBase64,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TodoAttachment',
      'id': id,
      'name': name,
      'mimeType': mimeType,
      'dataBase64': dataBase64,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TodoAttachmentImpl extends TodoAttachment {
  _TodoAttachmentImpl({
    required String id,
    required String name,
    required String mimeType,
    required String dataBase64,
  }) : super._(
         id: id,
         name: name,
         mimeType: mimeType,
         dataBase64: dataBase64,
       );

  /// Returns a shallow copy of this [TodoAttachment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TodoAttachment copyWith({
    String? id,
    String? name,
    String? mimeType,
    String? dataBase64,
  }) {
    return TodoAttachment(
      id: id ?? this.id,
      name: name ?? this.name,
      mimeType: mimeType ?? this.mimeType,
      dataBase64: dataBase64 ?? this.dataBase64,
    );
  }
}

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

abstract class TodoStep
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  TodoStep._({
    required this.id,
    required this.title,
    bool? completed,
  }) : completed = completed ?? false;

  factory TodoStep({
    required String id,
    required String title,
    bool? completed,
  }) = _TodoStepImpl;

  factory TodoStep.fromJson(Map<String, dynamic> jsonSerialization) {
    return TodoStep(
      id: jsonSerialization['id'] as String,
      title: jsonSerialization['title'] as String,
      completed: jsonSerialization['completed'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['completed']),
    );
  }

  String id;

  String title;

  bool completed;

  /// Returns a shallow copy of this [TodoStep]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TodoStep copyWith({
    String? id,
    String? title,
    bool? completed,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TodoStep',
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TodoStep',
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TodoStepImpl extends TodoStep {
  _TodoStepImpl({
    required String id,
    required String title,
    bool? completed,
  }) : super._(
         id: id,
         title: title,
         completed: completed,
       );

  /// Returns a shallow copy of this [TodoStep]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TodoStep copyWith({
    String? id,
    String? title,
    bool? completed,
  }) {
    return TodoStep(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

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
import 'package:flutter_todo_client/src/protocol/protocol.dart' as _i2;

abstract class TodoSettings implements _i1.SerializableModel {
  TodoSettings._({
    this.id,
    String? displayName,
    bool? darkMode,
    bool? showCompleted,
    bool? confirmDelete,
    bool? weekStartsMonday,
    bool? completionSound,
    required this.smartThemes,
    String? sortOrder,
    bool? sortDescending,
  }) : displayName = displayName ?? 'Local user',
       darkMode = darkMode ?? false,
       showCompleted = showCompleted ?? true,
       confirmDelete = confirmDelete ?? true,
       weekStartsMonday = weekStartsMonday ?? true,
       completionSound = completionSound ?? true,
       sortOrder = sortOrder ?? 'manual',
       sortDescending = sortDescending ?? false;

  factory TodoSettings({
    int? id,
    String? displayName,
    bool? darkMode,
    bool? showCompleted,
    bool? confirmDelete,
    bool? weekStartsMonday,
    bool? completionSound,
    required Map<String, String> smartThemes,
    String? sortOrder,
    bool? sortDescending,
  }) = _TodoSettingsImpl;

  factory TodoSettings.fromJson(Map<String, dynamic> jsonSerialization) {
    return TodoSettings(
      id: jsonSerialization['id'] as int?,
      displayName: jsonSerialization['displayName'] as String?,
      darkMode: jsonSerialization['darkMode'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['darkMode']),
      showCompleted: jsonSerialization['showCompleted'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['showCompleted']),
      confirmDelete: jsonSerialization['confirmDelete'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['confirmDelete']),
      weekStartsMonday: jsonSerialization['weekStartsMonday'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['weekStartsMonday'],
            ),
      completionSound: jsonSerialization['completionSound'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['completionSound'],
            ),
      smartThemes: _i2.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['smartThemes'],
      ),
      sortOrder: jsonSerialization['sortOrder'] as String?,
      sortDescending: jsonSerialization['sortDescending'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['sortDescending']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String displayName;

  bool darkMode;

  bool showCompleted;

  bool confirmDelete;

  bool weekStartsMonday;

  bool completionSound;

  Map<String, String> smartThemes;

  String sortOrder;

  bool sortDescending;

  /// Returns a shallow copy of this [TodoSettings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TodoSettings copyWith({
    int? id,
    String? displayName,
    bool? darkMode,
    bool? showCompleted,
    bool? confirmDelete,
    bool? weekStartsMonday,
    bool? completionSound,
    Map<String, String>? smartThemes,
    String? sortOrder,
    bool? sortDescending,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TodoSettings',
      if (id != null) 'id': id,
      'displayName': displayName,
      'darkMode': darkMode,
      'showCompleted': showCompleted,
      'confirmDelete': confirmDelete,
      'weekStartsMonday': weekStartsMonday,
      'completionSound': completionSound,
      'smartThemes': smartThemes.toJson(),
      'sortOrder': sortOrder,
      'sortDescending': sortDescending,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TodoSettingsImpl extends TodoSettings {
  _TodoSettingsImpl({
    int? id,
    String? displayName,
    bool? darkMode,
    bool? showCompleted,
    bool? confirmDelete,
    bool? weekStartsMonday,
    bool? completionSound,
    required Map<String, String> smartThemes,
    String? sortOrder,
    bool? sortDescending,
  }) : super._(
         id: id,
         displayName: displayName,
         darkMode: darkMode,
         showCompleted: showCompleted,
         confirmDelete: confirmDelete,
         weekStartsMonday: weekStartsMonday,
         completionSound: completionSound,
         smartThemes: smartThemes,
         sortOrder: sortOrder,
         sortDescending: sortDescending,
       );

  /// Returns a shallow copy of this [TodoSettings]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TodoSettings copyWith({
    Object? id = _Undefined,
    String? displayName,
    bool? darkMode,
    bool? showCompleted,
    bool? confirmDelete,
    bool? weekStartsMonday,
    bool? completionSound,
    Map<String, String>? smartThemes,
    String? sortOrder,
    bool? sortDescending,
  }) {
    return TodoSettings(
      id: id is int? ? id : this.id,
      displayName: displayName ?? this.displayName,
      darkMode: darkMode ?? this.darkMode,
      showCompleted: showCompleted ?? this.showCompleted,
      confirmDelete: confirmDelete ?? this.confirmDelete,
      weekStartsMonday: weekStartsMonday ?? this.weekStartsMonday,
      completionSound: completionSound ?? this.completionSound,
      smartThemes:
          smartThemes ??
          this.smartThemes.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
      sortOrder: sortOrder ?? this.sortOrder,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }
}

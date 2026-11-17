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
import 'package:serverpod/protocol.dart' as _i2;
import 'background/background_photo.dart' as _i3;
import 'todo/todo_attachment.dart' as _i4;
import 'todo/todo_exception.dart' as _i5;
import 'todo/todo_group.dart' as _i6;
import 'todo/todo_list.dart' as _i7;
import 'todo/todo_settings.dart' as _i8;
import 'todo/todo_snapshot.dart' as _i9;
import 'todo/todo_step.dart' as _i10;
import 'todo/todo_task.dart' as _i11;
export 'background/background_photo.dart';
export 'todo/todo_attachment.dart';
export 'todo/todo_exception.dart';
export 'todo/todo_group.dart';
export 'todo/todo_list.dart';
export 'todo/todo_settings.dart';
export 'todo/todo_snapshot.dart';
export 'todo/todo_step.dart';
export 'todo/todo_task.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'todo_group',
      dartName: 'TodoGroup',
      schema: 'public',
      module: 'flutter_todo',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'todo_group_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'position',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _i2.ColumnDefinition(
          name: 'deleted',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'todo_group_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'todo_list',
      dartName: 'TodoList',
      schema: 'public',
      module: 'flutter_todo',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'todo_list_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'groupId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'theme',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'blue\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'position',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _i2.ColumnDefinition(
          name: 'deleted',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'todo_list_fk_0',
          columns: ['groupId'],
          referenceTable: 'todo_group',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'todo_list_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'todo_settings',
      dartName: 'TodoSettings',
      schema: 'public',
      module: 'flutter_todo',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'todo_settings_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'displayName',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'Local user\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'darkMode',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'showCompleted',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'confirmDelete',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'weekStartsMonday',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'completionSound',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'smartThemes',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'Map<String,String>',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'manual\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'sortDescending',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'todo_settings_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'todo_task',
      dartName: 'TodoTask',
      schema: 'public',
      module: 'flutter_todo',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'todo_task_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'listId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'completed',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'important',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'myDay',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'dueDate',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'reminder',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'repeat',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'none\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'repeatEvery',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _i2.ColumnDefinition(
          name: 'notes',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'position',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'completedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'deleted',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'steps',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:TodoStep>',
        ),
        _i2.ColumnDefinition(
          name: 'attachments',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:TodoAttachment>',
        ),
        _i2.ColumnDefinition(
          name: 'nextOccurrenceId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'todo_task_fk_0',
          columns: ['listId'],
          referenceTable: 'todo_list',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'todo_task_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'todo_task_list_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'listId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i2.Protocol.targetTableDefinitions,
  ];

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

    if (t == _i3.BackgroundPhoto) {
      return _i3.BackgroundPhoto.fromJson(data) as T;
    }
    if (t == _i4.TodoAttachment) {
      return _i4.TodoAttachment.fromJson(data) as T;
    }
    if (t == _i5.TodoException) {
      return _i5.TodoException.fromJson(data) as T;
    }
    if (t == _i6.TodoGroup) {
      return _i6.TodoGroup.fromJson(data) as T;
    }
    if (t == _i7.TodoList) {
      return _i7.TodoList.fromJson(data) as T;
    }
    if (t == _i8.TodoSettings) {
      return _i8.TodoSettings.fromJson(data) as T;
    }
    if (t == _i9.TodoSnapshot) {
      return _i9.TodoSnapshot.fromJson(data) as T;
    }
    if (t == _i10.TodoStep) {
      return _i10.TodoStep.fromJson(data) as T;
    }
    if (t == _i11.TodoTask) {
      return _i11.TodoTask.fromJson(data) as T;
    }
    if (t == _i1.getType<_i3.BackgroundPhoto?>()) {
      return (data != null ? _i3.BackgroundPhoto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.TodoAttachment?>()) {
      return (data != null ? _i4.TodoAttachment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.TodoException?>()) {
      return (data != null ? _i5.TodoException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.TodoGroup?>()) {
      return (data != null ? _i6.TodoGroup.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.TodoList?>()) {
      return (data != null ? _i7.TodoList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.TodoSettings?>()) {
      return (data != null ? _i8.TodoSettings.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.TodoSnapshot?>()) {
      return (data != null ? _i9.TodoSnapshot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.TodoStep?>()) {
      return (data != null ? _i10.TodoStep.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.TodoTask?>()) {
      return (data != null ? _i11.TodoTask.fromJson(data) : null) as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == List<_i11.TodoTask>) {
      return (data as List).map((e) => deserialize<_i11.TodoTask>(e)).toList()
          as T;
    }
    if (t == List<_i7.TodoList>) {
      return (data as List).map((e) => deserialize<_i7.TodoList>(e)).toList()
          as T;
    }
    if (t == List<_i6.TodoGroup>) {
      return (data as List).map((e) => deserialize<_i6.TodoGroup>(e)).toList()
          as T;
    }
    if (t == List<_i10.TodoStep>) {
      return (data as List).map((e) => deserialize<_i10.TodoStep>(e)).toList()
          as T;
    }
    if (t == List<_i4.TodoAttachment>) {
      return (data as List)
              .map((e) => deserialize<_i4.TodoAttachment>(e))
              .toList()
          as T;
    }
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i3.BackgroundPhoto => 'BackgroundPhoto',
      _i4.TodoAttachment => 'TodoAttachment',
      _i5.TodoException => 'TodoException',
      _i6.TodoGroup => 'TodoGroup',
      _i7.TodoList => 'TodoList',
      _i8.TodoSettings => 'TodoSettings',
      _i9.TodoSnapshot => 'TodoSnapshot',
      _i10.TodoStep => 'TodoStep',
      _i11.TodoTask => 'TodoTask',
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
      case _i3.BackgroundPhoto():
        return 'BackgroundPhoto';
      case _i4.TodoAttachment():
        return 'TodoAttachment';
      case _i5.TodoException():
        return 'TodoException';
      case _i6.TodoGroup():
        return 'TodoGroup';
      case _i7.TodoList():
        return 'TodoList';
      case _i8.TodoSettings():
        return 'TodoSettings';
      case _i9.TodoSnapshot():
        return 'TodoSnapshot';
      case _i10.TodoStep():
        return 'TodoStep';
      case _i11.TodoTask():
        return 'TodoTask';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
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
      return deserialize<_i3.BackgroundPhoto>(data['data']);
    }
    if (dataClassName == 'TodoAttachment') {
      return deserialize<_i4.TodoAttachment>(data['data']);
    }
    if (dataClassName == 'TodoException') {
      return deserialize<_i5.TodoException>(data['data']);
    }
    if (dataClassName == 'TodoGroup') {
      return deserialize<_i6.TodoGroup>(data['data']);
    }
    if (dataClassName == 'TodoList') {
      return deserialize<_i7.TodoList>(data['data']);
    }
    if (dataClassName == 'TodoSettings') {
      return deserialize<_i8.TodoSettings>(data['data']);
    }
    if (dataClassName == 'TodoSnapshot') {
      return deserialize<_i9.TodoSnapshot>(data['data']);
    }
    if (dataClassName == 'TodoStep') {
      return deserialize<_i10.TodoStep>(data['data']);
    }
    if (dataClassName == 'TodoTask') {
      return deserialize<_i11.TodoTask>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i6.TodoGroup:
        return _i6.TodoGroup.t;
      case _i7.TodoList:
        return _i7.TodoList.t;
      case _i8.TodoSettings:
        return _i8.TodoSettings.t;
      case _i11.TodoTask:
        return _i11.TodoTask.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'flutter_todo';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i2.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}

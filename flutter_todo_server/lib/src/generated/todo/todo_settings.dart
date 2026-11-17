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
import 'package:flutter_todo_server/src/generated/protocol.dart' as _i2;

abstract class TodoSettings
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = TodoSettingsTable();

  static const db = TodoSettingsRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static TodoSettingsInclude include() {
    return TodoSettingsInclude._();
  }

  static TodoSettingsIncludeList includeList({
    _i1.WhereExpressionBuilder<TodoSettingsTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TodoSettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TodoSettingsTable>? orderByList,
    TodoSettingsInclude? include,
  }) {
    return TodoSettingsIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TodoSettings.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(TodoSettings.t),
      include: include,
    );
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

class TodoSettingsUpdateTable extends _i1.UpdateTable<TodoSettingsTable> {
  TodoSettingsUpdateTable(super.table);

  _i1.ColumnValue<String, String> displayName(String value) => _i1.ColumnValue(
    table.displayName,
    value,
  );

  _i1.ColumnValue<bool, bool> darkMode(bool value) => _i1.ColumnValue(
    table.darkMode,
    value,
  );

  _i1.ColumnValue<bool, bool> showCompleted(bool value) => _i1.ColumnValue(
    table.showCompleted,
    value,
  );

  _i1.ColumnValue<bool, bool> confirmDelete(bool value) => _i1.ColumnValue(
    table.confirmDelete,
    value,
  );

  _i1.ColumnValue<bool, bool> weekStartsMonday(bool value) => _i1.ColumnValue(
    table.weekStartsMonday,
    value,
  );

  _i1.ColumnValue<bool, bool> completionSound(bool value) => _i1.ColumnValue(
    table.completionSound,
    value,
  );

  _i1.ColumnValue<Map<String, String>, Map<String, String>> smartThemes(
    Map<String, String> value,
  ) => _i1.ColumnValue(
    table.smartThemes,
    value,
  );

  _i1.ColumnValue<String, String> sortOrder(String value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );

  _i1.ColumnValue<bool, bool> sortDescending(bool value) => _i1.ColumnValue(
    table.sortDescending,
    value,
  );
}

class TodoSettingsTable extends _i1.Table<int?> {
  TodoSettingsTable({super.tableRelation}) : super(tableName: 'todo_settings') {
    updateTable = TodoSettingsUpdateTable(this);
    displayName = _i1.ColumnString(
      'displayName',
      this,
      hasDefault: true,
    );
    darkMode = _i1.ColumnBool(
      'darkMode',
      this,
      hasDefault: true,
    );
    showCompleted = _i1.ColumnBool(
      'showCompleted',
      this,
      hasDefault: true,
    );
    confirmDelete = _i1.ColumnBool(
      'confirmDelete',
      this,
      hasDefault: true,
    );
    weekStartsMonday = _i1.ColumnBool(
      'weekStartsMonday',
      this,
      hasDefault: true,
    );
    completionSound = _i1.ColumnBool(
      'completionSound',
      this,
      hasDefault: true,
    );
    smartThemes = _i1.ColumnSerializable<Map<String, String>>(
      'smartThemes',
      this,
    );
    sortOrder = _i1.ColumnString(
      'sortOrder',
      this,
      hasDefault: true,
    );
    sortDescending = _i1.ColumnBool(
      'sortDescending',
      this,
      hasDefault: true,
    );
  }

  late final TodoSettingsUpdateTable updateTable;

  late final _i1.ColumnString displayName;

  late final _i1.ColumnBool darkMode;

  late final _i1.ColumnBool showCompleted;

  late final _i1.ColumnBool confirmDelete;

  late final _i1.ColumnBool weekStartsMonday;

  late final _i1.ColumnBool completionSound;

  late final _i1.ColumnSerializable<Map<String, String>> smartThemes;

  late final _i1.ColumnString sortOrder;

  late final _i1.ColumnBool sortDescending;

  @override
  List<_i1.Column> get columns => [
    id,
    displayName,
    darkMode,
    showCompleted,
    confirmDelete,
    weekStartsMonday,
    completionSound,
    smartThemes,
    sortOrder,
    sortDescending,
  ];
}

class TodoSettingsInclude extends _i1.IncludeObject {
  TodoSettingsInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => TodoSettings.t;
}

class TodoSettingsIncludeList extends _i1.IncludeList {
  TodoSettingsIncludeList._({
    _i1.WhereExpressionBuilder<TodoSettingsTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TodoSettings.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => TodoSettings.t;
}

class TodoSettingsRepository {
  const TodoSettingsRepository._();

  /// Returns a list of [TodoSettings]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<TodoSettings>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TodoSettingsTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TodoSettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TodoSettingsTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TodoSettings>(
      where: where?.call(TodoSettings.t),
      orderBy: orderBy?.call(TodoSettings.t),
      orderByList: orderByList?.call(TodoSettings.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TodoSettings] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<TodoSettings?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TodoSettingsTable>? where,
    int? offset,
    _i1.OrderByBuilder<TodoSettingsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TodoSettingsTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TodoSettings>(
      where: where?.call(TodoSettings.t),
      orderBy: orderBy?.call(TodoSettings.t),
      orderByList: orderByList?.call(TodoSettings.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TodoSettings] by its [id] or null if no such row exists.
  Future<TodoSettings?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TodoSettings>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TodoSettings]s in the list and returns the inserted rows.
  ///
  /// The returned [TodoSettings]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<TodoSettings>> insert(
    _i1.DatabaseSession session,
    List<TodoSettings> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<TodoSettings>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [TodoSettings] and returns the inserted row.
  ///
  /// The returned [TodoSettings] will have its `id` field set.
  Future<TodoSettings> insertRow(
    _i1.DatabaseSession session,
    TodoSettings row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<TodoSettings>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [TodoSettings]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<TodoSettings>> update(
    _i1.DatabaseSession session,
    List<TodoSettings> rows, {
    _i1.ColumnSelections<TodoSettingsTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<TodoSettings>(
      rows,
      columns: columns?.call(TodoSettings.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TodoSettings]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TodoSettings> updateRow(
    _i1.DatabaseSession session,
    TodoSettings row, {
    _i1.ColumnSelections<TodoSettingsTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<TodoSettings>(
      row,
      columns: columns?.call(TodoSettings.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TodoSettings] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TodoSettings?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<TodoSettingsUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<TodoSettings>(
      id,
      columnValues: columnValues(TodoSettings.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TodoSettings]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<TodoSettings>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<TodoSettingsUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<TodoSettingsTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TodoSettingsTable>? orderBy,
    _i1.OrderByListBuilder<TodoSettingsTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<TodoSettings>(
      columnValues: columnValues(TodoSettings.t.updateTable),
      where: where(TodoSettings.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TodoSettings.t),
      orderByList: orderByList?.call(TodoSettings.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [TodoSettings]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<TodoSettings>> delete(
    _i1.DatabaseSession session,
    List<TodoSettings> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<TodoSettings>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [TodoSettings].
  Future<TodoSettings> deleteRow(
    _i1.DatabaseSession session,
    TodoSettings row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TodoSettings>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<TodoSettings>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<TodoSettingsTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<TodoSettings>(
      where: where(TodoSettings.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TodoSettingsTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<TodoSettings>(
      where: where?.call(TodoSettings.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TodoSettings] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<TodoSettingsTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TodoSettings>(
      where: where(TodoSettings.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

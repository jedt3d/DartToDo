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

abstract class TodoList
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = TodoListTable();

  static const db = TodoListRepository._();

  @override
  int? id;

  String title;

  int? groupId;

  String theme;

  int position;

  bool deleted;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static TodoListInclude include() {
    return TodoListInclude._();
  }

  static TodoListIncludeList includeList({
    _i1.WhereExpressionBuilder<TodoListTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TodoListTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TodoListTable>? orderByList,
    TodoListInclude? include,
  }) {
    return TodoListIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TodoList.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(TodoList.t),
      include: include,
    );
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

class TodoListUpdateTable extends _i1.UpdateTable<TodoListTable> {
  TodoListUpdateTable(super.table);

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<int, int> groupId(int? value) => _i1.ColumnValue(
    table.groupId,
    value,
  );

  _i1.ColumnValue<String, String> theme(String value) => _i1.ColumnValue(
    table.theme,
    value,
  );

  _i1.ColumnValue<int, int> position(int value) => _i1.ColumnValue(
    table.position,
    value,
  );

  _i1.ColumnValue<bool, bool> deleted(bool value) => _i1.ColumnValue(
    table.deleted,
    value,
  );
}

class TodoListTable extends _i1.Table<int?> {
  TodoListTable({super.tableRelation}) : super(tableName: 'todo_list') {
    updateTable = TodoListUpdateTable(this);
    title = _i1.ColumnString(
      'title',
      this,
    );
    groupId = _i1.ColumnInt(
      'groupId',
      this,
    );
    theme = _i1.ColumnString(
      'theme',
      this,
      hasDefault: true,
    );
    position = _i1.ColumnInt(
      'position',
      this,
      hasDefault: true,
    );
    deleted = _i1.ColumnBool(
      'deleted',
      this,
      hasDefault: true,
    );
  }

  late final TodoListUpdateTable updateTable;

  late final _i1.ColumnString title;

  late final _i1.ColumnInt groupId;

  late final _i1.ColumnString theme;

  late final _i1.ColumnInt position;

  late final _i1.ColumnBool deleted;

  @override
  List<_i1.Column> get columns => [
    id,
    title,
    groupId,
    theme,
    position,
    deleted,
  ];
}

class TodoListInclude extends _i1.IncludeObject {
  TodoListInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => TodoList.t;
}

class TodoListIncludeList extends _i1.IncludeList {
  TodoListIncludeList._({
    _i1.WhereExpressionBuilder<TodoListTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TodoList.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => TodoList.t;
}

class TodoListRepository {
  const TodoListRepository._();

  /// Returns a list of [TodoList]s matching the given query parameters.
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
  Future<List<TodoList>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TodoListTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TodoListTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TodoListTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TodoList>(
      where: where?.call(TodoList.t),
      orderBy: orderBy?.call(TodoList.t),
      orderByList: orderByList?.call(TodoList.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TodoList] matching the given query parameters.
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
  Future<TodoList?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TodoListTable>? where,
    int? offset,
    _i1.OrderByBuilder<TodoListTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TodoListTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TodoList>(
      where: where?.call(TodoList.t),
      orderBy: orderBy?.call(TodoList.t),
      orderByList: orderByList?.call(TodoList.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TodoList] by its [id] or null if no such row exists.
  Future<TodoList?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TodoList>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TodoList]s in the list and returns the inserted rows.
  ///
  /// The returned [TodoList]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<TodoList>> insert(
    _i1.DatabaseSession session,
    List<TodoList> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<TodoList>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [TodoList] and returns the inserted row.
  ///
  /// The returned [TodoList] will have its `id` field set.
  Future<TodoList> insertRow(
    _i1.DatabaseSession session,
    TodoList row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<TodoList>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [TodoList]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<TodoList>> update(
    _i1.DatabaseSession session,
    List<TodoList> rows, {
    _i1.ColumnSelections<TodoListTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<TodoList>(
      rows,
      columns: columns?.call(TodoList.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TodoList]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TodoList> updateRow(
    _i1.DatabaseSession session,
    TodoList row, {
    _i1.ColumnSelections<TodoListTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<TodoList>(
      row,
      columns: columns?.call(TodoList.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TodoList] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TodoList?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<TodoListUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<TodoList>(
      id,
      columnValues: columnValues(TodoList.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TodoList]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<TodoList>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<TodoListUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<TodoListTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TodoListTable>? orderBy,
    _i1.OrderByListBuilder<TodoListTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<TodoList>(
      columnValues: columnValues(TodoList.t.updateTable),
      where: where(TodoList.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TodoList.t),
      orderByList: orderByList?.call(TodoList.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [TodoList]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<TodoList>> delete(
    _i1.DatabaseSession session,
    List<TodoList> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<TodoList>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [TodoList].
  Future<TodoList> deleteRow(
    _i1.DatabaseSession session,
    TodoList row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TodoList>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<TodoList>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<TodoListTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<TodoList>(
      where: where(TodoList.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TodoListTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<TodoList>(
      where: where?.call(TodoList.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TodoList] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<TodoListTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TodoList>(
      where: where(TodoList.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

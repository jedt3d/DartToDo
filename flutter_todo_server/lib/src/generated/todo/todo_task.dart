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
import '../todo/todo_step.dart' as _i2;
import '../todo/todo_attachment.dart' as _i3;
import 'package:flutter_todo_server/src/generated/protocol.dart' as _i4;

abstract class TodoTask
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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
    this.nextOccurrenceId,
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
    int? nextOccurrenceId,
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
      nextOccurrenceId: jsonSerialization['nextOccurrenceId'] as int?,
    );
  }

  static final t = TodoTaskTable();

  static const db = TodoTaskRepository._();

  @override
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

  int? nextOccurrenceId;

  @override
  _i1.Table<int?> get table => t;

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
    int? nextOccurrenceId,
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
      if (nextOccurrenceId != null) 'nextOccurrenceId': nextOccurrenceId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
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
      'steps': steps.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'attachments': attachments.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  static TodoTaskInclude include() {
    return TodoTaskInclude._();
  }

  static TodoTaskIncludeList includeList({
    _i1.WhereExpressionBuilder<TodoTaskTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TodoTaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TodoTaskTable>? orderByList,
    TodoTaskInclude? include,
  }) {
    return TodoTaskIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TodoTask.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(TodoTask.t),
      include: include,
    );
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
    int? nextOccurrenceId,
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
         nextOccurrenceId: nextOccurrenceId,
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
    Object? nextOccurrenceId = _Undefined,
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
      nextOccurrenceId: nextOccurrenceId is int?
          ? nextOccurrenceId
          : this.nextOccurrenceId,
    );
  }
}

class TodoTaskUpdateTable extends _i1.UpdateTable<TodoTaskTable> {
  TodoTaskUpdateTable(super.table);

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<int, int> listId(int value) => _i1.ColumnValue(
    table.listId,
    value,
  );

  _i1.ColumnValue<bool, bool> completed(bool value) => _i1.ColumnValue(
    table.completed,
    value,
  );

  _i1.ColumnValue<bool, bool> important(bool value) => _i1.ColumnValue(
    table.important,
    value,
  );

  _i1.ColumnValue<String, String> myDay(String? value) => _i1.ColumnValue(
    table.myDay,
    value,
  );

  _i1.ColumnValue<String, String> dueDate(String? value) => _i1.ColumnValue(
    table.dueDate,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> reminder(DateTime? value) =>
      _i1.ColumnValue(
        table.reminder,
        value,
      );

  _i1.ColumnValue<String, String> repeat(String value) => _i1.ColumnValue(
    table.repeat,
    value,
  );

  _i1.ColumnValue<int, int> repeatEvery(int value) => _i1.ColumnValue(
    table.repeatEvery,
    value,
  );

  _i1.ColumnValue<String, String> notes(String value) => _i1.ColumnValue(
    table.notes,
    value,
  );

  _i1.ColumnValue<int, int> position(int value) => _i1.ColumnValue(
    table.position,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.completedAt,
        value,
      );

  _i1.ColumnValue<bool, bool> deleted(bool value) => _i1.ColumnValue(
    table.deleted,
    value,
  );

  _i1.ColumnValue<List<_i2.TodoStep>, List<_i2.TodoStep>> steps(
    List<_i2.TodoStep> value,
  ) => _i1.ColumnValue(
    table.steps,
    value,
  );

  _i1.ColumnValue<List<_i3.TodoAttachment>, List<_i3.TodoAttachment>>
  attachments(List<_i3.TodoAttachment> value) => _i1.ColumnValue(
    table.attachments,
    value,
  );

  _i1.ColumnValue<int, int> nextOccurrenceId(int? value) => _i1.ColumnValue(
    table.nextOccurrenceId,
    value,
  );
}

class TodoTaskTable extends _i1.Table<int?> {
  TodoTaskTable({super.tableRelation}) : super(tableName: 'todo_task') {
    updateTable = TodoTaskUpdateTable(this);
    title = _i1.ColumnString(
      'title',
      this,
    );
    listId = _i1.ColumnInt(
      'listId',
      this,
    );
    completed = _i1.ColumnBool(
      'completed',
      this,
      hasDefault: true,
    );
    important = _i1.ColumnBool(
      'important',
      this,
      hasDefault: true,
    );
    myDay = _i1.ColumnString(
      'myDay',
      this,
    );
    dueDate = _i1.ColumnString(
      'dueDate',
      this,
    );
    reminder = _i1.ColumnDateTime(
      'reminder',
      this,
    );
    repeat = _i1.ColumnString(
      'repeat',
      this,
      hasDefault: true,
    );
    repeatEvery = _i1.ColumnInt(
      'repeatEvery',
      this,
      hasDefault: true,
    );
    notes = _i1.ColumnString(
      'notes',
      this,
      hasDefault: true,
    );
    position = _i1.ColumnInt(
      'position',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    completedAt = _i1.ColumnDateTime(
      'completedAt',
      this,
    );
    deleted = _i1.ColumnBool(
      'deleted',
      this,
      hasDefault: true,
    );
    steps = _i1.ColumnSerializable<List<_i2.TodoStep>>(
      'steps',
      this,
    );
    attachments = _i1.ColumnSerializable<List<_i3.TodoAttachment>>(
      'attachments',
      this,
    );
    nextOccurrenceId = _i1.ColumnInt(
      'nextOccurrenceId',
      this,
    );
  }

  late final TodoTaskUpdateTable updateTable;

  late final _i1.ColumnString title;

  late final _i1.ColumnInt listId;

  late final _i1.ColumnBool completed;

  late final _i1.ColumnBool important;

  late final _i1.ColumnString myDay;

  late final _i1.ColumnString dueDate;

  late final _i1.ColumnDateTime reminder;

  late final _i1.ColumnString repeat;

  late final _i1.ColumnInt repeatEvery;

  late final _i1.ColumnString notes;

  late final _i1.ColumnInt position;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime completedAt;

  late final _i1.ColumnBool deleted;

  late final _i1.ColumnSerializable<List<_i2.TodoStep>> steps;

  late final _i1.ColumnSerializable<List<_i3.TodoAttachment>> attachments;

  late final _i1.ColumnInt nextOccurrenceId;

  @override
  List<_i1.Column> get columns => [
    id,
    title,
    listId,
    completed,
    important,
    myDay,
    dueDate,
    reminder,
    repeat,
    repeatEvery,
    notes,
    position,
    createdAt,
    completedAt,
    deleted,
    steps,
    attachments,
    nextOccurrenceId,
  ];
}

class TodoTaskInclude extends _i1.IncludeObject {
  TodoTaskInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => TodoTask.t;
}

class TodoTaskIncludeList extends _i1.IncludeList {
  TodoTaskIncludeList._({
    _i1.WhereExpressionBuilder<TodoTaskTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TodoTask.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => TodoTask.t;
}

class TodoTaskRepository {
  const TodoTaskRepository._();

  /// Returns a list of [TodoTask]s matching the given query parameters.
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
  Future<List<TodoTask>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TodoTaskTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TodoTaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TodoTaskTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TodoTask>(
      where: where?.call(TodoTask.t),
      orderBy: orderBy?.call(TodoTask.t),
      orderByList: orderByList?.call(TodoTask.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TodoTask] matching the given query parameters.
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
  Future<TodoTask?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TodoTaskTable>? where,
    int? offset,
    _i1.OrderByBuilder<TodoTaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TodoTaskTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TodoTask>(
      where: where?.call(TodoTask.t),
      orderBy: orderBy?.call(TodoTask.t),
      orderByList: orderByList?.call(TodoTask.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TodoTask] by its [id] or null if no such row exists.
  Future<TodoTask?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TodoTask>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TodoTask]s in the list and returns the inserted rows.
  ///
  /// The returned [TodoTask]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<TodoTask>> insert(
    _i1.DatabaseSession session,
    List<TodoTask> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<TodoTask>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [TodoTask] and returns the inserted row.
  ///
  /// The returned [TodoTask] will have its `id` field set.
  Future<TodoTask> insertRow(
    _i1.DatabaseSession session,
    TodoTask row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<TodoTask>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [TodoTask]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<TodoTask>> update(
    _i1.DatabaseSession session,
    List<TodoTask> rows, {
    _i1.ColumnSelections<TodoTaskTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<TodoTask>(
      rows,
      columns: columns?.call(TodoTask.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TodoTask]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TodoTask> updateRow(
    _i1.DatabaseSession session,
    TodoTask row, {
    _i1.ColumnSelections<TodoTaskTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<TodoTask>(
      row,
      columns: columns?.call(TodoTask.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TodoTask] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TodoTask?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<TodoTaskUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<TodoTask>(
      id,
      columnValues: columnValues(TodoTask.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TodoTask]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<TodoTask>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<TodoTaskUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<TodoTaskTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TodoTaskTable>? orderBy,
    _i1.OrderByListBuilder<TodoTaskTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<TodoTask>(
      columnValues: columnValues(TodoTask.t.updateTable),
      where: where(TodoTask.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TodoTask.t),
      orderByList: orderByList?.call(TodoTask.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [TodoTask]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<TodoTask>> delete(
    _i1.DatabaseSession session,
    List<TodoTask> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<TodoTask>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [TodoTask].
  Future<TodoTask> deleteRow(
    _i1.DatabaseSession session,
    TodoTask row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TodoTask>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<TodoTask>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<TodoTaskTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<TodoTask>(
      where: where(TodoTask.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TodoTaskTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<TodoTask>(
      where: where?.call(TodoTask.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TodoTask] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<TodoTaskTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TodoTask>(
      where: where(TodoTask.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

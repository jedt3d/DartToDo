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
import 'dart:async' as _i2;
import 'package:flutter_todo_client/src/protocol/background/background_photo.dart'
    as _i3;
import 'package:flutter_todo_client/src/protocol/todo/todo_snapshot.dart'
    as _i4;
import 'package:flutter_todo_client/src/protocol/todo/todo_task.dart' as _i5;
import 'package:flutter_todo_client/src/protocol/todo/todo_list.dart' as _i6;
import 'package:flutter_todo_client/src/protocol/todo/todo_group.dart' as _i7;
import 'package:flutter_todo_client/src/protocol/todo/todo_settings.dart'
    as _i8;
import 'protocol.dart' as _i9;

/// Optional public-photo metadata; it has no access to task contents.
/// {@category Endpoint}
class EndpointBackground extends _i1.EndpointRef {
  EndpointBackground(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'background';

  _i2.Future<_i3.BackgroundPhoto?> featured({String? previousId}) =>
      caller.callServerEndpoint<_i3.BackgroundPhoto?>(
        'background',
        'featured',
        {'previousId': previousId},
      );
}

/// Persistent task operations for the one local OS user.
///
/// A database advisory transaction lock makes compound operations, including
/// recurrence and list deletion, atomic across desktop and simulator clients.
/// {@category Endpoint}
class EndpointTodo extends _i1.EndpointRef {
  EndpointTodo(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'todo';

  _i2.Future<_i4.TodoSnapshot> fetch() =>
      caller.callServerEndpoint<_i4.TodoSnapshot>(
        'todo',
        'fetch',
        {},
      );

  _i2.Future<_i5.TodoTask> saveTask(_i5.TodoTask task) =>
      caller.callServerEndpoint<_i5.TodoTask>(
        'todo',
        'saveTask',
        {'task': task},
      );

  _i2.Future<_i4.TodoSnapshot> completeTask(
    int id,
    bool completed,
    String localDate,
  ) => caller.callServerEndpoint<_i4.TodoSnapshot>(
    'todo',
    'completeTask',
    {
      'id': id,
      'completed': completed,
      'localDate': localDate,
    },
  );

  _i2.Future<_i4.TodoSnapshot> deleteTask(int id) =>
      caller.callServerEndpoint<_i4.TodoSnapshot>(
        'todo',
        'deleteTask',
        {'id': id},
      );

  _i2.Future<_i4.TodoSnapshot> restoreTask(int id) =>
      caller.callServerEndpoint<_i4.TodoSnapshot>(
        'todo',
        'restoreTask',
        {'id': id},
      );

  _i2.Future<_i6.TodoList> saveList(_i6.TodoList list) =>
      caller.callServerEndpoint<_i6.TodoList>(
        'todo',
        'saveList',
        {'list': list},
      );

  _i2.Future<_i4.TodoSnapshot> deleteList(int id) =>
      caller.callServerEndpoint<_i4.TodoSnapshot>(
        'todo',
        'deleteList',
        {'id': id},
      );

  _i2.Future<_i4.TodoSnapshot> restoreList(int id) =>
      caller.callServerEndpoint<_i4.TodoSnapshot>(
        'todo',
        'restoreList',
        {'id': id},
      );

  _i2.Future<_i7.TodoGroup> saveGroup(_i7.TodoGroup group) =>
      caller.callServerEndpoint<_i7.TodoGroup>(
        'todo',
        'saveGroup',
        {'group': group},
      );

  _i2.Future<_i4.TodoSnapshot> deleteGroup(int id) =>
      caller.callServerEndpoint<_i4.TodoSnapshot>(
        'todo',
        'deleteGroup',
        {'id': id},
      );

  _i2.Future<_i8.TodoSettings> saveSettings(_i8.TodoSettings settings) =>
      caller.callServerEndpoint<_i8.TodoSettings>(
        'todo',
        'saveSettings',
        {'settings': settings},
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i9.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    background = EndpointBackground(this);
    todo = EndpointTodo(this);
  }

  late final EndpointBackground background;

  late final EndpointTodo todo;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'background': background,
    'todo': todo,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}

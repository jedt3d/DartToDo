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
import '../background/background_endpoint.dart' as _i2;
import '../todo/todo_endpoint.dart' as _i3;
import 'package:flutter_todo_server/src/generated/todo/todo_task.dart' as _i4;
import 'package:flutter_todo_server/src/generated/todo/todo_list.dart' as _i5;
import 'package:flutter_todo_server/src/generated/todo/todo_group.dart' as _i6;
import 'package:flutter_todo_server/src/generated/todo/todo_settings.dart'
    as _i7;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'background': _i2.BackgroundEndpoint()
        ..initialize(
          server,
          'background',
          null,
        ),
      'todo': _i3.TodoEndpoint()
        ..initialize(
          server,
          'todo',
          null,
        ),
    };
    connectors['background'] = _i1.EndpointConnector(
      name: 'background',
      endpoint: endpoints['background']!,
      methodConnectors: {
        'featured': _i1.MethodConnector(
          name: 'featured',
          params: {
            'previousId': _i1.ParameterDescription(
              name: 'previousId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['background'] as _i2.BackgroundEndpoint).featured(
                    session,
                    previousId: params['previousId'],
                  ),
        ),
      },
    );
    connectors['todo'] = _i1.EndpointConnector(
      name: 'todo',
      endpoint: endpoints['todo']!,
      methodConnectors: {
        'fetch': _i1.MethodConnector(
          name: 'fetch',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['todo'] as _i3.TodoEndpoint).fetch(session),
        ),
        'saveTask': _i1.MethodConnector(
          name: 'saveTask',
          params: {
            'task': _i1.ParameterDescription(
              name: 'task',
              type: _i1.getType<_i4.TodoTask>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['todo'] as _i3.TodoEndpoint).saveTask(
                session,
                params['task'],
              ),
        ),
        'completeTask': _i1.MethodConnector(
          name: 'completeTask',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'completed': _i1.ParameterDescription(
              name: 'completed',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'localDate': _i1.ParameterDescription(
              name: 'localDate',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['todo'] as _i3.TodoEndpoint).completeTask(
                session,
                params['id'],
                params['completed'],
                params['localDate'],
              ),
        ),
        'deleteTask': _i1.MethodConnector(
          name: 'deleteTask',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['todo'] as _i3.TodoEndpoint).deleteTask(
                session,
                params['id'],
              ),
        ),
        'restoreTask': _i1.MethodConnector(
          name: 'restoreTask',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['todo'] as _i3.TodoEndpoint).restoreTask(
                session,
                params['id'],
              ),
        ),
        'saveList': _i1.MethodConnector(
          name: 'saveList',
          params: {
            'list': _i1.ParameterDescription(
              name: 'list',
              type: _i1.getType<_i5.TodoList>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['todo'] as _i3.TodoEndpoint).saveList(
                session,
                params['list'],
              ),
        ),
        'deleteList': _i1.MethodConnector(
          name: 'deleteList',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['todo'] as _i3.TodoEndpoint).deleteList(
                session,
                params['id'],
              ),
        ),
        'restoreList': _i1.MethodConnector(
          name: 'restoreList',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['todo'] as _i3.TodoEndpoint).restoreList(
                session,
                params['id'],
              ),
        ),
        'saveGroup': _i1.MethodConnector(
          name: 'saveGroup',
          params: {
            'group': _i1.ParameterDescription(
              name: 'group',
              type: _i1.getType<_i6.TodoGroup>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['todo'] as _i3.TodoEndpoint).saveGroup(
                session,
                params['group'],
              ),
        ),
        'deleteGroup': _i1.MethodConnector(
          name: 'deleteGroup',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['todo'] as _i3.TodoEndpoint).deleteGroup(
                session,
                params['id'],
              ),
        ),
        'saveSettings': _i1.MethodConnector(
          name: 'saveSettings',
          params: {
            'settings': _i1.ParameterDescription(
              name: 'settings',
              type: _i1.getType<_i7.TodoSettings>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['todo'] as _i3.TodoEndpoint).saveSettings(
                session,
                params['settings'],
              ),
        ),
      },
    );
  }
}

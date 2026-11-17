import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todo_client/flutter_todo_client.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/task_queries.dart';
import '../data/todo_controller.dart';
import '../data/todo_repository.dart';
import '../services/reminders.dart';
import '../services/backgrounds.dart';

part 'sidebar.dart';
part 'task_list.dart';
part 'task_details.dart';
part 'dialogs.dart';
part 'catalog_previews.dart';

const todoAccent = Color(0xff596bc2);
const todoColors = <String, Color>{
  'blue': Color(0xff6679c9),
  'purple': Color(0xff8064a2),
  'rose': Color(0xffb45476),
  'red': Color(0xffbd5756),
  'green': Color(0xff57876a),
  'teal': Color(0xff357e83),
  'grey': Color(0xff65757e),
};
const todoPhotos = <String>[
  'tv_tower',
  'beach',
  'desert',
  'fern',
  'field',
  'gradient',
  'lighthouse',
  'safari',
  'sea',
];

String _repeatLabel(TodoTask task) {
  if (task.repeat == 'none') return 'Repeat';
  if (task.repeatEvery > 1 || task.repeat == 'custom') {
    final unit = switch (task.repeat) {
      'weekly' => 'weeks',
      'monthly' => 'months',
      'yearly' => 'years',
      _ => 'days',
    };
    return 'Every ${task.repeatEvery} $unit';
  }
  return '${task.repeat[0].toUpperCase()}${task.repeat.substring(1)}';
}

/// The native single-user To Do application.
class TodoApp extends ConsumerWidget {
  const TodoApp({
    super.key,
    this.platformServices = true,
    this.reminderServiceFactory,
  });
  final ReminderService Function(ValueChanged<int>)? reminderServiceFactory;
  final bool platformServices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark =
        ref.watch(todoControllerProvider).value?.settings.darkMode ?? false;
    return MaterialApp(
      title: 'DartToDo',
      debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: _TodoHome(
        platformServices: platformServices,
        reminderServiceFactory: reminderServiceFactory,
      ),
    );
  }

  ThemeData _theme(Brightness brightness) => ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: todoAccent,
      brightness: brightness,
    ),
    useMaterial3: false,
    fontFamily: '.AppleSystemUIFont',
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xff202020)
        : Colors.white,
    splashFactory: NoSplash.splashFactory,
    dividerColor: brightness == Brightness.dark
        ? const Color(0xff414141)
        : const Color(0xffe4e4e4),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14),
      bodyLarge: TextStyle(fontSize: 14),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      isDense: true,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
    ),
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 500),
    ),
  );
}

class _TodoHome extends ConsumerStatefulWidget {
  const _TodoHome({this.platformServices = true, this.reminderServiceFactory});
  final ReminderService Function(ValueChanged<int>)? reminderServiceFactory;
  final bool platformServices;
  @override
  ConsumerState<_TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends ConsumerState<_TodoHome>
    with WidgetsBindingObserver {
  String _view = 'my-day';
  String _query = '';
  int? _selected;
  bool _suggestions = false;
  bool _mobileLists = false;
  bool _completedExpanded = true;
  final _detailKey = GlobalKey<_TaskDetailsState>();
  final _composerFocus = FocusNode();
  final _searchFocus = FocusNode();
  late final ReminderService _reminders;
  int? _pendingReminder;
  bool _openingReminder = false;
  bool _autoDetails = true;
  bool _iPadLandscape = false;
  Timer? _refreshTimer;
  String? _platformWarning;
  BackgroundSelection? _featured;
  String? _myDayThemeOverride;
  TodoController get _controller => ref.read(todoControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _reminders =
        widget.reminderServiceFactory?.call(_openReminderTask) ??
        ReminderService(onTaskSelected: _openReminderTask);
    WidgetsBinding.instance.addObserver(this);
    if (widget.platformServices) {
      unawaited(_loadBackground());
      unawaited(
        _reminders.initialize().catchError((Object error) {
          if (mounted) {
            setState(() => _platformWarning = 'Reminders unavailable: $error');
          }
        }),
      );
      _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        if (mounted && ref.read(mutationStatusProvider).pending == 0) {
          unawaited(_controller.refresh().catchError((Object _) {}));
          setState(() {});
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.sizeOf(context);
    final landscape =
        Theme.of(context).platform == TargetPlatform.iOS &&
        size.shortestSide >= 600 &&
        size.width > size.height;
    if (landscape && !_iPadLandscape) _autoDetails = true;
    _iPadLandscape = landscape;
  }

  void _openReminderTask(int taskId) {
    _pendingReminder = taskId;
    unawaited(_showPendingReminder());
  }

  Future<void> _showPendingReminder() async {
    if (!mounted || _openingReminder || _pendingReminder == null) return;
    if (ref.read(todoControllerProvider).value == null) return;
    _openingReminder = true;
    final id = _pendingReminder;
    try {
      if (!await _flushDetails() || !mounted) return;
      final task = ref
          .read(todoControllerProvider)
          .value
          ?.tasks
          .where((task) => task.id == id && !task.deleted)
          .firstOrNull;
      if (_pendingReminder != id) return;
      _pendingReminder = null;
      if (task == null) {
        _message('This reminder’s task is no longer available.');
        return;
      }
      FocusScope.of(context).unfocus();
      setState(() {
        _view = task.listId == 1 ? 'inbox' : 'list:${task.listId}';
        _query = '';
        _selected = task.id;
        _mobileLists = false;
        _suggestions = false;
        _autoDetails = true;
      });
    } finally {
      _openingReminder = false;
      if (mounted && _pendingReminder != null && _pendingReminder != id) {
        unawaited(_showPendingReminder());
      }
    }
  }

  Future<void> _moveTask(int taskId, int listId) async {
    if (!await _flushDetails() || !mounted) return;
    if (await _run(_controller.moveTask(taskId, listId)) && mounted) {
      setState(() {
        _view = listId == 1 ? 'inbox' : 'list:$listId';
        _query = '';
        _selected = taskId;
        _mobileLists = false;
        _suggestions = false;
      });
    }
  }

  Future<void> _loadBackground() async {
    final photo = await BackgroundService().load(
      onCached: (cached) {
        if (mounted) setState(() => _featured = cached);
      },
    );
    if (mounted && photo != null) setState(() => _featured = photo);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_flushDetails());
    }
    if (state == AppLifecycleState.resumed) {
      unawaited(
        _controller
            .refresh()
            .then((_) => _showPendingReminder())
            .catchError((Object _) {}),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _reminders.dispose();
    _composerFocus.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<bool> _run(Future<dynamic> action) async {
    try {
      await action;
      return true;
    } catch (error) {
      if (mounted) _message('Could not save. $error');
      return false;
    }
  }

  Future<bool> _flushDetails() async =>
      await _detailKey.currentState?._saveText() ?? true;

  Future<void> _navigate(String view) async {
    if (!await _flushDetails() || !mounted) return;
    setState(() {
      _view = view;
      _autoDetails = true;
      _query = '';
      _selected = null;
      _mobileLists = false;
      _suggestions = false;
    });
  }

  Future<void> _selectTask(TodoTask task) async {
    if (!await _flushDetails()) return;
    if (mounted) {
      FocusScope.of(context).unfocus();
      setState(() {
        _selected = task.id;
        _suggestions = false;
      });
    }
  }

  Future<void> _dismissPanels() async {
    if (!await _flushDetails() || !mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _selected = null;
      _autoDetails = false;
      _suggestions = false;
      _mobileLists = false;
      _query = '';
    });
  }

  Future<void> _focusSearch() async {
    if (!await _flushDetails() || !mounted) return;
    setState(() => _mobileLists = true);
    _searchFocus.requestFocus();
  }

  Future<void> _search(String value) async {
    final selected = _selected;
    setState(() => _query = value);
    if (!await _flushDetails() || !mounted || _selected != selected) return;
    setState(() => _selected = null);
  }

  Future<void> _toggleSuggestions() async {
    if (!await _flushDetails() || !mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _suggestions = !_suggestions;
      _selected = null;
    });
  }

  Future<String?> _nameDialog(String title, {String value = ''}) =>
      showDialog<String>(
        context: context,
        builder: (_) => _NameDialog(title: title, value: value),
      );

  Future<void> _newList(TodoSnapshot data, {int? groupId}) async {
    final title = await _nameDialog('New list');
    if (title == null) return;
    try {
      final list = await _controller.saveList(
        TodoList(title: title, groupId: groupId, position: data.lists.length),
      );
      if (mounted) await _navigate('list:${list.id}');
    } catch (error) {
      if (mounted) _message('Could not create list. $error');
    }
  }

  Future<void> _newGroup(TodoSnapshot data) async {
    final title = await _nameDialog('New group');
    if (title != null) {
      await _run(
        _controller.saveGroup(
          TodoGroup(title: title, position: data.groups.length),
        ),
      );
    }
  }

  void _message(String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), action: action));
  }

  Future<bool> _confirm(
    String title,
    String message,
    TodoSettings settings,
  ) async {
    if (!settings.confirmDelete) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteTask(TodoTask task, TodoSettings settings) async {
    if (!await _confirm(
      'Delete task?',
      '“${task.title}” will be removed.',
      settings,
    )) {
      return;
    }
    if (await _run(_controller.deleteTask(task.id!)) && mounted) {
      setState(() => _selected = null);
      _message(
        'Task deleted',
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _run(_controller.restoreTask(task.id!)),
        ),
      );
    }
  }

  Future<void> _deleteList(TodoList list, TodoSnapshot data) async {
    if (!await _confirm(
      'Delete list?',
      '“${list.title}” and its tasks will be removed.',
      data.settings,
    )) {
      return;
    }
    if (await _run(_controller.deleteList(list.id!)) && mounted) {
      await _navigate('my-day');
      if (!mounted) return;
      _message(
        'List deleted',
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _run(_controller.restoreList(list.id!)),
        ),
      );
    }
  }

  Future<void> _chooseTheme(TodoSnapshot data, TodoList? list) async {
    final theme = await showDialog<String>(
      context: context,
      builder: (_) => _ThemeDialog(selected: _themeId(data, list)),
    );
    if (theme == null) return;
    if (_view == 'my-day' && list == null) {
      setState(() => _myDayThemeOverride = theme);
      return;
    }
    if (list != null) {
      await _run(_controller.saveList(list.copyWith(theme: theme)));
    } else {
      await _run(
        _controller.saveSettings(
          data.settings.copyWith(
            smartThemes: {...data.settings.smartThemes, _view: theme},
          ),
        ),
      );
    }
  }

  String _themeId(TodoSnapshot data, TodoList? list) => _view == 'my-day'
      ? _myDayThemeOverride ?? 'featured'
      : list?.theme ??
            data.settings.smartThemes[_view] ??
            switch (_view) {
              'important' => 'rose',
              'planned' => 'teal',
              _ => 'blue',
            };

  Future<void> _listAction(
    String action,
    TodoSnapshot data,
    TodoList? list,
  ) async {
    switch (action) {
      case 'theme':
        await _chooseTheme(data, list);
      case 'rename':
        if (list == null) return;
        final title = await _nameDialog('Rename list', value: list.title);
        if (title != null) {
          await _run(_controller.saveList(list.copyWith(title: title)));
        }
      case 'delete':
        if (list != null) await _deleteList(list, data);
      case 'duplicate':
        if (list == null) return;
        try {
          final copy = await _controller.saveList(
            TodoList(
              title: '${list.title} copy',
              theme: list.theme,
              position: data.lists.length,
            ),
          );
          for (final task in data.tasks.where(
            (t) => !t.deleted && t.listId == list.id,
          )) {
            await _controller.saveTask(
              task.copyWith(
                id: null,
                listId: copy.id!,
                completed: false,
                completedAt: null,
                myDay: null,
              ),
            );
          }
          if (mounted) await _navigate('list:${copy.id}');
        } catch (error) {
          if (mounted) _message('Could not duplicate list. $error');
        }
      case 'completed':
        await _run(
          _controller.saveSettings(
            data.settings.copyWith(showCompleted: !data.settings.showCompleted),
          ),
        );
      case 'copy':
        final tasks = filteredTasks(data, _view, query: _query);
        await Clipboard.setData(
          ClipboardData(
            text: tasks
                .map((t) => '${t.completed ? '[x]' : '[ ]'} ${t.title}')
                .join('\n'),
          ),
        );
        if (mounted) _message('List copied');
      case 'print':
        final tasks = filteredTasks(data, _view, query: _query);
        final body = tasks
            .map((task) => '${task.completed ? '[x]' : '[ ]'} ${task.title}')
            .join('\n');
        await _run(
          const MethodChannel('darttodo/native').invokeMethod<void>(
            'printList',
            {'title': list?.title ?? _view, 'body': body},
          ),
        );
      case 'refresh':
        await _run(_controller.refresh());
      default:
        if (action.startsWith('sort:')) {
          await _run(
            _controller.saveSettings(
              data.settings.copyWith(sortOrder: action.substring(5)),
            ),
          );
        }
        if (action == 'reverse') {
          await _run(
            _controller.saveSettings(
              data.settings.copyWith(
                sortDescending: !data.settings.sortDescending,
              ),
            ),
          );
        }
    }
  }

  Future<void> _reorder(
    List<TodoTask> tasks,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex--;
    final next = [...tasks];
    next.insert(newIndex, next.removeAt(oldIndex));
    for (var i = 0; i < next.length; i++) {
      final position = i;
      await _run(
        _controller.updateTask(
          next[i].id!,
          (current) => current.copyWith(position: position),
        ),
      );
    }
  }

  Future<void> _reorderList(TodoList list, int delta, TodoSnapshot data) async {
    final peers =
        data.lists
            .where((l) => !l.deleted && l.id != 1 && l.groupId == list.groupId)
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));
    final old = peers.indexWhere((l) => l.id == list.id);
    final next = old + delta;
    if (old < 0 || next < 0 || next >= peers.length) return;
    peers.insert(next, peers.removeAt(old));
    for (var i = 0; i < peers.length; i++) {
      if (peers[i].position != i) {
        await _run(_controller.saveList(peers[i].copyWith(position: i)));
      }
    }
  }

  Future<void> _reorderGroup(
    TodoGroup group,
    int delta,
    TodoSnapshot data,
  ) async {
    final peers = data.groups.where((g) => !g.deleted).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final old = peers.indexWhere((g) => g.id == group.id);
    final next = old + delta;
    if (old < 0 || next < 0 || next >= peers.length) return;
    peers.insert(next, peers.removeAt(old));
    for (var i = 0; i < peers.length; i++) {
      if (peers[i].position != i) {
        await _run(_controller.saveGroup(peers[i].copyWith(position: i)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(todoControllerProvider, (previous, next) {
      final data = next.value;
      if (data != null && _pendingReminder != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => unawaited(_showPendingReminder()),
        );
      }
      if (widget.platformServices && data != null) {
        unawaited(
          _reminders.sync(data.tasks).catchError((Object error) {
            if (mounted) setState(() => _platformWarning = 'Reminders: $error');
          }),
        );
      }
    });
    final state = ref.watch(todoControllerProvider);
    final mutation = ref.watch(mutationStatusProvider);
    final data = state.value;
    if (data == null) {
      return Scaffold(
        body: Center(
          child: state.isLoading
              ? const CircularProgressIndicator()
              : _FailurePage(
                  error: state.error.toString(),
                  retry: () => _run(_controller.refresh()),
                ),
        ),
      );
    }
    final listId = _view.startsWith('list:')
        ? int.tryParse(_view.substring(5))
        : _view == 'inbox'
        ? 1
        : null;
    final list = data.lists
        .where((l) => l.id == listId && !l.deleted)
        .firstOrNull;
    final title = _query.isNotEmpty
        ? 'Search'
        : list?.title ??
              switch (_view) {
                'my-day' => 'My Day',
                'important' => 'Important',
                'planned' => 'Planned',
                'all' => 'All',
                'completed' => 'Completed',
                _ => 'Tasks',
              };
    final sort =
        TaskSort.values
            .where((s) => s.name == data.settings.sortOrder)
            .firstOrNull ??
        TaskSort.manual;
    var tasks = filteredTasks(data, _view, query: _query, sort: sort);
    if (data.settings.sortDescending) tasks = tasks.reversed.toList();
    final storedSelection = data.tasks
        .where((t) => t.id == _selected && !t.deleted)
        .firstOrNull;
    final themeId = _themeId(data, list);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
            _composerFocus.requestFocus(),
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
            _focusSearch,
        const SingleActivator(LogicalKeyboardKey.keyD, meta: true): () =>
            _navigate('my-day'),
        const SingleActivator(LogicalKeyboardKey.comma, meta: true): () =>
            showDialog<void>(
              context: context,
              builder: (_) => _SettingsDialog(
                settings: data.settings,
                save: (settings) => _run(_controller.saveSettings(settings)),
              ),
            ),
        const SingleActivator(LogicalKeyboardKey.escape): _dismissPanels,
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= 720 &&
                MediaQuery.sizeOf(context).shortestSide >= 600;
            final threePane = wide && constraints.maxWidth >= 1050;
            final automatic =
                threePane &&
                _iPadLandscape &&
                _autoDetails &&
                !_suggestions &&
                _query.isEmpty &&
                !_searchFocus.hasFocus;
            final firstVisible =
                tasks.where((task) => !task.completed).firstOrNull ??
                ((_view == 'completed' ||
                        (data.settings.showCompleted && _completedExpanded))
                    ? tasks.firstOrNull
                    : null);
            final selected =
                storedSelection ?? (automatic ? firstVisible : null);
            if (automatic && selected != null && _selected != selected.id) {
              final view = _view;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted &&
                    _iPadLandscape &&
                    _autoDetails &&
                    _selected == null &&
                    _view == view &&
                    !_suggestions &&
                    _query.isEmpty) {
                  setState(() => _selected = selected.id);
                }
              });
            }
            final emptyDetail = automatic && selected == null;
            final showDetail = selected != null;
            final sidebar = _Sidebar(
              data: data,
              moveTask: (taskId, listId) =>
                  unawaited(_moveTask(taskId, listId)),
              reorderList: (list, delta) => _reorderList(list, delta, data),
              reorderGroup: (group, delta) => _reorderGroup(group, delta, data),
              selectedView: _view,
              query: _query,
              searchFocus: _searchFocus,
              navigate: _navigate,
              search: _search,
              submitSearch: () => setState(() => _mobileLists = false),
              newList: (groupId) => _newList(data, groupId: groupId),
              newGroup: () => _newGroup(data),
              settings: () => showDialog<void>(
                context: context,
                builder: (_) => _SettingsDialog(
                  settings: data.settings,
                  save: (settings) => _run(_controller.saveSettings(settings)),
                ),
              ),
              renameList: (list) async {
                final name = await _nameDialog(
                  'Rename list',
                  value: list.title,
                );
                if (name != null) {
                  await _run(
                    _controller.saveList(list.copyWith(title: name)),
                  );
                }
              },
              deleteList: (list) => _deleteList(list, data),
              saveList: (list) => _run(_controller.saveList(list)),
              renameGroup: (group) async {
                final name = await _nameDialog(
                  'Rename group',
                  value: group.title,
                );
                if (name != null) {
                  await _run(
                    _controller.saveGroup(group.copyWith(title: name)),
                  );
                }
              },
              ungroup: (group) => _run(_controller.deleteGroup(group.id!)),
            );
            final taskPane = _TaskPane(
              title: title,
              view: _view,
              query: _query,
              themeId: themeId,
              featured: _view == 'my-day' && themeId == 'featured'
                  ? _featured
                  : null,
              tasks: tasks,
              selectedId: selected?.id,
              revealLists: wide
                  ? null
                  : () => setState(() => _mobileLists = true),
              showCompleted:
                  _view == 'completed' || data.settings.showCompleted,
              expanded: _completedExpanded,
              toggleExpanded: () =>
                  setState(() => _completedExpanded = !_completedExpanded),
              sort: sort,
              sortDescending: data.settings.sortDescending,
              back: wide ? null : () => setState(() => _mobileLists = true),
              action: (action) => _listAction(action, data, list),
              isCustom: list != null && list.id != 1,
              suggestions: _view == 'my-day' ? _toggleSuggestions : null,
              select: _selectTask,
              complete: (task) async {
                if (await _run(_controller.completeTask(task)) &&
                    !task.completed &&
                    data.settings.completionSound &&
                    widget.platformServices) {
                  await SystemSound.play(SystemSoundType.click);
                }
              },
              important: (task) => _run(
                _controller.updateTask(
                  task.id!,
                  (current) => current.copyWith(important: !current.important),
                ),
              ),
              contextAction: (task, action) => _taskAction(task, action, data),
              add: (title) async {
                await _controller.createTask(
                  title,
                  listId: listId ?? 1,
                  myDay: _view == 'my-day',
                  important: _view == 'important',
                );
              },
              composerFocus: _composerFocus,
              reorder: sort == TaskSort.manual && _query.isEmpty
                  ? _reorder
                  : null,
            );
            final detail = selected == null
                ? null
                : _TaskDetails(
                    key: _detailKey,
                    backLabel: threePane ? null : title,
                    task: selected,
                    data: data,
                    close: () => setState(() {
                      _selected = null;
                      _autoDetails = false;
                    }),
                    update: (change) =>
                        _run(_controller.updateTask(selected.id!, change)),
                    complete: () => _run(_controller.completeTask(selected)),
                    delete: () => _deleteTask(selected, data.settings),
                    requestNotifications: widget.platformServices
                        ? _reminders.requestPermission
                        : null,
                  );
            final suggestions = _SuggestionsPanel(
              tasks: suggestedTasks(data),
              close: () => setState(() => _suggestions = false),
              add: (task) => _run(
                _controller.updateTask(
                  task.id!,
                  (current) =>
                      current.copyWith(myDay: localDateKey(DateTime.now())),
                ),
              ),
            );
            return Column(
              children: [
                if (mutation.pending > 0)
                  const LinearProgressIndicator(minHeight: 2),
                if (_platformWarning != null)
                  MaterialBanner(
                    content: Text(_platformWarning!, maxLines: 2),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            setState(() => _platformWarning = null),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                Expanded(
                  child: wide
                      ? Row(
                          children: [
                            SizedBox(width: 244, child: sidebar),
                            const VerticalDivider(width: 1, thickness: 1),
                            Expanded(
                              child: !threePane && showDetail
                                  ? detail!
                                  : !threePane && _suggestions
                                  ? suggestions
                                  : taskPane,
                            ),
                            if (threePane &&
                                (showDetail ||
                                    _suggestions ||
                                    emptyDetail)) ...[
                              const VerticalDivider(width: 1),
                              SizedBox(
                                width: 320,
                                child: showDetail
                                    ? detail
                                    : _suggestions
                                    ? suggestions
                                    : const _EmptyDetails(),
                              ),
                            ],
                          ],
                        )
                      : _mobileLists
                      ? sidebar
                      : showDetail
                      ? detail!
                      : _suggestions
                      ? suggestions
                      : taskPane,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _taskAction(
    TodoTask task,
    String action,
    TodoSnapshot data,
  ) async {
    switch (action) {
      case 'my-day':
        await _run(
          _controller.updateTask(
            task.id!,
            (current) => current.copyWith(
              myDay: current.myDay == localDateKey(DateTime.now())
                  ? null
                  : localDateKey(DateTime.now()),
            ),
          ),
        );
      case 'important':
        await _run(
          _controller.updateTask(
            task.id!,
            (current) => current.copyWith(important: !current.important),
          ),
        );
      case 'complete':
        await _run(_controller.completeTask(task));
      case 'delete':
        await _deleteTask(task, data.settings);
      case 'copy':
        await Clipboard.setData(ClipboardData(text: task.title));
      case 'duplicate':
        await _run(
          _controller.saveTask(
            task.copyWith(
              id: null,
              title: '${task.title} copy',
              completed: false,
              completedAt: null,
            ),
          ),
        );
      default:
        if (action.startsWith('move:')) {
          await _run(
            _controller.updateTask(
              task.id!,
              (current) =>
                  current.copyWith(listId: int.parse(action.substring(5))),
            ),
          );
        }
    }
  }
}

class _FailurePage extends StatelessWidget {
  const _FailurePage({required this.error, required this.retry});
  final String error;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          CupertinoIcons.wifi_exclamationmark,
          size: 40,
          color: todoAccent,
        ),
        const SizedBox(height: 20),
        const Text(
          'Couldn’t connect to your local server',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text('Start DartToDo’s Serverpod service, then try again.'),
        const SizedBox(height: 12),
        SelectableText(error, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 20),
        OutlinedButton(onPressed: retry, child: const Text('Try again')),
      ],
    ),
  );
}

class _EmptyDetails extends StatelessWidget {
  const _EmptyDetails();
  @override
  Widget build(BuildContext context) => Material(
    child: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.doc_text, size: 36, color: todoAccent),
              const SizedBox(height: 16),
              Text(
                'No task selected',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add a task to this list to see its details here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

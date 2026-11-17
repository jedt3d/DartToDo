// dnf:catalog-harness
part of 'todo_app.dart';

// These isolated fixtures never read the local user's database.
TodoSnapshot catalogFixture() => TodoSnapshot(
  tasks: [
    TodoTask(
      id: 1,
      title: 'Plan the week',
      listId: 1,
      important: true,
      myDay: localDateKey(DateTime.now()),
      dueDate: localDateKey(DateTime.now()),
      notes: 'Choose three things that matter.',
      createdAt: DateTime.utc(2026, 11, 17),
      steps: [
        TodoStep(id: 'first', title: 'Review the calendar'),
        TodoStep(id: 'second', title: 'Make a shortlist', completed: true),
      ],
      attachments: [
        TodoAttachment(
          id: 'file',
          name: 'readme.txt',
          mimeType: 'text/plain',
          dataBase64: 'SGVsbG8=',
        ),
      ],
    ),
    TodoTask(
      id: 2,
      title: 'Pick up groceries',
      listId: 2,
      notes: 'Apples and bread',
      createdAt: DateTime.utc(2026, 11, 16),
      steps: [],
      attachments: [],
    ),
    TodoTask(
      id: 3,
      title: 'Read a book',
      listId: 1,
      completed: true,
      myDay: localDateKey(DateTime.now()),
      createdAt: DateTime.utc(2026, 11, 15),
      completedAt: DateTime.utc(2026, 11, 17),
      steps: [],
      attachments: [],
    ),
  ],
  lists: [
    TodoList(id: 1, title: 'Tasks'),
    TodoList(id: 2, title: 'Personal', groupId: 1),
    TodoList(id: 3, title: 'Work'),
  ],
  groups: [TodoGroup(id: 1, title: 'Home')],
  settings: TodoSettings(
    smartThemes: {'my-day': 'blue'},
    displayName: 'Local user',
  ),
);

final class _CatalogRepository implements TodoRepository {
  _CatalogRepository({this.loading = false, this.failed = false})
    : data = catalogFixture();
  final bool loading, failed;
  TodoSnapshot data;
  @override
  Future<TodoSnapshot> fetch() async {
    if (loading) {
      return Completer<TodoSnapshot>().future;
    }
    if (failed) {
      throw StateError('The local service is stopped.');
    }
    return data.copyWith();
  }

  @override
  Future<TodoTask> saveTask(TodoTask task) async {
    final saved = task.copyWith(
      id:
          task.id ??
          data.tasks.fold<int>(0, (id, task) => task.id! > id ? task.id! : id) +
              1,
    );
    data = data.copyWith(
      tasks: [...data.tasks.where((task) => task.id != saved.id), saved],
    );
    return saved;
  }

  @override
  Future<TodoSnapshot> completeTask(
    int id,
    bool completed,
    String localDate,
  ) async {
    data = data.copyWith(
      tasks: [
        for (final task in data.tasks)
          task.id == id ? task.copyWith(completed: completed) : task,
      ],
    );
    return data;
  }

  @override
  Future<TodoSnapshot> deleteTask(int id) async {
    data = data.copyWith(
      tasks: [
        for (final task in data.tasks)
          task.id == id ? task.copyWith(deleted: true) : task,
      ],
    );
    return data;
  }

  @override
  Future<TodoSnapshot> restoreTask(int id) async {
    data = data.copyWith(
      tasks: [
        for (final task in data.tasks)
          task.id == id ? task.copyWith(deleted: false) : task,
      ],
    );
    return data;
  }

  @override
  Future<TodoList> saveList(TodoList list) async {
    final saved = list.copyWith(id: list.id ?? data.lists.length + 1);
    data = data.copyWith(
      lists: [...data.lists.where((list) => list.id != saved.id), saved],
    );
    return saved;
  }

  @override
  Future<TodoSnapshot> deleteList(int id) async {
    data = data.copyWith(
      lists: [
        for (final list in data.lists)
          list.id == id ? list.copyWith(deleted: true) : list,
      ],
    );
    return data;
  }

  @override
  Future<TodoSnapshot> restoreList(int id) async {
    data = data.copyWith(
      lists: [
        for (final list in data.lists)
          list.id == id ? list.copyWith(deleted: false) : list,
      ],
    );
    return data;
  }

  @override
  Future<TodoGroup> saveGroup(TodoGroup group) async {
    final saved = group.copyWith(id: group.id ?? data.groups.length + 1);
    data = data.copyWith(
      groups: [...data.groups.where((group) => group.id != saved.id), saved],
    );
    return saved;
  }

  @override
  Future<TodoSnapshot> deleteGroup(int id) async {
    data = data.copyWith(
      groups: data.groups.where((group) => group.id != id).toList(),
      lists: [
        for (final list in data.lists)
          list.groupId == id ? list.copyWith(groupId: null) : list,
      ],
    );
    return data;
  }

  @override
  Future<TodoSettings> saveSettings(TodoSettings settings) async {
    data = data.copyWith(settings: settings);
    return settings;
  }

  @override
  void close() {}
}

class _CatalogFrame extends StatefulWidget {
  const _CatalogFrame({
    required this.builder,
    this.width = 600,
    this.height = 680,
    this.dark = false,
  });
  final Widget Function(BuildContext, FocusNode) builder;
  final double width, height;
  final bool dark;
  @override
  State<_CatalogFrame> createState() => _CatalogFrameState();
}

class _CatalogFrameState extends State<_CatalogFrame> {
  final _focus = FocusNode();
  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: const TodoApp()._theme(
      widget.dark ? Brightness.dark : Brightness.light,
    ),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Builder(builder: (context) => widget.builder(context, _focus)),
        ),
      ),
    ),
  );
}

class _CatalogDialog extends StatefulWidget {
  const _CatalogDialog({required this.builder});
  final WidgetBuilder builder;
  @override
  State<_CatalogDialog> createState() => _CatalogDialogState();
}

class _CatalogDialogState extends State<_CatalogDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  void _open() {
    if (mounted) {
      showDialog<Object>(context: context, builder: widget.builder);
    }
  }

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: _open,
      child: const Text('Open preview dialog'),
    ),
  );
}

Widget previewAppDefault(BuildContext context) => ProviderScope(
  overrides: [repositoryProvider.overrideWith((ref) => _CatalogRepository())],
  child: const TodoApp(platformServices: false),
);
Widget previewAppLoading(BuildContext context) => ProviderScope(
  overrides: [
    repositoryProvider.overrideWith((ref) => _CatalogRepository(loading: true)),
  ],
  child: const TodoApp(platformServices: false),
);
Widget previewAppError(BuildContext context) => ProviderScope(
  overrides: [
    repositoryProvider.overrideWith((ref) => _CatalogRepository(failed: true)),
  ],
  child: const TodoApp(platformServices: false),
);
Widget previewFailure(BuildContext context) => _CatalogFrame(
  builder: (_, _) => _FailurePage(error: 'Connection refused', retry: () {}),
);

Widget previewSidebar(BuildContext context) => _CatalogFrame(
  width: 244,
  builder: (_, focus) => _Sidebar(
    data: catalogFixture(),
    selectedView: 'my-day',
    query: '',
    searchFocus: focus,
    navigate: (_) {},
    search: (_) {},
    submitSearch: () {},
    newList: (_) {},
    newGroup: () {},
    settings: () {},
    renameList: (_) {},
    deleteList: (_) {},
    saveList: (_) {},
    renameGroup: (_) {},
    ungroup: (_) {},
  ),
);
Widget previewNavigationSelected(BuildContext context) => _CatalogFrame(
  width: 244,
  height: 80,
  builder: (_, _) => _NavTile(
    label: 'My Day',
    icon: CupertinoIcons.sun_max,
    color: todoAccent,
    selected: true,
    count: 2,
    onTap: () {},
  ),
);
Widget previewNavigationDefault(BuildContext context) => _CatalogFrame(
  width: 244,
  height: 80,
  builder: (_, _) => _NavTile(
    label: 'Tasks',
    icon: CupertinoIcons.house,
    color: todoAccent,
    selected: false,
    count: 5,
    onTap: () {},
  ),
);

Widget _catalogPane({
  bool empty = false,
  bool searching = false,
  bool completed = false,
  BackgroundSelection? featured,
}) => _CatalogFrame(
  builder: (_, focus) => _TaskPane(
    title: searching ? 'Search' : 'Tasks',
    view: 'inbox',
    query: searching ? 'unknown' : '',
    themeId: 'blue',
    tasks: empty || searching
        ? []
        : completed
        ? [catalogFixture().tasks.last]
        : catalogFixture().tasks,
    selectedId: 1,
    showCompleted: true,
    expanded: true,
    toggleExpanded: () {},
    sort: TaskSort.manual,
    sortDescending: false,
    back: null,
    action: (_) {},
    isCustom: true,
    suggestions: null,
    select: (_) {},
    complete: (_) {},
    important: (_) {},
    contextAction: (_, _) {},
    add: (_) async {},
    composerFocus: focus,
    reorder: null,
    featured: featured,
  ),
);
Widget previewTaskPane(BuildContext context) => _catalogPane();
Widget previewTaskPaneEmpty(BuildContext context) => _catalogPane(empty: true);
Widget previewTaskPaneSearch(BuildContext context) =>
    _catalogPane(searching: true);
Widget previewTaskPaneCompleted(BuildContext context) =>
    _catalogPane(completed: true);
Widget previewTaskPanePhoto(BuildContext context) => _catalogPane(
  featured: BackgroundSelection(
    BackgroundPhoto(
      id: 'catalog-fixture',
      imageUrl: 'https://images.unsplash.com/',
      photographer: 'Fixture photographer',
      photographerUrl: 'https://unsplash.com/',
      photoUrl: 'https://unsplash.com/',
      source: 'test-fixture',
    ),
    // Synthetic decoding fixture; it carries no photograph or fidelity claim.
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAEklEQVR4nGNQK837jw8zjAwFALxmggGs1llpAAAAAElFTkSuQmCC',
    ),
  ),
);
Widget previewHeaderButton(BuildContext context) => _CatalogFrame(
  height: 80,
  builder: (_, _) => Align(
    alignment: Alignment.topLeft,
    child: _HeaderButton(
      tooltip: 'Suggestions',
      icon: CupertinoIcons.lightbulb,
      onPressed: () {},
    ),
  ),
);
Widget previewTaskRow(BuildContext context) => _CatalogFrame(
  height: 100,
  builder: (_, _) => _TaskRow(
    task: catalogFixture().tasks.first,
    selected: false,
    select: () {},
    complete: () {},
    important: () {},
    action: (_) {},
  ),
);
Widget previewTaskRowSelected(BuildContext context) => _CatalogFrame(
  height: 100,
  builder: (_, _) => _TaskRow(
    task: catalogFixture().tasks.first,
    selected: true,
    select: () {},
    complete: () {},
    important: () {},
    action: (_) {},
  ),
);
Widget previewTaskRowCompleted(BuildContext context) => _CatalogFrame(
  height: 100,
  builder: (_, _) => _TaskRow(
    task: catalogFixture().tasks.last,
    selected: false,
    select: () {},
    complete: () {},
    important: () {},
    action: (_) {},
  ),
);
Widget previewCheckOpen(BuildContext context) => _CatalogFrame(
  height: 80,
  builder: (_, _) => Align(
    alignment: Alignment.topLeft,
    child: _CheckCircle(
      value: false,
      label: 'Complete preview task',
      onPressed: () {},
    ),
  ),
);
Widget previewCheckComplete(BuildContext context) => _CatalogFrame(
  height: 80,
  builder: (_, _) => Align(
    alignment: Alignment.topLeft,
    child: _CheckCircle(
      value: true,
      label: 'Mark preview task incomplete',
      onPressed: () {},
    ),
  ),
);
Widget previewComposer(BuildContext context) => _CatalogFrame(
  height: 100,
  builder: (_, focus) => Align(
    alignment: Alignment.topLeft,
    child: _Composer(add: (_) async {}, focusNode: focus),
  ),
);
Widget previewComposerSaving(BuildContext context) => _CatalogFrame(
  height: 100,
  builder: (_, focus) => Align(
    alignment: Alignment.topLeft,
    child: _Composer(add: (_) => Completer<void>().future, focusNode: focus),
  ),
);
Widget previewComposerError(BuildContext context) => _CatalogFrame(
  height: 100,
  builder: (_, focus) => Align(
    alignment: Alignment.topLeft,
    child: _Composer(
      add: (_) async {
        throw StateError('Preview write failure');
      },
      focusNode: focus,
    ),
  ),
);
Widget previewEmptyState(BuildContext context) => _CatalogFrame(
  builder: (_, _) => const ColoredBox(
    color: todoAccent,
    child: _EmptyState(
      title: 'No results',
      message: 'Try searching for a different word.',
    ),
  ),
);
Widget previewSuggestions(BuildContext context) => _CatalogFrame(
  width: 320,
  builder: (_, _) => _SuggestionsPanel(
    tasks: [catalogFixture().tasks[1]],
    close: () {},
    add: (_) {},
  ),
);
Widget previewSuggestionsEmpty(BuildContext context) => _CatalogFrame(
  width: 320,
  builder: (_, _) => _SuggestionsPanel(tasks: [], close: () {}, add: (_) {}),
);
Widget previewTaskDetails(BuildContext context) => _CatalogFrame(
  width: 320,
  builder: (_, _) => _TaskDetails(
    task: catalogFixture().tasks.first,
    data: catalogFixture(),
    close: () {},
    update: (_) async => true,
    complete: () {},
    delete: () {},
  ),
);
Widget previewTaskDetailsCompleted(BuildContext context) => _CatalogFrame(
  width: 320,
  builder: (_, _) => _TaskDetails(
    task: catalogFixture().tasks.last,
    data: catalogFixture(),
    close: () {},
    update: (_) async => true,
    complete: () {},
    delete: () {},
  ),
);
Widget previewDetailAction(BuildContext context) => _CatalogFrame(
  width: 320,
  height: 100,
  builder: (_, _) => _DetailAction(
    icon: CupertinoIcons.sun_max,
    label: 'Add to My Day',
    onTap: () {},
  ),
);
Widget previewDetailActionActive(BuildContext context) => _CatalogFrame(
  width: 320,
  height: 100,
  builder: (_, _) => _DetailAction(
    icon: CupertinoIcons.sun_max,
    label: 'Added to My Day',
    active: true,
    onTap: () {},
  ),
);
Widget previewSettings(BuildContext context) => _CatalogFrame(
  builder: (_, _) => _CatalogDialog(
    builder: (_) => _SettingsDialog(
      settings: catalogFixture().settings,
      save: (_) async => true,
    ),
  ),
);
Widget previewSettingsDark(BuildContext context) => _CatalogFrame(
  dark: true,
  builder: (_, _) => _CatalogDialog(
    builder: (_) => _SettingsDialog(
      settings: catalogFixture().settings.copyWith(darkMode: true),
      save: (_) async => true,
    ),
  ),
);
Widget previewThemeDialog(BuildContext context) => _CatalogFrame(
  builder: (_, _) =>
      _CatalogDialog(builder: (_) => const _ThemeDialog(selected: 'blue')),
);
Widget previewRepeatDialog(BuildContext context) => _CatalogFrame(
  builder: (_, _) =>
      _CatalogDialog(builder: (_) => const _RepeatDialog(every: 3)),
);
Widget previewNameDialog(BuildContext context) => _CatalogFrame(
  builder: (_, _) => _CatalogDialog(
    builder: (_) => const _NameDialog(title: 'New list', value: 'Weekend'),
  ),
);

Widget previewEmptyDetails(BuildContext context) =>
    _CatalogFrame(width: 320, builder: (_, _) => const _EmptyDetails());
Widget previewTaskMoveHandle(BuildContext context) => _CatalogFrame(
  height: 100,
  builder: (_, _) => Align(
    alignment: Alignment.topLeft,
    child: _TaskMoveHandle(task: catalogFixture().tasks.first),
  ),
);

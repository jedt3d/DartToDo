part of 'todo_app.dart';

class _Sidebar extends StatefulWidget {
  const _Sidebar({
    required this.data,
    required this.selectedView,
    required this.query,
    required this.searchFocus,
    required this.navigate,
    required this.search,
    required this.newList,
    required this.newGroup,
    required this.settings,
    required this.renameList,
    required this.deleteList,
    required this.saveList,
    required this.renameGroup,
    required this.ungroup,
    required this.submitSearch,
    this.moveTask,
    this.reorderList,
    this.reorderGroup,
  });
  final void Function(int taskId, int listId)? moveTask;
  final void Function(TodoList, int)? reorderList;
  final void Function(TodoGroup, int)? reorderGroup;
  final TodoSnapshot data;
  final String selectedView, query;
  final FocusNode searchFocus;
  final ValueChanged<String> navigate, search;
  final VoidCallback settings, newGroup, submitSearch;
  final void Function(int?) newList;
  final ValueChanged<TodoList> renameList, deleteList, saveList;
  final ValueChanged<TodoGroup> renameGroup, ungroup;
  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  late final _searchText = TextEditingController(text: widget.query);
  final _collapsed = <int>{};
  @override
  void didUpdateWidget(_Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_searchText.text != widget.query) _searchText.text = widget.query;
  }

  @override
  void dispose() {
    _searchText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final lists =
        widget.data.lists
            .where((list) => !list.deleted && list.id != 1)
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));
    final groups = widget.data.groups.where((group) => !group.deleted).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return Material(
      color: dark ? const Color(0xff282828) : const Color(0xfff0f0f0),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tight = constraints.maxHeight < 360;
            return Column(
              children: [
                SizedBox(height: tight ? 4 : 30),
                if (!tight)
                  InkWell(
                    onTap: widget.settings,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: todoAccent,
                            child: Text(
                              widget.data.settings.displayName.isEmpty
                                  ? 'L'
                                  : widget.data.settings.displayName
                                        .substring(0, 1)
                                        .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.data.settings.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Text(
                                  'Local account',
                                  style: TextStyle(
                                    color: Color(0xff777777),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(CupertinoIcons.chevron_down, size: 12),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 3, 12, 8),
                  child: SizedBox(
                    height:
                        (MediaQuery.sizeOf(context).width < 720 ||
                            Theme.of(context).platform == TargetPlatform.iOS)
                        ? 44
                        : 30,
                    child: TextField(
                      key: const Key('search-tasks'),
                      controller: _searchText,
                      focusNode: widget.searchFocus,
                      onChanged: widget.search,
                      onSubmitted: (_) => widget.submitSearch(),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        filled: true,
                        fillColor: dark
                            ? const Color(0xff383838)
                            : Colors.white,
                        prefixIcon: const Icon(CupertinoIcons.search, size: 17),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 32,
                        ),
                        suffixIcon: widget.query.isEmpty
                            ? null
                            : IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 14,
                                tooltip: 'Clear search',
                                icon: const Icon(
                                  CupertinoIcons.xmark_circle_fill,
                                ),
                                onPressed: () {
                                  _searchText.clear();
                                  widget.search('');
                                },
                              ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: dark
                                ? const Color(0xff555555)
                                : const Color(0xffdddddd),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: dark
                                ? const Color(0xff555555)
                                : const Color(0xffdddddd),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final item in const [
                        (
                          'my-day',
                          'My Day',
                          CupertinoIcons.sun_max,
                          Color(0xff788083),
                        ),
                        (
                          'important',
                          'Important',
                          CupertinoIcons.star,
                          Color(0xffa83d65),
                        ),
                        (
                          'planned',
                          'Planned',
                          CupertinoIcons.calendar,
                          Color(0xff26756e),
                        ),
                        (
                          'all',
                          'All',
                          CupertinoIcons.tray_full,
                          Color(0xff438587),
                        ),
                        (
                          'completed',
                          'Completed',
                          CupertinoIcons.checkmark_circle,
                          Color(0xff58856a),
                        ),
                        ('inbox', 'Tasks', CupertinoIcons.house, todoAccent),
                      ])
                        _taskDestination(
                          item.$1 == 'inbox' ? 1 : null,
                          _NavTile(
                            label: item.$2,
                            icon: item.$3,
                            color: item.$4,
                            selected:
                                widget.selectedView == item.$1 &&
                                widget.query.isEmpty,
                            count: taskCount(widget.data, item.$1),
                            onTap: () => widget.navigate(item.$1),
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        child: Divider(height: 1),
                      ),
                      for (final list in lists.where((l) => l.groupId == null))
                        _listTile(list),
                      for (final group in groups) ...[
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() {
                                  if (!_collapsed.add(group.id!)) {
                                    _collapsed.remove(group.id);
                                  }
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _collapsed.contains(group.id)
                                            ? CupertinoIcons.chevron_right
                                            : CupertinoIcons.chevron_down,
                                        size: 11,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          group.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'Group options',
                              iconSize: 16,
                              padding: EdgeInsets.zero,
                              onSelected: (action) {
                                switch (action) {
                                  case 'up':
                                    widget.reorderGroup?.call(group, -1);
                                  case 'down':
                                    widget.reorderGroup?.call(group, 1);
                                  case 'rename':
                                    widget.renameGroup(group);
                                  case 'ungroup':
                                    widget.ungroup(group);
                                  case 'new':
                                    widget.newList(group.id);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'up',
                                  child: Text('Move group up'),
                                ),
                                PopupMenuItem(
                                  value: 'down',
                                  child: Text('Move group down'),
                                ),
                                PopupMenuItem(
                                  value: 'new',
                                  child: Text('New list in group'),
                                ),
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Text('Rename group'),
                                ),
                                PopupMenuItem(
                                  value: 'ungroup',
                                  child: Text('Ungroup lists'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (!_collapsed.contains(group.id))
                          for (final list in lists.where(
                            (l) => l.groupId == group.id,
                          ))
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: _listTile(list),
                            ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      if (tight)
                        IconButton(
                          tooltip: 'Settings',
                          onPressed: widget.settings,
                          icon: const Icon(CupertinoIcons.gear, size: 20),
                        ),
                      Expanded(
                        child: TextButton.icon(
                          key: const Key('new-list'),
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            foregroundColor: dark
                                ? Colors.white
                                : const Color(0xff383838),
                          ),
                          onPressed: () => widget.newList(null),
                          icon: const Icon(CupertinoIcons.plus, size: 20),
                          label: const Text('New List'),
                        ),
                      ),
                      IconButton(
                        tooltip: 'New group',
                        onPressed: widget.newGroup,
                        icon: const Icon(
                          CupertinoIcons.folder_badge_plus,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _taskDestination(int? listId, Widget child) => listId == null
      ? child
      : DragTarget<_TaskDragData>(
          key: ValueKey('drop-list-$listId'),
          onWillAcceptWithDetails: (details) =>
              widget.moveTask != null && details.data.sourceListId != listId,
          onAcceptWithDetails: (details) =>
              widget.moveTask?.call(details.data.taskId, listId),
          builder: (context, candidates, rejected) => DecoratedBox(
            decoration: BoxDecoration(
              border: candidates.isNotEmpty
                  ? Border.all(color: todoAccent, width: 2)
                  : null,
              color: candidates.isNotEmpty
                  ? todoAccent.withValues(alpha: .15)
                  : null,
            ),
            child: child,
          ),
        );

  Widget _listTile(TodoList list) => _taskDestination(
    list.id,
    _NavTile(
      label: list.title,
      icon: CupertinoIcons.list_bullet,
      color: todoColors[list.theme] ?? todoAccent,
      selected:
          widget.selectedView == 'list:${list.id}' && widget.query.isEmpty,
      count: taskCount(widget.data, 'list:${list.id}'),
      onTap: () => widget.navigate('list:${list.id}'),
      trailing: PopupMenuButton<String>(
        tooltip: 'List options for ${list.title}',
        iconSize: 15,
        padding: EdgeInsets.zero,
        onSelected: (action) {
          if (action == 'up') widget.reorderList?.call(list, -1);
          if (action == 'down') widget.reorderList?.call(list, 1);
          if (action == 'rename') widget.renameList(list);
          if (action == 'delete') widget.deleteList(list);
          if (action.startsWith('group:')) {
            widget.saveList(
              list.copyWith(
                groupId: action == 'group:none'
                    ? null
                    : int.parse(action.substring(6)),
              ),
            );
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'up', child: Text('Move list up')),
          const PopupMenuItem(value: 'down', child: Text('Move list down')),
          const PopupMenuItem(value: 'rename', child: Text('Rename list')),
          const PopupMenuItem(
            value: 'group:none',
            child: Text('Move out of group'),
          ),
          for (final group in widget.data.groups.where((g) => !g.deleted))
            PopupMenuItem(
              value: 'group:${group.id}',
              child: Text('Move to ${group.title}'),
            ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete list', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ),
  );
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.count,
    required this.onTap,
    this.trailing,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final int count;
  final VoidCallback onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    label: '$label, $count tasks',
    child: InkWell(
      onTap: onTap,
      child: Container(
        height:
            (MediaQuery.sizeOf(context).width < 720 ||
                Theme.of(context).platform == TargetPlatform.iOS)
            ? 46
            : 32,
        color: selected
            ? Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xff454545)
                  : const Color(0xffd8d8d8)
            : null,
        padding: const EdgeInsets.only(left: 20, right: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (count > 0)
              Text(
                '$count',
                style: const TextStyle(fontSize: 12, color: Color(0xff777777)),
              ),
            if (trailing != null)
              SizedBox(
                width:
                    (MediaQuery.sizeOf(context).width < 720 ||
                        Theme.of(context).platform == TargetPlatform.iOS)
                    ? 44
                    : 26,
                child: trailing,
              ),
          ],
        ),
      ),
    ),
  );
}

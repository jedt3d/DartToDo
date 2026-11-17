part of 'todo_app.dart';

class _TaskPane extends StatelessWidget {
  const _TaskPane({
    required this.title,
    required this.view,
    required this.query,
    required this.themeId,
    required this.tasks,
    required this.selectedId,
    required this.showCompleted,
    required this.expanded,
    required this.toggleExpanded,
    required this.sort,
    required this.sortDescending,
    required this.back,
    required this.action,
    required this.isCustom,
    required this.suggestions,
    required this.select,
    required this.complete,
    required this.important,
    required this.contextAction,
    required this.add,
    required this.composerFocus,
    required this.reorder,
    this.featured,
    this.revealLists,
  });
  final String title, view, query, themeId;
  final BackgroundSelection? featured;
  final List<TodoTask> tasks;
  final int? selectedId;
  final bool showCompleted, expanded, sortDescending, isCustom;
  final TaskSort sort;
  final VoidCallback toggleExpanded;
  final VoidCallback? back, suggestions, revealLists;
  final ValueChanged<String> action;
  final ValueChanged<TodoTask> select, complete, important;
  final void Function(TodoTask, String) contextAction;
  final Future<void> Function(String) add;
  final FocusNode composerFocus;
  final Future<void> Function(List<TodoTask>, int, int)? reorder;

  @override
  Widget build(BuildContext context) {
    final active = tasks.where((task) => !task.completed).toList();
    final completed = tasks.where((task) => task.completed).toList();
    final photo = todoPhotos.contains(themeId);
    final background = todoColors[themeId] ?? const Color(0xff357e83);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        image: featured != null
            ? DecorationImage(
                image: MemoryImage(featured!.bytes),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: .18),
                  BlendMode.darken,
                ),
                onError: (error, stack) {},
              )
            : photo
            ? DecorationImage(
                image: AssetImage('assets/themes/$themeId.png'),
                onError: (error, stack) {},
                fit: BoxFit.cover,
                alignment: Alignment.center,
              )
            : null,
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tight = constraints.maxHeight < 360;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    tight
                        ? 4
                        : back == null
                        ? 30
                        : 12,
                    16,
                    tight ? 4 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (back != null && !tight)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: back,
                          icon: const Icon(
                            CupertinoIcons.chevron_left,
                            size: 18,
                          ),
                          label: const Text('Lists'),
                        ),
                      Row(
                        children: [
                          if (back != null && tight)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                minimumSize: const Size(44, 44),
                              ),
                              onPressed: back,
                              icon: const Icon(
                                CupertinoIcons.chevron_left,
                                size: 18,
                              ),
                              label: const Text('Lists'),
                            ),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: tight ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: tight ? 20 : 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (suggestions != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _HeaderButton(
                                tooltip: 'Suggestions',
                                icon: CupertinoIcons.lightbulb,
                                onPressed: suggestions!,
                              ),
                            ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .16),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: PopupMenuButton<String>(
                              key: const Key('list-options'),
                              tooltip: 'List options',
                              color: Theme.of(context).colorScheme.surface,
                              icon: const Icon(
                                CupertinoIcons.ellipsis,
                                color: Colors.white,
                                size: 22,
                              ),
                              onSelected: action,
                              itemBuilder: (_) => [
                                for (final item in const [
                                  ('manual', 'Manual order'),
                                  ('importance', 'Importance'),
                                  ('alphabetical', 'Alphabetically'),
                                  ('dueDate', 'Due Date'),
                                  ('created', 'Creation Date'),
                                  ('myDay', 'Added to My Day'),
                                ])
                                  CheckedPopupMenuItem(
                                    value: 'sort:${item.$1}',
                                    checked: sort.name == item.$1,
                                    child: Text('Sort · ${item.$2}'),
                                  ),
                                CheckedPopupMenuItem(
                                  value: 'reverse',
                                  checked: sortDescending,
                                  child: const Text('Reverse sort order'),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                  value: 'theme',
                                  child: Text('Change Theme…'),
                                ),
                                PopupMenuItem(
                                  value: 'completed',
                                  child: Text(
                                    showCompleted
                                        ? 'Hide Completed Tasks'
                                        : 'Show Completed Tasks',
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'copy',
                                  child: Text('Copy List'),
                                ),
                                const PopupMenuItem(
                                  value: 'print',
                                  child: Text('Print List…'),
                                ),
                                if (isCustom) ...[
                                  const PopupMenuItem(
                                    value: 'rename',
                                    child: Text('Rename List'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'duplicate',
                                    child: Text('Duplicate List'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Delete List',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                                const PopupMenuItem(
                                  value: 'refresh',
                                  child: Text('Refresh'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!tight && view == 'my-day' && query.isEmpty)
                        Text(
                          DateFormat('EEEE, d MMMM').format(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      if (!tight && query.isNotEmpty)
                        Text(
                          'Results for “$query”',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: tasks.isEmpty
                      ? (query.isNotEmpty
                            ? const _EmptyState(
                                title: 'No results',
                                message: 'Try searching for a different word.',
                              )
                            : const SizedBox.expand())
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          buildDefaultDragHandles: false,
                          itemCount:
                              active.length +
                              (showCompleted && completed.isNotEmpty
                                  ? 1 + (expanded ? completed.length : 0)
                                  : 0),
                          onReorder: (oldIndex, newIndex) {
                            if (oldIndex < active.length &&
                                newIndex <= active.length &&
                                reorder != null) {
                              reorder!(active, oldIndex, newIndex);
                            }
                          },
                          itemBuilder: (context, index) {
                            if (index == active.length) {
                              return Align(
                                key: const Key('completed-section'),
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.black.withValues(
                                      alpha: .12,
                                    ),
                                    minimumSize: const Size(0, 24),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                  ),
                                  onPressed: toggleExpanded,
                                  icon: Icon(
                                    expanded
                                        ? CupertinoIcons.chevron_down
                                        : CupertinoIcons.chevron_right,
                                    size: 10,
                                  ),
                                  label: Text(
                                    'Completed ${completed.length}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }
                            final task = index < active.length
                                ? active[index]
                                : completed[index - active.length - 1];
                            final row = Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: _TaskRow(
                                task: task,
                                revealLists: revealLists,
                                dragHandle:
                                    index < active.length && reorder != null
                                    ? Tooltip(
                                        message: 'Drag to reorder',
                                        child: Semantics(
                                          label: 'Reorder ${task.title}',
                                          child: ReorderableDragStartListener(
                                            index: index,
                                            child: const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Icon(
                                                CupertinoIcons
                                                    .line_horizontal_3,
                                                size: 14,
                                                color: Color(0xff999999),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                                selected: task.id == selectedId,
                                select: () => select(task),
                                complete: () => complete(task),
                                important: () => important(task),
                                action: (action) => contextAction(task, action),
                              ),
                            );
                            return KeyedSubtree(
                              key: ValueKey('task-${task.id}'),
                              child: row,
                            );
                          },
                        ),
                ),
                if (featured != null && !tight)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 44),
                              ),
                              onPressed: () => launchUrl(
                                Uri.parse(featured!.photo.photographerUrl),
                                mode: LaunchMode.externalApplication,
                              ),
                              child: Text(
                                'Photo by ${featured!.photo.photographer}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 44),
                              ),
                              onPressed: () => launchUrl(
                                Uri.parse(featured!.photo.photoUrl),
                                mode: LaunchMode.externalApplication,
                              ),
                              child: const Text(
                                'on Unsplash',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(tight ? 8 : 16),
                  child: _Composer(add: add, focusNode: composerFocus),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(4),
    ),
    child: IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: Colors.white, size: 22),
      onPressed: onPressed,
    ),
  );
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.selected,
    required this.select,
    required this.complete,
    required this.important,
    required this.action,
    this.dragHandle,
    this.revealLists,
  });
  final Widget? dragHandle;
  final VoidCallback? revealLists;
  final TodoTask task;
  final bool selected;
  final VoidCallback select, complete, important;
  final ValueChanged<String> action;

  Future<void> _menu(BuildContext context, Offset position) async {
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'my-day',
          child: Text(
            task.myDay == localDateKey(DateTime.now())
                ? 'Remove from My Day'
                : 'Add to My Day',
          ),
        ),
        PopupMenuItem(
          value: 'important',
          child: Text(
            task.important ? 'Remove importance' : 'Mark as important',
          ),
        ),
        PopupMenuItem(
          value: 'complete',
          child: Text(
            task.completed ? 'Mark as incomplete' : 'Mark as completed',
          ),
        ),
        const PopupMenuItem(value: 'duplicate', child: Text('Duplicate task')),
        const PopupMenuItem(value: 'copy', child: Text('Copy task')),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete task', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
    if (result != null) action(result);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final due = task.dueDate == null ? null : DateTime.tryParse(task.dueDate!);
    final metadata = <String>[
      if (task.myDay == localDateKey(DateTime.now())) 'My Day',
      if (due != null) DateFormat('EEE, d MMM').format(due),
      if (task.steps.isNotEmpty)
        '${task.steps.where((s) => s.completed).length} of ${task.steps.length}',
      if (task.repeat != 'none') _repeatLabel(task),
      if (task.notes.isNotEmpty) 'Note',
      if (task.attachments.isNotEmpty)
        '${task.attachments.length} file${task.attachments.length == 1 ? '' : 's'}',
    ];
    return Semantics(
      label: task.title,
      button: true,
      selected: selected,
      child: GestureDetector(
        onSecondaryTapUp: (details) => _menu(context, details.globalPosition),
        onLongPressStart: (details) => _menu(context, details.globalPosition),
        child: Material(
          color: dark
              ? selected
                    ? const Color(0xff3b3b52)
                    : const Color(0xff303030)
              : selected
              ? const Color(0xffd8dcef)
              : Colors.white,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: select,
            borderRadius: BorderRadius.circular(4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                child: Row(
                  children: [
                    ?dragHandle,
                    _TaskMoveHandle(task: task, revealLists: revealLists),
                    _CheckCircle(
                      value: task.completed,
                      label: task.completed
                          ? 'Mark ${task.title} incomplete'
                          : 'Complete ${task.title}',
                      onPressed: complete,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: task.completed
                                  ? const Color(0xff777777)
                                  : null,
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (metadata.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                metadata.join(' · '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      !task.completed &&
                                          due != null &&
                                          task.dueDate!.compareTo(
                                                localDateKey(DateTime.now()),
                                              ) <
                                              0
                                      ? const Color(0xffd04444)
                                      : const Color(0xff777777),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: task.important
                          ? 'Remove importance'
                          : 'Mark as important',
                      onPressed: important,
                      icon: Icon(
                        task.important
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        size: 20,
                        color: task.important
                            ? todoAccent
                            : const Color(0xff858585),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({
    required this.value,
    required this.label,
    required this.onPressed,
  });
  final bool value;
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
    checked: value,
    label: label,
    button: true,
    child: IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: Icon(
        value ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
        size: 22,
        color: value ? todoAccent : const Color(0xff808080),
      ),
    ),
  );
}

class _Composer extends StatefulWidget {
  const _Composer({required this.add, required this.focusNode});
  final Future<void> Function(String) add;
  final FocusNode focusNode;
  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _text = TextEditingController();
  bool _saving = false;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _text.text.trim();
    if (title.isEmpty || _saving) return;
    widget.focusNode.requestFocus();
    setState(() => _saving = true);
    try {
      await widget.add(title);
      if (mounted) _text.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not add task. $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 44),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .25),
      borderRadius: BorderRadius.circular(4),
    ),
    padding: const EdgeInsets.only(left: 8, right: 6),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Add task',
          onPressed: _saving ? null : _submit,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(CupertinoIcons.plus, color: Colors.white, size: 22),
        ),
        Expanded(
          child: TextField(
            key: const Key('add-task'),
            controller: _text,
            focusNode: widget.focusNode,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Add a Task',
              hintStyle: TextStyle(color: Colors.white),
              counterText: '',
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.message});
  final String title, message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.search, color: Colors.white70, size: 36),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({
    required this.tasks,
    required this.close,
    required this.add,
  });
  final List<TodoTask> tasks;
  final VoidCallback close;
  final ValueChanged<TodoTask> add;
  @override
  Widget build(BuildContext context) => Material(
    child: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tight = constraints.maxHeight < 360;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  tight ? 4 : 28,
                  8,
                  tight ? 4 : 12,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Suggestions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close suggestions',
                      onPressed: close,
                      icon: const Icon(CupertinoIcons.xmark, size: 18),
                    ),
                  ],
                ),
              ),
              if (!tight)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Choose tasks to focus on today. Your other tasks stay in their lists.',
                    style: TextStyle(fontSize: 12, color: Color(0xff777777)),
                  ),
                ),
              if (!tight) const SizedBox(height: 16),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text('You’re all caught up.'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: tasks.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final task = tasks[index];
                          return ListTile(
                            title: Text(
                              task.title,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: task.dueDate == null
                                ? null
                                : Text(
                                    task.dueDate!,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                            trailing: IconButton(
                              tooltip: 'Add ${task.title} to My Day',
                              onPressed: () => add(task),
                              icon: const Icon(
                                CupertinoIcons.plus,
                                color: todoAccent,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _TaskDragData {
  const _TaskDragData(this.taskId, this.sourceListId);
  final int taskId, sourceListId;
}

class _TaskMoveHandle extends StatelessWidget {
  const _TaskMoveHandle({required this.task, this.revealLists});
  final TodoTask task;
  final VoidCallback? revealLists;
  @override
  Widget build(BuildContext context) {
    const handle = SizedBox(
      width: 44,
      height: 44,
      child: Icon(
        CupertinoIcons.arrow_right_square,
        size: 16,
        color: Color(0xff888888),
      ),
    );
    final feedback = Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
    final payload = _TaskDragData(task.id!, task.listId);
    final touch =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android;
    return Tooltip(
      message: 'Drag to another list',
      child: Semantics(
        label: 'Move ${task.title} to another list',
        child: touch
            ? LongPressDraggable<_TaskDragData>(
                key: ValueKey('move-task-${task.id}'),
                data: payload,
                rootOverlay: true,
                onDragStarted: revealLists,
                feedback: feedback,
                child: handle,
              )
            : Draggable<_TaskDragData>(
                key: ValueKey('move-task-${task.id}'),
                data: payload,
                rootOverlay: true,
                feedback: feedback,
                child: handle,
              ),
      ),
    );
  }
}

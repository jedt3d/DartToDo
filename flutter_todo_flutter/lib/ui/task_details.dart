part of 'todo_app.dart';

class _TaskDetails extends StatefulWidget {
  const _TaskDetails({
    super.key,
    required this.task,
    required this.data,
    required this.close,
    required this.update,
    required this.complete,
    required this.delete,
    this.requestNotifications,
    this.backLabel,
  });
  final String? backLabel;
  final TodoTask task;
  final TodoSnapshot data;
  final VoidCallback close, complete, delete;
  final Future<bool> Function(TodoTask Function(TodoTask)) update;
  final Future<bool> Function()? requestNotifications;
  @override
  State<_TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<_TaskDetails> {
  late final _title = TextEditingController(text: widget.task.title);
  late final _notes = TextEditingController(text: widget.task.notes);
  final _step = TextEditingController();
  final _titleFocus = FocusNode();
  final _notesFocus = FocusNode();
  Timer? _noteTimer;
  bool _fileBusy = false;

  @override
  void initState() {
    super.initState();
    _titleFocus.addListener(_focusChanged);
    _notesFocus.addListener(_focusChanged);
  }

  void _focusChanged() {
    if (!_titleFocus.hasFocus && !_notesFocus.hasFocus) unawaited(_saveText());
  }

  @override
  void didUpdateWidget(_TaskDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _noteTimer?.cancel();
      _titleFocus.unfocus();
      _notesFocus.unfocus();
      _title.text = widget.task.title;
      _notes.text = widget.task.notes;
      _step.clear();
      return;
    }
    if (!_titleFocus.hasFocus && _title.text == oldWidget.task.title) {
      _title.text = widget.task.title;
    }
    if (!_notesFocus.hasFocus && _notes.text == oldWidget.task.notes) {
      _notes.text = widget.task.notes;
    }
  }

  @override
  void dispose() {
    _noteTimer?.cancel();
    _title.dispose();
    _notes.dispose();
    _step.dispose();
    _titleFocus.removeListener(_focusChanged);
    _notesFocus.removeListener(_focusChanged);
    _titleFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  Future<bool> _saveText() async {
    _noteTimer?.cancel();
    var title = _title.text.trim();
    final notes = _notes.text;
    if (title.isEmpty) {
      title = widget.task.title;
      _title.text = title;
    }
    if (title == widget.task.title && notes == widget.task.notes) return true;
    return widget.update(
      (current) => current.copyWith(title: title, notes: notes),
    );
  }

  Future<void> _close() async {
    if (await _saveText() && mounted) widget.close();
  }

  Future<void> _dateAction(String action) async {
    final today = DateTime.now();
    DateTime? date;
    if (action == 'today') date = DateTime(today.year, today.month, today.day);
    if (action == 'tomorrow') {
      date = DateTime(today.year, today.month, today.day + 1);
    }
    if (action == 'next-week') {
      date = DateTime(today.year, today.month, today.day + 7);
    }
    if (action == 'pick') {
      final firstDate = DateTime(2000);
      final lastDate = DateTime(2200);
      final storedDate = DateUtils.dateOnly(
        DateTime.tryParse(widget.task.dueDate ?? '') ?? today,
      );
      date = await showDatePicker(
        context: context,
        initialDate: storedDate.isBefore(firstDate)
            ? firstDate
            : storedDate.isAfter(lastDate)
            ? lastDate
            : storedDate,
        firstDate: firstDate,
        lastDate: lastDate,
        helpText: 'Add due date',
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      );
    }
    if (action == 'clear') {
      await widget.update((current) => current.copyWith(dueDate: null));
      return;
    }
    if (date != null) {
      await widget.update(
        (current) => current.copyWith(dueDate: localDateKey(date!)),
      );
    }
  }

  Future<void> _reminderAction(String action) async {
    if (action == 'clear') {
      await widget.update((current) => current.copyWith(reminder: null));
      return;
    }
    final now = DateTime.now();
    DateTime? date;
    if (action == 'later') date = now.add(const Duration(hours: 1));
    if (action == 'tomorrow') {
      date = DateTime(now.year, now.month, now.day + 1, 9);
    }
    if (action == 'next-week') {
      date = DateTime(now.year, now.month, now.day + 7, 9);
    }
    if (action == 'pick') {
      final firstDate = DateUtils.dateOnly(now);
      final lastDate = DateTime(2200);
      final storedDate = DateUtils.dateOnly(
        widget.task.reminder?.toLocal() ?? now,
      );
      final day = await showDatePicker(
        context: context,
        initialDate: storedDate.isBefore(firstDate)
            ? firstDate
            : storedDate.isAfter(lastDate)
            ? lastDate
            : storedDate,
        firstDate: firstDate,
        lastDate: lastDate,
        helpText: 'Remind me',
      );
      if (day == null || !mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );
      if (time == null) return;
      date = DateTime(day.year, day.month, day.day, time.hour, time.minute);
    }
    if (date == null) return;
    if (!date.isAfter(now)) {
      if (mounted) _message('Choose a reminder in the future.');
      return;
    }
    final granted = await widget.requestNotifications?.call() ?? true;
    await widget.update((current) => current.copyWith(reminder: date!.toUtc()));
    if (!granted && mounted) {
      _message(
        'Reminder saved. Enable notifications for DartToDo in System Settings.',
      );
    }
  }

  Future<void> _repeatAction(String action) async {
    var every = 1;
    var repeat = action;
    if (action == 'custom') {
      final result = await showDialog<({String unit, int every})>(
        context: context,
        builder: (_) => _RepeatDialog(
          every: widget.task.repeatEvery,
          unit:
              {
                'daily',
                'weekly',
                'monthly',
                'yearly',
              }.contains(widget.task.repeat)
              ? widget.task.repeat
              : 'daily',
        ),
      );
      if (result == null) return;
      every = result.every;
      repeat = result.unit;
    }
    await widget.update(
      (current) => current.copyWith(repeat: repeat, repeatEvery: every),
    );
  }

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
  Future<void> _addFile() async {
    if (_fileBusy) return;
    setState(() => _fileBusy = true);
    try {
      final result = await FilePicker.pickFile();
      if (result == null) return;
      final file = result;
      const limit = 25 * 1024 * 1024;
      final existingBytes = widget.task.attachments.fold<int>(
        0,
        (total, file) => total + base64Decode(file.dataBase64).length,
      );
      final builder = BytesBuilder(copy: false);
      await for (final chunk in file.readAsByteStream()) {
        if (existingBytes + builder.length + chunk.length > limit) {
          throw StateError('Files on a task must total 25 MB or smaller.');
        }
        builder.add(chunk);
      }
      final attachment = TodoAttachment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: file.name,
        mimeType: 'application/octet-stream',
        dataBase64: base64Encode(builder.takeBytes()),
      );
      await widget.update(
        (current) {
          final attachments = [...current.attachments, attachment];
          if (attachments.fold<int>(
                0,
                (total, file) => total + base64Decode(file.dataBase64).length,
              ) >
              limit) {
            throw StateError('Files on a task must total 25 MB or smaller.');
          }
          return current.copyWith(attachments: attachments);
        },
      );
    } catch (error) {
      if (mounted) _message('Could not attach file. $error');
    } finally {
      if (mounted) setState(() => _fileBusy = false);
    }
  }

  Future<void> _saveFile(TodoAttachment attachment) async {
    try {
      final path = await FilePicker.saveFile(
        fileName: attachment.name,
        dialogTitle: 'Save attachment',
        bytes: Uint8List.fromList(base64Decode(attachment.dataBase64)),
      );
      if (path != null && mounted) _message('Attachment saved');
    } catch (error) {
      if (mounted) _message('Could not save attachment. $error');
    }
  }

  Future<void> _addStep() async {
    final title = _step.text.trim();
    if (title.isEmpty) return;
    final step = TodoStep(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
    );
    if (await widget.update(
          (current) => current.copyWith(steps: [...current.steps, step]),
        ) &&
        mounted) {
      _step.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final myDay = task.myDay == localDateKey(DateTime.now());
    final due = DateTime.tryParse(task.dueDate ?? '');
    return Material(
      child: SafeArea(
        child: Column(
          children: [
            if (widget.backLabel != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Tooltip(
                  message: 'Close details',
                  child: TextButton.icon(
                    onPressed: _close,
                    icon: const Icon(CupertinoIcons.chevron_left, size: 18),
                    label: Text(widget.backLabel!),
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 25, 8, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CheckCircle(
                          value: task.completed,
                          label: task.completed
                              ? 'Mark incomplete'
                              : 'Mark completed',
                          onPressed: widget.complete,
                        ),
                        Expanded(
                          child: TextField(
                            key: const Key('task-title'),
                            controller: _title,
                            focusNode: _titleFocus,
                            minLines: 1,
                            maxLines: 5,
                            maxLength: 1000,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            onSubmitted: (_) => _saveText(),
                            decoration: const InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: task.important
                              ? 'Remove importance'
                              : 'Mark as important',
                          onPressed: () => widget.update(
                            (current) =>
                                current.copyWith(important: !current.important),
                          ),
                          icon: Icon(
                            task.important
                                ? CupertinoIcons.star_fill
                                : CupertinoIcons.star,
                            color: todoAccent,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final step in task.steps)
                    Row(
                      children: [
                        _CheckCircle(
                          value: step.completed,
                          label:
                              '${step.completed ? 'Uncomplete' : 'Complete'} step ${step.title}',
                          onPressed: () => widget.update(
                            (current) => current.copyWith(
                              steps: current.steps
                                  .map(
                                    (s) => s.id == step.id
                                        ? s.copyWith(completed: !s.completed)
                                        : s,
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('step-${step.id}'),
                            initialValue: step.title,
                            style: TextStyle(
                              fontSize: 13,
                              decoration: step.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            onFieldSubmitted: (title) {
                              if (title.trim().isNotEmpty) {
                                widget.update(
                                  (current) => current.copyWith(
                                    steps: current.steps
                                        .map(
                                          (s) => s.id == step.id
                                              ? s.copyWith(title: title.trim())
                                              : s,
                                        )
                                        .toList(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete step ${step.title}',
                          icon: const Icon(CupertinoIcons.xmark, size: 12),
                          onPressed: () => widget.update(
                            (current) => current.copyWith(
                              steps: current.steps
                                  .where((s) => s.id != step.id)
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Add step',
                        onPressed: _addStep,
                        icon: const Icon(
                          CupertinoIcons.plus,
                          color: todoAccent,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          key: const Key('add-step'),
                          controller: _step,
                          onSubmitted: (_) => _addStep(),
                          maxLength: 1000,
                          decoration: const InputDecoration(
                            hintText: 'Add Step',
                            counterText: '',
                            hintStyle: TextStyle(color: todoAccent),
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  _DetailAction(
                    icon: CupertinoIcons.sun_max,
                    label: myDay ? 'Added to My Day' : 'Add to My Day',
                    active: myDay,
                    onTap: () => widget.update(
                      (current) => current.copyWith(
                        myDay: myDay ? null : localDateKey(DateTime.now()),
                      ),
                    ),
                  ),
                  const Divider(height: 10),
                  PopupMenuButton<String>(
                    tooltip: 'Choose reminder',
                    onSelected: _reminderAction,
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'later',
                        child: Text('Later today · in 1 hour'),
                      ),
                      const PopupMenuItem(
                        value: 'tomorrow',
                        child: Text('Tomorrow · 9:00 AM'),
                      ),
                      const PopupMenuItem(
                        value: 'next-week',
                        child: Text('Next week · 9:00 AM'),
                      ),
                      const PopupMenuItem(
                        value: 'pick',
                        child: Text('Pick a date & time…'),
                      ),
                      if (task.reminder != null)
                        const PopupMenuItem(
                          value: 'clear',
                          child: Text('Remove reminder'),
                        ),
                    ],
                    child: _DetailAction(
                      icon: CupertinoIcons.bell,
                      label: task.reminder == null
                          ? 'Remind Me'
                          : DateFormat(
                              'EEE, d MMM · HH:mm',
                            ).format(task.reminder!.toLocal()),
                      active: task.reminder != null,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Choose due date',
                    onSelected: _dateAction,
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'today', child: Text('Today')),
                      const PopupMenuItem(
                        value: 'tomorrow',
                        child: Text('Tomorrow'),
                      ),
                      const PopupMenuItem(
                        value: 'next-week',
                        child: Text('Next Week'),
                      ),
                      const PopupMenuItem(
                        value: 'pick',
                        child: Text('Pick a Date…'),
                      ),
                      if (due != null)
                        const PopupMenuItem(
                          value: 'clear',
                          child: Text('Remove due date'),
                        ),
                    ],
                    child: _DetailAction(
                      icon: CupertinoIcons.calendar,
                      label: due == null
                          ? 'Add Due Date'
                          : 'Due ${DateFormat('EEE, d MMM').format(due)}',
                      active: due != null,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Choose repeat',
                    onSelected: _repeatAction,
                    itemBuilder: (_) => [
                      for (final item in const [
                        ('none', 'Never'),
                        ('daily', 'Daily'),
                        ('weekdays', 'Weekdays'),
                        ('weekly', 'Weekly'),
                        ('monthly', 'Monthly'),
                        ('yearly', 'Yearly'),
                        ('custom', 'Custom…'),
                      ])
                        CheckedPopupMenuItem(
                          value: item.$1,
                          checked: task.repeat == item.$1,
                          child: Text(item.$2),
                        ),
                    ],
                    child: _DetailAction(
                      icon: CupertinoIcons.repeat,
                      label: _repeatLabel(task),
                      active: task.repeat != 'none',
                    ),
                  ),
                  const Divider(height: 10),
                  _DetailAction(
                    icon: CupertinoIcons.paperclip,
                    label: _fileBusy ? 'Adding file…' : 'Add File',
                    onTap: _fileBusy ? null : _addFile,
                  ),
                  for (final file in task.attachments)
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.doc,
                          size: 16,
                          color: todoAccent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              alignment: Alignment.centerLeft,
                            ),
                            onPressed: () => _saveFile(file),
                            child: Text(
                              file.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove ${file.name}',
                          icon: const Icon(CupertinoIcons.xmark, size: 12),
                          onPressed: () => widget.update(
                            (current) => current.copyWith(
                              attachments: current.attachments
                                  .where((a) => a.id != file.id)
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const Divider(height: 10),
                  TextField(
                    key: const Key('task-notes'),
                    controller: _notes,
                    focusNode: _notesFocus,
                    minLines: 6,
                    maxLines: null,
                    maxLength: 20000,
                    decoration: const InputDecoration(
                      hintText: 'Add Note',
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (_) {
                      _noteTimer?.cancel();
                      _noteTimer = Timer(
                        const Duration(milliseconds: 300),
                        _saveText,
                      );
                    },
                  ),
                  const Divider(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: task.listId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Move task to',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    items: [
                      for (final list in widget.data.lists.where(
                        (list) => !list.deleted,
                      ))
                        DropdownMenuItem(
                          value: list.id,
                          child: Text(
                            list.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (id) {
                      if (id != null) {
                        widget.update(
                          (current) => current.copyWith(listId: id),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  if (widget.backLabel == null)
                    IconButton(
                      tooltip: 'Close details',
                      onPressed: _close,
                      icon: const Icon(CupertinoIcons.chevron_right, size: 18),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      'Created ${DateFormat('EEE, d MMM yyyy').format(task.createdAt.toLocal())}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xff777777),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete task',
                    onPressed: widget.delete,
                    icon: const Icon(CupertinoIcons.trash, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailAction extends StatelessWidget {
  const _DetailAction({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: active ? todoAccent : const Color(0xff808080),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: active ? todoAccent : const Color(0xff808080),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

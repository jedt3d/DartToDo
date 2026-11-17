part of 'todo_app.dart';

class _SettingsDialog extends StatefulWidget {
  const _SettingsDialog({required this.settings, required this.save});
  final TodoSettings settings;
  final Future<bool> Function(TodoSettings) save;
  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late TodoSettings _draft = widget.settings.copyWith();
  late final _name = TextEditingController(text: _draft.displayName);
  bool _saving = false;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final saved = await widget.save(
      _draft.copyWith(displayName: _name.text.trim()),
    );
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Settings'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Local account',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('display-name'),
              controller: _name,
              maxLength: 255,
              decoration: const InputDecoration(
                labelText: 'Your name',
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark appearance'),
              value: _draft.darkMode,
              onChanged: (value) =>
                  setState(() => _draft = _draft.copyWith(darkMode: value)),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show completed tasks'),
              value: _draft.showCompleted,
              onChanged: (value) => setState(
                () => _draft = _draft.copyWith(showCompleted: value),
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Confirm before deleting'),
              value: _draft.confirmDelete,
              onChanged: (value) => setState(
                () => _draft = _draft.copyWith(confirmDelete: value),
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Play completion sound'),
              value: _draft.completionSound,
              onChanged: (value) => setState(
                () => _draft = _draft.copyWith(completionSound: value),
              ),
            ),
            const Divider(),
            const Text(
              'DartToDo 1.0.0',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your tasks are stored in PostgreSQL on this Mac. No Microsoft account, cloud sync, advertising or analytics.',
              style: TextStyle(fontSize: 12, color: Color(0xff777777)),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Saving…' : 'Save'),
      ),
    ],
  );
}

class _ThemeDialog extends StatelessWidget {
  const _ThemeDialog({required this.selected});
  final String selected;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Change Theme'),
    content: SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Colours',
              style: TextStyle(fontSize: 12, color: Color(0xff777777)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in todoColors.entries)
                  Semantics(
                    label: '${entry.key} theme',
                    selected: entry.key == selected,
                    button: true,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, entry.key),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: entry.value,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: selected == entry.key
                            ? const Icon(
                                CupertinoIcons.checkmark,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Photos',
              style: TextStyle(fontSize: 12, color: Color(0xff777777)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final photo in todoPhotos)
                  Semantics(
                    label: '${photo.replaceAll('_', ' ')} theme',
                    selected: photo == selected,
                    button: true,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, photo),
                      child: Container(
                        width: 110,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: AssetImage('assets/themes/$photo.png'),
                            onError: (error, stack) {},
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: selected == photo
                            ? const Icon(
                                CupertinoIcons.checkmark,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Done'),
      ),
    ],
  );
}

class _RepeatDialog extends StatefulWidget {
  const _RepeatDialog({required this.every, this.unit = 'daily'});
  final int every;
  final String unit;
  @override
  State<_RepeatDialog> createState() => _RepeatDialogState();
}

class _RepeatDialogState extends State<_RepeatDialog> {
  late final _every = TextEditingController(text: widget.every.toString());
  late String _unit = widget.unit;
  @override
  void dispose() {
    _every.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Custom repeat'),
    content: SizedBox(
      width: 300,
      child: Row(
        children: [
          const Text('Every '),
          SizedBox(
            width: 65,
            child: TextField(
              key: const Key('repeat-every'),
              controller: _every,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              key: const Key('repeat-unit'),
              initialValue: _unit,
              items: [
                for (final item in const [
                  ('daily', 'days'),
                  ('weekly', 'weeks'),
                  ('monthly', 'months'),
                  ('yearly', 'years'),
                ])
                  DropdownMenuItem(value: item.$1, child: Text(item.$2)),
              ],
              onChanged: (unit) {
                if (unit != null) setState(() => _unit = unit);
              },
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          final value = int.tryParse(_every.text);
          if (value != null && value >= 1 && value <= 365) {
            Navigator.pop(context, (unit: _unit, every: value));
          }
        },
        child: const Text('Save'),
      ),
    ],
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.value});
  final String title, value;
  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _text = TextEditingController(text: widget.value);
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _text.text.trim();
    if (value.isNotEmpty) {
      Navigator.pop(context, value);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      key: const Key('name-input'),
      controller: _text,
      autofocus: true,
      maxLength: 255,
      decoration: const InputDecoration(
        hintText: 'Name',
        border: OutlineInputBorder(),
      ),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(onPressed: _submit, child: const Text('Save')),
    ],
  );
}

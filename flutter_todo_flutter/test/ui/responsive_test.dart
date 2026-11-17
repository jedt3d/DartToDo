import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_flutter/data/task_queries.dart';

import '../data/fixtures.dart';
import 'support.dart';

typedef _Device = ({
  String name,
  Size size,
  FakeViewPadding safe,
  double keyboard,
  bool phone,
});

const _devices = <_Device>[
  (
    name: 'phone portrait',
    size: Size(390, 844),
    safe: FakeViewPadding(top: 59, bottom: 34),
    keyboard: 320,
    phone: true,
  ),
  (
    name: 'phone landscape',
    size: Size(852, 393),
    safe: FakeViewPadding(left: 44, right: 44, bottom: 21),
    keyboard: 200,
    phone: true,
  ),
  (
    name: 'iPad portrait',
    size: Size(834, 1194),
    safe: FakeViewPadding(top: 24, bottom: 20),
    keyboard: 340,
    phone: false,
  ),
  (
    name: 'iPad landscape',
    size: Size(1194, 834),
    safe: FakeViewPadding(top: 24, bottom: 20),
    keyboard: 340,
    phone: false,
  ),
];

void _setInsets(WidgetTester tester, _Device device, {bool keyboard = false}) {
  tester.view.viewPadding = device.safe;
  tester.view.padding = FakeViewPadding(
    top: device.safe.top,
    left: device.safe.left,
    right: device.safe.right,
    bottom: keyboard ? 0 : device.safe.bottom,
  );
  tester.view.viewInsets = FakeViewPadding(
    bottom: keyboard ? device.keyboard : 0,
  );
}

void _resetInsetsAfterTest(WidgetTester tester) {
  addTearDown(() {
    tester.view.resetPadding();
    tester.view.resetViewPadding();
    tester.view.resetViewInsets();
  });
}

String _fieldText(WidgetTester tester, String key) =>
    tester.widget<TextField>(find.byKey(Key(key))).controller!.text;

Future<void> _showNotes(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const Key('task-notes')),
    150,
    scrollable: find
        .descendant(
          of: find.byType(ListView).last,
          matching: find.byType(Scrollable),
        )
        .first,
  );
}

Finder _dialogButton(String label) => find.descendant(
  of: find.byType(AlertDialog),
  matching: find.widgetWithText(TextButton, label),
);

void _expectDialogAboveKeyboard(WidgetTester tester, _Device device) {
  expect(tester.takeException(), isNull);
  final dialog = tester.getRect(
    find
        .descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(Material),
        )
        .first,
  );
  expect(dialog.top, greaterThanOrEqualTo(device.safe.top));
  expect(
    dialog.bottom,
    lessThanOrEqualTo(device.size.height - device.keyboard),
  );
}

Future<void> _showDialogControl(
  WidgetTester tester,
  _Device device,
  Finder control, {
  double minimumHeight = 44,
}) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(control);
  await tester.pumpAndSettle();
  expect(control.hitTestable(), findsOneWidget);
  final rect = tester.getRect(control);
  expect(rect.height, greaterThanOrEqualTo(minimumHeight));
  expect(rect.top, greaterThanOrEqualTo(device.safe.top));
  expect(rect.bottom, lessThanOrEqualTo(device.size.height - device.keyboard));
  expect(rect.left, greaterThanOrEqualTo(device.safe.left));
  expect(rect.right, lessThanOrEqualTo(device.size.width - device.safe.right));
}

Future<void> _openTheme(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('list-options')));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Change Theme…'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Change Theme…'));
  await tester.pumpAndSettle();
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;

  for (final device in _devices) {
    testWidgets(
      '${device.name} exposes every panel inside safe insets at large text',
      (tester) async {
        _resetInsetsAfterTest(tester);
        _setInsets(tester, device);
        await pumpApp(tester, size: device.size, textScale: 1.5);
        final composer = tester.getRect(find.byKey(const Key('add-task')));
        expect(composer.left, greaterThanOrEqualTo(device.safe.left));
        expect(
          composer.right,
          lessThanOrEqualTo(device.size.width - device.safe.right),
        );
        expect(
          composer.bottom,
          lessThanOrEqualTo(device.size.height - device.safe.bottom),
        );
        expect(
          find.byKey(const Key('search-tasks')),
          device.phone ? findsNothing : findsOneWidget,
        );
        if (device.phone) {
          await tester.tap(find.text('Lists'));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('search-tasks')), findsOneWidget);
          await tester.tap(find.text('My Day'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byTooltip('Suggestions'));
        await tester.pumpAndSettle();
        expect(find.text('Suggestions'), findsOneWidget);
        final closeSuggestion = tester.getRect(
          find.byTooltip('Close suggestions'),
        );
        expect(closeSuggestion.top, greaterThanOrEqualTo(device.safe.top));
        await tester.tap(find.byTooltip('Close suggestions'));
        await tester.pumpAndSettle();
        await openDetails(tester);
        final singleContentPane = device.phone || device.size.width < 1050;
        expect(
          find.widgetWithText(TextButton, 'My Day'),
          singleContentPane ? findsOneWidget : findsNothing,
        );
        await _showNotes(tester);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Close details').first);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('add-task')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      '${device.name} keeps composer and detail editing usable above keyboard',
      (tester) async {
        _resetInsetsAfterTest(tester);
        _setInsets(tester, device);
        await pumpApp(tester, size: device.size, textScale: 1.5);
        await tester.tap(find.byKey(const Key('add-task')));
        _setInsets(tester, device, keyboard: true);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final composer = tester.getRect(find.byKey(const Key('add-task')));
        expect(
          composer.bottom,
          lessThanOrEqualTo(device.size.height - device.keyboard),
        );
        _setInsets(tester, device);
        await tester.pumpAndSettle();
        await openDetails(tester);
        final remainingComposer = find.byKey(const Key('add-task'));
        if (remainingComposer.evaluate().isNotEmpty) {
          expect(
            tester.widget<TextField>(remainingComposer).focusNode!.hasFocus,
            isFalse,
          );
        }
        await _showNotes(tester);
        await tester.enterText(
          find.byKey(const Key('task-notes')),
          'Keyboard draft',
        );
        _setInsets(tester, device, keyboard: true);
        await tester.pumpAndSettle();
        expect(_fieldText(tester, 'task-notes'), 'Keyboard draft');
        expect(
          find.byTooltip('Close details').first.hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  for (final device in _devices) {
    testWidgets(
      '${device.name} keeps sidebar and Suggestions navigation reachable with keyboard',
      (tester) async {
        _resetInsetsAfterTest(tester);
        _setInsets(tester, device);
        await pumpApp(tester, size: device.size, textScale: 1.5);
        if (device.phone) {
          await tester.tap(find.text('Lists'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const Key('search-tasks')));
        _setInsets(tester, device, keyboard: true);
        await tester.pumpAndSettle();
        final search = tester.getRect(find.byKey(const Key('search-tasks')));
        expect(search.left, greaterThanOrEqualTo(device.safe.left));
        expect(search.top, greaterThanOrEqualTo(device.safe.top));
        expect(
          search.bottom,
          lessThanOrEqualTo(device.size.height - device.keyboard),
        );
        if (device.phone && device.size.width > device.size.height) {
          expect(find.byTooltip('Settings').hitTestable(), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('My Day').first);
        await tester.pumpAndSettle();
        expect(find.byTooltip('Suggestions').hitTestable(), findsOneWidget);
        await tester.tap(find.byTooltip('Suggestions'));
        await tester.pumpAndSettle();
        final close = find.byTooltip('Close suggestions');
        expect(close.hitTestable(), findsOneWidget);
        final closeRect = tester.getRect(close);
        expect(closeRect.top, greaterThanOrEqualTo(device.safe.top));
        expect(
          closeRect.bottom,
          lessThanOrEqualTo(device.size.height - device.keyboard),
        );
        expect(tester.takeException(), isNull);
        await tester.tap(close);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('add-task')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  testWidgets(
    'long title and notes remain scrollable in phone landscape with keyboard',
    (tester) async {
      final device = _devices[1];
      _resetInsetsAfterTest(tester);
      _setInsets(tester, device);
      const title =
          'Prepare the complete architecture review and implementation plan '
          'for the next release across every supported platform';
      final repository = await pumpApp(
        tester,
        size: device.size,
        textScale: 1.5,
        data: uiData(
          tasks: [
            task(id: 1, title: title, myDay: localDateKey(DateTime.now())),
          ],
        ),
      );
      await openDetails(tester, title: title);
      await tester.tap(find.byKey(const Key('task-title')));
      _setInsets(tester, device, keyboard: true);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _showNotes(tester);
      await tester.enterText(
        find.byKey(const Key('task-notes')),
        'A note reached by scrolling past the long title',
      );
      await tester.tap(find.byTooltip('Close details').first);
      await tester.pumpAndSettle();
      expect(
        repository.data.tasks.single.notes,
        'A note reached by scrolling past the long title',
      );
      expect(find.byKey(const Key('task-title')), findsNothing);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  for (final device in _devices.where((device) => device.phone)) {
    testWidgets(
      '${device.name} Settings saves an edited name above keyboard at large text',
      (tester) async {
        _resetInsetsAfterTest(tester);
        _setInsets(tester, device);
        final repository = await pumpApp(
          tester,
          size: device.size,
          textScale: 1.5,
        );
        await tester.tap(find.text('Lists'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Local account'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('display-name')));
        _setInsets(tester, device, keyboard: true);
        await tester.pumpAndSettle();
        _expectDialogAboveKeyboard(tester, device);
        await _showDialogControl(
          tester,
          device,
          find.byKey(const Key('display-name')),
        );
        await tester.tap(find.byKey(const Key('display-name')));
        await tester.enterText(
          find.byKey(const Key('display-name')),
          'Responsive local user',
        );
        await _showDialogControl(tester, device, _dialogButton('Save'));
        await tester.tap(_dialogButton('Save'));
        await tester.pumpAndSettle();
        expect(repository.data.settings.displayName, 'Responsive local user');
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      '${device.name} Change Theme selects a colour with keyboard and large text',
      (tester) async {
        _resetInsetsAfterTest(tester);
        _setInsets(tester, device);
        final repository = await pumpApp(
          tester,
          size: device.size,
          textScale: 1.5,
        );
        await tester.tap(find.text('Lists'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Important'));
        await tester.pumpAndSettle();
        await _openTheme(tester);
        _setInsets(tester, device, keyboard: true);
        await tester.pumpAndSettle();
        _expectDialogAboveKeyboard(tester, device);
        final green = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'green theme',
        );
        await _showDialogControl(tester, device, green);
        await tester.tap(green);
        await tester.pumpAndSettle();
        expect(repository.data.settings.smartThemes['important'], 'green');
        expect(find.byType(AlertDialog), findsNothing);
        await _openTheme(tester);
        await _showDialogControl(tester, device, _dialogButton('Done'));
        await tester.tap(_dialogButton('Done'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      '${device.name} New List saves entered name above keyboard at large text',
      (tester) async {
        _resetInsetsAfterTest(tester);
        _setInsets(tester, device);
        final repository = await pumpApp(
          tester,
          size: device.size,
          textScale: 1.5,
        );
        await tester.tap(find.text('Lists'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('new-list')));
        await tester.pumpAndSettle();
        _setInsets(tester, device, keyboard: true);
        await tester.pumpAndSettle();
        _expectDialogAboveKeyboard(tester, device);
        await _showDialogControl(
          tester,
          device,
          find.byKey(const Key('name-input')),
        );
        await tester.tap(find.byKey(const Key('name-input')));
        await tester.enterText(
          find.byKey(const Key('name-input')),
          'Responsive list',
        );
        await _showDialogControl(tester, device, _dialogButton('Save'));
        await tester.tap(_dialogButton('Save'));
        await tester.pumpAndSettle();
        expect(
          repository.data.lists.where(
            (list) => list.title == 'Responsive list',
          ),
          hasLength(1),
        );
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Responsive list'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      '${device.name} Custom Repeat saves interval and unit with keyboard and large text',
      (tester) async {
        _resetInsetsAfterTest(tester);
        _setInsets(tester, device);
        final repository = await pumpApp(
          tester,
          size: device.size,
          textScale: 1.5,
        );
        await openDetails(tester);
        await tester.scrollUntilVisible(
          find.byTooltip('Choose repeat'),
          120,
          scrollable: find
              .descendant(
                of: find.byType(ListView).last,
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.tap(find.byTooltip('Choose repeat'));
        await tester.pumpAndSettle();
        final custom = find.widgetWithText(
          CheckedPopupMenuItem<String>,
          'Custom…',
        );
        await tester.ensureVisible(custom);
        await tester.pumpAndSettle();
        await tester.tap(custom);
        await tester.pumpAndSettle();
        _setInsets(tester, device, keyboard: true);
        await tester.pumpAndSettle();
        _expectDialogAboveKeyboard(tester, device);
        await _showDialogControl(
          tester,
          device,
          find.byKey(const Key('repeat-every')),
        );
        await tester.tap(find.byKey(const Key('repeat-every')));
        await tester.enterText(find.byKey(const Key('repeat-every')), '3');
        await _showDialogControl(
          tester,
          device,
          find.byKey(const Key('repeat-unit')),
        );
        await tester.tap(find.byKey(const Key('repeat-unit')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('months').last);
        await tester.tap(find.text('months').last);
        await tester.pumpAndSettle();
        await _showDialogControl(tester, device, _dialogButton('Save'));
        await tester.tap(_dialogButton('Save'));
        await tester.pumpAndSettle();
        expect(repository.data.tasks.single.repeat, 'monthly');
        expect(repository.data.tasks.single.repeatEvery, 3);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  for (final action in ['Escape', 'search', 'suggestions']) {
    testWidgets(
      'failed notes flush keeps editor and draft when leaving through $action',
      (tester) async {
        final repository = await pumpApp(tester, size: const Size(1200, 800));
        await openDetails(tester);
        repository.saveError = StateError('Write fixture unavailable');
        await _showNotes(tester);
        final draft = 'Keep the draft after $action';
        await tester.enterText(find.byKey(const Key('task-notes')), draft);
        switch (action) {
          case 'Escape':
            await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          case 'search':
            await tester.enterText(
              find.byKey(const Key('search-tasks')),
              'Focus',
            );
          case 'suggestions':
            await tester.tap(find.byTooltip('Suggestions'));
        }
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();
        expect(repository.saveCalls, greaterThan(0));
        expect(find.byKey(const Key('task-notes')), findsOneWidget);
        expect(_fieldText(tester, 'task-notes'), draft);
        expect(repository.data.tasks.single.notes, isEmpty);
        expect(find.textContaining('Could not save.'), findsWidgets);
        repository.saveError = null;
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('task-notes')), findsNothing);
        expect(repository.data.tasks.single.notes, draft);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('blank title restoration still saves edited notes on close', (
    tester,
  ) async {
    final repository = await pumpApp(tester);
    await openDetails(tester);
    await _showNotes(tester);
    await tester.enterText(
      find.byKey(const Key('task-notes')),
      'Preserve notes with an empty title',
    );
    await tester.enterText(find.byKey(const Key('task-title')), '');
    await tester.tap(find.byTooltip('Close details').first);
    await tester.pumpAndSettle();
    expect(repository.data.tasks.single.title, 'Focus task');
    expect(
      repository.data.tasks.single.notes,
      'Preserve notes with an empty title',
    );
    expect(find.byKey(const Key('task-notes')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Completed view remains visible when ordinary completed sections are hidden',
    (tester) async {
      final today = localDateKey(DateTime.now());
      final data = uiData(
        tasks: [
          task(id: 1, title: 'Already done', myDay: today, completed: true),
          task(id: 2, title: 'Still open', myDay: today),
        ],
      );
      data.settings = data.settings.copyWith(showCompleted: false);
      await pumpApp(tester, data: data);
      expect(find.text('Already done'), findsNothing);
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      expect(find.text('Already done'), findsOneWidget);
      expect(find.byTooltip('Mark Already done incomplete'), findsOneWidget);
      expect(find.text('Still open'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'compact search restores its retained query after returning from results',
    (tester) async {
      await pumpApp(tester, size: const Size(390, 844));
      await tester.tap(find.text('Lists'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('search-tasks')), 'Focus');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('search-tasks')), findsNothing);
      expect(find.text('Focus task'), findsOneWidget);
      await tester.tap(find.text('Lists'));
      await tester.pumpAndSettle();
      expect(_fieldText(tester, 'search-tasks'), 'Focus');
      expect(find.byTooltip('Clear search'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'late task creation does not steal focus from selected detail notes',
    (tester) async {
      final repository = await pumpApp(tester, size: const Size(1200, 800));
      repository.saveGate = Completer<void>();
      await tester.enterText(
        find.byKey(const Key('add-task')),
        'Queued new task',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.tap(find.text('Focus task'));
      await tester.pump();
      await _showNotes(tester);
      await tester.tap(find.byKey(const Key('task-notes')));
      await tester.pump();
      final notesFocus = tester
          .widget<TextField>(find.byKey(const Key('task-notes')))
          .focusNode!;
      expect(notesFocus.hasFocus, isTrue);
      repository.saveGate!.complete();
      await tester.pumpAndSettle();
      expect(
        repository.data.tasks.any((task) => task.title == 'Queued new task'),
        isTrue,
      );
      expect(notesFocus.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}

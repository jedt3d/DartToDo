import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_flutter/ui/todo_app.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  final previews = <String, WidgetBuilder>{
    'previewEmptyDetails': previewEmptyDetails,
    'previewTaskMoveHandle': previewTaskMoveHandle,
    'previewAppDefault': previewAppDefault,
    'previewAppLoading': previewAppLoading,
    'previewAppError': previewAppError,
    'previewFailure': previewFailure,
    'previewSidebar': previewSidebar,
    'previewNavigationSelected': previewNavigationSelected,
    'previewNavigationDefault': previewNavigationDefault,
    'previewTaskPane': previewTaskPane,
    'previewTaskPaneEmpty': previewTaskPaneEmpty,
    'previewTaskPaneSearch': previewTaskPaneSearch,
    'previewTaskPaneCompleted': previewTaskPaneCompleted,
    'previewTaskPanePhoto': previewTaskPanePhoto,
    'previewHeaderButton': previewHeaderButton,
    'previewTaskRow': previewTaskRow,
    'previewTaskRowSelected': previewTaskRowSelected,
    'previewTaskRowCompleted': previewTaskRowCompleted,
    'previewCheckOpen': previewCheckOpen,
    'previewCheckComplete': previewCheckComplete,
    'previewComposer': previewComposer,
    'previewComposerSaving': previewComposerSaving,
    'previewComposerError': previewComposerError,
    'previewEmptyState': previewEmptyState,
    'previewSuggestions': previewSuggestions,
    'previewSuggestionsEmpty': previewSuggestionsEmpty,
    'previewTaskDetails': previewTaskDetails,
    'previewTaskDetailsCompleted': previewTaskDetailsCompleted,
    'previewDetailAction': previewDetailAction,
    'previewDetailActionActive': previewDetailActionActive,
    'previewSettings': previewSettings,
    'previewSettingsDark': previewSettingsDark,
    'previewThemeDialog': previewThemeDialog,
    'previewRepeatDialog': previewRepeatDialog,
    'previewNameDialog': previewNameDialog,
  };

  Future<void> exercisePreview(
    MapEntry<String, WidgetBuilder> entry,
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(Builder(builder: entry.value));
      if (entry.key == 'previewAppLoading') {
        await tester.pump(const Duration(milliseconds: 100));
      } else {
        await tester.pumpAndSettle();
      }
      switch (entry.key) {
        case 'previewEmptyDetails':
          expect(find.text('No task selected'), findsOneWidget);
          expect(find.byKey(const Key('task-title')), findsNothing);
        case 'previewTaskMoveHandle':
          expect(find.byTooltip('Drag to another list'), findsOneWidget);
          final move = find.byKey(const ValueKey('move-task-1'));
          final gesture = await tester.startGesture(tester.getCenter(move));
          await tester.pump(
            kLongPressTimeout + const Duration(milliseconds: 100),
          );
          await gesture.moveBy(const Offset(100, 100));
          await tester.pump();
          expect(find.text('Plan the week'), findsOneWidget);
          await gesture.up();
          await tester.pumpAndSettle();
          expect(find.text('Plan the week'), findsNothing);
        case 'previewAppDefault':
          expect(find.text('Plan the week'), findsOneWidget);
          expect(find.byKey(const Key('add-task')), findsOneWidget);
          expect(find.text('Read a book'), findsOneWidget);
        case 'previewAppLoading':
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.byKey(const Key('add-task')), findsNothing);
        case 'previewAppError':
          expect(
            find.text('Couldn’t connect to your local server'),
            findsOneWidget,
          );
          expect(find.text('Try again'), findsOneWidget);
        case 'previewFailure':
          expect(find.text('Connection refused'), findsOneWidget);
          expect(find.text('Try again'), findsOneWidget);
        case 'previewSidebar':
          expect(find.text('Personal'), findsOneWidget);
          expect(find.text('Work'), findsOneWidget);
          expect(find.text('Home'), findsOneWidget);
          expect(find.byKey(const Key('search-tasks')), findsOneWidget);
        case 'previewNavigationSelected':
          expect(find.text('2'), findsOneWidget);
          expect(
            tester
                .getSemantics(
                  find.bySemanticsLabel(RegExp('My Day, 2 tasks')).first,
                )
                .flagsCollection
                .isSelected,
            Tristate.isTrue,
          );
        case 'previewNavigationDefault':
          expect(find.text('Tasks'), findsOneWidget);
          expect(find.text('5'), findsOneWidget);
          expect(
            tester
                .getSemantics(
                  find.bySemanticsLabel(RegExp('Tasks, 5 tasks')).first,
                )
                .flagsCollection
                .isSelected,
            Tristate.isFalse,
          );
        case 'previewTaskPane':
          expect(find.text('Plan the week'), findsOneWidget);
          expect(find.text('Pick up groceries'), findsOneWidget);
          expect(find.text('Completed 1'), findsOneWidget);
        case 'previewTaskPaneEmpty':
          expect(find.byKey(const Key('add-task')), findsOneWidget);
          expect(find.text('Plan the week'), findsNothing);
          expect(find.text('Completed 1'), findsNothing);
        case 'previewTaskPaneSearch':
          expect(find.text('No results'), findsOneWidget);
          expect(find.text('Results for “unknown”'), findsOneWidget);
        case 'previewTaskPaneCompleted':
          expect(find.text('Completed 1'), findsOneWidget);
          expect(find.text('Read a book'), findsOneWidget);
          expect(find.text('Plan the week'), findsNothing);
        case 'previewTaskPanePhoto':
          expect(find.text('Photo by Fixture photographer'), findsOneWidget);
          expect(find.text('on Unsplash'), findsOneWidget);
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is DecoratedBox &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration as BoxDecoration).image?.image
                      is MemoryImage,
            ),
            findsOneWidget,
          );
        case 'previewHeaderButton':
          expect(find.byTooltip('Suggestions'), findsOneWidget);
        case 'previewTaskRow' || 'previewTaskRowSelected':
          expect(find.text('Plan the week'), findsOneWidget);
          expect(find.textContaining('1 of 2'), findsOneWidget);
          expect(find.byTooltip('Remove importance'), findsOneWidget);
          if (entry.key == 'previewTaskRowSelected') {
            final material = tester.widget<Material>(
              find
                  .ancestor(
                    of: find.text('Plan the week'),
                    matching: find.byType(Material),
                  )
                  .first,
            );
            expect(material.color, isNot(Colors.white));
          }
        case 'previewTaskRowCompleted':
          expect(find.text('Read a book'), findsOneWidget);
          expect(
            tester.widget<Text>(find.text('Read a book')).style!.decoration,
            TextDecoration.lineThrough,
          );
          expect(
            find.byTooltip('Mark Read a book incomplete'),
            findsOneWidget,
          );
        case 'previewCheckOpen' || 'previewCheckComplete':
          final completed = entry.key == 'previewCheckComplete';
          final node = tester.getSemantics(
            find
                .bySemanticsLabel(
                  RegExp(
                    completed
                        ? 'Mark preview task incomplete'
                        : 'Complete preview task',
                  ),
                )
                .first,
          );
          expect(
            node.flagsCollection.isChecked,
            completed ? CheckedState.isTrue : CheckedState.isFalse,
          );
        case 'previewComposer' ||
            'previewComposerSaving' ||
            'previewComposerError':
          await tester.enterText(
            find.byKey(const Key('add-task')),
            'Preview draft',
          );
          await tester.testTextInput.receiveAction(TextInputAction.done);
          if (entry.key == 'previewComposerSaving') {
            await tester.pump();
            expect(find.byType(CircularProgressIndicator), findsOneWidget);
            expect(
              tester.widget<IconButton>(find.byType(IconButton)).onPressed,
              isNull,
            );
          } else {
            await tester.pumpAndSettle();
            final text = tester
                .widget<TextField>(find.byKey(const Key('add-task')))
                .controller!
                .text;
            if (entry.key == 'previewComposerError') {
              expect(
                find.textContaining('Preview write failure'),
                findsOneWidget,
              );
              expect(text, 'Preview draft');
            } else {
              expect(text, isEmpty);
            }
          }
        case 'previewEmptyState':
          expect(find.text('No results'), findsOneWidget);
          expect(
            find.text('Try searching for a different word.'),
            findsOneWidget,
          );
        case 'previewSuggestions':
          expect(find.text('Pick up groceries'), findsOneWidget);
          expect(
            find.byTooltip('Add Pick up groceries to My Day'),
            findsOneWidget,
          );
        case 'previewSuggestionsEmpty':
          expect(find.text('You’re all caught up.'), findsOneWidget);
          expect(find.text('Pick up groceries'), findsNothing);
        case 'previewTaskDetails':
          expect(
            tester
                .widget<TextField>(find.byKey(const Key('task-title')))
                .controller!
                .text,
            'Plan the week',
          );
          expect(
            find.byTooltip('Complete step Review the calendar'),
            findsOneWidget,
          );
          expect(find.text('readme.txt'), findsOneWidget);
          expect(
            tester
                .widget<TextField>(find.byKey(const Key('task-notes')))
                .controller!
                .text,
            'Choose three things that matter.',
          );
        case 'previewTaskDetailsCompleted':
          expect(
            tester
                .widget<TextField>(find.byKey(const Key('task-title')))
                .controller!
                .text,
            'Read a book',
          );
          expect(find.byTooltip('Mark incomplete'), findsOneWidget);
          expect(find.text('readme.txt'), findsNothing);
        case 'previewDetailAction':
          expect(find.text('Add to My Day'), findsOneWidget);
        case 'previewDetailActionActive':
          expect(find.text('Added to My Day'), findsOneWidget);
        case 'previewSettings' || 'previewSettingsDark':
          expect(find.text('Settings'), findsOneWidget);
          expect(
            tester
                .widget<TextField>(find.byKey(const Key('display-name')))
                .controller!
                .text,
            'Local user',
          );
          expect(
            tester
                .widget<SwitchListTile>(
                  find.widgetWithText(SwitchListTile, 'Dark appearance'),
                )
                .value,
            entry.key == 'previewSettingsDark',
          );
        case 'previewThemeDialog':
          expect(find.text('Change Theme'), findsOneWidget);
          expect(find.text('Colours'), findsOneWidget);
          expect(find.text('Photos'), findsOneWidget);
          expect(
            tester
                .getSemantics(find.bySemanticsLabel('blue theme'))
                .flagsCollection
                .isSelected,
            Tristate.isTrue,
          );
        case 'previewRepeatDialog':
          expect(find.text('Custom repeat'), findsOneWidget);
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            '3',
          );
        case 'previewNameDialog':
          expect(find.text('New list'), findsOneWidget);
          expect(
            tester
                .widget<TextField>(find.byKey(const Key('name-input')))
                .controller!
                .text,
            'Weekend',
          );
          await tester.enterText(
            find.byKey(const Key('name-input')),
            '  Saturday  ',
          );
          await tester.tap(find.widgetWithText(TextButton, 'Save'));
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsNothing);
      }
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  }

  for (final entry in previews.entries) {
    testWidgets(
      'catalog ${entry.key}',
      (tester) => exercisePreview(entry, tester),
    );
  }
  const statePreviews = <String, List<String>>{
    'default': [
      'previewTaskMoveHandle',
      'previewAppDefault',
      'previewComposer',
      'previewDetailAction',
      'previewHeaderButton',
      'previewNameDialog',
      'previewNavigationDefault',
      'previewSettings',
      'previewSidebar',
      'previewSuggestions',
      'previewTaskDetails',
      'previewTaskPane',
      'previewTaskRow',
      'previewThemeDialog',
    ],
    'custom': ['previewRepeatDialog'],
    'dark': ['previewSettingsDark'],
    'selected': ['previewNavigationSelected', 'previewTaskRowSelected'],
    'active': ['previewDetailActionActive'],
    'completed': [
      'previewTaskDetailsCompleted',
      'previewTaskPaneCompleted',
      'previewTaskRowCompleted',
    ],
    'unchecked': ['previewCheckOpen'],
    'checked': ['previewCheckComplete'],
    'saving': ['previewComposerSaving'],
    'error': ['previewAppError', 'previewComposerError', 'previewFailure'],
    'search-empty': ['previewEmptyState', 'previewTaskPaneSearch'],
    'empty': [
      'previewEmptyDetails',
      'previewSuggestionsEmpty',
      'previewTaskPaneEmpty',
    ],
    'loading': ['previewAppLoading'],
    'photo': ['previewTaskPanePhoto'],
  };
  for (final state in statePreviews.entries) {
    testWidgets('catalog state ${state.key}', (tester) async {
      for (final name in state.value) {
        await exercisePreview(MapEntry(name, previews[name]!), tester);
      }
    });
  }
}

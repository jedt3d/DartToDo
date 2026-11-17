import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_flutter/widgetbook.dart' as catalog;
import 'package:widgetbook/widgetbook.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets('Widgetbook opens an in-library private component preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    catalog.main();
    await tester.pumpAndSettle();
    expect(find.byType(Widgetbook), findsOneWidget);
    await tester.tap(find.text('_NameDialog'));
    await tester.pumpAndSettle();
    expect(find.text('New list'), findsOneWidget);
    expect(find.byKey(const Key('name-input')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

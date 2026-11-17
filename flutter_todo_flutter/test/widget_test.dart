import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui/support.dart';

void main() {
  testWidgets('local app starts with an actionable task composer', (
    tester,
  ) async {
    await pumpApp(tester, data: uiData(tasks: []));
    expect(find.byKey(const Key('add-task')), findsOneWidget);
    expect(find.byTooltip('Add task'), findsOneWidget);
    expect(find.text('Local account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import 'test_helpers.dart';

void main() {
  for (final mode in DropdownMode.values) {
    testWidgets('standalone Material search borders work in $mode', (
      tester,
    ) async {
      const border = OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      );
      const focusedBorder = OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      );

      await tester.pumpWidget(
        buildTestApp(
          MultiDropdown<int>(
            items: createItems(),
            dropdownMode: mode,
            searchEnabled: true,
            fieldDecoration: const FieldDecoration(
              inputDecoration: InputDecoration(labelText: 'Choose items'),
            ),
            searchDecoration: const SearchFieldDecoration(
              border: border,
              focusedBorder: focusedBorder,
            ),
          ),
        ),
      );

      expect(find.text('Choose items'), findsOneWidget);
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      final search = find.byType(TextField);
      expect(search, findsOneWidget);
      final decoration = tester.widget<TextField>(search).decoration!;
      expect(decoration.border, same(border));
      expect(decoration.focusedBorder, same(focusedBorder));

      await tester.tap(search);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );

      await tester.enterText(search, 'Item 3');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Item 3'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Item 1'), findsNothing);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('null search borders are passed through', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        MultiDropdown<int>(
          items: createItems(),
          searchEnabled: true,
          searchDecoration: const SearchFieldDecoration(
            border: null,
            focusedBorder: null,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    final decoration = tester
        .widget<TextField>(find.byType(TextField))
        .decoration!;
    expect(decoration.border, isNull);
    expect(decoration.focusedBorder, isNull);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:measured_card_table/measured_card_table.dart';

void main() {
  test('controller stores only growing finite widths', () {
    final controller = MeasuredCardTableController();

    controller.applyMeasurement('name', 10);
    expect(controller.widthFor('name'), 12);

    controller.applyMeasurement('name', 5);
    expect(controller.widthFor('name'), 12);

    controller.applyMeasurement('name', double.nan);
    expect(controller.widthFor('name'), 12);

    controller.applyMeasurement('name', double.infinity);
    expect(controller.widthFor('name'), 12);

    controller.applyMeasurement('', 100);
    expect(controller.widthFor(''), 0);

    controller.reset();
    expect(controller.widthFor('name'), 0);

    controller.dispose();
  });

  testWidgets('renders rows and cells', (tester) async {
    const rows = ['one', 'two'];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MeasuredCardTable<String>(
          rows: rows,
          columns: [
            CardTableColumn<String>(
              id: 'value',
              fallbackWidth: 100,
              builder: (context, row) => Text(row),
            ),
          ],
          rowBuilder: (context, row, cells) => cells,
        ),
      ),
    );

    expect(find.text('one'), findsWidgets);
    expect(find.text('two'), findsWidgets);
  });
}
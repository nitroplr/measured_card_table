# measured_card_table

A Flutter widget for building responsive card-based tables with consistently measured cell widths.

`MeasuredCardTable` is useful when you want table-like alignment without forcing a traditional horizontal table layout. Each row is rendered as your own card or panel, while cells wrap responsively based on the available width.

## Features

- Consistent measured widths for matching cells across rows
- Responsive wrapping for narrow screens
- Custom row and card builders
- Optional external measurement controller
- No runtime dependencies beyond Flutter

## Example

```dart
MeasuredCardTable<Order>(
  rows: orders,
  columns: [
    CardTableColumn<Order>(
      id: 'seller',
      fallbackWidth: 180,
      builder: (context, order) => Text(order.seller),
    ),
    CardTableColumn<Order>(
      id: 'price',
      fallbackWidth: 140,
      builder: (context, order) => Text(order.price),
    ),
  ],
  rowBuilder: (context, order, cells) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: cells,
      ),
    );
  },
)
```

## Usage

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  measured_card_table: ^0.0.1
```

Import it:

```dart
import 'package:measured_card_table/measured_card_table.dart';
```

Create columns with stable ids:

```dart
final columns = [
  CardTableColumn<Order>(
    id: 'seller',
    fallbackWidth: 180,
    builder: (context, order) => Text(order.seller),
  ),
  CardTableColumn<Order>(
    id: 'price',
    fallbackWidth: 140,
    builder: (context, order) => Text(order.price),
  ),
];
```

Use those columns in a table:

```dart
MeasuredCardTable<Order>(
  rows: orders,
  columns: columns,
  rowBuilder: (context, order, cells) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: cells,
      ),
    );
  },
)
```

## Controller

You can provide a `MeasuredCardTableController` when you want to reset measurements or share measurements between compatible tables.

```dart
final controller = MeasuredCardTableController();

MeasuredCardTable<Order>(
  controller: controller,
  rows: orders,
  columns: columns,
  rowBuilder: (context, order, cells) => Card(child: cells),
);

// Later:
controller.reset();
```

## Notes

Column ids should be stable. If the set or order of column ids changes, the table resets its measured widths.

See the `example` directory for a complete Flutter app.
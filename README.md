# measured_card_table

Responsive card-table layout widgets for Flutter with consistently measured cell widths.

This package is meant for UI layouts where you want the visual consistency of a table,
but the flexibility of cards that wrap naturally on smaller screens.

- render each row as your own card, panel, or custom widget
- keep matching cells aligned across rows by sharing measured widths
- let cells wrap into multiple runs when horizontal space is limited

> If you have order cards, profile summaries, marketplace listings, or metric-heavy rows,
> this package helps them stay visually aligned without forcing a traditional table layout.

## Features

### `MeasuredCardTable<T>`

Build responsive rows from your own data model.

- generic row type
- custom row/card builder
- responsive wrapping with configurable spacing
- optional `MeasuredCardTableController`
- resets measurements when the column id set changes

### `CardTableColumn<T>`

Describe one logical cell/column.

- stable `id` for width measurement
- `fallbackWidth` before measurement is available
- custom cell builder
- configurable alignment

### `MeasuredCardTableController`

Share or reset measured column widths.

- provide a controller manually when needed
- call `reset()` when external content changes significantly
- omit it when the table can manage measurements internally

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  measured_card_table: ^0.0.1
```

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:measured_card_table/measured_card_table.dart';

class Order {
  final String seller;
  final String price;

  const Order({
    required this.seller,
    required this.price,
  });
}

final orders = [
  Order(seller: 'Aradune Trader', price: '2 Krono'),
  Order(seller: 'Very Long Character Name Trader', price: '999,999 Platinum'),
];

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return MeasuredCardTable<Order>(
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
    );
  }
}
```

## Create reusable columns

```dart
import 'package:flutter/material.dart';
import 'package:measured_card_table/measured_card_table.dart';

class Order {
  final String seller;
  final String price;

  const Order({required this.seller, required this.price});
}

List<CardTableColumn<Order>> buildOrderColumns() {
  return [
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
}
```

## Use a controller

```dart
import 'package:flutter/material.dart';
import 'package:measured_card_table/measured_card_table.dart';

class Order {
  final String seller;

  const Order({required this.seller});
}

class OrdersWithController extends StatefulWidget {
  const OrdersWithController({super.key});

  @override
  State<OrdersWithController> createState() => _OrdersWithControllerState();
}

class _OrdersWithControllerState extends State<OrdersWithController> {
  final controller = MeasuredCardTableController();

  final orders = const [
    Order(seller: 'Aradune Trader'),
    Order(seller: 'Very Long Character Name Trader'),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MeasuredCardTable<Order>(
      controller: controller,
      rows: orders,
      columns: [
        CardTableColumn<Order>(
          id: 'seller',
          fallbackWidth: 180,
          builder: (context, order) => Text(order.seller),
        ),
      ],
      rowBuilder: (context, order, cells) => Card(child: cells),
    );
  }

  void resetMeasurements() {
    controller.reset();
  }
}
```

## Concepts

**Rows**

Each value in `rows` is passed to every column builder and to `rowBuilder`.

**Columns**

Each `CardTableColumn` represents one logical cell in every row. Use stable ids,
such as `seller`, `price`, or `status`.

**Fallback Widths**

`fallbackWidth` is used before measured content widths are available. After layout,
the table grows each column width to fit the widest measured content for that column.

**Wrapping**

Cells are placed in a `Wrap`, so narrow layouts naturally move cells onto additional
runs instead of overflowing horizontally.

**Controller Lifetime**

If you do not pass a controller, the table creates and disposes its own controller.
If you do pass one, you own its lifetime.

## When to use this package

- You want card rows with table-like alignment
- You want responsive wrapping instead of horizontal scrolling
- You want custom row/card layouts
- You have repeated metric-style cells

## When NOT to use this package

- You need a full data table with sorting/pagination
- You need virtualization for thousands of visible rows
- You need strict non-wrapping grid columns

## Notes

Column ids should be stable. If the set or order changes, measurements reset.

For large lists, combine with your own pagination or virtualization.

See the example directory for a full app.

## License

MIT. See LICENSE.
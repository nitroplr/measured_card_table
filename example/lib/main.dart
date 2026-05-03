import 'package:flutter/material.dart';
import 'package:measured_card_table/measured_card_table.dart';

import 'example_order.dart';
import 'example_orders.dart';
import 'example_shell.dart';
import 'metric_tile.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Measured Card Table Example',
      debugShowCheckedModeBanner: false,
      home: ExampleShell(
        child: MeasuredCardTable<ExampleOrder>(
          rows: exampleOrders,
          gap: 12,
          rowGap: 12,
          columns: [
            CardTableColumn(
              id: 'seller',
              fallbackWidth: 230,
              builder: _sellerCell,
            ),
            CardTableColumn(
              id: 'server',
              fallbackWidth: 210,
              builder: _serverCell,
            ),
            CardTableColumn(
              id: 'price',
              fallbackWidth: 240,
              builder: _priceCell,
            ),
            CardTableColumn(
              id: 'quantity',
              fallbackWidth: 115,
              builder: _quantityCell,
            ),
            CardTableColumn(
              id: 'status',
              fallbackWidth: 130,
              builder: _statusCell,
            ),
          ],
          rowBuilder: _orderCard,
        ),
      ),
    );
  }
}

Widget _sellerCell(BuildContext context, ExampleOrder row) {
  return MetricTile(label: 'Seller', value: row.seller);
}

Widget _serverCell(BuildContext context, ExampleOrder row) {
  return MetricTile(label: 'Server', value: row.server);
}

Widget _priceCell(BuildContext context, ExampleOrder row) {
  return MetricTile(label: 'Price', value: row.price);
}

Widget _quantityCell(BuildContext context, ExampleOrder row) {
  return MetricTile(label: 'Quantity', value: row.quantity);
}

Widget _statusCell(BuildContext context, ExampleOrder row) {
  return MetricTile(
    label: 'Status',
    value: row.isOnline ? '● Online' : '○ Offline',
  );
}

Widget _orderCard(BuildContext context, ExampleOrder row, Widget cells) {
  return Card(
    margin: EdgeInsets.zero,
    color: const Color(0xFF122330),
    elevation: 8,
    shadowColor: Colors.black.withValues(alpha: 0.22),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(
        color: Colors.white.withValues(alpha: 0.08),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: cells,
    ),
  );
}

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
        child: _ResizableTableDemo(),
      ),
    );
  }
}

class _ResizableTableDemo extends StatefulWidget {
  const _ResizableTableDemo();

  @override
  State<_ResizableTableDemo> createState() => _ResizableTableDemoState();
}

class _ResizableTableDemoState extends State<_ResizableTableDemo> {
  static const double _minWidthFactor = 0.30;
  static const double _maxWidthFactor = 1.00;

  double _widthFactor = _maxWidthFactor;

  @override
  Widget build(BuildContext context) {
    final percent = (_widthFactor * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final tableWidth = availableWidth * _widthFactor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResizeControls(
              percent: percent,
              widthFactor: _widthFactor,
              minWidthFactor: _minWidthFactor,
              maxWidthFactor: _maxWidthFactor,
              onChanged: (value) {
                setState(() => _widthFactor = value);
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: tableWidth,
                child: const MeasuredCardTable<ExampleOrder>(
                  rows: exampleOrders,
                  gap: 0,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            ),
          ],
        );
      },
    );
  }
}

class _ResizeControls extends StatelessWidget {
  final int percent;
  final double widthFactor;
  final double minWidthFactor;
  final double maxWidthFactor;
  final ValueChanged<double> onChanged;

  const _ResizeControls({
    required this.percent,
    required this.widthFactor,
    required this.minWidthFactor,
    required this.maxWidthFactor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF122330),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Available card width: $percent%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              min: minWidthFactor,
              max: maxWidthFactor,
              divisions: 70,
              value: widthFactor,
              label: '$percent%',
              onChanged: onChanged,
            ),
          ],
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
      padding: EdgeInsets.all(8.0),
      child: cells,
    ),
  );
}

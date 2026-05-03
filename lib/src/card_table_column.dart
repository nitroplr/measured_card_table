import 'package:flutter/widgets.dart';

/// Describes one logical column in a [MeasuredCardTable].
class CardTableColumn<T> {
  /// Stable unique identifier for this column.
  ///
  /// Width measurements are stored by this value. Keep it stable across rebuilds.
  final String id;

  /// Width used before the column has been measured.
  final double fallbackWidth;

  /// Alignment for the visible cell content.
  final AlignmentGeometry alignment;

  /// Builds the cell widget for a row value.
  final Widget Function(BuildContext context, T row) builder;

  /// Creates a card table column.
  const CardTableColumn({
    required this.id,
    required this.fallbackWidth,
    required this.builder,
    this.alignment = Alignment.centerLeft,
  }) : assert(id.length > 0),
       assert(fallbackWidth >= 0);
}

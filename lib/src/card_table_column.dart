import 'package:flutter/widgets.dart';

/// Defines one logical column displayed by a measured card table.
class CardTableColumn<T> {
  /// Unique, stable identifier used to store this column's measured width.
  final String id;

  /// Width used until this column has been measured.
  final double fallbackWidth;

  /// Alignment applied inside the measured cell width.
  final AlignmentGeometry alignment;

  /// Builds this column's cell for the provided row.
  ///
  /// Do not return [Expanded], [Flexible], or other widgets that require a
  /// flex parent. The table controls cell width.
  final Widget Function(BuildContext context, T row) builder;

  /// Creates a measured card table column.
  const CardTableColumn({
    required this.id,
    required this.fallbackWidth,
    required this.builder,
    this.alignment = Alignment.centerLeft,
  }) : assert(id.length > 0),
       assert(fallbackWidth >= 0);
}

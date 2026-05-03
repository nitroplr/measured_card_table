import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Stores and shares measured column widths.
class MeasuredCardTableController extends ChangeNotifier {
  static const double _measurementPadding = 6;

  final Map<String, double> _widths = <String, double>{};

  /// Returns the measured width for a column.
  ///
  /// Returns zero when the column has not been measured yet.
  double widthFor(String columnId) => _widths[columnId] ?? 0;

  /// Stores a measured width for a column.
  ///
  /// Widths only increase until reset is called. This prevents cells from
  /// shrinking during rebuilds when shorter content is measured later.
  void applyMeasurement(String columnId, double width) {
    if (columnId.isEmpty || width <= 0 || width.isNaN || width.isInfinite) {
      return;
    }

    final double next = width.ceilToDouble() + _measurementPadding;
    final double current = _widths[columnId] ?? 0;

    if (next <= current) return;

    _widths[columnId] = math.max(current, next);
    notifyListeners();
  }

  /// Clears all measured widths.
  void reset() {
    if (_widths.isEmpty) return;

    _widths.clear();
    notifyListeners();
  }
}

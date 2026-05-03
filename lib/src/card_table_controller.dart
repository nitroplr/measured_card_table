import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Stores measured column widths for a [MeasuredCardTable].
///
/// A controller can be shared between tables that use the same logical columns,
/// or omitted to let the table manage its own measurements.
class MeasuredCardTableController extends ChangeNotifier {
  static const double _measurementPadding = 6;

  final Map<String, double> _widths = <String, double>{};

  /// Returns the measured width for [columnId], or zero if not measured yet.
  double widthFor(String columnId) => _widths[columnId] ?? 0;

  /// Applies a measured [width] for [columnId].
  ///
  /// Widths only grow until [reset] is called. This avoids visual jitter when
  /// rows with shorter content are rebuilt after wider content was measured.
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

  /// Clears all measured column widths.
  void reset() {
    if (_widths.isEmpty) return;

    _widths.clear();
    notifyListeners();
  }
}

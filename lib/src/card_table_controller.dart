import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Stores and shares measured column widths.
class MeasuredCardTableController extends ChangeNotifier {
  static const double _measurementPadding = 2;

  final Map<String, double> _widths = <String, double>{};

  bool _notificationScheduled = false;
  bool _disposed = false;

  /// Returns the measured width for a column.
  ///
  /// Returns zero when the column has not been measured yet.
  double widthFor(String columnId) => _widths[columnId] ?? 0;

  /// Whether at least one column has a measured width.
  bool get hasMeasurements => _widths.isNotEmpty;

  /// Stores a measured width for a column.
  ///
  /// Widths only increase until [reset] is called.
  void applyMeasurement(String columnId, double width) {
    if (_disposed) return;

    if (columnId.isEmpty || width <= 0 || width.isNaN || width.isInfinite) {
      return;
    }

    final next = width.ceilToDouble() + _measurementPadding;
    final current = _widths[columnId] ?? 0;

    if (next <= current) return;

    _widths[columnId] = math.max(current, next);
    _scheduleNotifyListeners();
  }

  /// Clears all measured widths.
  void reset() {
    if (_disposed || _widths.isEmpty) return;

    _widths.clear();
    _scheduleNotifyListeners();
  }

  void _scheduleNotifyListeners() {
    if (_notificationScheduled) return;

    _notificationScheduled = true;

    scheduleMicrotask(() {
      _notificationScheduled = false;

      if (_disposed) return;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'card_table_column.dart';
import 'card_table_controller.dart';

/// Builds responsive card rows whose cells share measured column widths.
///
/// Each row is provided to [rowBuilder] with a `cells` widget. Place that
/// `cells` widget inside your card, panel, or custom row container.
class MeasuredCardTable<T> extends StatefulWidget {
  /// Rows displayed by the table.
  final List<T> rows;

  /// Logical columns displayed for every row.
  final List<CardTableColumn<T>> columns;

  /// Builds the outer widget for a row.
  final Widget Function(BuildContext context, T row, Widget cells) rowBuilder;

  /// Optional external controller for sharing or resetting measurements.
  final MeasuredCardTableController? controller;

  /// Horizontal spacing between cells.
  final double gap;

  /// Vertical spacing between wrapped cell runs and between rows.
  final double rowGap;

  /// Width subtracted before packing cells.
  ///
  /// This gives wrapping a little room for rounding and parent constraints.
  final double packingSafetyBuffer;

  /// Creates a measured card table.
  const MeasuredCardTable({
    super.key,
    required this.rows,
    required this.columns,
    required this.rowBuilder,
    this.controller,
    this.gap = 12,
    this.rowGap = 8,
    this.packingSafetyBuffer = 8,
  }) : assert(gap >= 0),
       assert(rowGap >= 0),
       assert(packingSafetyBuffer >= 0);

  @override
  State<MeasuredCardTable<T>> createState() => _MeasuredCardTableState<T>();
}

class _MeasuredCardTableState<T> extends State<MeasuredCardTable<T>> {
  late final MeasuredCardTableController _localController;

  MeasuredCardTableController get _controller {
    return widget.controller ?? _localController;
  }

  @override
  void initState() {
    super.initState();
    _localController = MeasuredCardTableController();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant MeasuredCardTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final MeasuredCardTableController oldController =
        oldWidget.controller ?? _localController;
    final MeasuredCardTableController newController =
        widget.controller ?? _localController;

    if (oldController != newController) {
      oldController.removeListener(_handleControllerChanged);
      newController.addListener(_handleControllerChanged);
    }

    if (!_sameColumnIds(oldWidget.columns, widget.columns)) {
      newController.reset();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _localController.dispose();
    super.dispose();
  }

  bool _sameColumnIds(
    List<CardTableColumn<T>> oldColumns,
    List<CardTableColumn<T>> newColumns,
  ) {
    if (oldColumns.length != newColumns.length) return false;

    for (var i = 0; i < oldColumns.length; i++) {
      if (oldColumns[i].id != newColumns[i].id) return false;
    }

    return true;
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty || widget.columns.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final double availableWidth = math.max(
          0,
          maxWidth - widget.packingSafetyBuffer,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < widget.rows.length; i++) ...[
                  widget.rowBuilder(
                    context,
                    widget.rows[i],
                    _PackedCells<T>(
                      row: widget.rows[i],
                      columns: widget.columns,
                      controller: _controller,
                      availableWidth: availableWidth,
                      gap: widget.gap,
                      rowGap: widget.rowGap,
                    ),
                  ),
                  if (i != widget.rows.length - 1)
                    SizedBox(height: widget.rowGap),
                ],
              ],
            ),
            Positioned(
              left: 0,
              top: 0,
              child: _MeasurementLayer<T>(
                rows: widget.rows,
                columns: widget.columns,
                controller: _controller,
                maxWidth: availableWidth,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PackedCells<T> extends StatelessWidget {
  final T row;
  final List<CardTableColumn<T>> columns;
  final MeasuredCardTableController controller;
  final double availableWidth;
  final double gap;
  final double rowGap;

  const _PackedCells({
    required this.row,
    required this.columns,
    required this.controller,
    required this.availableWidth,
    required this.gap,
    required this.rowGap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: gap,
      runSpacing: rowGap,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (final column in columns)
          _VisibleCell<T>(
            row: row,
            column: column,
            controller: controller,
            maxWidth: availableWidth,
          ),
      ],
    );
  }
}

class _VisibleCell<T> extends StatelessWidget {
  final T row;
  final CardTableColumn<T> column;
  final MeasuredCardTableController controller;
  final double maxWidth;

  const _VisibleCell({
    required this.row,
    required this.column,
    required this.controller,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final double measuredWidth = controller.widthFor(column.id);
    final double desiredWidth = measuredWidth > 0
        ? measuredWidth
        : column.fallbackWidth;
    final double width = desiredWidth.clamp(0, maxWidth).toDouble();

    return SizedBox(
      width: width,
      child: Align(
        alignment: column.alignment,
        child: column.builder(context, row),
      ),
    );
  }
}

class _MeasurementLayer<T> extends StatelessWidget {
  final List<T> rows;
  final List<CardTableColumn<T>> columns;
  final MeasuredCardTableController controller;
  final double maxWidth;

  const _MeasurementLayer({
    required this.rows,
    required this.columns,
    required this.controller,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Offstage(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final column in columns)
              for (final row in rows)
                IntrinsicWidth(
                  child: _MeasureSize(
                    onChange: (size) {
                      controller.applyMeasurement(column.id, size.width);
                    },
                    child: column.builder(context, row),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _MeasureSize extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onChange;

  const _MeasureSize({required this.child, required this.onChange});

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) return;

      final Size size = renderObject.size;
      if (_oldSize == size) return;

      _oldSize = size;
      widget.onChange(size);
    });

    return widget.child;
  }
}

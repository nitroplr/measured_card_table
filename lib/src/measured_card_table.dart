import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'card_table_column.dart';
import 'card_table_controller.dart';

/// Displays rows as custom cards with consistently measured cell widths.
///
/// The table measures each column's content, gives matching cells the same
/// width, and packs cells into explicit horizontal rows. When a row cannot fit
/// all cells, extra packed rows are generated automatically.
class MeasuredCardTable<T> extends StatefulWidget {
  /// Rows displayed by the table.
  final List<T> rows;

  /// Logical columns displayed for every row.
  final List<CardTableColumn<T>> columns;

  /// Builds the outer widget for a row.
  final Widget Function(BuildContext context, T row, Widget cells) rowBuilder;

  /// Optional external controller for sharing or resetting measurements.
  final MeasuredCardTableController? controller;

  /// Optional key used to reset measurements when row content changes.
  ///
  /// Use this when the same columns are reused for meaningfully different data.
  final Object? measurementKey;

  /// Horizontal spacing between cells for fixed-gap alignments.
  final double gap;

  /// Vertical spacing between packed cell rows and between table rows.
  final double rowGap;

  /// Horizontal alignment used for each packed cell row.
  final MainAxisAlignment mainAxisAlignment;

  /// Cross-axis alignment for cells in each packed cell row.
  final CrossAxisAlignment crossAxisAlignment;

  /// Width subtracted before packing cells.
  ///
  /// This gives row packing room for rounding and parent constraints.
  final double packingSafetyBuffer;

  /// Creates a measured card table.
  const MeasuredCardTable({
    super.key,
    required this.rows,
    required this.columns,
    required this.rowBuilder,
    this.controller,
    this.measurementKey,
    this.gap = 12,
    this.rowGap = 8,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.packingSafetyBuffer = 2,
  }) : assert(gap >= 0),
       assert(rowGap >= 0),
       assert(packingSafetyBuffer >= 0);

  @override
  State<MeasuredCardTable<T>> createState() => _MeasuredCardTableState<T>();
}

class _MeasuredCardTableState<T> extends State<MeasuredCardTable<T>> {
  late final MeasuredCardTableController _localController;

  MeasuredCardTableController get _controller => widget.controller ?? _localController;

  @override
  void initState() {
    super.initState();
    _validateColumns();
    _localController = MeasuredCardTableController();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant MeasuredCardTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validateColumns();

    final oldController = oldWidget.controller ?? _localController;
    final newController = widget.controller ?? _localController;

    if (oldController != newController) {
      oldController.removeListener(_handleControllerChanged);
      newController.addListener(_handleControllerChanged);
    }

    if (!_sameColumnIds(oldWidget.columns, widget.columns) || oldWidget.measurementKey != widget.measurementKey) {
      newController.reset();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _localController.dispose();
    super.dispose();
  }

  void _validateColumns() {
    final ids = <String>{};

    for (final column in widget.columns) {
      if (!ids.add(column.id)) {
        throw FlutterError(
          'Duplicate CardTableColumn id detected: "${column.id}". '
          'Column ids must be unique.',
        );
      }
    }
  }

  bool _sameColumnIds(List<CardTableColumn<T>> oldColumns, List<CardTableColumn<T>> newColumns) {
    if (oldColumns.length != newColumns.length) return false;

    for (var i = 0; i < oldColumns.length; i++) {
      if (oldColumns[i].id != newColumns[i].id) return false;
    }

    return true;
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty || widget.columns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
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
              gap: widget.gap,
              rowGap: widget.rowGap,
              mainAxisAlignment: widget.mainAxisAlignment,
              crossAxisAlignment: widget.crossAxisAlignment,
              packingSafetyBuffer: widget.packingSafetyBuffer,
            ),
          ),
          if (i != widget.rows.length - 1) SizedBox(height: widget.rowGap),
        ],
      ],
    );
  }
}

class _PackedCells<T> extends StatelessWidget {
  final T row;
  final List<CardTableColumn<T>> columns;
  final MeasuredCardTableController controller;
  final double gap;
  final double rowGap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double packingSafetyBuffer;

  const _PackedCells({
    required this.row,
    required this.columns,
    required this.controller,
    required this.gap,
    required this.rowGap,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    required this.packingSafetyBuffer,
  });

  bool get _usesFixedGap {
    return mainAxisAlignment == MainAxisAlignment.start ||
        mainAxisAlignment == MainAxisAlignment.end ||
        mainAxisAlignment == MainAxisAlignment.center;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.hasBoundedWidth ? constraints.maxWidth : MediaQuery.sizeOf(context).width;

        final availableWidth = _safeAvailableWidth(maxWidth);
        final packedRows = _packColumns(availableWidth);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < packedRows.length; i++) ...[
                  _PackedCellRow<T>(
                    row: row,
                    columns: packedRows[i],
                    controller: controller,
                    availableWidth: availableWidth,
                    gap: gap,
                    mainAxisAlignment: mainAxisAlignment,
                    crossAxisAlignment: crossAxisAlignment,
                    usesFixedGap: _usesFixedGap,
                  ),
                  if (i != packedRows.length - 1) SizedBox(height: rowGap),
                ],
              ],
            ),
            Positioned(
              left: 0,
              top: 0,
              child: IgnorePointer(
                child: _MeasurementLayer<T>(row: row, columns: columns, controller: controller),
              ),
            ),
          ],
        );
      },
    );
  }

  List<List<CardTableColumn<T>>> _packColumns(double availableWidth) {
    if (availableWidth <= 0) {
      return [
        for (final column in columns) [column],
      ];
    }

    final packedRows = <List<CardTableColumn<T>>>[];
    var currentRow = <CardTableColumn<T>>[];
    var currentWidth = 0.0;

    for (final column in columns) {
      final columnWidth = _widthFor(column, availableWidth);
      final spacing = _usesFixedGap && currentRow.isNotEmpty ? gap : 0.0;
      final nextWidth = currentWidth + spacing + columnWidth;

      if (currentRow.isNotEmpty && nextWidth > availableWidth) {
        packedRows.add(currentRow);
        currentRow = [column];
        currentWidth = columnWidth;
      } else {
        currentRow.add(column);
        currentWidth = nextWidth;
      }
    }

    if (currentRow.isNotEmpty) {
      packedRows.add(currentRow);
    }

    return packedRows;
  }

  double _safeAvailableWidth(double maxWidth) {
    return math.max(0, maxWidth - packingSafetyBuffer).floorToDouble();
  }

  double _widthFor(CardTableColumn<T> column, double availableWidth) {
    final measuredWidth = controller.widthFor(column.id);
    final desiredWidth = measuredWidth > 0 ? measuredWidth : column.fallbackWidth;

    return desiredWidth.clamp(0, availableWidth).toDouble();
  }
}

class _PackedCellRow<T> extends StatelessWidget {
  final T row;
  final List<CardTableColumn<T>> columns;
  final MeasuredCardTableController controller;
  final double availableWidth;
  final double gap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool usesFixedGap;

  const _PackedCellRow({
    required this.row,
    required this.columns,
    required this.controller,
    required this.availableWidth,
    required this.gap,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    required this.usesFixedGap,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (var i = 0; i < columns.length; i++) {
      final column = columns[i];

      children.add(
        _VisibleCell<T>(
          row: row,
          column: column,
          width: _widthFor(column),
          alignmentOverride: columns.length == 1 ? AlignmentDirectional.centerStart : null,
        ),
      );

      if (usesFixedGap && i != columns.length - 1) {
        children.add(SizedBox(width: gap));
      }
    }

    final resolvedMainAxisAlignment = columns.length == 1 ? MainAxisAlignment.start : mainAxisAlignment;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: availableWidth),
      child: Row(
        mainAxisAlignment: resolvedMainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }

  double _widthFor(CardTableColumn<T> column) {
    final measuredWidth = controller.widthFor(column.id);
    final desiredWidth = measuredWidth > 0 ? measuredWidth : column.fallbackWidth;

    return desiredWidth.clamp(0, availableWidth).toDouble();
  }
}

class _VisibleCell<T> extends StatelessWidget {
  final T row;
  final CardTableColumn<T> column;
  final double width;
  final AlignmentGeometry? alignmentOverride;

  const _VisibleCell({required this.row, required this.column, required this.width, this.alignmentOverride});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Align(alignment: alignmentOverride ?? column.alignment, child: column.builder(context, row)),
    );
  }
}

class _MeasurementLayer<T> extends StatelessWidget {
  final T row;
  final List<CardTableColumn<T>> columns;
  final MeasuredCardTableController controller;

  const _MeasurementLayer({required this.row, required this.columns, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Offstage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final column in columns)
            _MeasureSize(
              onChange: (size) {
                controller.applyMeasurement(column.id, size.width);
              },
              child: column.builder(context, row),
            ),
        ],
      ),
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const _MeasureSize({required this.onChange, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onChange);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderMeasureSize renderObject) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _lastReportedSize;

  @override
  void performLayout() {
    super.performLayout();

    final child = this.child;
    if (child == null) return;

    final measuredSize = Size(child.size.width.ceilToDouble(), child.size.height.ceilToDouble());

    if (_lastReportedSize == measuredSize) return;
    _lastReportedSize = measuredSize;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(measuredSize);
    });
  }
}

## 0.1.1

* Updated tests.

## 0.1.0

* Reworked layout engine to use explicit row packing instead of wrap-based behavior.
* Columns are now packed into multiple horizontal rows when they exceed available width.
* Improved measurement stability:
    * Widths are ceiled and padded to prevent overflow edge cases.
* Single-column rows are now always left-aligned for better UX.
* Added `packingSafetyBuffer` to avoid rounding overflow issues.
* Improved alignment behavior consistency across packed rows.
* Performance improvements:
    * Reduced unnecessary rebuilds via microtask batching.
* Updated example app to better demonstrate real-world usage.
* Documentation updates:
    * Clarified that layout uses row packing, not Wrap.
    * Improved API descriptions and usage expectations.

## 0.0.1

* Initial release.
* Provides `MeasuredCardTable`, `CardTableColumn`, and `MeasuredCardTableController`.
* Supports measured, consistently sized card cells that pack into rows based on available width.
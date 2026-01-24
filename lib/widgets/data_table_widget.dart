import 'package:flutter/material.dart';

/// Widget untuk menampilkan data dalam format spreadsheet/table
class DataTableWidget extends StatefulWidget {
  final List<String> columnHeaders;
  final List<List<dynamic>> rows;
  final List<double>? columnWidths;
  final bool showRowNumbers;
  final TextAlign? textAlign;

  const DataTableWidget({
    super.key,
    required this.columnHeaders,
    required this.rows,
    this.columnWidths,
    this.showRowNumbers = true,
    this.textAlign = TextAlign.left,
  });

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  late ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colCount = widget.columnHeaders.length + (widget.showRowNumbers ? 1 : 0);
    final columnWidths = widget.columnWidths ?? List.filled(colCount, 100.0);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _horizontalScrollController,
      child: Column(
        children: [
          // Header Row
          Container(
            color: Colors.grey[700],
            child: Row(
              children: [
                if (widget.showRowNumbers)
                  Container(
                    width: columnWidths.isNotEmpty ? columnWidths[0] : 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey[600]!),
                        bottom: BorderSide(color: Colors.grey[600]!),
                      ),
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ...List.generate(
                  widget.columnHeaders.length,
                  (idx) => Container(
                    width: widget.showRowNumbers
                        ? columnWidths.length > idx + 1
                            ? columnWidths[idx + 1]
                            : 120
                        : columnWidths.length > idx
                            ? columnWidths[idx]
                            : 120,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey[600]!),
                        bottom: BorderSide(color: Colors.grey[600]!),
                      ),
                    ),
                    child: Text(
                      widget.columnHeaders[idx],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Data Rows
          ...List.generate(
            widget.rows.length,
            (rowIdx) => Container(
              color: rowIdx.isEven ? Colors.white : Colors.grey[50],
              child: Row(
                children: [
                  if (widget.showRowNumbers)
                    Container(
                      width: columnWidths.isNotEmpty ? columnWidths[0] : 50,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey[300]!),
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        '${rowIdx + 1}',
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ...List.generate(
                    widget.rows[rowIdx].length,
                    (colIdx) => Container(
                      width: widget.showRowNumbers
                          ? columnWidths.length > colIdx + 1
                              ? columnWidths[colIdx + 1]
                              : 120
                          : columnWidths.length > colIdx
                              ? columnWidths[colIdx]
                              : 120,
                      height: 40,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey[300]!),
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        widget.rows[rowIdx][colIdx],
                        style: const TextStyle(fontSize: 11),
                        textAlign: widget.textAlign,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

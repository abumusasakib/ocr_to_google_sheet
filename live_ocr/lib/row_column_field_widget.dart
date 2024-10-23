import 'package:flutter/material.dart';

class RowColumnFieldWidget extends StatefulWidget {
  final void Function(String) onSelected;
  final bool isRow;
  final bool isColumn;
  final String? initialValue; // initialValue property
  final TextEditingController controller;

  const RowColumnFieldWidget(
      {super.key,
      required this.onSelected,
      this.isRow = false,
      this.isColumn = false,
      this.initialValue, // Initialize the initialValue
      required this.controller});

  @override
  State<RowColumnFieldWidget> createState() => _RowColumnFieldWidgetState();
}

class _RowColumnFieldWidgetState extends State<RowColumnFieldWidget> {
  final List<String> rows = [];
  final List<String> columns = [];
  String? selectedValue; // To hold the currently selected value

  @override
  void initState() {
    super.initState();
    // Populate rows and columns
    for (int i = 1; i <= 10; i++) {
      rows.add(i.toString());
    }
    for (int i = 65; i <= 90; i++) {
      columns.add(String.fromCharCode(i));
    }

    // Set the initial value if provided
    selectedValue = widget.initialValue;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: DropdownMenu<String>(
            controller: widget.controller,
            enableFilter: true,
            requestFocusOnTap: true,
            menuHeight: 300,
            initialSelection: selectedValue, // Use the initial value
            onSelected: (sheetName) {
              if (sheetName != null) {
                widget.onSelected(sheetName);
                setState(() {
                  selectedValue = sheetName; // Update the selected value
                });
              }
            },
            searchCallback:
                (List<DropdownMenuEntry<String>> entries, String query) {
              // Filter entries based on the search query
              final filteredEntries = entries
                  .where((DropdownMenuEntry<String> entry) =>
                      entry.label.toLowerCase().contains(query.toLowerCase()))
                  .toList();

              // Return the index of the first matching entry or null
              return filteredEntries.isNotEmpty
                  ? entries.indexOf(filteredEntries.first)
                  : null;
            },
            dropdownMenuEntries: widget.isRow
                ? rows
                    .map((e) => DropdownMenuEntry<String>(value: e, label: e))
                    .toList()
                : columns
                    .map((e) => DropdownMenuEntry<String>(value: e, label: e))
                    .toList(),
          ),
        ),
      ],
    );
  }
}

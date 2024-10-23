import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:live_ocr/create_google_sheet_view.dart';
import 'package:live_ocr/spreadsheet_manager.dart';
import 'package:live_ocr/utils_google.dart';

class SheetSelectorWidget extends StatefulWidget {
  final void Function(String) onSheetSelected;
  final String? selectedSheetId; // Property to retain selected sheet

  const SheetSelectorWidget({
    super.key,
    required this.onSheetSelected,
    this.selectedSheetId, // Initialize the selectedSheetId
  });

  @override
  State<SheetSelectorWidget> createState() => _SheetSelectorWidgetState();
}

class _SheetSelectorWidgetState extends State<SheetSelectorWidget> {
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _hasSearchResults = ValueNotifier<bool>(true);
  final ValueNotifier<String> _currentSearchQuery =
      ValueNotifier<String>(''); // Store the current search query
  String?
      _selectedSheetId; // Local variable to track the currently selected sheet ID
  List<drive.File> _sheetsFiles = [];
  final SpreadsheetManager spreadsheetManager = SpreadsheetManager();

  Future<void> _refreshSheetsList() async {
    // Fetch the updated list of sheets
    final newSheetsFiles = await GoogleDriveUtility.fetchSheetsFiles();
    for (final sheetFile in newSheetsFiles) {
      debugPrint("newSheetsFiles contains ${sheetFile.name}");
    }
    setState(() {
      _sheetsFiles = newSheetsFiles; // Update the list
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshSheetsList().then((value) {
      debugPrint("widget.selectedSheetId: ${widget.selectedSheetId}");
    _selectedSheetId =
        widget.selectedSheetId; // Initialize with the provided selectedSheetId
    });
    setState(() {
      
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _hasSearchResults.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    debugPrint("Attempting to dismiss keyboard");
    if (_focusNode.hasFocus) {
      debugPrint("Keyboard dismissed");
      _focusNode.unfocus();
    } else {
      debugPrint("No keyboard to dismiss");
    }
  }

  // Method to truncate the name to a specific length
  String _truncateName(String name, int maxLength) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("selectedSheetId: $_selectedSheetId");
    return GestureDetector(
      onTap: _dismissKeyboard, // Dismiss keyboard when tapping outside
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownMenu<String>(
            width: 200,
            menuHeight: 300,
            enableFilter: true,
            focusNode: _focusNode,
            requestFocusOnTap: true,
            initialSelection: _selectedSheetId, // Set the initial selection
            onSelected: (sheetID) {
              if (sheetID != null) {
                widget.onSheetSelected(sheetID);
                _dismissKeyboard(); // Dismiss keyboard on selection
              }
            },
            searchCallback:
                (List<DropdownMenuEntry<String>> entries, String query) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _currentSearchQuery.value = query;
              });

              if (query.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _hasSearchResults.value = true;
                });
                return null;
              }

              // Filter entries based on the search query
              final filteredEntries = entries
                  .where((DropdownMenuEntry<String> entry) =>
                      entry.label.toLowerCase().contains(query.toLowerCase()))
                  .toList();

              // Update _hasSearchResults based on whether there are filtered entries
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _hasSearchResults.value = filteredEntries.isNotEmpty;
              });

              return filteredEntries.isNotEmpty
                  ? entries.indexOf(filteredEntries.first)
                  : null;
            },
            dropdownMenuEntries: _sheetsFiles.map((file) {
              final truncatedName = _truncateName(
                  file.name ?? 'Unnamed', 45); // Truncate to 45 characters
              return DropdownMenuEntry<String>(
                value: file.id ?? "No ID",
                label: truncatedName,
              );
            }).toList(),
          ),
          const Gap(8),
          ValueListenableBuilder<bool>(
            valueListenable: _hasSearchResults,
            builder: (context, hasResults, child) {
              return hasResults
                  ? const SizedBox
                      .shrink() // Hide the icon if there are search results
                  : IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateGoogleSheetView(
                              initialSheetName:
                                  _currentSearchQuery.value, // Pass the query
                            ),
                          ),
                        );

                        // TODO: Handle result here

                        if (result is Map<String, String>) {
                          setState(() {
                            _selectedSheetId = spreadsheetManager.spreadsheetId; // Automatically select the newly created sheet
                          });

                          widget.onSheetSelected(spreadsheetManager.spreadsheetId!);
                          _dismissKeyboard(); // Dismiss keyboard on selection
                        }
                      },
                      icon: const Icon(Icons.add),
                    );
            },
          ),
        ],
      ),
    );
  }
}

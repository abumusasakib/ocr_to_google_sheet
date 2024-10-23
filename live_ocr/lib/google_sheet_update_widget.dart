import 'dart:math';

import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:live_ocr/scanned_text_list_widget.dart';
import 'package:live_ocr/sheet_selector_widget.dart';
import 'package:live_ocr/spreadsheet_manager.dart';
import 'package:live_ocr/utils_google.dart';

final List<TextEditingController> controllers = [];
final List<bool> checkBoxValues = [];
final List<TextEditingController> rowControllers = [];
final List<TextEditingController> columnControllers = [];

class GoogleSheetUpdateWidget extends StatefulWidget {
  const GoogleSheetUpdateWidget({
    super.key,
    required this.textKeys,
    required this.textValues,
    required this.sheetsFiles,
  });

  final List<String> textValues;
  final List<String> textKeys;
  final List<drive.File> sheetsFiles;

  @override
  State<GoogleSheetUpdateWidget> createState() =>
      _GoogleSheetUpdateWidgetState();
}

class _GoogleSheetUpdateWidgetState extends State<GoogleSheetUpdateWidget> {
  // List<drive.File> _sheetsFiles = [];
  bool _isLoading = false; // Track whether insertion is in progress

  @override
  void initState() {
    super.initState();
    // _sheetsFiles = widget.sheetsFiles; // Initialize with the provided list
  }

  // Future<void> _refreshSheetsList() async {
  //   // Fetch the updated list of sheets
  //   final newSheetsFiles = await GoogleDriveUtility.fetchSheetsFiles();
  //   setState(() {
  //     _sheetsFiles = newSheetsFiles; // Update the list
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final SpreadsheetManager spreadsheetManager = SpreadsheetManager();
    final selectedSpreadsheetId = spreadsheetManager.spreadsheetId;

    return Scaffold(
      appBar: AppBar(title: const Text('Add to Google Sheet')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Please select a spreadsheet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SheetSelectorWidget(
                  onSheetSelected: (sheetId) {
                    // // Store selected sheet ID in singleton
                    spreadsheetManager.spreadsheetId = sheetId;
                    setState(() {});
                    // debugPrint('Selected sheet ID: $sheetId');
                  },
                  selectedSheetId:
                      spreadsheetManager.spreadsheetId, // Retain selection
                ),
                if (selectedSpreadsheetId != null)
                  ScannedTextListWidget(
                    textKeys: widget.textKeys,
                    textValues: widget.textValues,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(255, 211, 217, 222),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Go back',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Colors.green,
                        ),
                      ),
                      onPressed: _isLoading || selectedSpreadsheetId == null
                          ? null // Disable button when loading
                          : () async {
                              setState(() {
                                _isLoading = true; // Start loading
                              });

                              bool hasError = false; // Track any errors
                              int maxRowNumber = 0;
                              for (int index = 0;
                                  index < widget.textKeys.length;
                                  index++) {
                                if (checkBoxValues[index]) {
                                  maxRowNumber = max(
                                      int.parse(rowControllers[index].text),
                                      maxRowNumber);
                                  try {
                                    final cell = columnControllers[index].text +
                                        rowControllers[index].text;
                                    final value =
                                        '${widget.textKeys[index]}: ${controllers[index].text}';
                                    debugPrint(
                                        'Inserting value: $value into $cell of Spreadsheet $selectedSpreadsheetId');
                                    await GoogleDriveUtility.insertValue(
                                      selectedSpreadsheetId,
                                      cell,
                                      value,
                                    );
                                    debugPrint(
                                        'Successfully inserted value: $value into $cell of Spreadsheet $selectedSpreadsheetId');
                                  } catch (e) {
                                    hasError = true;
                                    debugPrint(
                                        'Error inserting value: ${widget.textKeys[index]} into spreadsheet: $e');
                                    break; // Stop further insertions if an error occurs
                                  }
                                }
                              }

                              // Show appropriate message based on the success or failure
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: hasError
                                        ? const Text(
                                            'Error inserting some values. Please try again!',
                                          )
                                        : const Text(
                                            'Values successfully added to the Google Sheet!',
                                          ),
                                    backgroundColor:
                                        hasError ? Colors.red : Colors.green,
                                  ),
                                );
                              }

                              if (!hasError) {
                                debugPrint(
                                    'Successfully inserted all values into spreadsheet $selectedSpreadsheetId');

                                // Increment the row number if all entries were successfully inserted
                                spreadsheetManager.currentRow =
                                    maxRowNumber + 1;
                              }

                              setState(() {
                                _isLoading = false; // Stop loading
                              });

                              if (!hasError && context.mounted) {
                                Navigator.pop(
                                    context); // Close the screen if successful
                              }
                            },
                      child: const Text(
                        'Add To Sheet',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading) // Show loading indicator when insertion is in progress
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

var keyStyle = const TextStyle(
  color: Colors.black,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

var textStyle = const TextStyle(
  color: Colors.blue,
  fontSize: 12,
  fontWeight: FontWeight.w500,
);

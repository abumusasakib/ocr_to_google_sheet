import 'dart:math';

import 'package:flutter/material.dart';
import 'package:live_ocr/google_sheet_update_widget.dart';
import 'package:live_ocr/row_column_field_widget.dart';
import 'package:live_ocr/spreadsheet_manager.dart';

class ScannedTextListWidget extends StatefulWidget {
  const ScannedTextListWidget({
    super.key,
    required this.textKeys,
    required this.textValues,
  });
  final List<String> textKeys;
  final List<String> textValues;

  @override
  State<ScannedTextListWidget> createState() => _ScannedTextListWidgetState();
}

class _ScannedTextListWidgetState extends State<ScannedTextListWidget> {
  final SpreadsheetManager spreadsheetManager = SpreadsheetManager();

  @override
  void initState() {
    super.initState();
    spreadsheetManager.initializeManager();
    _initializeData();
  }

  void _initializeData() {
    for (var value in widget.textValues) {
      controllers.add(TextEditingController(text: value));
      rowControllers.add(TextEditingController(
          text: spreadsheetManager.currentRow.toString()));
      columnControllers.add(TextEditingController(text: ''));
      checkBoxValues.add(true);
    }
  }

  @override
  void dispose() {
    checkBoxValues.clear();
    controllers.clear();
    rowControllers.clear();
    columnControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: min(widget.textKeys.length * 170,
            MediaQuery.of(context).size.height - 300),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: widget.textKeys.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // First row: Index and item name
                    Row(
                      children: [
                        Text(
                          '${index + 1}. ',
                          style: textStyle,
                        ),
                        SizedBox(
                          height: 60,
                          width: MediaQuery.of(context).size.width - 80,
                          child: TextField(
                            controller: controllers[index],
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: widget.textKeys[index],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Second row: Row label, TextField, Column label, TextField, and Checkbox
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 20),
                          Transform(
                            transform: Matrix4.identity()..scale(0.7),
                            child: SizedBox(
                              width: 140,
                              height: 60,
                              child: RowColumnFieldWidget(
                                isRow: true,
                                onSelected: (str) {
                                  if (!spreadsheetManager.isFirstRowSelected) {
                                    for (var controller in rowControllers) {
                                      controller.text = str;
                                    }
                                    spreadsheetManager.isFirstRowSelected =
                                        true;
                                  }
                                },
                                controller: rowControllers[index],
                              ),
                            ),
                          ),
                          Transform(
                            transform: Matrix4.identity()
                              ..translate(-30.0, 0.0)
                              ..scale(0.7),
                            child: SizedBox(
                              width: 140,
                              height: 60,
                              child: RowColumnFieldWidget(
                                isColumn: true,
                                onSelected: (str) {},
                                controller: columnControllers[index],
                              ),
                            ),
                          ),
                          Transform(
                            transform: Matrix4.identity()
                              ..translate(-70.0, -17.0)
                              ..scale(1.4),
                            child: Checkbox(
                              value: checkBoxValues[index],
                              onChanged: (bool? newValue) {
                                setState(() {
                                  checkBoxValues[index] = newValue ?? false;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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

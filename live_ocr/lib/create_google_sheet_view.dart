import 'package:flutter/material.dart';
import 'package:live_ocr/spreadsheet_manager.dart';
import 'package:live_ocr/utils_google.dart';

class CreateGoogleSheetView extends StatefulWidget {
  final String initialSheetName; // A parameter to accept the initial sheet name
  const CreateGoogleSheetView({super.key, required this.initialSheetName});

  @override
  State<CreateGoogleSheetView> createState() => _CreateGoogleSheetViewState();
}

class _CreateGoogleSheetViewState extends State<CreateGoogleSheetView> {
  final TextEditingController _sheetNameController = TextEditingController();
  bool _isCreating = false;
  final SpreadsheetManager spreadsheetManager = SpreadsheetManager();

  @override
  void initState() {
    super.initState();
    // Prepopulate the TextField with the initial sheet name
    _sheetNameController.text = widget.initialSheetName;
  }

  @override
  void dispose() {
    _sheetNameController.dispose();
    super.dispose();
  }

  Future<void> _createNewGoogleSheet() async {
    if (_sheetNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a sheet name')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // Use the utility method to create the Google Sheet
      final newSheet =
          await GoogleDriveUtility.createGoogleSheet(_sheetNameController.text);
      
      spreadsheetManager.spreadsheetId = newSheet.spreadsheetId;

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Google Sheet "${newSheet.properties?.title}" created successfully!')),
      );

      // Pass the newly created sheet data back to the previous screen
      Navigator.pop(context, {
        'sheetId': newSheet.spreadsheetId!,
        'sheetName': newSheet.properties?.title ?? 'Unnamed Sheet',
      });
    } catch (e) {
      // Handle any errors and show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create Google Sheet: $e')),
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Google Sheet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _sheetNameController,
              decoration: const InputDecoration(
                labelText: 'Enter Sheet Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isCreating
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createNewGoogleSheet,
                    child: const Text('Create New Google Sheet'),
                  ),
          ],
        ),
      ),
    );
  }
}

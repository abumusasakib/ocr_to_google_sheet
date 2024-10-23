import 'dart:convert';
import 'dart:typed_data';

import 'package:live_ocr/google_auth_client.dart';
import 'package:live_ocr/google_signin_view.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;

/*
# Example Usage
Here’s how you can use this `GoogleDriveUtility` class to perform spreadsheet operations:

1. **Fetch Spreadsheet:**
   ```dart
   final spreadsheet = await GoogleDriveUtility.fetchSpreadsheet(spreadsheetId);
   ```

2. **Insert Value into Cell:**
   ```dart
   await GoogleDriveUtility.insertValue(spreadsheetId, 'A1', 'Hello, World');
   ```

3. **Get Value from Cell:**
   ```dart
   final value = await GoogleDriveUtility.getValue(spreadsheetId, 'A1');
   print(value); // prints 'Hello, World'
   ```

4. **Insert Row:**
   ```dart
   final rowValues = ['Name', 'Age', 'Location'];
   await GoogleDriveUtility.insertRow(spreadsheetId, 'Sheet1!A1', rowValues);
   ```

5. **Insert Column:**
   ```dart
   final columnValues = ['John', 'Jane', 'Doe'];
   await GoogleDriveUtility.insertColumn(spreadsheetId, 'Sheet1!A1:A', columnValues);
   ```

6. **Insert Map into Row:**
   ```dart
   final mapValues = {'Name': 'John', 'Age': '30', 'Location': 'NYC'};
   await GoogleDriveUtility.insertMapRow(spreadsheetId, 'Sheet1!A1', mapValues);
   ```

*/

// Utility functions for Google Drive and Sheets APIs
/// Google Drive utility functions
class GoogleDriveUtility {
  /// Get the authenticated Google Drive API instance
  ///
  /// Throws an [Exception] if the user is not signed in.
  static Future<drive.DriveApi> _getDriveApi() async {
    // Obtain current user auth headers
    final currentUser = SignInToGoogle.googleSignIn.currentUser;
    if (currentUser == null) {
      throw Exception('No user signed in');
    }

    final authHeaders = await currentUser.authHeaders;
    // Create authenticated Google client
    final authenticatedClient = GoogleAuthClient(authHeaders);
    // Create Google Drive API instance
    return drive.DriveApi(authenticatedClient);
  }

  /// Get the authenticated Google Sheets API instance
  ///
  /// Throws an [Exception] if the user is not signed in.
  static Future<sheets.SheetsApi> _getSheetsApi() async {
    // Obtain current user auth headers
    final currentUser = SignInToGoogle.googleSignIn.currentUser;
    if (currentUser == null) {
      throw Exception('No user signed in');
    }

    final authHeaders = await currentUser.authHeaders;
    // Create authenticated Google client
    final authenticatedClient = GoogleAuthClient(authHeaders);
    // Create Google Sheets API instance
    return sheets.SheetsApi(authenticatedClient);
  }

  /// Fetch a list of Google Sheets files from the user's Google Drive
  ///
  /// This function returns a list of [drive.File] objects, each representing a
  /// Google Sheets file. The list is empty if no files are found, or if the
  /// user is not signed in.
  ///
  /// Throws an [Exception] if the user is not signed in.
  static Future<List<drive.File>> fetchSheetsFiles() async {
    final driveApi = await _getDriveApi();
    final fileList = await driveApi.files
        .list(q: "mimeType='application/vnd.google-apps.spreadsheet'");
    return fileList.files ?? [];
  }

  /// Create a new Google Sheets file with the given filename
  ///
  /// Throws an [Exception] if the user is not signed in.
  ///
  /// Returns a [drive.File] object representing the newly created file.
  static Future<drive.File> createSheet(String fileName) async {
    final driveApi = await _getDriveApi();
    final file = drive.File()
      ..name = fileName
      ..mimeType = 'application/vnd.google-apps.spreadsheet';
    return await driveApi.files.create(file);
  }

  // Method to create a Google Sheet
  /// Create a new Google Sheets file with the given filename
  ///
  /// Throws an [Exception] if the user is not signed in.
  ///
  /// Returns a [sheets.Spreadsheet] object representing the newly created file.
  static Future<sheets.Spreadsheet> createGoogleSheet(String sheetName) async {
    final sheetsApi = await _getSheetsApi();
    // Create a new spreadsheet request
    final request = sheets.Spreadsheet(
      properties: sheets.SpreadsheetProperties(title: sheetName),
    );
    // Send the request to create the new sheet
    return await sheetsApi.spreadsheets.create(request);
  }

  // Fetch Spreadsheet by its ID
  /// Fetch a [sheets.Spreadsheet] object representing the spreadsheet with the
  /// given ID.
  //
  /// Throws an [Exception] if the user is not signed in or if the spreadsheet
  /// does not exist.
  //
  /// Returns a [sheets.Spreadsheet] object representing the spreadsheet, or
  /// `null` if the spreadsheet does not exist.
  static Future<sheets.Spreadsheet> fetchSpreadsheet(
      String spreadsheetId) async {
    final sheetsApi = await _getSheetsApi();
    return await sheetsApi.spreadsheets.get(spreadsheetId);
  }

  // Insert a value into a cell
  /// Insert a value into a cell of a Google Sheets document
  ///
  /// `spreadsheetId` is the ID of the spreadsheet to update.
  /// `range` is the A1 notation of the cell to update.
  /// `value` is the value to insert into the cell.
  ///
  /// Throws an [Exception] if the user is not signed in or if the spreadsheet
  /// does not exist.
  static Future<void> insertValue(
      String spreadsheetId, String range, String value) async {
    final sheetsApi = await _getSheetsApi();
    final valueRange = sheets.ValueRange(values: [
      [value]
    ]);
    await sheetsApi.spreadsheets.values
        .update(valueRange, spreadsheetId, range, valueInputOption: 'RAW');
  }

  // Get a value from a specific cell
  /// Get the value of a cell in a Google Sheets document
  ///
  /// `spreadsheetId` is the ID of the spreadsheet to fetch from.
  /// `range` is the A1 notation of the cell to fetch.
  ///
  /// Throws an [Exception] if the user is not signed in or if the spreadsheet
  /// does not exist.
  ///
  /// Returns the value of the cell as a [String], or `null` if the cell is empty.
  static Future<String?> getValue(String spreadsheetId, String range) async {
    final sheetsApi = await _getSheetsApi();
    final response =
        await sheetsApi.spreadsheets.values.get(spreadsheetId, range);
    return response.values?.first.first?.toString();
  }

  // Insert a row of data
  /// Insert a row of data into a Google Sheets document
  ///
  /// `spreadsheetId` is the ID of the spreadsheet to update.
  /// `range` is the A1 notation of the top-left cell of the row to insert.
  /// `rowValues` is a list of values to insert into the row.
  ///
  /// Throws an [Exception] if the user is not signed in or if the spreadsheet
  /// does not exist.
  static Future<void> insertRow(
      String spreadsheetId, String range, List<dynamic> rowValues) async {
    final sheetsApi = await _getSheetsApi();
    final valueRange = sheets.ValueRange(values: [rowValues]);
    await sheetsApi.spreadsheets.values.append(valueRange, spreadsheetId, range,
        valueInputOption: 'RAW', insertDataOption: 'INSERT_ROWS');
  }

  // Insert a column of data
  /// Insert a column of data into a Google Sheets document
  ///
  /// `spreadsheetId` is the ID of the spreadsheet to update.
  /// `range` is the A1 notation of the top-left cell of the column to insert.
  /// `columnValues` is a list of values to insert into the column.
  ///
  /// Throws an [Exception] if the user is not signed in or if the spreadsheet
  /// does not exist.
  static Future<void> insertColumn(
      String spreadsheetId, String range, List<dynamic> columnValues) async {
    final sheetsApi = await _getSheetsApi();
    final valueRange = sheets.ValueRange(
        values: columnValues.map((value) => [value]).toList());
    await sheetsApi.spreadsheets.values.append(valueRange, spreadsheetId, range,
        valueInputOption: 'RAW', insertDataOption: 'INSERT_ROWS');
  }

  // Insert a map into a row, mapping keys to the first row
  /// Insert a map into a row of a Google Sheets document, mapping the keys of
  /// the map to the values of the first row.
  ///
  /// `spreadsheetId` is the ID of the spreadsheet to update.
  /// `range` is the A1 notation of the top-left cell of the row to insert.
  /// `mapValues` is the map of values to insert into the row.
  ///
  /// Throws an [Exception] if the user is not signed in or if the spreadsheet
  /// does not exist.
  static Future<void> insertMapRow(String spreadsheetId, String range,
      Map<String, dynamic> mapValues) async {
    final sheetsApi = await _getSheetsApi();
    final valueRange = sheets.ValueRange(values: [
      mapValues.keys.toList(),
      mapValues.values.toList(),
    ]);
    await sheetsApi.spreadsheets.values
        .update(valueRange, spreadsheetId, range, valueInputOption: 'RAW');
  }

  // Insert a map into a column, mapping keys to the first column
  /// Insert a map into a column of a Google Sheets document, mapping the keys of
  /// the map to the values of the first column.
  ///
  /// `spreadsheetId` is the ID of the spreadsheet to update.
  /// `range` is the A1 notation of the top-left cell of the column to insert.
  /// `mapValues` is the map of values to insert into the column.
  ///
  /// Throws an [Exception] if the user is not signed in or if the spreadsheet
  /// does not exist.
  static Future<void> insertMapColumn(String spreadsheetId, String range,
      Map<String, dynamic> mapValues) async {
    final sheetsApi = await _getSheetsApi();
    final valueRange = sheets.ValueRange(
      values:
          mapValues.entries.map((entry) => [entry.key, entry.value]).toList(),
    );
    await sheetsApi.spreadsheets.values
        .update(valueRange, spreadsheetId, range, valueInputOption: 'RAW');
  }

  /// Delete a file from Google Drive by its ID
  ///
  /// `fileId` is the ID of the file to delete
  ///
  /// Throws an [Exception] if the user is not signed in or if the file does not
  /// exist.
  static Future<void> deleteFile(String fileId) async {
    final driveApi = await _getDriveApi();
    await driveApi.files.delete(fileId);
  }

  /// Get the content of a file from Google Drive by its ID
  ///
  /// `fileId` is the ID of the file to fetch
  ///
  /// Throws an [Exception] if the user is not signed in or if the file does not
  /// exist.
  ///
  /// Returns the content of the file as a [String].
  static Future<String> getFileContent(String fileId) async {
    final driveApi = await _getDriveApi();
    final response = await driveApi.files.get(fileId,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final stream = response.stream;
    final bytesBuilder = BytesBuilder();
    await for (var chunk in stream) {
      bytesBuilder.add(chunk);
    }
    final bytes = bytesBuilder.toBytes();
    return utf8.decode(bytes);
  }

  /// Update the content of a file in Google Drive by its ID
  ///
  /// `fileId` is the ID of the file to update
  /// `content` is the new content of the file
  ///
  /// Throws an [Exception] if the user is not signed in or if the file does not
  /// exist.
  static Future<void> updateFile(String fileId, String content) async {
    final driveApi = await _getDriveApi();
    final media =
        drive.Media(Stream.fromIterable([content.codeUnits]), content.length);
    await driveApi.files.update(drive.File(), fileId, uploadMedia: media);
  }

  /// Search for files in Google Drive
  ///
  /// `query` is the search query string
  ///
  /// Throws an [Exception] if the user is not signed in.
  ///
  /// Returns a list of [drive.File] objects representing the search results.
  static Future<List<drive.File>> searchFiles(String query) async {
    final driveApi = await _getDriveApi();
    final fileList = await driveApi.files.list(q: query);
    return fileList.files ?? [];
  }
}

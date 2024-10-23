class SpreadsheetManager {
  static final SpreadsheetManager _instance = SpreadsheetManager._internal();

  String? spreadsheetId;
  bool _isFirstRowSelected = false;
  int currentRow = 1;

  factory SpreadsheetManager() {
    return _instance;
  }

  SpreadsheetManager._internal();

  void initializeManager() {
    _isFirstRowSelected = false;
  }

  bool get isFirstRowSelected {
    return _isFirstRowSelected;
  }

  set isFirstRowSelected(bool value) {
    _isFirstRowSelected = value;
  }
}

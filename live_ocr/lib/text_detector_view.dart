import 'dart:async';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:live_ocr/google_sheet_update_widget.dart';
import 'package:live_ocr/text_detector_painter.dart';

import 'detector_view.dart';

class TextRecognizerView extends StatefulWidget {
  const TextRecognizerView({super.key, required this.sheetsFiles});
  final List<drive.File> sheetsFiles;

  @override
  State<TextRecognizerView> createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  // final _script = TextRecognitionScript.latin;
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  final searchingTextKeys = [
    'Name',
    'Date of Birth',
    'ID NO',
    'APN',
    'A.P.N',
    'A.P No',
    'APN / Parcel ID(s)',
    'APN Number',
    'A.P. NUMBER',
    'Assessor Parcel Number',
    'Asscssor Parcel Number',
    'Assessor\'s Parcel No',
    'Assessor\'s Identification No',
    'Parcel ID Number',
    'Parcel Number',
    'Document No '
  ];
  final searchingTextPatterns = [
    KeyPatternPair(
      key: apnKey, // e.g. $1,000,000.00
      maxLength: 1,
      pattern: RegExp(r'^\d{3,4}[-\s]\d{3}[-\s]\d{2,3}[,.;:]?$'),
    ),
    KeyPatternPair(
      key: amountKey, // e.g. $1,000,000.00
      maxLength: 1,
      pattern: RegExp(r'^[\$S]?\d{1,3}(,\d{3})*(\.\d{2})[,.;:]?$'),
    ),
    KeyPatternPair(
      key: 'Date', // e.g. monthName dd, yyyy or dd/mm/yyyy formats
      maxLength: 1,
      pattern: RegExp(
          r'^(0?[1-9]|[12][0-9]|3[01])[\/-](0?[1-9]|1[0-2])[\/-]\d{4}[,.;:]?$',
          caseSensitive: false),
    ),
    KeyPatternPair(
      key: 'Date', // e.g. monthName dd, yyyy or dd/mm/yyyy formats
      maxLength: 3,
      pattern: RegExp(
          r'''(?:January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2})(?:TH|th|ND|nd)?,?\s*(\d{4})|(?:\d{1,2}(?:TH|th|ST|st|ND|nd|RD|rd)?\s+(?:January|February|March|April|May|June|July|August|September|October|November|December),\s+\d{4})[,.;:]?''',
          caseSensitive: false),
    ),
  ];

  List<String> matchedTextKeys = [];
  List<String> matchedKeyValues = [];
  Set<KeyValuePair> setOfKeyValues = {};

  @override
  void initState() {
    super.initState();
    timerForAutoNavigation();
  }

  late Timer timer;
  void timerForAutoNavigation() async {
    timer = Timer.periodic(const Duration(milliseconds: 5000), (_) async {
      if (setOfKeyValues.isNotEmpty) {
        gotoNextScreen();
      }
    });
  }

  void gotoNextScreen() async {
    timer.cancel();
    processData();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleSheetUpdateWidget(
          textKeys: matchedTextKeys,
          textValues: matchedKeyValues,
          sheetsFiles: widget.sheetsFiles,
        ),
      ),
    );
    matchedTextKeys.clear();
    matchedKeyValues.clear();
    setOfKeyValues.clear();
    isProcessing = false;
    timerForAutoNavigation();
  }

  bool isProcessing = false;
  void processData() {
    isProcessing = true;
    KeyValuePair? lineApn;
    for (var item in setOfKeyValues) {
      if (item.isLineApn) {
        if (lineApn == null) {
          lineApn = item;
        } else {
          if (numberOfDigits(lineApn.value) <= numberOfDigits(item.value)) {
            lineApn.copyWith(
              key: item.key,
              value: item.value,
            );
          }
        }
      }
    }
    if (lineApn != null) {
      matchedTextKeys.add(lineApn.key);
      matchedKeyValues.add(lineApn.value);
    } else {
      String combinedApnValues = '';
      for (var item in setOfKeyValues) {
        if (item.key == apnKey) {
          if (combinedApnValues.isNotEmpty) {
            combinedApnValues = '$combinedApnValues, ';
          }
          combinedApnValues = combinedApnValues + item.value;
        }
      }
      if (combinedApnValues.isNotEmpty) {
        matchedTextKeys.add(apnKey);
        matchedKeyValues.add(combinedApnValues);
      }
    }
    setOfKeyValues.removeWhere((item) => (item.isLineApn == true));
    setOfKeyValues.removeWhere((item) => (item.key == apnKey));
    for (var item in setOfKeyValues) {
      matchedTextKeys.add(item.key);
      matchedKeyValues.add(item.value);
    }
  }

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        DetectorView(
          title: 'Text Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
        Positioned(
            left: MediaQuery.of(context).size.width / 2 - 40,
            bottom: 100,
            child: Visibility(
              visible: matchedTextKeys.isNotEmpty,
              child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: gotoNextScreen,
                child: const Text('OK'),
              ),
            ))
      ]),
    );
  }

  _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final recognizedText = await _textRecognizer.processImage(inputImage);

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = TextRecognizerPainter(
        recognizedText: recognizedText,
        imageSize: inputImage.metadata!.size,
        rotation: inputImage.metadata!.rotation,
        cameraLensDirection: _cameraLensDirection,
        highlightedTextIdList: searchingTextKeys,
        textPatterns: searchingTextPatterns,
        onReturnMatchedTexts: (matchedKeyValuePairs) {
          if (!isProcessing) {
            setOfKeyValues.addAll(matchedKeyValuePairs);
          }
        },
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Recognized text:\n\n${recognizedText.text}';
      // Set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

class KeyPatternPair {
  final String key;
  final RegExp pattern;
  final int maxLength;

  KeyPatternPair({
    required this.key,
    required this.pattern,
    required this.maxLength,
  });
}

class KeyValuePair extends Equatable {
  final String key;
  final String value;
  final bool isLineApn;

  const KeyValuePair({
    required this.key,
    required this.value,
    this.isLineApn = false,
  });

  KeyValuePair copyWith({
    String? key,
    String? value,
    bool? isMultipleApn,
  }) {
    return KeyValuePair(
      key: key ?? this.key,
      value: value ?? this.value,
      isLineApn: isMultipleApn ?? isLineApn,
    );
  }

  @override
  List<Object?> get props => [
        key,
        value,
        isLineApn,
      ];
}

const String apnKey = "APN";

const String amountKey = "Amount";

bool isNumeric(String char) {
  final numericRegex = RegExp(r'^[0-9]$');
  return numericRegex.hasMatch(char);
}

int numberOfDigits(String str) {
  int cnt = 0;
  for (var char in str.characters) {
    if (isNumeric(char)) {
      cnt++;
    }
  }
  return cnt;
}

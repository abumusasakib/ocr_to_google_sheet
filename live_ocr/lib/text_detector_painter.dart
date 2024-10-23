import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:live_ocr/text_detector_view.dart';

import 'coordinates_translator.dart';

class TextRecognizerPainter extends CustomPainter {
  TextRecognizerPainter({
    this.highlightedTextIdList,
    this.onReturnMatchedTexts,
    required this.recognizedText,
    required this.imageSize,
    required this.rotation,
    required this.cameraLensDirection,
    required this.textPatterns,
  });

  final List<KeyPatternPair>? textPatterns;
  final List<String>? highlightedTextIdList;
  final void Function(List<KeyValuePair>)? onReturnMatchedTexts;
  final RecognizedText recognizedText;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  bool matchPattern(String text, String word) {
    String pattern = r"^" + word;
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(text);
  }

  @override
  void paint(Canvas canvas, Size size) {
    List<KeyValuePair> matchedKeyValues = [];
    bool shouldContinueline = false;

    for (final textBlock in recognizedText.blocks) {
      if (highlightedTextIdList != null) {
        for (int idx = 0; idx < textBlock.lines.length; idx++) {
          if (shouldContinueline) {
            shouldContinueline = false;
            continue;
          }
          final currLine = textBlock.lines[idx];
          TextLine? nextLine;
          if (idx + 1 < textBlock.lines.length) {
            nextLine = textBlock.lines[idx + 1];
          }

          final keyValue = getMatchedKeyValue(
            highlightedTextIdList!,
            currLine.text,
          );
          if (keyValue != null) {
            debugPrint("keyvalue = ${keyValue.value}");
            if (idx != textBlock.lines.length - 1 && nextLine != null) {
              final newKeyValue = KeyValuePair(
                key: keyValue.key,
                value: keyValue.value + nextLine.text,
                isLineApn: true,
              );
              matchedKeyValues.add(newKeyValue);
              paintTextLine(canvas, size, currLine);
              paintTextLine(canvas, size, nextLine);
              shouldContinueline = true;
            } else {
              matchedKeyValues.add(keyValue);
              paintTextLine(canvas, size, currLine);
            }
          } else {
            // for length 1 patterns
            bool lastElementMatched = false;
            for (int id = 0; id < currLine.elements.length; id++) {
              final textElement = currLine.elements[id];
              for (final textPattern in textPatterns!) {
                if (textPattern.pattern.hasMatch(textElement.text)) {
                  final keyValue = KeyValuePair(
                    key: textPattern.key,
                    value: modifiedTextValue(
                      textElement.text,
                      textPattern.key,
                    ),
                  );
                  matchedKeyValues.add(keyValue);
                  paintTextElement(canvas, size, textElement);
                  if (id == currLine.elements.length - 1) {
                    lastElementMatched = true;
                  }
                  break;
                }
              }
            }
            if (!lastElementMatched && nextLine != null) {
              final concatedText =
                  currLine.elements.last.text + nextLine.elements.first.text;
              for (final textPattern in textPatterns!) {
                if (textPattern.pattern.hasMatch(concatedText)) {
                  final keyValue = KeyValuePair(
                    key: textPattern.key,
                    value: modifiedTextValue(
                      concatedText,
                      textPattern.key,
                    ),
                  );
                  matchedKeyValues.add(keyValue);
                  paintThreeLengthPattern(canvas, size, currLine.elements.last,
                      currLine.elements.last, concatedText);
                  break;
                }
              }
            }

            // For Length 3 patterns
            List<TextElement> textElements = [];
            textElements.addAll(currLine.elements);
            if (nextLine != null) {
              textElements.add(nextLine.elements[0]);
              if (nextLine.elements.length > 1) {
                textElements.add(nextLine.elements[1]);
              }
            }
            for (int id = 0; id <= textElements.length - 3; id++) {
              final concatedText =
                  '${textElements[id].text} ${textElements[id + 1].text} ${textElements[id + 2].text}';
              for (final textPattern in textPatterns!) {
                if (textPattern.maxLength != 3) continue;
                if (textPattern.pattern.hasMatch(concatedText)) {
                  final keyValue = KeyValuePair(
                    key: textPattern.key,
                    value: modifiedTextValue(
                      concatedText,
                      textPattern.key,
                    ),
                  );
                  matchedKeyValues.add(keyValue);
                  paintThreeLengthPattern(canvas, size, textElements[id],
                      textElements[id + 2], concatedText);
                  break;
                }
              }
            }
          }
        }
      }
    }

    if (onReturnMatchedTexts != null) {
      onReturnMatchedTexts!(matchedKeyValues);
    }
  }

  String modifiedTextValue(String text, String key) {
    if (!isNumeric(text.characters.last)) {
      text = text.substring(0, text.length - 1);
    }
    text = (key != amountKey)
        ? text
        : isNumeric(text.characters.first)
            ? '\$${text.substring(0)}'
            : '\$${text.substring(1)}';
    return text;
  }

  void paintTextLine(Canvas canvas, Size size, TextLine textLine) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint background = Paint()..color = const Color(0x99000000);

    final ParagraphBuilder builder = ParagraphBuilder(
      ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: 16,
        textDirection: TextDirection.ltr,
      ),
    );
    builder.pushStyle(
      ui.TextStyle(
        color: Colors.lightGreenAccent,
        background: background,
      ),
    );
    builder.addText(textLine.text);
    builder.pop();

    final left = translateX(
      textLine.boundingBox.left,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final top = translateY(
      textLine.boundingBox.top,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final right = translateX(
      textLine.boundingBox.right,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    // final bottom = translateY(
    //   textBlock.boundingBox.bottom,
    //   size,
    //   imageSize,
    //   rotation,
    //   cameraLensDirection,
    // );
    //
    // canvas.drawRect(
    //   Rect.fromLTRB(left, top, right, bottom),
    //   paint,
    // );

    final List<Offset> cornerPoints = <Offset>[];
    for (final point in textLine.cornerPoints) {
      double x = translateX(
        point.x.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      double y = translateY(
        point.y.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      if (Platform.isAndroid) {
        switch (cameraLensDirection) {
          case CameraLensDirection.front:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation90deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation270deg:
                x = translateX(
                  point.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                );
                y = size.height -
                    translateY(
                      point.x.toDouble(),
                      size,
                      imageSize,
                      rotation,
                      cameraLensDirection,
                    );
                break;
            }
            break;
          case CameraLensDirection.back:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation270deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation90deg:
                x = size.width -
                    translateX(
                      point.y.toDouble(),
                      size,
                      imageSize,
                      rotation,
                      cameraLensDirection,
                    );
                y = translateY(
                  point.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                );
                break;
            }
            break;
          case CameraLensDirection.external:
            break;
        }
      }

      cornerPoints.add(Offset(x, y));
    }

    // Add the first point to close the polygon
    cornerPoints.add(cornerPoints.first);
    canvas.drawPoints(PointMode.polygon, cornerPoints, paint);

    canvas.drawParagraph(
      builder.build()
        ..layout(ParagraphConstraints(
          width: (right - left).abs(),
        )),
      Offset(
          Platform.isAndroid && cameraLensDirection == CameraLensDirection.front
              ? right
              : left,
          top),
    );
  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }

  KeyValuePair? getMatchedKeyValue(
    List<String> textKeys,
    String line,
  ) {
    line.trim();
    String matchedKey = '';
    String value = '';

    for (var key in textKeys) {
      if (line.startsWith(key)) {
        for (int pos = key.length; pos < line.length; pos++) {
          if (isNumeric(line[pos])) {
            matchedKey = key;
            value = line.substring(pos);
            break;
          }
        }
        break;
      }
    }

    if (matchedKey.isEmpty) return null;
    return KeyValuePair(
      key: matchedKey,
      value: value,
      isLineApn: true,
    );
  }

  void paintTextElement(
      ui.Canvas canvas, ui.Size size, TextElement textElement) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint background = Paint()..color = const Color(0x99000000);

    final ParagraphBuilder builder = ParagraphBuilder(
      ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: 16,
        textDirection: TextDirection.ltr,
      ),
    );
    builder.pushStyle(
      ui.TextStyle(
        color: Colors.lightGreenAccent,
        background: background,
      ),
    );
    builder.addText(textElement.text);
    builder.pop();

    final left = translateX(
      textElement.boundingBox.left,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final top = translateY(
      textElement.boundingBox.top,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final right = translateX(
      textElement.boundingBox.right,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    // final bottom = translateY(
    //   textBlock.boundingBox.bottom,
    //   size,
    //   imageSize,
    //   rotation,
    //   cameraLensDirection,
    // );
    //
    // canvas.drawRect(
    //   Rect.fromLTRB(left, top, right, bottom),
    //   paint,
    // );

    final List<Offset> cornerPoints = <Offset>[];
    for (final point in textElement.cornerPoints) {
      double x = translateX(
        point.x.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      double y = translateY(
        point.y.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      if (Platform.isAndroid) {
        switch (cameraLensDirection) {
          case CameraLensDirection.front:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation90deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation270deg:
                x = translateX(
                  point.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                );
                y = size.height -
                    translateY(
                      point.x.toDouble(),
                      size,
                      imageSize,
                      rotation,
                      cameraLensDirection,
                    );
                break;
            }
            break;
          case CameraLensDirection.back:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation270deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation90deg:
                x = size.width -
                    translateX(
                      point.y.toDouble(),
                      size,
                      imageSize,
                      rotation,
                      cameraLensDirection,
                    );
                y = translateY(
                  point.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                );
                break;
            }
            break;
          case CameraLensDirection.external:
            break;
        }
      }

      cornerPoints.add(Offset(x, y));
    }

    // Add the first point to close the polygon
    cornerPoints.add(cornerPoints.first);
    canvas.drawPoints(PointMode.polygon, cornerPoints, paint);

    canvas.drawParagraph(
      builder.build()
        ..layout(ParagraphConstraints(
          width: (right - left).abs(),
        )),
      Offset(
          Platform.isAndroid && cameraLensDirection == CameraLensDirection.front
              ? right
              : left,
          top),
    );
  }

  void paintThreeLengthPattern(
    ui.Canvas canvas,
    ui.Size size,
    TextElement firstElement,
    TextElement secondElement,
    String concatedText,
  ) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint background = Paint()..color = const Color(0x99000000);

    final ParagraphBuilder builder = ParagraphBuilder(
      ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: 16,
        textDirection: TextDirection.ltr,
      ),
    );
    builder.pushStyle(
      ui.TextStyle(
        color: Colors.lightGreenAccent,
        background: background,
      ),
    );
    builder.addText(concatedText);
    builder.pop();

    final left = translateX(
      firstElement.boundingBox.left,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final top = translateY(
      firstElement.boundingBox.top,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    final right = translateX(
      secondElement.boundingBox.right,
      size,
      imageSize,
      rotation,
      cameraLensDirection,
    );
    // final bottom = translateY(
    //   textBlock.boundingBox.bottom,
    //   size,
    //   imageSize,
    //   rotation,
    //   cameraLensDirection,
    // );
    //
    // canvas.drawRect(
    //   Rect.fromLTRB(left, top, right, bottom),
    //   paint,
    // );

    final List<Offset> cornerPoints = <Offset>[];
    for (final point in firstElement.cornerPoints) {
      double x = translateX(
        point.x.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      double y = translateY(
        point.y.toDouble(),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      if (Platform.isAndroid) {
        switch (cameraLensDirection) {
          case CameraLensDirection.front:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation90deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation270deg:
                x = translateX(
                  point.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                );
                y = size.height -
                    translateY(
                      point.x.toDouble(),
                      size,
                      imageSize,
                      rotation,
                      cameraLensDirection,
                    );
                break;
            }
            break;
          case CameraLensDirection.back:
            switch (rotation) {
              case InputImageRotation.rotation0deg:
              case InputImageRotation.rotation270deg:
                break;
              case InputImageRotation.rotation180deg:
                x = size.width - x;
                y = size.height - y;
                break;
              case InputImageRotation.rotation90deg:
                x = size.width -
                    translateX(
                      point.y.toDouble(),
                      size,
                      imageSize,
                      rotation,
                      cameraLensDirection,
                    );
                y = translateY(
                  point.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                );
                break;
            }
            break;
          case CameraLensDirection.external:
            break;
        }
      }

      cornerPoints.add(Offset(x, y));
    }

    // Add the first point to close the polygon
    cornerPoints.add(cornerPoints.first);
    canvas.drawPoints(PointMode.polygon, cornerPoints, paint);

    canvas.drawParagraph(
      builder.build()
        ..layout(ParagraphConstraints(
          width: (right - left).abs(),
        )),
      Offset(
          Platform.isAndroid && cameraLensDirection == CameraLensDirection.front
              ? right
              : left,
          top),
    );
  }
}

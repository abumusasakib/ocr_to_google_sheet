# Live OCR Text Recognizer

This project is a **Live OCR (Optical Character Recognition) Text Recognizer** that processes text in real time using the device's camera and highlights specific key-value pairs and patterns found in the text. It uses **Google's ML Kit Text Recognition** to extract and process text, and integrates with **Google Sheets** to update recognized data.

## Features

- **Live OCR Text Recognition**: Captures text from the camera feed in real time.
- **Key-Value Matching**: Detects and highlights predefined key-value pairs from recognized text.
- **Pattern Matching**: Identifies and highlights specific patterns, such as monetary amounts and dates.
- **Google Sheets Integration**: Automatically updates recognized key-value pairs to a selected Google Sheet.
- **Auto-Navigation**: Navigates to the next screen once key-value pairs are matched.
- **Customizable Detection**: Easily extend the application to recognize additional text patterns.

## Tech Stack

- **Flutter**: For building the user interface and handling camera input.
- **Google ML Kit**: For real-time text recognition.
- **Google Sheets API**: To update recognized key-value pairs into Google Sheets.
- **Camera Package**: For capturing images and video feed from the device's camera.
- **Custom Painter**: For drawing bounding boxes around recognized text in the camera view.

## Installation

### Prerequisite

Make sure you have [Flutter](https://flutter.dev/docs/get-started/install) installed on your system.

### Development Environment Setup

#### 1. Prepare Workspace

```bash
# Clone the project repository

git clone <repo url>

# Navigate to the project directory:
cd live_ocr
```

#### 2. Add Project Secrets

Collect these files from the `live-ocr-credentials` folder:

- `keystore.jks`

- `key.properties`

```bash
# Place them like this:

.

|__ android

| |__ keystore.jks

| |__ key.properties

|__ ios

|__ README.md
```

#### 3. Install `fvm`

```bash
# macos or brew package manager for linux

brew tap leoafarias/fvm

brew install fvm

dart pub global activate fvm
```

#### 4. Install the dependencies

```bash
fvm flutter pub get 
```

### How to Run

#### Android Studio Launch Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="RunManager">

    <!-- Debug Mode Configuration -->
    <configuration name="live_ocr (Debug Mode)" type="FlutterRunConfigurationType" factoryName="Flutter">
      <option name="filePath" value="$PROJECT_DIR$/lib/main.dart" />
      <method v="2" />
    </configuration>

    <!-- Release Mode Configuration -->
    <configuration name="live_ocr (Release Mode)" type="FlutterRunConfigurationType" factoryName="Flutter">
      <option name="filePath" value="$PROJECT_DIR$/lib/main.dart" />
      <option name="buildFlavor" value="release" /> <!-- Added release flag -->
      <method v="2" />
    </configuration>

  </component>
</project>
```

#### Through the command line

You can run the Flutter app in release mode from the command line using this command:

```bash
fvm flutter run --release
```

This command will build and run the Flutter app in release mode.

### How to build the APK

Run the following command to generate a signed APK in release mode:

```bash
fvm flutter build apk --release
```

This will create a signed APK with the provided keystore.

### Firebase App Setup (Maintainers Only)

Ensure that you have enabled the appropriate APIs (Google Drive, Google Sheets) in the Google Cloud Console project.

#### Change the Android package name in a Flutter project

##### Step 1: Change the Package Name in the Flutter Project

1. **Update `AndroidManifest.xml` files:**

   - Go to `android/app/src/main/AndroidManifest.xml`.

   - Look for the `package` attribute in the `<manifest>` tag and change it to your new package name (if available).

     ```xml
     <manifest xmlns:android="http://schemas.android.com/apk/res/android"
         package="com.newpackage.name">
     ```

   - Repeat this in `android/app/src/debug/AndroidManifest.xml` and `android/app/src/profile/AndroidManifest.xml` if they exist.

2. **Update the package in the `build.gradle` file:**

   - Open `android/app/build.gradle`.
   - Update the `applicationId` to match the new package name.

     ```gradle
     defaultConfig {
         applicationId "com.newpackage.name"
     }
     ```

3. **Update the directory structure:**

   - Navigate to `android/app/src/main/java` or `android/app/src/main/kotlin` (depending on whether you’re using Java or Kotlin).

   - Rename the directory structure to match your new package name (e.g., from `com/oldpackage/name` to `com/newpackage/name`).

     - In your file explorer, rename each directory individually, for example:
       - `com/oldpackage` → `com/newpackage`
       - `name/oldpackage` → `name/newpackage`

   - Update the package declaration inside your `MainActivity.java` (or `.kt`) file to reflect the new package.

     ```java
     package com.newpackage.name;
     ```

4. **Sync the project:**

   - Open Android Studio and run `flutter clean`.
   - Rebuild the project (`flutter pub get`) to ensure the changes take effect.

##### Step 2: Update the Package Name in Firebase

1. **Create a New Android App in Firebase:**

   - Go to the Firebase console: [https://console.firebase.google.com](https://console.firebase.google.com).
   - Select your project.
   - In the Firebase dashboard, navigate to the **"Project Settings"** by clicking on the gear icon in the left sidebar.
   - Scroll down to the **"Your Apps"** section, and click **Add App** → **Android**.
   - Enter your new Android package name in the "Android package name" field.

2. **Download the new `google-services.json` file:**

   - After you register your new app, Firebase will prompt you to download a new `google-services.json` file.
   - Download it and place it in your Flutter project at `android/app/`.

3. **Update `google-services.json`:**

   - Replace the old `google-services.json` file with the newly downloaded one inside the `android/app/` directory.

4. **Rebuild your app:**

   - Re-run your project in release/debug mode to ensure everything is working with the new package name.
   - Firebase will now recognize the new app configuration.

##### Step 3: Update Firebase Authentication (If Needed)

- In Firebase, you may need to set up authentication methods (like Google Sign-In) for the new Android app you just registered.
- For Google Sign-In, make sure to add the SHA-1 and SHA-256 fingerprints for the new app in Firebase.

After completing these steps, both the Android package name in your Flutter project and Firebase will be updated successfully!

#### Get **SHA-1 fingerprint** from credential files

To get the **SHA-1 fingerprint** from the `keytool` command, you need to run this command:

##### Command to get the SHA-1 fingerprint

```bash
keytool -list -v -keystore keystore.jks -alias key -storepass ocr1234 -keypass ocr1234
```

- **`-v`:** This flag gives a verbose output, which includes both SHA-1 and SHA-256 fingerprints.
- **`-keystore keystore.jks`:** Specifies the path to the keystore file.
- **`-alias key`:** Specifies the alias of the key you are working with.
- **`-storepass ocr1234`:** The password for the keystore.
- **`-keypass ocr1234`:** The password for the key itself (if needed).

##### Output

This will provide a detailed output that includes both **SHA-1** and **SHA-256** fingerprints like this:

```text
Certificate fingerprints:
         SHA1:  XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
         SHA256: E4:11:4A:40:4B:DD:F2:6C:E9:3D:04:0F:62:1B:3B:14:32:CB:5E:76:7A:B3:40:88:A0:3E:B1:8F:1A:1A:CA:14
```

The **SHA-1** fingerprint will be listed under `SHA1`. You can then add this to your Firebase project (if you're using Firebase) or the Google Cloud Console.

## Project Structure

The core files of this project are:

```bash
lib/
│
├── google_sheet_update_widget.dart    # Handles updating data to Google Sheets
├── text_detector_painter.dart         # CustomPainter for highlighting recognized text
├── text_detector_view.dart            # Main screen with camera feed and text processing
├── detector_view.dart                 # Widget for handling camera and image input
├── coordinates_translator.dart        # Utility for translating coordinates for the camera
└── main.dart                          # App entry point
```

## How The App Works

1. **Text Recognition**: The app uses the device's camera to capture images in real time, and Google ML Kit's text recognizer extracts text from the image.
2. **Matching Text**: The `TextRecognizerPainter` is responsible for drawing bounding boxes around detected text and matching specific key-value pairs or text patterns.
3. **Auto Navigation**: If a match is found for predefined keys (like `Name`, `Date of Birth`, etc.), the app automatically navigates to the next screen, which allows users to update the matched data into Google Sheets.
4. **Google Sheets Update**: On the next screen, users can select a Google Sheet from a list of available sheets, and the recognized key-value pairs are written into the selected sheet.

## How The Text Matching Works

Here's a high-level summary of how it works:

1. **Pattern Matching**:
   
   - We use the `KeyPatternPair` class to define the key and regex pattern for matching specific text (e.g., date and amount formats).
   - In the `paint` method, we're iterating through each `TextElement` (smallest unit of recognized text) and applying the regex pattern from `textPatterns` using the `hasMatch` method.

2. **Code Adjustments**:
   
   - **Regex for Alphanumeric Characters**:
     The `isAlphanumeric` function helps filter non-alphanumeric characters. It's already in place to assist in matching the key-value pairs.
   - **Pattern Matching with Highlighting**:
     The `textPattern.pattern.hasMatch(textElement.text)` ensures that each `TextElement` is checked against the regex pattern. When a match is found, the matching text is stored in a `KeyValuePair` object and highlighted on the canvas.

Here's an overview of what the key points are doing and how the integration works:

### Integration of Regex in `paint`

```dart
if (textPatterns != null) {
  for (final textLine in textBlock.lines) {
    for (final textElement in textLine.elements) {
      for (final textPattern in textPatterns!) {
        if (textPattern.pattern.hasMatch(textElement.text)) {
          final keyValue = KeyValuePair(
            key: textPattern.key,
            value: textElement.text,
          );
          matchedKeyValues.add(keyValue);
          paintPatternBorder(canvas, size, textElement);  // Highlight the matched text
        }
      }
    }
  }
}
```

#### Explanation

1. **Text Element Matching**:
   Each `textElement.text` (detected text) is checked against all regex patterns in `textPatterns`. If the regex pattern matches, the `KeyValuePair` stores the key and matched value, which can later be returned for further processing (like updating Google Sheets).

2. **Visual Highlighting**:
   The matched text is visually highlighted by calling `paintPatternBorder`, which draws a rectangle around the matched text element using the bounding box coordinates.

### Customization

We can easily extend the functionality by adding new text patterns or updating the key-value matching logic:

- **Key-Value Matching**: Modify the `searchingTextKeys` list in `text_detector_view.dart` to detect new keys.
- **Pattern Matching**: Add new `KeyPatternPair` items to the `searchingTextPatterns` list to match additional text patterns.

## Known Issue

The app is currently optimized for Android devices. Some adjustments may be needed for iOS.

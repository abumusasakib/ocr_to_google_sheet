# Live OCR to Google Sheet

This project is a Flutter application that performs Optical Character Recognition (OCR) using Google ML Kit and allows the recognized text to be saved directly to Google Sheets. The app is designed to work on both Android and iOS and includes Firebase integration for additional functionality.

## Features

- **Real-time Text Recognition**: Utilizes Google ML Kit for OCR functionality to recognize text from images in real-time.
- **Google Sheets Integration**: Automatically saves recognized text to a Google Sheet.
- **Google Authentication**: Allows users to securely authenticate with Google for accessing Google Sheets.
- **Cross-Platform Support**: Runs on both Android and iOS devices.
- **Environment Configurations**: Environment variables managed via `.env` file for secure storage of sensitive information like API keys.

## Project Structure

```plaintext
.
├── google_mlkit_text_recognition        # Google ML Kit plugin for text recognition
├── live_ocr                             # Main app directory
│   ├── android                          # Android-specific configurations and build files
│   ├── assets                           # Project assets (e.g., images, ML models)
│   ├── ios                              # iOS-specific configurations and build files
│   ├── lib                              # Core Flutter codebase
│   │   ├── main.dart                    # Entry point of the application
│   │   ├── firebase_options.dart        # Firebase configuration options (do not hardcode keys here)
│   │   ├── google_auth_client.dart      # Google authentication client setup
│   │   ├── google_sheet_update_widget.dart  # UI for updating Google Sheets
│   │   ├── spreadsheet_manager.dart     # Manages interaction with Google Sheets
│   │   └── utils_google.dart            # Utility functions for Google services
│   ├── pubspec.yaml                     # Project dependencies
│   └── web                              # Web-specific files for web builds
```

## Getting Started

### Prerequisites

- **Flutter**: [Install Flutter](https://flutter.dev/docs/get-started/install) if you haven't already.
- **Firebase**: Set up Firebase for Android and iOS.
- **Google Cloud Project**: Enable Google Sheets and Google Drive APIs in your Google Cloud project.

### Configuration

1. **Set up Firebase**
   - Run the Firebase CLI to configure Firebase options:
     ```bash
     flutterfire configure
     ```
   - This will create `firebase_options.dart` in `lib/`.

2. **Add API Keys**
   - Add your Google Sheets API key and other sensitive information to the `.env` file in the root directory:
     ```plaintext
     FIREBASE_API_KEY=your-firebase-api-key
     FIREBASE_APP_ID=your-firebase-app-id
     FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
     FIREBASE_PROJECT_ID=your-project-id
     FIREBASE_STORAGE_BUCKET=your-storage-bucket
     ```
   - Ensure `.env` is listed in `.gitignore` to keep it secure.

3. **Enable Google Sheets and Drive APIs**
   - In your Google Cloud Console, enable the Google Sheets API and Google Drive API for your project.

4. **Authentication**
   - Add OAuth 2.0 credentials to your Google Cloud project to enable secure access to Google Sheets.

### Running the Application

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run the application:
   ```bash
   flutter run
   ```

### Important Files

- `lib/firebase_options.dart`: Firebase configuration, generated by FlutterFire CLI.
- `lib/google_auth_client.dart`: Handles Google authentication for accessing Google Sheets.
- `lib/spreadsheet_manager.dart`: Contains methods for interacting with Google Sheets API.
- `lib/utils_google.dart`: Utility functions to assist with Google API interactions.

## Additional Notes

- **Environment Variables**: Environment variables are managed using `flutter_dotenv`. Refer to `pubspec.yaml` for package dependencies.
- **Android and iOS Setup**: Ensure that Firebase and Google API credentials are correctly set up in the `android` and `ios` directories.

## Contributing

If you’d like to contribute, please fork the repository and submit a pull request with any proposed changes.

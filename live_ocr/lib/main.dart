import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:live_ocr/firebase_options.dart';
import 'package:live_ocr/utils_google.dart';
import 'package:live_ocr/home_screen_view.dart';
import 'package:live_ocr/google_signin_view.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if the user is already logged in and redirect accordingly
  final result = await _checkIfLoggedIn();
  runApp(MyApp(
    isLoggedIn: result['isLoggedIn'] as bool,
    sheetsFiles: result['sheetsFiles'] as List<drive.File>,
  ));
}

Future<Map<String, dynamic>> _checkIfLoggedIn() async {
  await SignInToGoogle.googleSignIn.signInSilently();
  if (SignInToGoogle.googleSignIn.currentUser != null) {
    // Fetch the list of Google Sheets if the user is already logged in
    final List<drive.File> sheetsFiles =
        await GoogleDriveUtility.fetchSheetsFiles();
    return {'isLoggedIn': true, 'sheetsFiles': sheetsFiles};
  }
  return {
    'isLoggedIn': false,
    'sheetsFiles': <drive.File>[]
  }; // Here sheetsFiles is an empty List<drive.File>
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final List<drive.File> sheetsFiles;

  const MyApp({super.key, required this.isLoggedIn, required this.sheetsFiles});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          isLoggedIn ? Home(sheetsFiles: sheetsFiles) : const SignInToGoogle(),
    );
  }
}

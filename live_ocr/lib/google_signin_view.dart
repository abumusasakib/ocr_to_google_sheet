import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:live_ocr/google_auth_client.dart';
import 'package:live_ocr/home_screen_view.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis/drive/v3.dart' as drive;

const List<String> scopes = <String>[
  'email',
  drive.DriveApi.driveReadonlyScope,
  sheets.SheetsApi.spreadsheetsScope,
];

class SignInToGoogle extends StatefulWidget {
  static final GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes);

  const SignInToGoogle({super.key});

  @override
  State<SignInToGoogle> createState() => _SignInToGoogleState();
}

class _SignInToGoogleState extends State<SignInToGoogle> {
  @override
  void initState() {
    super.initState();
    SignInToGoogle.googleSignIn.onCurrentUserChanged.listen((account) {
      if (account != null) {
        _fetchSheetsFilesAndNavigate();
      }
    });
    SignInToGoogle.googleSignIn.signInSilently();
  }

  Future<void> _fetchSheetsFilesAndNavigate() async {
    final currentUser = SignInToGoogle.googleSignIn.currentUser;
    final authHeaders = await currentUser!.authHeaders;
    final authenticatedClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticatedClient);

    final fileList = await driveApi.files
        .list(q: "mimeType='application/vnd.google-apps.spreadsheet'");
    final files = fileList.files ?? [];

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(sheetsFiles: files),
        ),
      );
    }
  }

  Future<void> _handleSignIn() async {
    await SignInToGoogle.googleSignIn.signIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in with Google')),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleSignIn,
          child: const Text('Sign In'),
        ),
      ),
    );
  }
}

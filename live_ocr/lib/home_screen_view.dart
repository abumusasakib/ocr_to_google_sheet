import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:live_ocr/google_signin_view.dart';
import 'package:live_ocr/text_detector_view.dart';

class Home extends StatefulWidget {
  final List<drive.File> sheetsFiles;
  const Home({super.key, required this.sheetsFiles});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<drive.File> _sheetsFiles = [];
  String spreadSheetId = '';

  @override
  void initState() {
    super.initState();
    _sheetsFiles = widget.sheetsFiles; // Initialize with the provided list
  }

  void _handleLogout() async {
    await SignInToGoogle.googleSignIn.disconnect();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInToGoogle()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "LiveOCR",
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: theme.textTheme.headlineMedium?.fontSize,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when the user taps outside any input fields
          FocusScope.of(context).unfocus();
        },
        child: TextRecognizerView(
          sheetsFiles: _sheetsFiles,
        ),
      ),
    );
  }
}

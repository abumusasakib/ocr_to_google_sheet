import 'package:http/http.dart' as http;

// Helper class for Google API authentication
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Add the auth headers to each request
    return _client.send(request..headers.addAll(_headers));
  }
}
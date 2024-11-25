import 'package:http/http.dart' as http;
import 'dart:convert';

class MpesaServices {
  final String consumerKey;
  final String consumerSecret;
  final bool isSandbox;

  MpesaServices({
    required this.consumerKey,
    required this.consumerSecret,
    this.isSandbox = true,
  });

  Future<String> _getAccessToken() async {
    String authUrl = isSandbox
        ? 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'
        : 'https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';

    String credentials = base64.encode(utf8.encode('$consumerKey:$consumerSecret'));
    var response = await http.get(
      Uri.parse(authUrl),
      headers: {'Authorization': 'Basic $credentials'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['access_token'];
    } else {
      var error = json.decode(response.body);
      throw Exception('Failed to obtain access token: ${error['error_description']}');
    }
  }

  Future<Map<String, dynamic>> initiateB2CTransaction({
    required String phoneNumber,
    required double amount,
    required String commandID,
    required String remarks,
    required String initiatorName,
    required String securityCredentials,
    required String shortcode,
    String? occasion,
  }) async {
    String accessToken = await _getAccessToken();
    String b2cUrl = isSandbox
        ? 'https://sandbox.safaricom.co.ke/mpesa/b2c/v1/paymentrequest'
        : 'https://api.safaricom.co.ke/mpesa/b2c/v1/paymentrequest';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    Map<String, dynamic> body = {
      "InitiatorName": initiatorName,
      "SecurityCredential": securityCredentials,
      "CommandID": commandID,
      "Amount": amount,
      "PartyA": shortcode,
      "PartyB": phoneNumber,
      "Remarks": remarks,
      "QueueTimeOutURL": "https://mydomain.com/b2c/queue",
      "ResultURL": "https://us-central1-sem3-e5826.cloudfunctions.net/mpesaB2CResult",
      "Occasion": occasion ?? "",
    };

    var response = await http.post(
      Uri.parse(b2cUrl),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      var error = json.decode(response.body);
      throw Exception('B2C transaction failed: ${error['errorMessage']}');
    }
  }
}

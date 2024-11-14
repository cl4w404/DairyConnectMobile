import 'package:http/http.dart' as http;
import 'dart:convert';

class MpesaService {
  final String consumerKey;
  final String consumerSecret;
  final bool isSandbox;

  MpesaService({
    required this.consumerKey,
    required this.consumerSecret,
    this.isSandbox = true,
  });

  Future<String> _getAccessToken() async {
    String authUrl = isSandbox
        ? 'https://sandbox.safaricom.co.ke/oauth/v3/generate?grant_type=client_credentials'
        : 'https://api.safaricom.co.ke/oauth/v3/generate?grant_type=client_credentials';

    String credentials = base64.encode(utf8.encode('$consumerKey:$consumerSecret'));
    var response = await http.get(
      Uri.parse(authUrl),
      headers: {'Authorization': 'Basic $credentials'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Failed to obtain access token');
    }
  }

  Future<Map<String, dynamic>> initiateB2CTransaction({
    required String phoneNumber,
    required double amount,
    required String commandID,
    required String remarks,
    String? occasion,
  }) async {
    String accessToken = await _getAccessToken();
    String b2cUrl = isSandbox
        ? 'https://sandbox.safaricom.co.ke/mpesa/b2c/v3/paymentrequest'
        : 'https://api.safaricom.co.ke/mpesa/b2c/v3/paymentrequest';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    Map<String, dynamic> body = {
      "InitiatorName": "your_initiator_name", // Replace with your initiator name
      "InitiatorPassword":"",
      "SecurityCredential": "your_encoded_security_credential", // Replace with your encoded credential
      "CommandID": commandID,
      "Amount": amount,
      "PartyA": "your_short_code", // Your B2C shortcode
      "PartyB": phoneNumber,
      "Remarks": remarks,
      "QueueTimeOutURL": "your_timeout_url",
      "ResultURL": "your_result_url",
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
      throw Exception('B2C transaction failed');
    }
  }
}

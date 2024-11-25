import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/controller/ServiceOptions/mpesa_service.dart';
import 'package:rive/rive.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/MpesaService.dart';

class MpesaService extends StatefulWidget {
  MpesaService({Key? key}) : super(key: key);

  @override
  _MpesaServiceState createState() => _MpesaServiceState();
}

class _MpesaServiceState extends State<MpesaService> {
  Map<String, dynamic>? userDetails;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController amount = TextEditingController();
  String? phoneNumber;

  void performTransaction(double amountM, String phone) async {
    MpesaServices mpesaService = MpesaServices(
      consumerKey: "nAxLxBXpZmipLH8kRph4qSYLuyAqjNpk6jcLp4FAfO65ASWc",
      consumerSecret: "6DBbwtdBbZeZwBW9z9xMgo4pgrptiu1CiP2Ha9OH0Uw9kwnJ257KIY1CvljAvS7p",
      isSandbox: true, // Set to false in production
    );

    setState(() {
      isLoading = true;
    });

    try {
      var result = await mpesaService.initiateB2CTransaction(
        phoneNumber: phone,
        amount: amountM,
        commandID: "BusinessPayment",
        remarks: "Test remarks",
        occasion: "null",
        initiatorName: 'testapi',
        securityCredentials: 'XM53emtz0dCA7nywZ/iGIJNsz6petTDQ/VN9gEDiLWOK+QTDmXOxT0+jeKE1bHN3iz5AqggFSWdafPeSLk6mTKYixE0yco7eFAcvfdPfMcMNuUcPneljxZ3sH1j8Iog28Ln5UD+WP8ULJb+cCR8vyMYAWrdtnEPVF2I5JtibDWGcMnprWDmHn36b8Rp8bHdv+aQTlEnLLcNs3sdaMtpKMBx/5YjFIQBV3EPtiX11yMijAHDVySqO5QVxhDB+IZZ7BC2pLw1/TVAWk2hXssl7oXRTEjnsD9JTUhiv6pB2CqKUNVsQXilIFhevHZl1oX9w9U4hLWuF/E3fQxv34wbVnw==',
        shortcode: "600990",
      );

      setState(() {
        isLoading = false;
      });

      _showAlert(
          context, "Success", "Transaction successful", AlertType.success);
      print(result);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      _showAlert(context, "Failed", "Transaction failed", AlertType.error);
      print(e);
    }
  }

  void _showAlert(
      BuildContext context, String title, String desc, AlertType type) {
    Alert(
      context: context,
      type: type,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            amount.clear();
          },
          width: 120,
        )
      ],
    ).show();
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final data = await fetchUserDetails(uid);
      setState(() {
        userDetails = data;
      });
      fetchPhoneNumber(uid);
    }
  }

  Future<void> fetchPhoneNumber(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          phoneNumber = userDoc['phone_number'];
        });
      } else {
        print("User document does not exist");
      }
    } catch (e) {
      print("Error fetching phone number: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String uid) async {
    final String url =
        'https://dairyconnect.onrender.com/api/v1/dairyconnect/users/$uid';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "M-pesa Withdrawals",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter A Valid amount';
                  }
                  return null;
                },
                controller: amount,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.monetization_on,
                    color: Colors.blue.shade900,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 40.0),
                  labelText: "Amount",
                  filled: true,
                  fillColor: Colors.green.shade50,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Enter The amount you would like to Withdraw. Note that the amount should be 1 Ksh and above",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              if (userDetails != null)
                Text(
                  "Balance: ${userDetails!['balance']} Ksh",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            double d = double.parse(amount.text);
                            if (d <= userDetails!['balance']) {
                              if (phoneNumber != null) {
                                performTransaction(d, phoneNumber!);
                              } else {
                                _showAlert(context, "Failed", "Phone number not found", AlertType.error);
                              }
                            } else {
                              _showAlert(context, "Failed", "Insufficient balance", AlertType.error);
                            }
                          }
                        },
                        child: Text(
                          "Send",
                          style: TextStyle(color: Colors.white),
                        ))),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dairy_connect/admin/single-user.details.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rive/rive.dart';

class AddTransaction extends StatefulWidget {
  final String uid;

  AddTransaction({Key? key, required this.uid}) : super(key: key);

  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  TextEditingController transactionIds = TextEditingController();
  TextEditingController liters = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool? _selectedValue;

  // Function to generate a random transaction ID
  String generateRandomId({int length = 13}) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join('');
  }

  void _showLoadingAlert(BuildContext context) {
    Alert(
      context: context,
      title: "Loading",
      desc: "Please wait...",
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
        ],
      ),
      buttons: [],
      closeFunction: () {},
    ).show();
  }

  void _hideLoadingAlert(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.green.shade900),
        title: Text('Add Transaction'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return Center(child: Text("Document does not exist"));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text(
                      "Add Farmer's Collection",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ), // Centers the text
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.0),
                      child: Container(
                        height: 1.0,
                        width: 700.0,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 30),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 55,
                        backgroundImage: NetworkImage(data['passport']),
                      ),
                      title: Text(
                        data['name'],
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(data['account']),
                      selectedColor: Colors.green.shade50,
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SingleUserDetails(
                            uid: widget.uid,
                          ),
                        ));
                        print(widget.uid);
                      },
                    ),
                    SizedBox(
                      height: 250,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8, top: 25),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Enter Liters';
                                        }
                                        return null;
                                      },
                                      controller: liters,
                                      cursorColor: Colors.black,
                                      style: TextStyle(color: Colors.black),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.numbers_rounded,
                                          color: Colors.blue.shade900,
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 40.0),
                                        labelText: "Enter Liters",
                                        filled: true,
                                        fillColor: Colors.indigo.shade50,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: DropdownButtonFormField<bool>(
                                      decoration: InputDecoration(
                                        labelText: 'Select True or False',
                                        filled: true,
                                        fillColor: Colors.indigo.shade50,
                                        border: OutlineInputBorder(),
                                      ),
                                      value: _selectedValue,
                                      items: [
                                        DropdownMenuItem(
                                          value: true,
                                          child: Text('True'),
                                        ),
                                        DropdownMenuItem(
                                          value: false,
                                          child: Text('False'),
                                        ),
                                      ],
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          _selectedValue = newValue;
                                        });
                                      },
                                      hint: Text('Choose an option'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: SizedBox(
                                  width: 200,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        _showLoadingAlert(context); // Show loading alert
                                        try {
                                          final response = await http.post(
                                            Uri.parse(
                                                'https://dairyconnect.onrender.com/api/v1/dairyconnect/${widget.uid}/transactions'),
                                            headers: <String, String>{
                                              'Content-Type':
                                              'application/json',
                                            },
                                            body: jsonEncode(<String, dynamic>{
                                              'liters':
                                              double.parse(liters.text),
                                              'status': _selectedValue,
                                              'transactionId':
                                              generateRandomId(), // Call the function to generate ID
                                            }),
                                          );

                                          if (response.statusCode == 200 ||
                                              response.statusCode == 201) {
                                            _hideLoadingAlert(context);
                                            liters.clear();
                                            transactionIds.clear();
                                            Alert(
                                              context: context,
                                              type: AlertType.success,
                                              title: "Data Added",
                                              desc: "Data successfully added",
                                              buttons: [],
                                            ).show();
                                            print('Data inserted successfully');
                                          } else {
                                            _hideLoadingAlert(context); // Hide loading alert
                                            Alert(
                                              context: context,
                                              type: AlertType.error,
                                              title: "Error",
                                              desc: "Error inserting data",
                                              buttons: [],
                                            ).show();
                                            print(
                                                'Failed to insert data. Status code: ${response.statusCode}');
                                          }
                                        } catch (e) {
                                          _hideLoadingAlert(context); // Hide loading alert
                                          print('Error: $e');
                                          Alert(
                                            context: context,
                                            type: AlertType.error,
                                            title: "Error",
                                            desc: "$e",
                                            buttons: [],
                                          ).show();
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Add Record",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade900,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          // Show loading animation while data is loading
          return Center(
            child: RiveAnimation.asset('assets/loading.rive'),
          );
        },
      ),
    );
  }
}

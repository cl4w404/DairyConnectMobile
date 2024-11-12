import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dairy_connect/admin/admin.dart';
import 'package:dairy_connect/main.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rive/rive.dart';
import 'package:dairy_connect/models/TransactionEntity.dart';

class SingleUserDetails extends StatefulWidget {
  final String uid;

  SingleUserDetails({Key? key, required this.uid}) : super(key: key);

  @override
  State<SingleUserDetails> createState() => _SingleUserDetailsState();
}

class _SingleUserDetailsState extends State<SingleUserDetails> {
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();

  Future<void> resetPassword(String email) async {
    await firebase_auth.FirebaseAuth.instance
        .sendPasswordResetEmail(email: email);
  }

  List<Transactions> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://dairyconnect.onrender.com/api/v1/dairyconnect/${widget.uid}/transactions?limit=10'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          transactions =
              jsonData.map((json) => Transactions.fromJson(json)).toList();
        });
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.green.shade900),
        title: Text('Users Info'),
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
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    "Account Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 1.0,
                    color: Colors.blue.shade900,
                  ),
                  SizedBox(height: 30),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 55,
                      backgroundImage: NetworkImage(data['passport']),
                    ),
                    title: Text(
                      data['name'],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(data['account']),
                  ),
                  SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: Text("Download Statement",
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade900),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  cursorColor: Colors.black,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.email,
                                        color: Colors.blue.shade900),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 40.0),
                                    labelText: data['email'],
                                    filled: true,
                                    fillColor: Colors.indigo.shade50,
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  cursorColor: Colors.black,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.phone,
                                        color: Colors.blue.shade900),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 40.0),
                                    labelText: data['phone_number'],
                                    filled: true,
                                    fillColor: Colors.indigo.shade50,
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  cursorColor: Colors.black,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                        Icons.perm_identity_rounded,
                                        color: Colors.blue.shade900),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 40.0),
                                    labelText: data['national_id'],
                                    filled: true,
                                    fillColor: Colors.indigo.shade50,
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 235,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    firebase_auth.FirebaseAuth.instance
                                        .sendPasswordResetEmail(
                                            email: data['email'])
                                        .whenComplete(() {
                                      Alert(
                                        context: context,
                                        type: AlertType.success,
                                        title: "Activation Email",
                                        desc:
                                            "Activation email sent to ${data['email']}",
                                        buttons: [],
                                      ).show();
                                    });
                                  },
                                  child: Text("Edit Password",
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade900),
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: 235,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text("Edit Phone Number",
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Transaction Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  SizedBox(height: 15),
                  Container(
                    child: transactions.isNotEmpty
                        ? Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DataTable(
                                dataRowColor: transactions.length.isEven
                                    ? MaterialStateProperty.all(Colors.grey.shade200)
                                    : MaterialStateProperty.all(Colors.white),
                                columnSpacing: 30.0, // Space between columns
                                dataRowHeight: 60.0, // Height of each row
                                headingRowHeight: 50.0, // Height of header rowa
                                dataTextStyle: TextStyle(),
                                columns: const [
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Transaction ID')),
                                  DataColumn(label: Text('Liters')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Status')),
                                ],
                                rows: transactions.map((transaction) {
                                  return DataRow(cells: [
                                    DataCell(Text(transaction.date)),
                                    DataCell(
                                        Text(transaction.transactionId)),
                                    DataCell(Text(
                                        transaction.liters.toString())),
                                    DataCell(Text((transaction.liters * 40)
                                        .toString())),
                                    DataCell(transaction.status
                                      .toString() == 'true'?
                                    Text(transaction.status
                                        .toString(), style: TextStyle(color: Colors.green),)
                                        :Text(transaction.status
                                        .toString(), style: TextStyle(color: Colors.red),)), // Assuming 40 is the rate per liter
                                  ]);
                                }).toList(),
                              ),
                            ),
                          )
                        : Center(child: RiveAnimation.asset('loading.rive')),
                  ),
                ],
              ),
            );
          }

          return Center(child: RiveAnimation.asset('loading.rive'));
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class LandingPage extends StatefulWidget {
  LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<List<dynamic>> fetchTransactions(String uid) async {
    final String url =
        'https://dairyconnect.onrender.com/api/v1/dairyconnect/${uid}/transactions?limit=10';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> transactions = json.decode(response.body);
        return transactions;
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      print("Error fetching transactions: $e");
      return [];
    }
  }

  @override
  late String message;
  void initState() {
    super.initState();
    message = 'Flutter popup card demo app. Click the account icon in the top right.';
  }

  Future<void> _showTransactionDetails(Map<String, dynamic> transaction) async {
    await showPopupCard<String>(
      context: context,
      builder: (context) {
        return PopupCard(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: PopupCardDetails(transaction: transaction),
        );
      },
      offset: const Offset(-8, 60),
      alignment: Alignment.topCenter,
      useSafeArea: true,
      dimBackground: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;

    return Scaffold(
        body: FutureBuilder<DocumentSnapshot>(
          future: users.doc(uid).get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return Text("Document does not exist");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(data['passport']),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          children: [
                            Text(data['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            SizedBox(
                              height: 5,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1.0),
                              child: Container(
                                height: 2.0,
                                width: 115.0,
                                color: Colors.blue.shade50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Card design
                    SizedBox(
                      height: 190,
                      width: 360,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10)),
                          image: DecorationImage(
                            image: AssetImage('assets/card.jpg'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              trailing: Image.asset(
                                'assets/white.png',
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            ListTile(
                              leading: Image.asset('assets/chip.png'),
                              title: Text(
                                "${data['account']}",
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "${data['name']}",
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: Image.asset('assets/visa.png'),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Latest Transactions',
                        style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    SizedBox(
                      height: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.0),
                      child: Container(
                        height: 2.0,
                        width: 170.0,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<dynamic>>(
                        future: fetchTransactions(data['id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.green.shade900,
                                ));
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text("Failed to load transactions"));
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text("No transactions available"));
                          }

                          List<dynamic> transactions = snapshot.data!;
                          return ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              var transaction = transactions[index];
                              return ListTile(
                                onTap: () => _showTransactionDetails(transaction),
                                leading: CircleAvatar(
                                  radius: 27,
                                  backgroundColor: Colors.blue.shade900,
                                  child: Text(
                                    "T",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                  ),
                                ),
                                title: Text(
                                    "${DateFormat.yMMMMd().add_jm().format(DateTime.parse(transaction['date']))}",
                                    style: TextStyle(color: Colors.black)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${transaction['liters']} L",
                                        style: TextStyle(
                                            color: Colors.green.shade700)),

                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return Center(
                child: CircularProgressIndicator(
                  color: Colors.green.shade900,
                ));
          },
        ));
  }
}

class PopupCardDetails extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const PopupCardDetails({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Transaction Details",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
            SizedBox(height: 10),
            Text("Earnings: ${transaction['liters'] * 40} Ksh"),
            Text(
                "Date: ${DateFormat.yMMMMd().add_jm().format(DateTime.parse(transaction['date']))}"),
            Text("Status: ${transaction['status'] ? 'Completed' : 'Pending'}"),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rflutter_alert/rflutter_alert.dart';

class VetService extends StatefulWidget {
  VetService({Key? key}) : super(key: key);

  @override
  _VetServiceState createState() => _VetServiceState();
}

class _VetServiceState extends State<VetService> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  DateTime? selectedDate;
  bool isLoading = false;

  String generateRandomId({int length = 13}) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join('');
  }

  void submitAppointment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final uid = user.uid;

        // Debugging: Print the user ID
        print("User ID: $uid");

        // Send appointment data to external API
        final response = await http.post(
          Uri.parse('https://dairyconnect.onrender.com/api/v1/dairyconnect/$uid/withdrawals'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'date': DateTime.now().toIso8601String(),
            'amount': 500,
            'ref': generateRandomId().toString(),
            'type': "VetServices",
          }),
        );

        if (response.statusCode == 200) {
          try {
            // Save appointment to Firestore
            final docRef = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('appointments')
                .add({
              'date': dateController.text,
              'attended': false,
            });

            print("Appointment added with ID: ${docRef.id}");

            setState(() {
              dateController.clear();
              isLoading = false;
            });

            // Show success alert
            Alert(
              context: context,
              type: AlertType.success,
              title: "Appointment Booked",
              desc: "Your appointment has been successfully booked.",
              buttons: [
                DialogButton(
                  child: Text(
                    "OK",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  width: 120,
                )
              ],
            ).show();
          } catch (e) {
            setState(() {
              isLoading = false;
            });
            print("Error adding to Firestore: $e");
          }
        } else if (response.statusCode == 400) {
          setState(() {
            isLoading = false;
          });

          // Show insufficient funds alert
          Alert(
            context: context,
            type: AlertType.error,
            title: "Insufficient Funds",
            desc: "You do not have enough funds to book this appointment.",
            buttons: [
              DialogButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.pop(context),
                width: 120,
              )
            ],
          ).show();
        } else {
          setState(() {
            isLoading = false;
          });
          print('Failed to send appointment data to external API');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print("User is not logged in.");
      }
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      selectedDate = args.value;
      dateController.text = selectedDate != null
          ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
          : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Vet Services"),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Book Appointment",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: "Preferred Date",
                    filled: true,
                    fillColor: Colors.green.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Select Date"),
                          content: Container(
                            height: 300,
                            child: SfDateRangePicker(
                              onSelectionChanged: _onSelectionChanged,
                              selectionMode: DateRangePickerSelectionMode.single,
                              minDate: DateTime.now(),
                              backgroundColor: Colors.green.shade50,
                              selectionColor: Colors.blue.shade900,
                              todayHighlightColor: Colors.blue.shade900,
                              headerStyle: DateRangePickerHeaderStyle(
                                textStyle: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              monthCellStyle: DateRangePickerMonthCellStyle(
                                todayTextStyle: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                                weekendTextStyle: TextStyle(
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "OK",
                                style: TextStyle(color: Colors.blue.shade900),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: submitAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text("Submit"),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Appointment Records",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('appointments')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final appointments = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        final attended = appointment['attended'] as bool;
                        return ListTile(
                          title: Text(
                            "Appointment Date: ${appointment['date']}",
                            style: TextStyle(
                              color: attended ? Colors.green : Colors.red,
                            ),
                          ),
                          subtitle: Text(
                            attended ? "Attended" : "Pending",
                            style: TextStyle(
                              color: attended ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialRecords extends StatefulWidget {
  FinancialRecords({Key? key}) : super(key: key);

  @override
  _FinancialRecordsState createState() => _FinancialRecordsState();
}

class _FinancialRecordsState extends State<FinancialRecords> with SingleTickerProviderStateMixin {
  List<dynamic> records = [];
  bool isLoading = true;
  String selectedType = 'Both';
  late AnimationController _controller;
  late Animation<double> _animation;

  String getUid() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return uid;
  }

  String getUserEmail() {
    String email = FirebaseAuth.instance.currentUser!.email!;
    return email;
  }

  @override
  void initState() {
    super.initState();
    fetchRecords();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchRecords() async {
    final response = await http.get(Uri.parse('https://dairyconnect.onrender.com/api/v1/dairyconnect/${getUid()}/user-withdrawal'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(data); // Print the data to check the response
      setState(() {
        records = data;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load records');
    }
  }

  String formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  List<dynamic> getFilteredRecords() {
    if (selectedType == 'Mpesa') {
      return records.where((record) => record['type'] == 'Mpesa').toList();
    } else if (selectedType == 'VetServices') {
      return records.where((record) => record['type'] == 'VetServices').toList();
    } else {
      return records;
    }
  }

  Future<void> sendEmail() async {
    final emailContent = getFilteredRecords().map((record) {
      final date = record['date'];
      final ref = record['ref'];
      final type = record['type'];
      final amount = record['amount'].toString();
      return '''
        <tr>
          <td style="padding: 8px; border: 1px solid #ddd;">${formatDate(date)}</td>
          <td style="padding: 8px; border: 1px solid #ddd;">$ref</td>
          <td style="padding: 8px; border: 1px solid #ddd;">$type</td>
          <td style="padding: 8px; border: 1px solid #ddd;">$amount</td>
        </tr>
      ''';
    }).join();

    final emailHtml = '''
      <html>
        <body style="font-family: Arial, sans-serif; color: #333;">
          <div style="text-align: center; margin-bottom: 20px;">
            <img src="https://firebasestorage.googleapis.com/v0/b/sem3-e5826.appspot.com/o/appImages%2Fall.png?alt=media&token=bab50a1d-1b86-4d9f-9a51-b58abff952ea" alt="Logo" style="width: 100px; height: 100px; border-radius: 50%; background-color: #004d40; padding: 10px;">
          </div>
          <h2 style="color: #004d40;">Financial Records</h2>
          <table style="width: 100%; border-collapse: collapse;">
            <thead>
              <tr style="background-color: #004d40; color: #ffffff;">
                <th style="padding: 8px; border: 1px solid #ddd;">Date</th>
                <th style="padding: 8px; border: 1px solid #ddd;">Reference</th>
                <th style="padding: 8px; border: 1px solid #ddd;">Type</th>
                <th style="padding: 8px; border: 1px solid #ddd;">Amount</th>
              </tr>
            </thead>
            <tbody>
              $emailContent
            </tbody>
          </table>
        </body>
      </html>
    ''';

    await FirebaseFirestore.instance.collection('mail').add({
      'to': getUserEmail(), // Retrieve the user's email from Firebase Authentication
      'message': {
        'subject': 'Financial Records',
        'html': emailHtml,
      },
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email has been successfully sent!'),
        backgroundColor: Colors.green[900],
      ),
    );

    print('Email document added to Firestore');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Financial Records"),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: Icon(Icons.email),
            onPressed: sendEmail,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ScaleTransition(
              scale: _animation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[900]!),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                    items: <String>['Both', 'Mpesa', 'VetServices']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]))),
                    DataColumn(label: Text('Reference', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]))),
                    DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]))),
                    DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]))),
                  ],
                  rows: getFilteredRecords().map((record) {
                    final date = record['date'];
                    final ref = record['ref'];
                    final type = record['type'];
                    final amount = record['amount'].toString();
                    return DataRow(cells: [
                      DataCell(Text(formatDate(date))),
                      DataCell(Text(ref)),
                      DataCell(Text(type)),
                      DataCell(Text(amount)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

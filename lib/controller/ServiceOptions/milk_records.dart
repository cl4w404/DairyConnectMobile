import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MilkRecords extends StatefulWidget {
  MilkRecords({Key? key}) : super(key: key);

  @override
  _MilkRecordsState createState() => _MilkRecordsState();
}

class _MilkRecordsState extends State<MilkRecords> {
  List<dynamic> records = [];
  bool isLoading = true;

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
  }

  Future<void> fetchRecords() async {
    final response = await http.get(Uri.parse('https://dairyconnect.onrender.com/api/v1/dairyconnect/${getUid()}/transactions'));

    if (response.statusCode == 200) {
      setState(() {
        records = json.decode(response.body);
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

  Future<void> sendEmail() async {
    final emailContent = records.map((record) {
      final earnings = record['liters'] * 40;
      return '''
        <tr>
          <td>${record['transactionId']}</td>
          <td>${record['liters']}</td>
          <td>${record['status'] ? 'Completed' : 'Pending'}</td>
          <td>${formatDate(record['date'])}</td>
          <td>$earnings</td>
        </tr>
      ''';
    }).join();

    final emailHtml = '''
      <html>
        <body style="font-family: Arial, sans-serif; color: #333;">
          <div style="text-align: center; margin-bottom: 20px;">
            <img src="https://firebasestorage.googleapis.com/v0/b/sem3-e5826.appspot.com/o/appImages%2Fall.png?alt=media&token=bab50a1d-1b86-4d9f-9a51-b58abff952ea" alt="Logo" style="width: 100px; height: 100px; border-radius: 50%; background-color: #FFFFFF; padding: 10px;">
          </div>
          <h2 style="color: #004d40;">Milk Collection Records</h2>
          <table style="width: 100%; border-collapse: collapse;">
            <thead>
              <tr style="background-color: #004d40; color: #ffffff;">
                <th style="padding: 8px; border: 1px solid #ddd;">Transaction ID</th>
                <th style="padding: 8px; border: 1px solid #ddd;">Liters</th>
                <th style="padding: 8px; border: 1px solid #ddd;">Status</th>
                <th style="padding: 8px; border: 1px solid #ddd;">Date</th>
                <th style="padding: 8px; border: 1px solid #ddd;">Earnings</th>
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
        'subject': 'Milk Collection Records',
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
        title: Text("Milk Collection"),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: Icon(Icons.email, color: Colors.white,),
            onPressed: sendEmail,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DataTable(
              columns: [
                DataColumn(label: Text('Transaction ID', style: TextStyle(color: Colors.green[900]))),
                DataColumn(label: Text('Liters', style: TextStyle(color: Colors.green[900]))),
                DataColumn(label: Text('Status', style: TextStyle(color: Colors.green[900]))),
                DataColumn(label: Text('Date', style: TextStyle(color: Colors.green[900]))),
                DataColumn(label: Text('Earnings', style: TextStyle(color: Colors.green[900]))),
              ],
              rows: records.map((record) {
                final earnings = record['liters'] * 40;
                return DataRow(cells: [
                  DataCell(Text(record['transactionId'])),
                  DataCell(Text(record['liters'].toString())),
                  DataCell(Text(record['status'] ? 'Completed' : 'Pending')),
                  DataCell(Text(formatDate(record['date']))),
                  DataCell(Text(earnings.toString())),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

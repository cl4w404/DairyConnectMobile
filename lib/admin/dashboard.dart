import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

import '../models/Liters.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController search = TextEditingController();
  String name = "";

  late Future<Map<String, dynamic>> futureData;
  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://dairyconnect.onrender.com/api/v1/dairyconnect/transactions'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      double trueLiters = 0;
      double falseLiters = 0;
      Map<String, double> dailyLiters = {};

      for (var transaction in data) {
        if (transaction['status']) {
          trueLiters += transaction['liters'];
        } else {
          falseLiters += transaction['liters'];
        }

        String date =
            transaction['date'].substring(0, 10); // Extract the date part
        double liters = transaction['liters'].toDouble();

        if (dailyLiters.containsKey(date)) {
          dailyLiters[date] = dailyLiters[date]! + liters;
        } else {
          dailyLiters[date] = liters;
        }
      }

      List<DailyLiters> litersList = dailyLiters.entries.map((entry) {
        return DailyLiters(DateTime.parse(entry.key), entry.value);
      }).toList();

      return {
        "pieData": {
          "True Transactions": trueLiters,
          "False Transactions": falseLiters,
        },
        "barData": litersList,
      };
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return isSmallScreen
        ? Text("Mobile view")
        : ListView(children: [
            StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshots) {
                  final DateTime oneWeekAgo =
                      DateTime.now().subtract(Duration(days: 7));

                  return (snapshots.connectionState == ConnectionState.waiting)
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(80.0),
                            child: CircularProgressIndicator(
                              color: Colors.green.shade500,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 200,
                                          width: 280,
                                          child: Card(
                                              child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    Colors.blue.shade50,
                                                radius: 25,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.blue.shade900,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${snapshots.data!.docs.length}",
                                                    style: TextStyle(
                                                        fontSize: 32,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "Users",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.black),
                                                  )
                                                ],
                                              ),
                                            ],
                                          )),
                                        ),
                                        SizedBox(
                                            height: 200,
                                            width: 280,
                                            child: Card(child: LayoutBuilder(
                                                builder:
                                                    (context, constraints) {
                                              int documentsCreatedWithinWeek =
                                                  0; // Initialize a counter

                                              snapshots.data!.docs
                                                  .forEach((document) {
                                                final Map<String, dynamic>
                                                    data = document.data();
                                                final Timestamp createdAt = data[
                                                    'createdAt']; // Assuming 'createdAt' is the timestamp field

                                                // Compare the timestamp with one week ago
                                                if (createdAt
                                                    .toDate()
                                                    .isAfter(oneWeekAgo)) {
                                                  documentsCreatedWithinWeek++;
                                                }
                                              });
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Colors.green.shade50,
                                                    radius: 25,
                                                    child: Icon(
                                                      Icons.calendar_month,
                                                      color:
                                                          Colors.green.shade900,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        ' $documentsCreatedWithinWeek',
                                                        style: TextStyle(
                                                            fontSize: 32,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        "Users This Week",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.black),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }))),
                                        SizedBox(
                                            height: 200,
                                            width: 280,
                                            child: Card()),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 840,
                                          height: 400,
                                          child: Card(
                                              child:  FutureBuilder<Map<String, dynamic>>(
                                                future: futureData,
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return Center(child: CircularProgressIndicator());
                                                  } else if (snapshot.hasError) {
                                                    return Center(child: Text('Error: ${snapshot.error}'));
                                                  } else if (snapshot.hasData) {
                                                    Map<String, double> pieData = snapshot.data!['pieData'];
                                                    List<DailyLiters> barData = snapshot.data!['barData'];

                                                    return Row(
                                                      children: [
                                                        Expanded(
                                                          child: Card(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(30.0),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  SizedBox(height: 4),
                                                                  SfCircularChart(
                                                                    title: ChartTitle(text: 'Transaction'),
                                                                    legend: Legend(isVisible: true),
                                                                    series: <CircularSeries>[
                                                                      PieSeries<MapEntry<String, double>, String>(
                                                                        dataSource: pieData.entries.toList(),
                                                                        xValueMapper: (MapEntry<String, double> data, _) => data.key,
                                                                        yValueMapper: (MapEntry<String, double> data, _) => data.value,
                                                                        dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Card(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(30.0),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  SizedBox(height: 10),
                                                                  Text(
                                                                    'Daily Liters Collected',
                                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                  ),
                                                                  SizedBox(height: 10),
                                                                  Expanded(
                                                                    child: SfCartesianChart(
                                                                      primaryXAxis: DateTimeAxis(),
                                                                      title: ChartTitle(text: 'Daily Liters Collected'),
                                                                      legend: Legend(isVisible: true),
                                                                      tooltipBehavior: TooltipBehavior(enable: true),
                                                                      series: <CartesianSeries>[
                                                                        ColumnSeries<DailyLiters, DateTime>(
                                                                          dataSource: barData,
                                                                          xValueMapper: (DailyLiters liters, _) => liters.date,
                                                                          yValueMapper: (DailyLiters liters, _) => liters.liters,
                                                                          name: 'Liters',
                                                                          dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  } else {
                                                    return Center(child: Text('No data available'));
                                                  }
                                                },
                                              ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 600,
                              width: 280,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 14.0, right: 14, top: 10),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        onChanged: (val) {
                                          setState(() {
                                            name = val;
                                          });
                                        },
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Enter A Valid Name';
                                          }
                                          return null;
                                        },
                                        controller: search,
                                        cursorColor: Colors.black,
                                        style: TextStyle(color: Colors.black),
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.person_2,
                                            color: Colors.blue.shade900,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 40.0),
                                          labelText: "Enter Account number",
                                          filled: true,
                                          fillColor: Colors.indigo.shade50,
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .redAccent.shade700),
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 14,
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                            itemCount:
                                                snapshots.data!.docs.length,
                                            itemBuilder: (context, index) {
                                              var data = snapshots
                                                      .data!.docs[index]
                                                      .data()
                                                  as Map<String, dynamic>;
                                              if (name.isEmpty) {
                                                return ListTile(
                                                  tileColor: Colors.white,
                                                  splashColor:
                                                      Colors.red.shade900,
                                                  leading: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            data['passport']),
                                                  ),
                                                  title: Text(
                                                    data['name'],
                                                    style: TextStyle(
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  subtitle:
                                                      Text(data['account']),
                                                );
                                              } else if (data['account']
                                                          .toString() ==
                                                      name.toString() ||
                                                  data['account']
                                                      .toString()
                                                      .contains(
                                                          name.toString())) {
                                                return ListTile(
                                                  tileColor: Colors.white,
                                                  splashColor:
                                                      Colors.red.shade900,
                                                  leading: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            data['passport']),
                                                  ),
                                                  title: Text(
                                                    data['name'],
                                                    style: TextStyle(
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  subtitle:
                                                      Text(data['account']),
                                                );
                                              }
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                }),
          ]);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController search = TextEditingController();
  String name = "";
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
                                              child: StreamBuilder(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('acc2acc Transactions')
                                                      .snapshots(),
                                                  builder:
                                                      (context, snapshot) {
                                                    double acc2acc = double.parse(snapshot.data!.docs.length.toString());
                                                    if(snapshot.hasData){
                                                      return StreamBuilder(
                                                          stream: FirebaseFirestore
                                                              .instance
                                                              .collection('transaction')
                                                              .snapshots(),
                                                          builder:
                                                              (context, snapsho) {
                                                                var data7 = snapsho.data!.docs.reversed.toList();
                                                                var data8 = snapshot.data!.docs.reversed.toList();
                                                                double mpesa=double.parse(snapsho.data!.docs.length.toString());
                                                                late int mpTotal;
                                                                late int accTotal;
                                                                for(var doc in data7){
                                                                  mpTotal = doc['amount'];
                                                                  mpTotal ++;
                                                                }

                                                                for(var doc1 in data8){
                                                                  accTotal = doc1['amount'];
                                                                  accTotal ++;
                                                                }

                                                                Map<String, double> dataMap = {
                                                                  "M-pesa Transactions": mpesa,
                                                                  "Account 2 Account": acc2acc,

                                                                };
                                                            return Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,

                                                              children: [

                                                                Padding(
                                                                  padding: const EdgeInsets.all(30.0),
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,

                                                                    children: [

                                                                      SizedBox(
                                                                        height: 10,
                                                                      ),
                                                                      PieChart(
                                                                        dataMap: dataMap,
                                                                        animationDuration: Duration(milliseconds: 800),
                                                                        chartLegendSpacing: 32,
                                                                        chartRadius: MediaQuery.of(context).size.width / 10,
                                                                        colorList: [Colors.green,Colors.yellow],
                                                                        initialAngleInDegree: 0,
                                                                        chartType: ChartType.ring,
                                                                        ringStrokeWidth: 32,
                                                                        centerText: "Transaction",
                                                                        legendOptions: LegendOptions(
                                                                          showLegendsInRow: false,
                                                                          legendPosition: LegendPosition.right,
                                                                          showLegends: true,
                                                                          legendShape: BoxShape.circle,
                                                                          legendTextStyle: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        chartValuesOptions: ChartValuesOptions(
                                                                          showChartValueBackground: true,
                                                                          showChartValues: true,
                                                                          showChartValuesInPercentage: false,
                                                                          showChartValuesOutside: false,
                                                                          decimalPlaces: 1,
                                                                        ),
                                                                        // gradientList: ---To add gradient colors---
                                                                        // emptyColorGradient: ---Empty Color gradient---
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(width: 100,),
                                                                Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text("Total Ksh transacted",style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 25,
                                                                      color: Colors.black,
                                                                    ),),
                                                                    SizedBox(
                                                                      height: 12,
                                                                    ),
                                                                    Text("M-pesa Transactions : $mpTotal ksh" ,style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 15,
                                                                      color: Colors.black,
                                                                    ),),
                                                                    Text("Account to Acount: $accTotal Ksh",style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 15,
                                                                      color: Colors.black,
                                                                    ),)
                                                                  ],
                                                                )
                                                              ],
                                                            );
                                                          });

                                                    }else{
                                                      return Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          CircularProgressIndicator(),
                                                        ],
                                                      );
                                                    }
                                                      }),
                                            ))
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

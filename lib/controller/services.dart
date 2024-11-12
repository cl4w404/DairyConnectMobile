import 'package:flutter/material.dart';

class Services extends StatefulWidget {
  Services({Key? key}) : super(key: key);

  @override
  _ServicesState createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  bool obscurePass = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            leading: Text("Balance"),
            title: obscurePass == true ? Text("*** Ksh") : Text("500 Ksh"),
            trailing: IconButton(
                onPressed: () {
                  if (obscurePass == true) {
                    setState(() {
                      obscurePass == false;
                    });
                  } else {
                    obscurePass == true;
                  }
                },
                icon: obscurePass == true
                    ? Icon(Icons.remove_red_eye_outlined)
                    : Icon(Icons.remove)),
          ),
          Container(
            child: Text("Settings"),
          )
          GridView(gridDelegate: gridDelegate)
        ],
      ),
    );
  }
}

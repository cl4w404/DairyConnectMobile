import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/models/user.dart';
import 'package:dairy_connect/service/userService.dart';

class RegUser extends StatefulWidget {
  RegUser({Key? key}) : super(key: key);

  @override
  _RegUserState createState() => _RegUserState();
}

class _RegUserState extends State<RegUser> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  late bool role;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                try {
                  final User? user = FirebaseAuth.instance.currentUser;
                  final uid = user!.uid;
                  Users users = new Users(
                      name: nameController.text,
                      phone: phoneController.text,
                      email: emailController.text,
                      pass: passController.text,
                      uid: uid,
                      role: role);
                  UserServices()
                      .addUser(users)
                      .then((value) => null)
                      .catchError((onError) {});
                } catch (e) {
                  print(e);
                }
              },
              child: Text("Register User"))
        ],
      ),
    );
  }
}

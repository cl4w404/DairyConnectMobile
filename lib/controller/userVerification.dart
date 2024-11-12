import 'dart:async';
import 'package:dairy_connect/controller/BottomNavigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/controller/landing_page.dart';
import 'package:dairy_connect/controller/login_user.dart';
import 'package:rive/rive.dart';

class VerifyUser extends StatefulWidget {
  const VerifyUser({Key? key}) : super(key: key);

  @override
  _VerifyUserState createState() => _VerifyUserState();
}

class _VerifyUserState extends State<VerifyUser> {
  bool isEmailVerified = false;
  var timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  Widget build(BuildContext context) => isEmailVerified
      ? FirebaseAuth.instance.currentUser == null
          ? LoginUser()
          : Landin()
      : Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue.shade900,
            title: Container(
                height: 100,
                width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('')
                )
              ),),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: SizedBox(
                      height: 200,
                      width: 200,
                      child: RiveAnimation.asset('assets/mail.riv'))),
              Text("Please verify your Email",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))
            ],
          ),
        );

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user!.sendEmailVerification();
    } catch (e) {
      final snackbar = SnackBar(
          content: Text(
        e.toString(),
      ));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel;
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }
}

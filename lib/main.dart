import 'dart:io';

import 'package:dairy_connect/admin/add_transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/admin/add__user.dart';
import 'package:dairy_connect/admin/admin.dart';
import 'package:dairy_connect/admin/single-user.details.dart';
import 'package:dairy_connect/admin/user_details.dart';
import 'package:dairy_connect/controller/landing_page.dart';
import 'package:dairy_connect/controller/login_user.dart';
import 'package:dairy_connect/controller/reg_user.dart';
import 'package:dairy_connect/controller/userVerification.dart';
final auth = FirebaseAuth.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBBqDB1Tb1OSxcqOVCS8zIsfGblsaDWejE",
        appId: "1:1075337256760:web:ccc9277d972675ce72ebcd",
        messagingSenderId: "1075337256760 .",
        projectId: "sem3-e5826",
        storageBucket: "gs://sem3-e5826.appspot.com",
      ),
    );
  }else if(Platform.isAndroid){
    await Firebase.initializeApp(
        name: 'DEFAULTAPP',
      options: const FirebaseOptions(
          apiKey: "AIzaSyBBqDB1Tb1OSxcqOVCS8zIsfGblsaDWejE",
          appId: "1:1075337256760:web:ccc9277d972675ce72ebcd",
          messagingSenderId: "1075337256760",
          projectId: "sem3-e5826",
          storageBucket: "gs://sem3-e5826.appspot.com",
      )
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        //FirebaseAuth.instance.currentUser == null ? '/': '/userhome'
        initialRoute: '/',
        routes: {
          '/': (_) => LoginUser(),
          '/userhome': (_) => LandingPage(),
          '/verifyUser':(_) => VerifyUser(),
          '/adminHome': (_) => SidebarXExampleApp(),
          '/RegisterUser': (_) => AddUser(),
          '/UserDetails':(_)=> UserDetails(),
          '/SingleUser':(_)=> SingleUserDetails(uid: ''),
          '/AddTransaction':(_)=>AddTransaction(uid: ''),
        }
    );
  }
}


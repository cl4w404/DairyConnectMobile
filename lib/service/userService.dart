import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/models/user.dart';

class UserServices {
  //Users users = new Users(name: '', phone: 0, email: '', pass: '', uid: '', role: false);
  Future<void> addUser(Users users) async {
    final CollectionReference userData =
        FirebaseFirestore.instance.collection('Users');
    auth.UserCredential userCredential = await auth.FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: users.email, password: users.pass);
    userCredential.user?.updateDisplayName(users.name);
    userData.doc(users.uid).set(users.toMap());
  }

  Future<void> logIn(String email, String pass) async {
    auth.UserCredential userCredential = await auth.FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: email.toString(), password: pass.toString());
  }

  String getUid(){
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return uid;
  }

}

import 'package:flutter/material.dart';
extension ShowSnackBar on BuildContext {
  void showErrorMessage( {required String message}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.pink.shade50,
    )
    );
  }
}


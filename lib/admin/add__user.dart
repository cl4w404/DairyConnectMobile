import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/main.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firabase_storage;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  TextEditingController firstName = TextEditingController();
  TextEditingController secName = TextEditingController();
  TextEditingController thirdtName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController nationalID = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController accNo = TextEditingController();
  TextEditingController role = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selctFile = '';
  List<Uint8List> pickedImagesInBytes = [];
  late Uint8List selectedImageInBytes;
  int imageCounts = 0;
  DateTime time = DateTime.now();
  bool isLoading = false;

  _selectFile() async {
    FilePickerResult? fileResult = await FilePicker.platform.pickFiles(
        allowMultiple: true, type: FileType.custom, allowedExtensions: ['jpg']);

    if (fileResult != null) {
      selctFile = fileResult.files.first.name;
      fileResult.files.forEach((element) {
        setState(() {
          //pickedImagesInBytes.add(element.bytes);
          selectedImageInBytes = fileResult.files.first.bytes!;
          imageCounts += 1;
        });
      });
    }
    print(selctFile);
  }

  Future<String> _uploadFile() async {
    String imageUrl = '';

    try {
      firabase_storage.UploadTask uploadTask;

      firabase_storage.Reference ref = firabase_storage.FirebaseStorage.instance
          .ref('PassportImages')
          .child('passport $time')
          .child('/' + selctFile);

      final metadata =
          firabase_storage.SettableMetadata(contentType: 'image/jpeg');

      //uploadTask = ref.putFile(File(file.path));
      uploadTask = ref.putData(selectedImageInBytes, metadata);

      await uploadTask.whenComplete(() => null);
      imageUrl = await ref.getDownloadURL();
    } catch (e) {
      print(e);
    }
    return imageUrl;
  }

  genNumber() {
    final random = new Random();

    // Generate a random number between 0 and 9999999999 (9 digits).
    int randomNumber = random.nextInt(999999999) + 1;
    setState(() {
      accNo.text = randomNumber.toString();
    });
    print(randomNumber);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;
    return screenSize < 800
        ? Text(
            "Add user",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          )
        : Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: [
                  Text(
                    "User Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: 1000,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Official Names",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Enter A Valid Name';
                                          }
                                          return null;
                                        },
                                        controller: firstName,
                                        cursorColor: Colors.black,
                                        style: TextStyle(color: Colors.black),
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.person,
                                            color: Colors.blue.shade900,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 40.0),
                                          labelText: "First Name",
                                          filled: true,
                                          fillColor: Colors.indigo.shade50,
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Enter A Valid Name';
                                          }
                                          return null;
                                        },
                                        controller: secName,
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
                                          labelText: "Second Name",
                                          filled: true,
                                          fillColor: Colors.indigo.shade50,
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Enter A Valid Name';
                                          }
                                          return null;
                                        },
                                        controller: thirdtName,
                                        cursorColor: Colors.black,
                                        style: TextStyle(color: Colors.black),
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.person_3,
                                            color: Colors.blue.shade900,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 40.0),
                                          labelText: "Third Name",
                                          filled: true,
                                          fillColor: Colors.indigo.shade50,
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Official Details",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            validator: (email) => email !=
                                                        null &&
                                                    !EmailValidator.validate(
                                                        email)
                                                ? 'Enter a valid email'
                                                : null,
                                            controller: email,
                                            cursorColor: Colors.black,
                                            style:
                                                TextStyle(color: Colors.black),
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.email,
                                                color: Colors.blue.shade900,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 40.0),
                                              labelText: "Email",
                                              filled: true,
                                              fillColor: Colors.indigo.shade50,
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Enter A Valid Number';
                                              }
                                              return null;
                                            },
                                            controller: phone,
                                            cursorColor: Colors.black,
                                            style:
                                                TextStyle(color: Colors.black),
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.phone,
                                                color: Colors.blue.shade900,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 40.0),
                                              labelText: "Phone Number",
                                              filled: true,
                                              fillColor: Colors.indigo.shade50,
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Enter A Valid ID';
                                              }
                                              return null;
                                            },
                                            controller: nationalID,
                                            cursorColor: Colors.black,
                                            style:
                                                TextStyle(color: Colors.black),
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.perm_identity_rounded,
                                                color: Colors.blue.shade900,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 40.0),
                                              labelText: "Enter National ID",
                                              filled: true,
                                              fillColor: Colors.indigo.shade50,
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 425,
                                          child: Expanded(
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Enter A Valid Password';
                                                }
                                                return null;
                                              },
                                              controller: password,
                                              cursorColor: Colors.black,
                                              style: TextStyle(
                                                  color: Colors.black),
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.password,
                                                  color: Colors.blue.shade900,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 40.0),
                                                labelText: "Enter Password",
                                                filled: true,
                                                fillColor:
                                                    Colors.indigo.shade50,
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          width: 425,
                                          child: Expanded(
                                            child: TextFormField(
                                              onTap: () {
                                                genNumber();
                                              },
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Enter A Valid Account';
                                                }
                                                return null;
                                              },
                                              controller: accNo,
                                              cursorColor: Colors.black,
                                              style: TextStyle(
                                                  color: Colors.black),
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.person_2,
                                                  color: Colors.blue.shade900,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 40.0),
                                                labelText: "Account number",
                                                filled: true,
                                                fillColor:
                                                    Colors.indigo.shade50,
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            onTap: () {
                                              genNumber();
                                            },
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Enter A Valid role';
                                              }
                                              return null;
                                            },
                                            controller: role,
                                            cursorColor: Colors.black,
                                            style:
                                                TextStyle(color: Colors.black),
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.person_2,
                                                color: Colors.blue.shade900,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 40.0),
                                              labelText: "Enter true or false",
                                              filled: true,
                                              fillColor: Colors.indigo.shade50,
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 20),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            _selectFile();
                                          },
                                          child: Text("Pick Image")),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      selctFile,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                            height: 40,
                            width: 200,
                            child: ElevatedButton(
                                onPressed: () async {
                                  genNumber();
                                  try {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      String imageUrl = await _uploadFile();
                                      String rname =
                                          "${firstName.text} ${secName.text} ${thirdtName.text}";
                                      firebase_auth.UserCredential
                                          userCredential = await firebaseAuth
                                              .createUserWithEmailAndPassword(
                                        email: email.text,
                                        password: password.text,
                                      );
                                      await userCredential.user
                                          ?.updateDisplayName("${rname}");
                                      final user = auth.currentUser;
                                      final uid = user!.uid;
                                      bool admin = false;

                                      if (role.text == "true") {
                                        setState(() {
                                          admin = true;
                                        });
                                      } else if (role.text == "false") {
                                        setState(() {
                                          admin = false;
                                        });
                                      }

                                      // Insert a new row in the user table
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(uid)
                                          .set({
                                        'id': uid,
                                        'phone_number': phone.text,
                                        'national_id': nationalID.text,
                                        'name': rname,
                                        'account': accNo.text,
                                        'email': email.text,
                                        'admin': admin,
                                        'amount': 0.0,
                                        'passport': imageUrl.toString(),
                                        'createdAt': time,
                                      }).then((value) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        firstName.clear();
                                        secName.clear();
                                        thirdtName.clear();
                                        email.clear();
                                        phone.clear();
                                        nationalID.clear();
                                        password.clear();
                                        accNo.clear();
                                        role.clear();
                                        Alert(
                                          context: context,
                                          type: AlertType.success,
                                          title: "User Registration",
                                          desc: "User Added Successfully",
                                          buttons: [],
                                        ).show();
                                      }).onError((error, stackTrace) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        firstName.clear();
                                        secName.clear();
                                        thirdtName.clear();
                                        email.clear();
                                        phone.clear();
                                        nationalID.clear();
                                        password.clear();
                                        accNo.clear();
                                        role.clear();
                                        Alert(
                                          context: context,
                                          type: AlertType.error,
                                          title: "Error",
                                          desc: "$error",
                                          buttons: [],
                                        ).show();
                                      });
                                      // Create an authentication account for the user
                                      // Display a success message or perform other actions as needed
                                      final snackbar = SnackBar(
                                        content:
                                            Text("User Added Successfully"),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackbar);
                                    }
                                  } catch (e) {
                                    final snackbar = SnackBar(
                                      content: Text(e.toString()),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackbar);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade900,
                                ),
                                child: isLoading == true
                                    ? Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.white),
                                      )
                                    : Text('Add User')))
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}

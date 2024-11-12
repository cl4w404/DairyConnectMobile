import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Email extends StatefulWidget {
  Email({Key? key}) : super(key: key);

  @override
  _EmailState createState() => _EmailState();
}

class _EmailState extends State<Email> {
  TextEditingController subjectController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          List<String> emails = [];

          if (snapshot.hasData) {
            final clients = snapshot.data!.docs.reversed.toList();

            for (var document in clients) {
              String mail = document['email'];
              emails.add(mail);
            }
          }
          return Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Text(
                "Send Email",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 450,
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter A Valid Subject';
                    }
                    return null;
                  },
                  controller: subjectController,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  maxLines: 2,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.numbers,
                      color: Colors.blue.shade900,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 40.0),
                    labelText: "Insert Subject",
                    filled: true,
                    fillColor: Colors.indigo.shade50,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 450,
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter A Valid message';
                    }
                    return null;
                  },
                  controller: bodyController,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  maxLines: 17,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.numbers,
                      color: Colors.blue.shade900,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 40.0),
                    labelText: "Insert email body",
                    filled: true,
                    fillColor: Colors.indigo.shade50,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 1050.0),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          CollectionReference mailCollection =
                              FirebaseFirestore.instance.collection("mail");
                          await mailCollection.add({
                            'to': emails,
                            'message': {
                              'subject': subjectController.text,
                              'html': bodyController.text,
                            },
                          });
                        }
                      },
                      child: Text("Send")),
                ),
              )
            ],
          );
        });
  }
}

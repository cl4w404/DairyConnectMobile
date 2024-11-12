import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/service/userService.dart';

class LoginUser extends StatefulWidget {
  LoginUser({Key? key}) : super(key: key);

  @override
  _LoginUserState createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
   bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: currentWidth < 700
          ?
      Stack(
        children: [
          Container(
            width: 400,
            height: 340,
            decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: SizedBox(
                        height:200,
                        width: 200,
                        child: Image.asset('assets/white.png')),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Container(
                  width: 320,
                  height: 370,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          topLeft: Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 35,
                            color: Colors.black,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.0),
                          child: Container(
                            height: 2.0,
                            width: 115.0,
                            color: Colors.green.shade50,
                          ),
                        ),


                        SizedBox(
                          height: 5,
                        ),

                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (email) => email != null &&
                                      !EmailValidator.validate(email)
                                      ? 'Enter a valid email'
                                      : null,
                                  controller: emailController,
                                  cursorColor: Colors.black,
                                  style: TextStyle(color: Colors.black),
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
                                    fillColor: Colors.blue.shade50,
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                        BorderRadius.circular(50)),
                                  ),
                                ),
                                SizedBox(
                                  height: 22,
                                ),
                                TextFormField(
                                  obscureText: true,
                                  validator: (value) {
                                    if (value!.length < 7) {
                                      return 'Enter an 8 digit password';
                                    }
                                    return null;
                                  },
                                  controller: passController,
                                  cursorColor: Colors.black,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.password,
                                      color: Colors.blue.shade900,
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 40.0),
                                    labelText: "Password",
                                    filled: true,
                                    fillColor: Colors.blue.shade50,
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                        BorderRadius.circular(50)),
                                  ),
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                SizedBox(
                                  height: 40,
                                  width: 200,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!
                                          .validate()) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        try {
                                          //Login Gode Goes Here
                                          UserServices()
                                              .logIn(emailController.text, passController.text)
                                              .then((value) {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                Navigator.of(context)
                                                    .pushNamedAndRemoveUntil(
                                                    '/verifyUser',
                                                        (route) => true);
                                          })
                                              .catchError((e) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                            final snackbar = SnackBar(
                                                content:
                                                Text(e.toString()));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackbar);
                                          });
                                        } catch (e) {
                                          setState(() {
                                          isLoading = false;
                                        });
                                          final snackbar = SnackBar(
                                              content:
                                              Text(e.toString()));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackbar);

                                        }

                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade900,
                                    ),
                                    child: isLoading == true
                                        ? CircularProgressIndicator(
                                      color: Colors.green
                                    )
                                        : Text(
                                      "Login",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.w700),
                                    ),
                                  ),
                                ),


                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          ),

        ],
      ):Center(
        child: Container(
          height: 800,
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('updatedBack.jpg'),
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), // Apply opacity here
                  BlendMode.dstATop, // Blend mode to apply the color
                ),
              )
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 250.0),
            child: Container(
              child: Row(
                children: [
                  Container(
                    width: 400,
                    height: 487,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset('assets/white.png'),
                            ))
                      ],
                    ),
                  ),
                  Container(
                      width: 550,
                      height: 487,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20))),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sign In",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1.0),
                              child: Container(
                                height: 2.0,
                                width: 115.0,
                                color: Colors.blue,
                              ),
                            ),
                            Form(
                              key: _formKey,
                              child: Padding(
                                padding: const EdgeInsets.all(70.0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      validator: (email) => email != null &&
                                          !EmailValidator.validate(email)
                                          ? 'Enter a valid email'
                                          : null,
                                      controller: emailController,
                                      cursorColor: Colors.black,
                                      style: TextStyle(color: Colors.black),
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
                                            BorderRadius.circular(50)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    TextFormField(
                                      obscureText: true,
                                      validator: (value) {
                                        if (value!.length < 7) {
                                          return 'Enter an 8 digit password';
                                        }
                                        return null;
                                      },
                                      controller: passController,
                                      cursorColor: Colors.black,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.password,
                                          color: Colors.blue.shade900,
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 40.0),
                                        labelText: "Password",
                                        filled: true,
                                        fillColor: Colors.indigo.shade50,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                            BorderRadius.circular(50)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    SizedBox(
                                      height: 40,
                                      width: 200,
                                      child: ElevatedButton(

                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              try {
                                                //Login Gode Goes Here
                                                UserServices()
                                                    .logIn(emailController.text, passController.text)
                                                    .then((value) {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                  if (emailController.text ==
                                                      "mbuguangigi254@gmail.com") {
                                                    Navigator.of(context)
                                                        .pushNamedAndRemoveUntil(
                                                        '/adminHome',
                                                            (route) => true);
                                                  } else {
                                                    Navigator.of(context)
                                                        .pushNamedAndRemoveUntil(
                                                        '/verifyUser',
                                                            (route) => true);
                                                  }
                                                })
                                                    .catchError((e) {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                  final snackbar = SnackBar(
                                                      content:
                                                      Text(e.toString()));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackbar);
                                                });
                                              } catch (e) {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                final snackbar = SnackBar(
                                                    content:
                                                    Text(e.toString()));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackbar);

                                              }

                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            Colors.green.shade600,
                                          ),
                                                child: isLoading == true
                                                    ? CircularProgressIndicator(
                                                    color: Colors.white                                            )
                                                    : Text(
                                                  "Login",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.w700),
                                                ),
                                      )
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      //     : Column(
      //   children: [
      //     ElevatedButton(
      //
      //         onPressed: () {
      //           UserServices()
      //               .logIn(emailController.text, passController.text)
      //               .then((value) => null)
      //               .catchError((e) {
      //             final snackbar = SnackBar(
      //                 content:
      //                 Text(e.toString()));
      //             ScaffoldMessenger.of(context)
      //                 .showSnackBar(snackbar);
      //           });
      //         },
      //         child: Text("Login"))
      //   ],
      // ),
    );
  }
}

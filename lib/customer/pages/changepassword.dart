import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/login.dart';

import 'package:user/main.dart';

import 'package:user/pages/accountdetails.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Color maincolor = Color(0xFFa02e49);
  bool showpassword = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _oldPassController = TextEditingController();
  TextEditingController _newPassController = TextEditingController();
  TextEditingController _confirmPassController = TextEditingController();

  Future<void> updatePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    bool success = false;
    final credential = EmailAuthProvider.credential(
        email: user!.email!, password: _oldPassController.text);
    try {
      await user.reauthenticateWithCredential(credential);
      success = true;
      print(_newPassController.text);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.only(top: 16, bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: Color.fromARGB(255, 0, 204, 255),
                  width: 3.0,
                ),
              ),
              title: Text(
                'Password changed successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 128, 255)),
              ),
              content: SizedBox(
                height: 120,
                child: Column(
                  children: [
                    FittedBox(child: Text("You must login again")),
                    Text('Thank you!'),
                    SizedBox(height: 10),
                    Divider(
                      thickness: 2,
                    ),
                    Center(
                      child: TextButton(
                          onPressed: () async {
                            await _auth.signOut();
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => MyApp(
                                  homeScreen: LoginPage(),
                                ),
                              ),
                            );
                          },
                          child: Text('Ok',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 0, 204, 255),
                                  fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
              ),
            );
          });
      // Password is correct
    } catch (e) {
      // Password is incorrect
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.only(top: 16, bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: Color(0xFFa02e49),
                  width: 3.0,
                ),
              ),
              title: Text(
                'Incorrect Current Password',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                height: 120,
                child: Column(
                  children: [
                    FittedBox(child: Text("Wrong Old Password!")),
                    Text('Please try again.'),
                    SizedBox(height: 10),
                    Divider(
                      thickness: 2,
                    ),
                    Center(
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Ok',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFFa02e49),
                                  fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
              ),
            );
          });
    }
    if (success) {
      try {
        await user.updatePassword(_newPassController.text);
        print('Current password is correct');
      } catch (e) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                titlePadding: EdgeInsets.only(top: 16, bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: Color(0xFFa02e49),
                    width: 3.0,
                  ),
                ),
                title: Text(
                  'Weak Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: SizedBox(
                  height: 120,
                  child: Column(
                    children: [
                      FittedBox(child: Text("Your password is too weak!")),
                      Text('Please try again.'),
                      SizedBox(height: 10),
                      Divider(
                        thickness: 2,
                      ),
                      Center(
                        child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Ok',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFFa02e49),
                                    fontWeight: FontWeight.bold))),
                      ),
                    ],
                  ),
                ),
              );
            });
        // Password is incorrect
        print('Too Weak');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACCOUNT DETAILS'),
        backgroundColor: maincolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
                child: Column(
              children: [
                Text(
                  "Please don't share your password to anyone",
                  style: TextStyle(
                      color: maincolor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _oldPassController,
                          obscureText: !showpassword,
                          style: TextStyle(
                              color: maincolor, fontWeight: FontWeight.bold),
                          decoration: buildInputDecoration('Old Password'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your Old Password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _newPassController,
                          obscureText: !showpassword,
                          style: TextStyle(
                              color: maincolor, fontWeight: FontWeight.bold),
                          decoration: buildInputDecoration('New Password'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _confirmPassController,
                          obscureText: !showpassword,
                          style: TextStyle(
                              color: maincolor, fontWeight: FontWeight.bold),
                          decoration: buildInputDecoration('Confirm Password'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please confirm your password';
                            } else if (value != _newPassController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return maincolor.withOpacity(.32);
                                      }
                                      return maincolor;
                                    }),
                                    value: showpassword,
                                    onChanged: (value) {
                                      setState(() {
                                        showpassword = !showpassword;
                                      });
                                    }),
                                Text(
                                  'Show Password',
                                  style: TextStyle(
                                      color: maincolor.withOpacity(0.8)),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )),
            Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFFa02e49))),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              updatePassword();
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) => AccountDetailsPage(),
                              //   ),
                              // );
                            }
                          },
                          child: Text('CONFIRM')),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

InputDecoration buildInputDecoration(String hinttext) {
  Color maincolor = Color(0xFFa02e49);
  return InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(0.5),
    contentPadding: EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 16.0,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: maincolor, width: 2.0),
      borderRadius: BorderRadius.circular(30.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: maincolor, width: 2.0),
      borderRadius: BorderRadius.circular(30.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFa02e49), width: 2.0),
      borderRadius: BorderRadius.circular(30.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFa02e49), width: 2.0),
      borderRadius: BorderRadius.circular(30.0),
    ),
    hintText: hinttext,
    hintStyle: TextStyle(color: maincolor.withOpacity(0.5)),
    prefixIconConstraints: BoxConstraints(minWidth: 40),
  );
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'dart:math';

import 'package:user/successforgot.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool _isExpanded = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String generateTempPassword() {
    final random = Random();
    final alphanumeric =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final password = 'taps-' +
        List.generate(
                8, (index) => alphanumeric[random.nextInt(alphanumeric.length)])
            .join();
    return password;
  }

  void sendMail() async {
    print(generateTempPassword());
    User? user = FirebaseAuth.instance.currentUser;

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);

      print("Password reset email sent successfully");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SuccessForgot()));
    } catch (e) {
      print("Error sending password reset email: $e");
    }
    // String username = 'zxcv.jan1212@gmail.com';
    // String password = 'bmqpncmqjqtupdwg';

    // final smtpServer = gmail(username, password);

    // // Create a message
    // final message = Message()
    //   ..from = Address(username, 'Tapsiman')
    //   ..recipients.add('zxcv.jan1216@gmail.com') // add recipient email here
    //   ..subject = ' Your temporary password has been successfully sent!'
    //   ..text = ''
    //   ..html =
    //       "<p>Dear User,</p><p>We are pleased to inform you that your request for a temporary password has been successfully processed. We have generated a new temporary password that you can use to access your account.</p><p>Your temporary password is: [password]</p><p>Please note that this password is temporary and should be changed immediately upon logging in. We highly recommend that you choose a strong and unique password to protect your account.</p><p>Thank you for using our service!</p><br><br><p>Best regards,</p><p>Tapsiman</p>";

    // // Send the message
    // try {
    //   final sendReport = await send(message, smtpServer);
    //   print('Message sent: ' + sendReport.toString());
    //   // Navigator.push(
    //   //     context, MaterialPageRoute(builder: (context) => SuccessForgot()));
    // } on MailerException catch (e) {
    //   print('Message not sent. \n' + e.toString());
    // }
  }

  Future<void> checkEmail(String email) async {
    try {
      List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(email);

      if (signInMethods.isNotEmpty) {
        // Email address is already registered
        print('Email address already registered');
        sendMail();
      } else {
        // Email address is not registered yet
        print('Email address is not yet registered');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email address is not registered'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Input valid Email Address'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa02e49),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text('Forgot Password?',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                    Image.asset(
                      'assets/images/forgot-sad.png',
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                    Text(
                      'Enter the email address',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'associated with your account.',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'We will email you a link to reset and you can change it after. ',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 17),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35.0),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          label: const Center(
                            child: Text("Enter Email Address"),
                          ),
                          alignLabelWithHint: true,
                          border: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your Email Address';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                            checkEmail(_emailController.text);

                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => SuccessForgot()));
                          }
                        },
                        child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: 55,
                            width: 250,
                            margin: EdgeInsets.all(16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFa02e49), width: 2),
                              borderRadius: BorderRadius.circular(50),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: _isExpanded
                                    ? [Colors.white, Colors.white]
                                    : [Color(0xFFa02e49), Colors.pinkAccent],
                              ),
                            ),
                            child: Center(
                                child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Text(
                                'Send',
                                style: TextStyle(
                                    color: _isExpanded
                                        ? Colors.deepPurple
                                        : Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ))),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

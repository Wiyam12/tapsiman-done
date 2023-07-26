import 'package:flutter/material.dart';
import 'package:user/login.dart';

class SuccessForgot extends StatefulWidget {
  const SuccessForgot({super.key});

  @override
  State<SuccessForgot> createState() => _SuccessForgotState();
}

class _SuccessForgotState extends State<SuccessForgot> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.deepPurple,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Text('Success',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  Image.asset(
                    'assets/images/forgot-happy.png',
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                  Text(
                    'Check your email address',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'to reset your password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Note: It is important to never share your password with anyone, as it can compromise the security of your account and personal information.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 17),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  //   child: TextFormField(
                  //     decoration: InputDecoration(
                  //       label: const Center(
                  //         child: Text("Enter Email Address"),
                  //       ),
                  //       alignLabelWithHint: true,
                  //       border: UnderlineInputBorder(),
                  //       focusedBorder: UnderlineInputBorder(
                  //         borderSide: BorderSide(color: Colors.blue),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: 55,
                          width: 250,
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.deepPurple, width: 2),
                            borderRadius: BorderRadius.circular(50),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: _isExpanded
                                  ? [Colors.white, Colors.white]
                                  : [Colors.deepPurple, Colors.pinkAccent],
                            ),
                          ),
                          child: Center(
                              child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              'Thank you',
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
    );
  }
}

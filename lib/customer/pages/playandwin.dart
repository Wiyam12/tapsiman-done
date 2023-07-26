import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:user/customer/pages/flipcard.dart';
import 'package:user/customer/pages/home.dart';

import 'vouchers.dart';

class PlayAndWinPage extends StatefulWidget {
  const PlayAndWinPage({super.key});

  @override
  State<PlayAndWinPage> createState() => _PlayAndWinPageState();
}

class _PlayAndWinPageState extends State<PlayAndWinPage> {
  Color maincolor = Color(0xFFa02e49);
  int? endTime;
  CountdownTimerController? controller;

  Timer? _timer;
  int _start = 0;
  String? timeremaining;
  bool isTimer = true;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    setState(() {
      _timer = new Timer.periodic(
        oneSec,
        (Timer timer) {
          if (_start == 0) {
            setState(() {
              timer.cancel();
            });
          } else {
            setState(() {
              _start--;
              if (_start < 0) {
                isTimer = false;
              }
              Duration duration = Duration(seconds: _start);
              int hours = duration.inHours;
              int minutes = duration.inMinutes.remainder(60);
              int seconds = duration.inSeconds.remainder(60);
              String formattedTime =
                  '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
              timeremaining = formattedTime;
            });
          }
        },
      );
    });
  }

  Future<void> checkdailyplay() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    Timestamp timestamp = userSnapshot.data()?['dailytokendate'];

    if (timestamp != null) {
      // Convert the Firestore Timestamp to a DateTime object
      DateTime tokenDate = timestamp.toDate();

      // Calculate the target date by adding 24 hours to the token date
      DateTime targetDate = tokenDate.add(Duration(hours: 24));

      // Get the current date and time
      DateTime now = DateTime.now();

      // Calculate the remaining time until the target date
      Duration remainingTime = targetDate.difference(now);
      setState(() {
        _start = remainingTime.inSeconds;
      });
      // Extract the remaining hours, minutes, and seconds
      int remainingHours = remainingTime.inHours;
      int remainingMinutes = remainingTime.inMinutes.remainder(60);
      int remainingSeconds = remainingTime.inSeconds.remainder(60);

      print(
          'Remaining Time: $remainingHours:$remainingMinutes:$remainingSeconds');
    } else {
      // 'dailytokendate' field is not set in Firestore
      print('No daily token date found in Firestore.');
    }
  }

  void onEnd() {
    print('onEnd');
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    checkdailyplay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HomePageCustomer(),
                ),
              );
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        elevation: 0.0,
        backgroundColor: maincolor,
        title: Text('Play & Win'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VouchersPage(),
                  ),
                );
              },
              icon: Icon(Icons.confirmation_num))
        ],
      ),
      body: Center(
          child: GestureDetector(
        onTap: () {
          if (!isTimer) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FLipCardPage(),
              ),
            );
          }
        },
        child: Container(
          color: maincolor,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                        color: Color(0xFFc96f6f),
                        borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 70, horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                image: AssetImage(
                                  'images/logo.png',
                                ),
                              )),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: Text(
                      'Flip a card once a day to win coins and use it on your next order!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (!isTimer)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FLipCardPage(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFFc96f6f)),
                  ),
                  child: Text(
                    'Play',
                  ),
                ),
              if (isTimer)
                Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color(0xFFa05c6b)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "TIMER $timeremaining",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ))
            ],
          ),
        ),
      )),
    );
  }
}

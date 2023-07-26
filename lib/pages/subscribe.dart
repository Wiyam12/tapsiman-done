import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  int selectedValue = 1;
  String? username;
  String? useremail;
  String myplan = '';
  bool expired = false;
  Future<void> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      final data = snapshot.data();
      // Access the data fields from the document
      final name = data!['name'] as String;
      final email = data['email'] as String;
      final plan = data['plan'] as String;
      final expiration = data['expiration'] as Timestamp?;

      if (expiration != null) {
        DateTime expirationDate = expiration.toDate();
        if (expirationDate.isBefore(DateTime.now())) {
          // The subscription has expired, you can handle this case here
          print('Subscription has expired.');
          setState(() {
            expired = true;
          });
        } else {
          // The subscription is still valid
          print('Subscription is still valid.');
        }
      } else {
        // 'expiration' field does not exist in the document
        print('No expiration date found.');
      }

      // Rest of your code
      setState(() {
        if (plan == 'free') {
          selectedValue = 1;
        } else if (plan == 'starter') {
          selectedValue = 2;
        } else if (plan == 'boss') {
          selectedValue = 3;
        }
        myplan = plan;
        username = name;
        useremail = email;
      });
    } else {
      // Handle the case when the document does not exist
    }
  }

  _launchURL(String plan) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    // print(topup);
    // const url = 'https://flutter.io';
    String url =
        'https://tapsiman.loca.lt/paymongo/index.php?buy=$plan&name=$username&email=$useremail&userid=${userId}';
    // const String url = 'https://pm.link/filipworks/test/tYfde8e';
    final Uri uri = Uri.parse(url);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    print('myplan: $myplan');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa02e49),
        title: Text('PICK A PLAN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ExpansionTile(
                      backgroundColor: Color(0xFFa02e49),
                      collapsedTextColor: Colors.white,
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      collapsedBackgroundColor: Color(0xFFa02e49),
                      title: Row(
                        children: [
                          Radio(
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Colors.white;
                              }
                              return Colors.white;
                            }),
                            value: 1,
                            groupValue: selectedValue,
                            onChanged: (value) {
                              if (myplan != 'boss' &&
                                  myplan != 'starter' &&
                                  myplan != '') {
                                print('true');
                                print(myplan);
                                setState(() {
                                  selectedValue = value!;
                                });
                              }
                            },
                          ),
                          Text(
                            'FREE',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('FREE for Lifetime'),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                      children: <Widget>[
                        ListTile(
                            title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              thickness: 2,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '● Add up to 5 products',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ExpansionTile(
                      backgroundColor: Color(0xFFa02e49),
                      collapsedTextColor: Colors.white,
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      collapsedBackgroundColor: Color(0xFFa02e49),
                      title: Row(
                        children: [
                          Radio(
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Colors.white;
                              }
                              return Colors.white;
                            }),
                            value: 2,
                            groupValue: selectedValue,
                            onChanged: (value) {
                              if (myplan != 'boss' && myplan != '') {
                                print('true');
                                print(myplan);
                                setState(() {
                                  selectedValue = value!;
                                });
                              }
                            },
                          ),
                          Text(
                            'STARTER',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('500 PHP / month'),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                      children: <Widget>[
                        ListTile(
                            title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              thickness: 2,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '● Unlimited Products',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ExpansionTile(
                      backgroundColor: Color(0xFFa02e49),
                      collapsedTextColor: Colors.white,
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      collapsedBackgroundColor: Color(0xFFa02e49),
                      title: Row(
                        children: [
                          Radio(
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Colors.white;
                              }
                              return Colors.white;
                            }),
                            value: 3,
                            groupValue: selectedValue,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value!;
                              });
                            },
                          ),
                          Text(
                            'BOSS',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('1000 PHP / month'),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                      children: <Widget>[
                        ListTile(
                            title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              thickness: 2,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '● Unlimited Products',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '● Print Receipts',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          },
                          child: Text('CANCEL')),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFFa02e49))),
                          onPressed: () {
                            print(selectedValue);
                            if (selectedValue == 1) {}
                            if ((myplan == 'boss' && selectedValue == 2) ||
                                (myplan == 'boss' && selectedValue == 1)) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      titlePadding:
                                          EdgeInsets.only(top: 16, bottom: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        side: BorderSide(
                                          color: Color(0xFFa02e49),
                                          width: 3.0,
                                        ),
                                      ),
                                      title: Text(
                                        'SUBSCRIPTION FAILED',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      content: SizedBox(
                                        height: 120,
                                        child: Column(
                                          children: [
                                            FittedBox(
                                                child: Text(
                                                    'NO DOWNGRADE SUBSCRIPTION')),
                                            Text('Please try again!'),
                                            SizedBox(height: 10),
                                            Divider(
                                              thickness: 2,
                                            ),
                                            Center(
                                              child: TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('OK',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color:
                                                              Color(0xFFa02e49),
                                                          fontWeight: FontWeight
                                                              .bold))),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            } else {
                              if ((myplan == 'boss' && selectedValue == 3) ||
                                  (myplan == 'starter' && selectedValue == 2)) {
                                if (expired) {
                                  _launchURL('starter');
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.zero,
                                          titlePadding: EdgeInsets.only(
                                              top: 16, bottom: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            side: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 3.0,
                                            ),
                                          ),
                                          title: Text(
                                            'RESUBSCRIBED',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: SizedBox(
                                            height: 120,
                                            child: Column(
                                              children: [
                                                FittedBox(
                                                    child: Text(
                                                        'Your subscription is not yet expired')),
                                                Text(
                                                    'You want to resubscribe?'),
                                                SizedBox(height: 10),
                                                Divider(
                                                  thickness: 2,
                                                ),
                                                Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('NO',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Color(
                                                                      0xFFa02e49),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            _launchURL('boss');
                                                          },
                                                          child: Text('YES',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Color(
                                                                      0xFFa02e49),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                }
                              } else {
                                if (selectedValue == 2) {
                                  _launchURL('starter');
                                }
                                if (selectedValue == 3) {
                                  _launchURL('boss');
                                }
                              }
                            }

                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => HomePage(),
                            //   ),
                            // );
                          },
                          child: Text('PROCEED')),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

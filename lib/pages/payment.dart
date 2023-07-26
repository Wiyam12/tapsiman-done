import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:user/pages/orders.dart';
import 'package:user/pages/testprinttt.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage(
      {super.key,
      required this.totalAmount,
      required this.name,
      required this.tablenumber,
      required this.note});
  final double totalAmount;
  final String name;
  final int tablenumber;
  final String note;
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _orders = Hive.box('_orders');
  List<dynamic> dataArray = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;

  TestPrinttt TestPrintt = TestPrinttt();

  final _formKey = GlobalKey<FormState>();
  TextEditingController _paymentcontroller = TextEditingController();
  TextEditingController _receivedcontroller = TextEditingController();
  TextEditingController _changecontroller = TextEditingController();

  String textFieldValue = '';
  double totalpayment = 100.0;
  double change = 0.0;
  double amountreceived = 0.0;

  String received = '';
  String changectrl = '';

  String? plan;
  String? businessName;
  bool isProceed = false;

  calculate(double payment) {
    if (payment >= totalpayment) {
      setState(() {
        amountreceived = payment;
        change = amountreceived - totalpayment;
        _receivedcontroller.text = amountreceived.toString();
        _changecontroller.text = change.toString();
        print(amountreceived);
        print(change.toStringAsFixed(2));
      });
    }
  }

  String generateRandomReceipt() {
    final random = Random();
    final alphanumericCharacters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final receiptLength = 10; // Adjust the length as per your requirements

    String receipt = '';

    for (int i = 0; i < receiptLength; i++) {
      int randomIndex = random.nextInt(alphanumericCharacters.length);
      receipt += alphanumericCharacters[randomIndex];
    }

    return receipt;
  }

  Future<void> _getOrder() async {
    for (int i = 0; i < _orders.length; i++) {
      setState(() {
        dataArray.add(_orders.getAt(i));
      });
    }

    print(dataArray);

    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      final data = snapshot.data();
      // Access the data fields from the document
      final name = data!['plan'] as String;
      final businessname = data['businessname'] as String;
      // Rest of your code
      setState(() {
        plan = name;
        businessName = businessname;
      });
    }
  }

  Future<void> _addOrder() async {
    try {
      setState(() {
        isProceed = true;
      });
      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid;

      //   // Upload image to Firebase Storage

      //   // Additional data provided
      final receipt = generateRandomReceipt();
      final customerName = widget.name;
      final tableNumber = widget.tablenumber;
      final note = widget.note;
      final totalAmount = widget.totalAmount;
      DateTime now = DateTime.now();
      DateTime today = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
        now.second,
        now.millisecond,
      );

      //   // Store product data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .add({
        'receipt': receipt,
        'customerName': customerName,
        'tableNumber': tableNumber,
        'note': note,
        'order': dataArray,
        'totalPayment': totalAmount,
        'status': 'pending',
        'date': today,
        'amountReceived': amountreceived,
        'changed': change
      });
      final batch = FirebaseFirestore.instance.batch();
      for (int i = 0; i < dataArray.length; i++) {
        if (dataArray[i]['productId'] != null) {
          final productId = dataArray[i]['productId'] as String;
          final quantity = dataArray[i]['quantity'] as int;

          final productRef = FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('products')
              .doc(productId);

          batch.update(
              productRef, {'productStocks': FieldValue.increment(-quantity)});
        }
      }

      await batch.commit();

      if (plan == 'boss') {
        TestPrintt.printReceipt(
            widget.name,
            widget.tablenumber,
            widget.note,
            widget.totalAmount,
            dataArray,
            receipt,
            businessName!,
            amountreceived,
            change,
            0.0,
            context);
      } else {
        _orders.clear();
      }
      //   // Show success message or navigate to a different screen

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order Successfully!'),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OrderPage(
            status: 'pending',
          ),
        ),
      );
    } catch (error) {
      setState(() {
        isProceed = false;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to Pay. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _getOrder();
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.name;
    int tablenumber = widget.tablenumber;
    String note = widget.note;

    totalpayment = widget.totalAmount;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa02e49),
        title: Text('PAYMENT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Total Payment:   ₱$totalpayment',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFa02e49)),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _receivedcontroller,
                          style: TextStyle(color: Color(0xFFa02e49)),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            label: Text('AMOUNT RECEIVED'),
                            labelStyle: TextStyle(color: Color(0xFFa02e49)),
                            hintStyle: TextStyle(color: Color(0xFFa02e49)),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFa02e49), width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFa02e49), width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _changecontroller,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Color(0xFFa02e49)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            label: Text('CHANGE'),
                            labelStyle: TextStyle(color: Color(0xFFa02e49)),
                            hintStyle: TextStyle(color: Color(0xFFa02e49)),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFa02e49), width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFa02e49), width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _paymentcontroller,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: Color(0xFFa02e49)),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Type or select bill tendered',
                              hintStyle: TextStyle(color: Color(0xFFa02e49)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFa02e49),
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFa02e49),
                                  width: 2.0,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value != null && value != '') {
                                double parsevalue =
                                    double.parse(value.toString());
                                if (parsevalue != null) {
                                  _receivedcontroller.text =
                                      parsevalue.toString();
                                  calculate(parsevalue);
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .white), // Change the background color
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the border radius as needed
                                          side: BorderSide(
                                              color: Color(
                                                  0xFFa02e49)), // Change the border color
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      calculate(10.0);
                                      setState(() {
                                        textFieldValue = '10';
                                        _paymentcontroller.text =
                                            textFieldValue;
                                      });

                                      // Button onPressed logic
                                    },
                                    child: Text(
                                      '10',
                                      style: TextStyle(
                                          color: Color(0xFFa02e49),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .white), // Change the background color
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the border radius as needed
                                          side: BorderSide(
                                              color: Color(
                                                  0xFFa02e49)), // Change the border color
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Button onPressed logic

                                      calculate(20.0);
                                      setState(() {
                                        textFieldValue = '20';
                                        _paymentcontroller.text =
                                            textFieldValue;
                                      });
                                    },
                                    child: Text(
                                      '20',
                                      style: TextStyle(
                                          color: Color(0xFFa02e49),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .white), // Change the background color
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the border radius as needed
                                          side: BorderSide(
                                              color: Color(
                                                  0xFFa02e49)), // Change the border color
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Button onPressed logic
                                      calculate(50.0);
                                      setState(() {
                                        textFieldValue = '50';
                                        _paymentcontroller.text =
                                            textFieldValue;
                                      });
                                    },
                                    child: Text(
                                      '50',
                                      style: TextStyle(
                                          color: Color(0xFFa02e49),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .white), // Change the background color
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the border radius as needed
                                          side: BorderSide(
                                              color: Color(
                                                  0xFFa02e49)), // Change the border color
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Button onPressed logic

                                      calculate(100.0);
                                      setState(() {
                                        textFieldValue = '100';
                                        _paymentcontroller.text =
                                            textFieldValue;
                                      });
                                    },
                                    child: Text(
                                      '100',
                                      style: TextStyle(
                                          color: Color(0xFFa02e49),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .white), // Change the background color
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the border radius as needed
                                          side: BorderSide(
                                              color: Color(
                                                  0xFFa02e49)), // Change the border color
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Button onPressed logic
                                      calculate(200.0);
                                      setState(() {
                                        textFieldValue = '200';
                                        _paymentcontroller.text =
                                            textFieldValue;
                                      });
                                    },
                                    child: Text(
                                      '200',
                                      style: TextStyle(
                                          color: Color(0xFFa02e49),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .white), // Change the background color
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the border radius as needed
                                          side: BorderSide(
                                              color: Color(
                                                  0xFFa02e49)), // Change the border color
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Button onPressed logic
                                      calculate(300.0);
                                      setState(() {
                                        textFieldValue = '300';
                                        _paymentcontroller.text =
                                            textFieldValue;
                                      });
                                    },
                                    child: Text(
                                      '300',
                                      style: TextStyle(
                                          color: Color(0xFFa02e49),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .white), // Change the background color
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the border radius as needed
                                          side: BorderSide(
                                              color: Color(
                                                  0xFFa02e49)), // Change the border color
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Button onPressed logic
                                      calculate(400.0);
                                      setState(() {
                                        textFieldValue = '400';
                                        _paymentcontroller.text =
                                            textFieldValue;
                                      });
                                    },
                                    child: Text(
                                      '400',
                                      style: TextStyle(
                                          color: Color(0xFFa02e49),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .white), // Change the background color
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the border radius as needed
                                          side: BorderSide(
                                              color: Color(
                                                  0xFFa02e49)), // Change the border color
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Button onPressed logic
                                      calculate(500.0);
                                      setState(() {
                                        textFieldValue = '500';
                                        _paymentcontroller.text =
                                            textFieldValue;
                                      });
                                    },
                                    child: Text(
                                      '500',
                                      style: TextStyle(
                                          color: Color(0xFFa02e49),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .white), // Change the background color
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the border radius as needed
                                          side: BorderSide(
                                              color: Color(
                                                  0xFFa02e49)), // Change the border color
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Button onPressed logic
                                      calculate(1000.0);
                                      setState(() {
                                        textFieldValue = '1000';
                                        _paymentcontroller.text =
                                            textFieldValue;
                                      });
                                    },
                                    child: Text(
                                      '1000',
                                      style: TextStyle(
                                          color: Color(0xFFa02e49),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .white), // Change the background color
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the border radius as needed
                                          side: BorderSide(
                                              color: Color(
                                                  0xFFa02e49)), // Change the border color
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Button onPressed logic
                                      calculate(totalpayment);
                                      setState(() {
                                        textFieldValue =
                                            totalpayment.toString();
                                        _paymentcontroller.text =
                                            textFieldValue;
                                      });
                                    },
                                    child: Text(
                                      'EXACT AMOUNT',
                                      style: TextStyle(
                                          color: Color(0xFFa02e49),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Divider(
                            thickness: 2,
                            color: Color(0xFFa02e49),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFFa02e49))),
                          onPressed: () {
                            if (!isProceed) {
                              if (_formKey.currentState!.validate()) {
                                // Validation passed, submit the form
                                // Add your submit logic here
                                _addOrder();
                              }
                            }
                          },
                          child:
                              Text(isProceed ? 'Please wait...' : 'PROCEED')),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

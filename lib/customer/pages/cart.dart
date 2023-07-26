import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/customer/pages/home.dart';

import 'addorder.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool empty = false;
  double totalPayment = 0.0;
  double totalCoins = 0.0;
  bool _useCoins = false;
  bool sending = false;

  List<List<dynamic>> menu = [
    // [
    //   'Product 1',
    //   'Price 1',
    //   '15-20 minutes',
    //   AssetImage('images/ambot.png'),
    //   1
    // ],
    // [
    //   'Product 2',
    //   'Price 2',
    //   '10-15 minutes',
    //   AssetImage('images/ambot.png'),
    //   4
    // ],
    // [
    //   'Product 1',
    //   'Price 1',
    //   '15-20 minutes',
    //   AssetImage('images/ambot.png'),
    //   4
    // ],
    // [
    //   'Product 1',
    //   'Price 1',
    //   '15-20 minutes',
    //   AssetImage('images/ambot.png'),
    //   4
    // ],

    // ['Product 3', 'Price 3', 'Details 3', AssetImage('images/ambot.png')],
  ];

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

  Future<void> fetchMenuData() async {
    double totalAmount = 0.0;
    final prefs = await SharedPreferences.getInstance();
    String storeId = prefs.getString('storeId') ?? '';
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final DocumentSnapshot<Map<String, dynamic>> usersnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final userdata = usersnapshot.data();
    final coins = double.parse(userdata!['coin'].toString());
    setState(() {
      totalCoins = coins;
    });
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .where('storeId', isEqualTo: storeId)
        .get();
    if (snapshot.docs.isEmpty) {
      setState(() {
        empty = true;
      });
    }
    final data = snapshot.docs.map((doc) {
      final imageUrl = doc['imageUrl'] as String;
      final productName = doc['productName'] as String;
      final productPrice = double.parse(doc['productPrice'].toString());
      final note = doc['note'] as String;
      final productId = doc['productId'] as String;
      final quantity = doc['quantity'] as int;
      final cartId = doc.id;
      final productCost = double.parse(doc['productCost'].toString());
      totalAmount += productPrice * quantity;
      return [
        productName,
        productPrice,
        note,
        imageUrl,
        quantity,
        productId,
        cartId,
        productCost
      ];
    }).toList();

    setState(() {
      totalPayment = totalAmount;
      menu = data;
    });
  }

  Future<void> _addOrder() async {
    setState(() {
      sending = true;
    });
    final prefs = await SharedPreferences.getInstance();
    String storeId = prefs.getString('storeId') ?? '';
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final DocumentSnapshot<Map<String, dynamic>> usersnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final userdata = usersnapshot.data();
    final name = userdata!['name'] as String;

    final receipt = generateRandomReceipt();
    final customerName = name;
    final tableNumber = 0;
    final note = '';
    double totalAmount = totalPayment;
    DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      0,
      0,
      0,
      0,
    );

    List<Map<String, dynamic>> orderList = menu.map((item) {
      return {
        'productName': item[0],
        'productPrice': item[1],
        'note': item[2],
        'imageUrl': item[3],
        'quantity': item[4],
        'productId': item[5],
        'cartId': item[6],
        'productCost': item[7]
        // Add more fields as needed
      };
    }).toList();

    try {
      if (_useCoins) {
        totalAmount -= totalCoins;

        DocumentReference updateDateToken =
            FirebaseFirestore.instance.collection('users').doc(userId);
        await updateDateToken.update({'coin': 0});

        final CollectionReference<Map<String, dynamic>> vouchersCollection =
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('voucher');
        final QuerySnapshot<Map<String, dynamic>> voucherquerySnapshot =
            await vouchersCollection.get();

        final voucherbatch = FirebaseFirestore.instance.batch();

        for (final docSnapshot in voucherquerySnapshot.docs) {
          // Update each document in the batch to set 'used' field to true
          voucherbatch.update(docSnapshot.reference, {'used': true});
        }

        // Commit the batch to execute all the updates at once
        await voucherbatch.commit();
      }
      final batch = FirebaseFirestore.instance.batch();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(storeId)
          .collection('orders')
          .add({
        'receipt': receipt,
        'customerName': customerName,
        'tableNumber': tableNumber,
        'note': note,
        'order': orderList,
        'totalPayment': totalAmount,
        'status': 'pending',
        'date': today,
        'customerId': userId,
        'useCoins': totalCoins
      });

      for (int i = 0; i < menu.length; i++) {
        if (menu[i][5] != null) {
          final productId = menu[i][5] as String;
          final quantity = menu[i][4] as int;

          final productRef = FirebaseFirestore.instance
              .collection('users')
              .doc(storeId)
              .collection('products')
              .doc(productId);

          batch.update(
              productRef, {'productStocks': FieldValue.increment(-quantity)});
        }
      }

      await batch.commit();
      CollectionReference cartCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');
      QuerySnapshot cartquerySnapshot = await cartCollectionRef.get();
      WriteBatch cartbatch = FirebaseFirestore.instance.batch();
      cartquerySnapshot.docs.forEach((doc) {
        cartbatch.delete(doc.reference);
      });
      await cartbatch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order Successful!'),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomePageCustomer(),
        ),
      );
    } catch (error) {
      setState(() {
        sending = false;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to place the order. Please try again.'),
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
    fetchMenuData();
  }

  @override
  Widget build(BuildContext context) {
    print('menu: $menu');
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
              icon: Icon(Icons.arrow_back, color: Colors.white)),
          elevation: 0.0,
          backgroundColor: Color(0xFFa02e49),
          title: Text('Cart'),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          color: Color(0xFFa02e49),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                // Text(
                //   'Order Number',
                //   style: TextStyle(
                //       color: Colors.white,
                //       fontSize: 25,
                //       fontWeight: FontWeight.bold),
                // ),
                // Text(
                //   'Order Receipt',
                //   style: TextStyle(
                //       color: Colors.white,
                //       fontSize: 25,
                //       fontWeight: FontWeight.bold),
                // ),
                SizedBox(
                  height: 10,
                ),
                empty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Text(
                            'No Cart',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        // color: Colors.black,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: menu.length,
                          itemBuilder: (context, index) {
                            String productId = menu[index][5];
                            String cartId = menu[index][6];
                            String productName = menu[index][0];
                            double price = menu[index][1];
                            String details = menu[index][2];
                            String image = menu[index][3];
                            int qty = menu[index][4];

                            return GestureDetector(
                              onTap: () {
                                print(productId);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddOrder(
                                        productId: productId, type: cartId),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  height: 120,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.network(image,
                                                fit: BoxFit.cover),
                                            // Image(
                                            //   image: image,
                                            //   fit: BoxFit.cover,
                                            // ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '$productName',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.06),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.timer,
                                                color: Colors.grey[300],
                                              ),
                                              Text('15-20 minutes',
                                                  style: TextStyle(
                                                      color: Colors.grey[400])),
                                            ],
                                          ),
                                          Text('NOTE: $details',
                                              style: TextStyle(
                                                  color: Colors.grey[400])),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '₱ ${price.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.pinkAccent,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                  Text('QTY: $qty'),
                                                  // Container(
                                                  //     decoration: BoxDecoration(
                                                  //       color: Colors.white,
                                                  //       boxShadow: [
                                                  //         BoxShadow(
                                                  //           color: Colors.grey
                                                  //               .withOpacity(0.5),
                                                  //           spreadRadius: 2,
                                                  //           blurRadius: 5,
                                                  //           offset: Offset(0, 3),
                                                  //         ),
                                                  //       ],
                                                  //     ),
                                                  //     child: Icon(Icons.add))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Use $totalCoins Coins',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              Switch(
                                value: _useCoins,
                                activeColor: Colors.white,
                                onChanged: (value) {
                                  setState(() {
                                    _useCoins = !_useCoins;
                                    print(_useCoins);
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFeb5135)),
                                onPressed: () {
                                  _addOrder();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FittedBox(
                                    child: Text(
                                      sending
                                          ? 'Please wait...'
                                          : 'Confirm Order',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ]),
            ),
          ),
        ));
  }
}

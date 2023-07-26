import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/customer/pages/orderdetails.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<List<dynamic>> menu = [
    // [
    //   'Friday',
    //   'June 2, 2023',
    //   'Order Number',
    //   'Receipt Number',
    //   580,
    //   4,
    //   '0001'
    // ],
    // [
    //   'Saturday',
    //   'June 3, 2023',
    //   'Order Number1',
    //   'Receipt Numbe1r',
    //   500,
    //   1,
    //   '0002'
    // ],
    // [
    //   'Sunday',
    //   'June 4, 2023',
    //   'Order Number2',
    //   'Receipt Number2',
    //   230,
    //   3,
    //   '0003'
    // ],

    // ['Product 3', 'Price 3', 'Details 3', AssetImage('images/ambot.png')],
  ];

  Future<void> fetchMenuData() async {
    final prefs = await SharedPreferences.getInstance();
    String storeId = prefs.getString('storeId') ?? '';
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final DocumentSnapshot<Map<String, dynamic>> storesnapshot =
        await FirebaseFirestore.instance.collection('users').doc(storeId).get();
    final storedata = storesnapshot.data();
    final businessname = storedata!['businessname'] as String;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(storeId)
        .collection('orders')
        .where('customerId', isEqualTo: userId)
        .get();

    // Map the retrieved data into the desired format
    querySnapshot.docs.forEach((doc) {
      Timestamp timestamp = doc['date'];
      DateTime dateTime = timestamp.toDate();
      String formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
      String dayOfWeek = DateFormat('EEEE').format(dateTime);
      List<dynamic> orderData = [
        dayOfWeek,
        formattedDate,
        businessname,
        doc['receipt'],
        doc['totalPayment'],
        doc['order'].length,
        doc.id
        // Add more fields as needed
      ];

      setState(() {
        menu.add(orderData);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMenuData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xFFa02e49),
        title: Text('My Orders'),
        centerTitle: true,
      ),
      body: Container(
        color: Color(0xFFa02e49),
        width: double.infinity,
        child: Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.82,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: menu.length,
              itemBuilder: (context, index) {
                String day = menu[index][0];
                String date = menu[index][1];
                String ordernum = menu[index][2];
                String receipt = menu[index][3];
                String price = menu[index][4].toString();
                String qty = menu[index][5].toString();
                String orderid = menu[index][6];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(
                          orderid: orderid,
                        ),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                                height: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$day',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25),
                                    ),
                                    Text('$date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25))
                                  ],
                                )),
                          ),
                          SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$ordernum',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.grey[400]),
                              ),
                              Text('$receipt',
                                  style: TextStyle(color: Colors.grey[400])),
                              SizedBox(height: 10),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₱ $price',
                                        style: TextStyle(
                                            color: Colors.pinkAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text('QTY: $qty')
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
          )
        ]),
      ),
    );
  }
}

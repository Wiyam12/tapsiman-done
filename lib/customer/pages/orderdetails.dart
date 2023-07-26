import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key, required this.orderid});
  final String orderid;
  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String? orderid;
  String? receipt;
  String? date;
  double totalAmount = 0.0;
  String? businessName;
  // bool usecoins = false;
  double useCoins = 0.0;
  List<List<dynamic>> menu = [
    // [
    //   'Friday',
    //   'June 2, 2023',
    //   'Order Number',
    //   'Receipt Number',
    //   580,
    //   4,
    //   '0001',
    //   [
    //     [
    //       'Tapsilog',
    //       4,
    //       50,
    //       [
    //         ['addon1', 1, 10],
    //         ['addon2', 2, 15]
    //       ]
    //     ],
    //     [
    //       'Examplesdasdafxcasdfsds',
    //       1,
    //       100,
    //       [
    //         ['addon1', 1, 10],
    //         ['addon2', 1, 5]
    //       ]
    //     ],
    //     ['Example', 3, 120, []],
    //     ['Example', 3, 120, []],
    //     ['Example', 3, 120, []],
    //     ['Example', 3, 120, []],
    //     ['Example', 3, 120, []],
    //     ['Example', 3, 120, []],
    //     ['Example', 3, 120, []],
    //     ['Example', 3, 120, []],
    //     ['Example', 3, 120, []],
    //     ['Example', 3, 120, []],
    //     ['Example', 3, 120, []],
    //     ['Example', 3, 120, []],
    //   ],
    // ],
  ];

  Future<void> fetchMenuData() async {
    final prefs = await SharedPreferences.getInstance();
    String storeId = prefs.getString('storeId') ?? '';

    final DocumentSnapshot<Map<String, dynamic>> storesnapshot =
        await FirebaseFirestore.instance.collection('users').doc(storeId).get();
    final storedata = storesnapshot.data();
    final businessname = storedata!['businessname'] as String;

    DocumentSnapshot<Map<String, dynamic>> orderSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(storeId)
            .collection('orders')
            .doc(widget.orderid)
            .get();
    List<dynamic> orderData = orderSnapshot.data()?['order'] ?? [];
    final orderdataDet = orderSnapshot.data();
    final orderreceipt = orderdataDet!['receipt'] as String;
    Timestamp timestamp = orderdataDet['date'];
    if (orderdataDet.containsKey('useCoins')) {
      // final useCoins = double.parse(orderdataDet['useCoins'].toString());
      setState(() {
        useCoins = double.parse(orderdataDet['useCoins'].toString());
      });
    }

    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);

    orderData.forEach((item) {
      List<dynamic> itemData = [
        item['productName'],
        item['productPrice'],
        item['quantity'],
        // Add more fields as needed
      ];
      setState(() {
        totalAmount = double.parse(orderdataDet['totalPayment'].toString());
        receipt = orderreceipt;
        date = formattedDate;
        businessName = businessname;
        menu.add(itemData);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    orderid = widget.orderid;

    fetchMenuData();
  }

  @override
  Widget build(BuildContext context) {
    print(orderid);
    print('totalAmount: $totalAmount');
    print('menu: $menu');
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xFFa02e49),
        title: Text('$date'),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Color(0xFFa02e49),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          '$businessName',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$receipt',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              for (int i = 0; i < menu.length; i++)
                                Row(
                                  children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        height: 20,
                                        child: FittedBox(
                                          child: Text(
                                            '${menu[i][0]}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        )),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Text(
                                          'QTY: ${menu[i][2]}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 20),
                                        )),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Text(
                                          '₱${menu[i][1]}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 20),
                                        ))
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'TOTAL: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '₱$totalAmount',
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            if (useCoins != 0.0)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Use Coins: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '$useCoins',
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                          ],
                        )
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

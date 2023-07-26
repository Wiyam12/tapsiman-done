import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user/pages/orderhistory.dart';
import 'package:user/pages/orders.dart';
import 'package:user/pages/testprinttt.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage(
      {super.key,
      required this.table,
      required this.receipt,
      required this.status,
      required this.orders,
      required this.orderId});

  final String table;
  final String receipt;
  final String status;
  final List<dynamic> orders;
  final String orderId;
  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  TestPrinttt TestPrintt = TestPrinttt();
  Color maincolor = Color(0xFFa02e49);
  String? customerName;
  String? table;
  int? tableNumber;
  String? note;
  double totalAmount = 0.0;
  String? receipt;
  String? status;
  String? businessName;
  double amountReceived = 0.0;
  double changed = 0.0;
  List<dynamic> orders = [];
  String? orderId;
  bool last = false;
  double grandtotal = 0.0;
  String? displayDate;
  String newStatus = '';
  bool sending = false;
  double useCoins = 0.0;
  double tootalPayment = 0.0;
  bool isprint = false;
  String myplan = '';
  List<List<dynamic>> order = [
    // [
    //   'Tapsilog',
    //   15,
    //   1,
    // ],
    // [
    //   'Hotsilog',
    //   15,
    //   1,
    // ],
  ];
  Future<void> retrieveVoidStatus() async {
    setState(() {
      sending = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    DocumentReference orderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(widget.orderId);

    await orderRef.update({'status': 'pending'});

    // Get a reference to the specific order document
    fetchData();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderPage(
          status: 'pending',
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order's Successfully Retrieved"),
      ),
    );

    // Update the 'status' field of the order document
  }

  Future<void> updateVoidStatus() async {
    setState(() {
      sending = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    DocumentReference orderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(widget.orderId);

    await orderRef.update({'status': 'voided'});

    // Get a reference to the specific order document
    fetchData();
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => OrderHistoryPage(
                complete: false,
                voide: true,
              )),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order's Updated to VOIDED"),
      ),
    );

    // Update the 'status' field of the order document
  }

  Future<void> updateOrderStatus() async {
    setState(() {
      sending = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    String? newStatus;
    DocumentReference orderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(widget.orderId);
    if (widget.status == 'pending') {
      newStatus = 'onprocess';
      await orderRef.update({'status': newStatus});
    }
    if (widget.status == 'onprocess') {
      newStatus = 'ready';
      await orderRef.update({'status': newStatus});
    }
    // Get a reference to the specific order document
    fetchData();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderPage(
          status: newStatus!,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order's Updated to ${newStatus!.toUpperCase()}"),
      ),
    );

    // Update the 'status' field of the order document
  }

  Future<void> fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final orderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(widget.orderId);
    final DocumentSnapshot<Map<String, dynamic>> usersnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userdata = usersnapshot.data();

    final businessname = userdata!['businessname'] as String;
    final plan = userdata['plan'] as String;

    final orderSnapshot = await orderRef.get();
    if (orderSnapshot.exists) {
      final data = orderSnapshot.data();
      final customername = data!['customerName'] as String;
      final date = data['date'] as Timestamp;
      final tablenumber = data['tableNumber'] as int;
      final mynote = data['note'] as String;
      final totalpayment = double.parse(data['totalPayment'].toString());
      double amountreceived = 0.0;

      double change = 0.0;
      if (data.containsKey('amountReceived')) {
        amountreceived = double.parse(data['amountReceived'].toString());
      }

      if (data.containsKey('useCoins')) {
        setState(() {
          useCoins = double.parse(data['useCoins'].toString());
        });
      }
      if (data.containsKey('changed')) {
        change = double.parse(data['changed'].toString());
      }

      DateTime dateTime = date.toDate();
      String formattedDate =
          DateFormat('MMM d, yyyy | h:mm a').format(dateTime);
      List<List<dynamic>> convertedOrders = orders.map((order) {
        return [
          order['productName'],
          order['productPrice'],
          order['quantity'],
        ];
      }).toList();
      setState(() {
        if (mounted) {
          amountReceived = amountreceived;
          changed = change;
          businessName = businessname;
          myplan = plan;
          totalAmount = totalpayment;
          tableNumber = tablenumber;
          note = mynote;
          if (widget.status == 'pending') {
            newStatus = 'onprocess';
          }
          if (widget.status == 'onprocess') {
            newStatus = 'ready';
          }
          order = convertedOrders;
          displayDate = formattedDate;
          customerName = customername;
        }
      });
    }
    setState(() {
      isprint = true;
    });
    // Process the orderData as needed
  }

  double calculateTotalAmount(List<dynamic> order) {
    double totalAmount = 0.0;

    for (int i = 0; i < order.length; i++) {
      double itemPrice = double.parse(order[i][1].toString());
      int itemQuantity = order[i][2];
      totalAmount += itemPrice * itemQuantity;
    }

    return totalAmount;
  }

  String getCurrentDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMM dd, yyyy').format(now);
    String formattedTime = DateFormat('h:mm a').format(now);
    return '$formattedDate | $formattedTime';
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    table = widget.table;
    receipt = widget.receipt;
    status = widget.status;
    orders = widget.orders;
    orderId = widget.orderId;
    // _getOrder();
  }

  @override
  Widget build(BuildContext context) {
    print('widget order: ${widget.orders}');
    print(orders);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa02e49),
        elevation: 0.0,
        title: Text('ORDER STATUS'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          status!.toUpperCase(),
                          style: TextStyle(
                              color: maincolor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
                Row(
                  children: [
                    Text('$displayDate'),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: maincolor),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer Name: $customerName',
                              style: TextStyle(color: maincolor),
                            ),
                            Text(
                              'Table Number: $table',
                              style: TextStyle(color: maincolor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: maincolor),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'Receipt No.',
                              style: TextStyle(color: maincolor),
                            ),
                            Text(
                              '$receipt',
                              style: TextStyle(
                                color: maincolor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(
                              'ITEM/S',
                              style: TextStyle(
                                  color: Color(0xFFa02e49),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(
                              'QTY',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFFa02e49),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(
                              'PRICE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFFa02e49),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(
                              'SUBTOTAL',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFFa02e49),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Divider(thickness: 2, color: Color(0xFFa02e49)),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: ListView.builder(
                          itemCount: order.length,
                          itemBuilder: (context, index) {
                            // bool hasaddons = false;

                            if (order.length == index + 1) {
                              last = true;
                              print('last');
                            }
                            print(order.length);
                            print(index);

                            String productName = order[index][0];
                            double price =
                                double.parse(order[index][1].toString());
                            int quantity = order[index][2];
                            // if (currentOrder[3].length > 0) {
                            //   addons = currentOrder[3];
                            //   hasaddons = true;
                            // }

                            double subtotal = 0.0;
                            subtotal = price * quantity;

                            grandtotal += subtotal;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Text(
                                          productName,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Color(0xFFa02e49)),
                                        )),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Text(
                                          '$quantity',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xFFa02e49)),
                                        )),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Text(
                                          '₱ $price',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xFFa02e49)),
                                        )),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Text(
                                          '₱$subtotal',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xFFa02e49)),
                                        )),
                                  ],
                                ),
                                Divider(thickness: 1, color: Color(0xFFa02e49)),
                                if (last)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('AMOUNT PAYABLE',
                                          style: TextStyle(
                                              color: Color(0xFFa02e49))),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Text('₱$totalAmount',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color(0xFFa02e49))),
                                      ),
                                    ],
                                  )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: status == 'ready'
                    ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xFFa02e49))),
                                onPressed: () {
                                  if (isprint) {
                                    if (myplan == 'boss') {
                                      TestPrintt.printReceipt(
                                          customerName!,
                                          tableNumber!,
                                          note!,
                                          double.parse(totalAmount.toString()),
                                          widget.orders,
                                          widget.receipt,
                                          businessName!,
                                          double.parse(
                                              amountReceived.toString()),
                                          double.parse(changed.toString()),
                                          double.parse(useCoins.toString()),
                                          context);
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
                                                'PRINT FAILED',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              content: SizedBox(
                                                height: 120,
                                                child: Column(
                                                  children: [
                                                    FittedBox(
                                                        child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 8.0),
                                                      child: Text(
                                                          "You don't have permission to print receipt!"),
                                                    )),
                                                    Text(
                                                        'Subscribed to Boss Plan'),
                                                    SizedBox(height: 10),
                                                    Divider(
                                                      thickness: 2,
                                                    ),
                                                    Center(
                                                      child: TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('OK',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Color(
                                                                      0xFFa02e49),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    }
                                  }

                                  // Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //     builder: (context) => PosPage(),
                                  //   ),
                                  // );
                                },
                                child: Text(sending
                                    ? 'Please wait...'
                                    : 'PRINT RECEIPT')),
                          ),
                        ],
                      )
                    : status == 'voided'
                        ? Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Color(0xFFa02e49))),
                                    onPressed: () {
                                      retrieveVoidStatus();
                                      // Navigator.of(context).push(
                                      //   MaterialPageRoute(
                                      //     builder: (context) => PosPage(),
                                      //   ),
                                      // );
                                    },
                                    child: Text(sending
                                        ? 'Please wait...'
                                        : 'RETRIEVE ORDER')),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Color(0xFFa02e49))),
                                    onPressed: () {
                                      if (!sending) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                contentPadding: EdgeInsets.zero,
                                                titlePadding: EdgeInsets.only(
                                                    top: 16, bottom: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  side: BorderSide(
                                                    color: Color(0xFFa02e49),
                                                    width: 3.0,
                                                  ),
                                                ),
                                                title: Text(
                                                  'Warning',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.25,
                                                  child: Column(
                                                    children: [
                                                      FittedBox(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                            'Are you sure you want to'),
                                                      )),
                                                      Text(
                                                          'update this order to Voided?'),
                                                      SizedBox(height: 10),
                                                      Divider(
                                                        thickness: 2,
                                                      ),
                                                      Row(
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
                                                              child: Text('No',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
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
                                                                updateVoidStatus();
                                                              },
                                                              child: Text('Yes',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      color: Color(
                                                                          0xFFa02e49),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      }

                                      // Navigator.of(context).push(
                                      //   MaterialPageRoute(
                                      //     builder: (context) => PosPage(),
                                      //   ),
                                      // );
                                    },
                                    child: Text(
                                        sending ? 'Please wait...' : 'VOID')),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Color(0xFFa02e49))),
                                    onPressed: () {
                                      if (!sending) {
                                        updateOrderStatus();
                                      }

                                      // Navigator.of(context).push(
                                      //   MaterialPageRoute(
                                      //     builder: (context) => PosPage(),
                                      //   ),
                                      // );
                                    },
                                    child: Text(sending
                                        ? 'Please wait...'
                                        : newStatus.toUpperCase())),
                              ),
                            ],
                          )),
          ),
        ],
      ),
    );
  }
}

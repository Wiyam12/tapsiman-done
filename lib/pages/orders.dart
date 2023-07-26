import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user/pages/home.dart';
import 'package:user/pages/orderhistory.dart';
import 'package:user/pages/orderstatus.dart';
import 'package:user/pages/pos.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key, required this.status});
  final String status;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String? selectedStatus;

  List<bool> isSelected = [];
  double totalprice = 0.0;

  List<List<dynamic>> menu = [
    // [
    //   'table 1',
    //   'receipt1',
    //   'pending',
    // [
    //   ['tapsilog', 1, 100],
    //   ['tapsilog', 2, 100],
    //   ['tapsilog', 3, 100],
    //   ['tapsilog', 1, 100],
    //   ['tapsilog', 2, 100],
    //   ['tapsilog', 3, 100],
    //   ['tapsilog', 1, 100],
    //   ['tapsilog', 2, 100],
    //   ['tapsilog', 3, 100],
    //   ['tapsilog', 1, 100],
    //   ['tapsilog', 2, 100],
    //   ['tapsilog', 3, 100],
    // ]
    // ],
  ];

  List<String> _dropdownItems = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];
  String _selectedItem = 'DAILY';
  DateTime today = DateTime.now();
  final dateFormat = DateFormat('dd MMMM - yyyy');
  DateTime endDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day - 1,
    0, // hour value of 0 represents 12:00 AM
    0, // minute value of 0
    0, // second value of 0
    0, // millisecond value of 0
  );
  void updateDate() {
    if (_selectedItem == 'DAILY') {
      DateTime yesterday = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day - 1,
        0, // hour value of 0 represents 12:00 AM
        0, // minute value of 0
        0, // second value of 0
        0, // millisecond value of 0
      );
      print('yesterday: $yesterday');
      setState(() {
        endDate = yesterday;
        _selectedItem = 'DAILY';
      });
      _getOrder();
    } else if (_selectedItem == 'WEEKLY') {
      DateTime lastWeek = today.subtract(Duration(days: 7));
      print(lastWeek);
      setState(() {
        endDate = lastWeek;
        _selectedItem = 'WEEKLY';
      });
      _getOrder();
    } else if (_selectedItem == 'MONTHLY') {
      DateTime lastMonth = DateTime(today.year, today.month - 1, today.day);
      print(lastMonth);
      setState(() {
        endDate = lastMonth;
        _selectedItem = 'MONTHLY';
        //
      });
      _getOrder();
    } else if (_selectedItem == 'YEARLY') {
      DateTime lastYear = DateTime(today.year - 1, today.month, today.day);
      print(lastYear);
      setState(() {
        endDate = lastYear;
        _selectedItem = 'YEARLY';
        //
      });
      _getOrder();
    }
  }

  String getStartDateText() {
    if (_selectedItem == 'DAILY') {
      DateTime yesterday = today.subtract(Duration(days: 1));
      print(yesterday);
      setState(() {
        _selectedItem = 'DAILY';
      });
      return '${dateFormat.format(yesterday)}';
    } else if (_selectedItem == 'WEEKLY') {
      DateTime lastWeek = today.subtract(Duration(days: 7));
      print(lastWeek);
      setState(() {
        _selectedItem = 'WEEKLY';
      });
      return '${dateFormat.format(lastWeek)}';
    } else if (_selectedItem == 'MONTHLY') {
      DateTime lastMonth = DateTime(today.year, today.month - 1, today.day);
      print(lastMonth);
      setState(() {
        _selectedItem = 'MONTHLY';
      });

      return '${dateFormat.format(lastMonth)}';
    } else if (_selectedItem == 'YEARLY') {
      DateTime lastYear = DateTime(today.year - 1, today.month, today.day);
      print(lastYear);
      setState(() {
        _selectedItem = 'YEARLY';
      });
      return '${dateFormat.format(lastYear)}';
    } else {
      return 'Start Date';
    }
  }

  List<List<dynamic>> orders = [];
  Future<void> updateOrderStatus(String orderId, String status) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    String? newStatus;
    DocumentReference orderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId);
    if (status == 'pending') {
      newStatus = 'onprocess';
      await orderRef.update({'status': newStatus});
    }
    if (status == 'onprocess') {
      newStatus = 'ready';
      await orderRef.update({'status': newStatus});
    }
    // Get a reference to the specific order document
    _getOrder();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order's Updated to ${newStatus!.toUpperCase()}"),
      ),
    );
    // Update the 'status' field of the order document
  }

  Future<void> _getOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .where('date', isGreaterThanOrEqualTo: endDate)
        .where('date', isLessThanOrEqualTo: today)
        .orderBy('date', descending: true)
        .get();

    final data = snapshot.docs.map((doc) {
      final tableNumber = doc['tableNumber'] as int;
      final receipt = doc['receipt'] as String;
      final status = doc['status'] as String;
      final order = doc['order'] as List<dynamic>;
      final orderId = doc.id;
      final totalpayment = double.parse(doc['totalPayment'].toString());

      // final productPrice = doc['productPrice'] as double;

      print('order: $order');
      return [
        'Table $tableNumber',
        receipt,
        status,
        order,
        orderId,
        totalpayment
      ];
    }).toList();

    setState(() {
      menu = data;
    });
    print('menu: $menu');
  }

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.status;
    if (selectedStatus == 'pending') {
      isSelected = [true, false, false];
    } else if (selectedStatus == 'onprocess') {
      isSelected = [false, true, false];
    } else {
      isSelected = [false, false, true];
    }
    _getOrder();
  }

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> filteredMenu =
        menu.where((item) => item[2] == selectedStatus).toList();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)),
        actions: [
          if (selectedStatus == 'ready')
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OrderHistoryPage(
                      complete: true,
                      voide: false,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'HISTORY',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            )
        ],
        backgroundColor: Color(0xFFa02e49),
        title: Text('ORDERS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2, color: Color(0xFFa02e49))),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                              width: 2,
                                              color: Color(0xFFa02e49)))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      getStartDateText(),
                                      style:
                                          TextStyle(color: Color(0xFFa02e49)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Text(
                                dateFormat.format(today),
                                style: TextStyle(color: Color(0xFFa02e49)),
                                textAlign: TextAlign.center,
                              ))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Row(
                        children: [
                          Text(
                            'Filter: ',
                            style: TextStyle(color: Color(0xFFa02e49)),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Container(
                            padding: EdgeInsets.zero,
                            height: 20,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: Color(0xFFa02e49)),
                                borderRadius: BorderRadius.circular(50)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: DropdownButton(
                                iconSize: 12,
                                iconEnabledColor: Color(0xFFa02e49),
                                underline: Container(),
                                value: _selectedItem,
                                items: _dropdownItems.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFa02e49)),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedItem = newValue!;
                                    updateDate();
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ToggleButtons(
                        isSelected: isSelected,
                        onPressed: (int index) {
                          setState(() {
                            if (index == 0) {
                              selectedStatus = 'pending';
                            }
                            if (index == 1) {
                              selectedStatus = 'onprocess';
                            }
                            if (index == 2) {
                              selectedStatus = 'ready';
                            }

                            for (int i = 0; i < isSelected.length; i++) {
                              isSelected[i] = (i == index);
                            }
                          });
                        },
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'PENDING',
                              style: TextStyle(
                                color: isSelected[0]
                                    ? Colors.white
                                    : Color(0xFFa02e49),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'ON PROCESS',
                              style: TextStyle(
                                color: isSelected[1]
                                    ? Colors.white
                                    : Color(0xFFa02e49),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'READY',
                              style: TextStyle(
                                color: isSelected[2]
                                    ? Colors.white
                                    : Color(0xFFa02e49),
                              ),
                            ),
                          ),
                        ],
                        color: Colors.white,
                        selectedColor: Colors.white,
                        fillColor: Color(0xFFa02e49),
                        borderColor: Color(0xFFa02e49),
                        selectedBorderColor: Color(0xFFa02e49),
                        // borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: filteredMenu.length,
                      itemBuilder: (context, index) {
                        totalprice = 0.0;

                        return _buildMenuItem(filteredMenu[index]);
                      },
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PosPage(),
                              ),
                            );
                          },
                          child: Text('NEW ENTRY')),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(List<dynamic> item) {
    String table = item[0];
    String receipt = item[1];
    String status = item[2];
    List<dynamic> orders = item[3];
    String orderId = item[4];
    double totalpayment = item[5];

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderStatusPage(
              table: table,
              receipt: receipt,
              status: status,
              orders: orders,
              orderId: orderId,
            ),
          ),
        );
      },
      onLongPress: () {
        print('longpress $orderId');
        if (status != 'ready') {
          updateOrderStatus(orderId, status);
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: status == selectedStatus ? Color(0xFFa02e49) : Colors.white,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              table,
              style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFa02e49),
                  fontWeight: FontWeight.bold),
            ),
            Divider(
              thickness: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Color(0xFFa02e49)),
                      borderRadius: BorderRadius.circular(50)),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      receipt,
                      style: TextStyle(fontSize: 12, color: Color(0xFFa02e49)),
                    ),
                  ),
                ),
              ],
            ),
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FittedBox(child: Text('ITEM/S')),
                  FittedBox(child: Text('QTY')),
                  FittedBox(child: Text('PRICE')),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.07,
              child: SingleChildScrollView(
                child: Column(
                  children: orders.map<Widget>((order) {
                    String orderName = order['productName'];
                    int quantity = order['quantity'];
                    double price =
                        double.parse(order['productPrice'].toString());
                    // List<List<dynamic>> addons = order.length > 3 ? order[3] : [];
                    // totalprice += price * quantity;
                    // double totalprice =
                    //     double.parse(order['totalPayment'].toString());
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.11,
                              child: Text(
                                orderName.length > 8
                                    ? orderName.substring(0, 6) + '...'
                                    : orderName,
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFFa02e49)),
                                softWrap: true,
                              ),
                            ),
                            Text(
                              '$quantity',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFa02e49)),
                            ),
                            Text(
                              '₱${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFa02e49)),
                            ),
                          ],
                        ),
                        // if (addons.isNotEmpty) ..._buildAddonList(addons),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            Divider(thickness: 2, color: Color(0xFFa02e49)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFFa02e49)),
                  ),
                  Text('$totalpayment',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFa02e49)))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAddonList(List<List<dynamic>> addons) {
    return addons.map<Widget>((addon) {
      String addonName = addon[0];
      int addonQuantity = addon[1];
      double addonPrice = double.parse(addon[2].toString());
      totalprice += addonPrice * addonQuantity;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                addonName.length > 8
                    ? addonName.substring(0, 6) + '...'
                    : addonName,
                style: TextStyle(fontSize: 11),
              ),
              Text(
                ' $addonQuantity',
                style: TextStyle(fontSize: 11),
              ),
              Text(
                '$addonPrice',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ],
      );
    }).toList();
  }
}

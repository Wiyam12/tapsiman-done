import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user/pages/orders.dart';
import 'package:user/pages/orderstatus.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage(
      {super.key, required this.complete, required this.voide});
  final bool voide;
  final bool complete;
  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  Color maincolor = Color(0xFFa02e49);
  bool completed = true;
  bool voided = false;
  String search = '';
  // List<dynamic> ordersList = [];
  List<List<dynamic>> order = [
    // ['RECEIPT1', 'table 1', 'martes', 100.0],
    // ['receipt2', 'table 1', 'marites1', 299.0],
  ];
  Future<void> fetchOrderData() async {
    String statusSearch = '';
    if (completed) {
      statusSearch = 'ready';
    } else {
      statusSearch = 'voided';
    }
    List<List<dynamic>> orders = [];
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final orderSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .where('status', isEqualTo: statusSearch)
        .get();

    orders = orderSnapshot.docs.map((doc) {
      final receipt = doc['receipt'] as String;
      final tablenumber = doc['tableNumber'] as int;
      final customername = doc['customerName'] as String;
      final totalpayment = double.parse(doc['totalPayment'].toString());
      final orderList = doc['order'] as List<dynamic>;
      final status = doc['status'] as String;

      final orderid = doc.id;

      return [
        receipt,
        'Table $tablenumber',
        customername,
        totalpayment,
        orderList,
        status,
        orderid
      ];
    }).toList();

    // List<dynamic> neworders = orderSnapshot.docs.map((doc) {

    //   return {
    //     'quantity': doc['quantity'] as int,
    //     'note': doc['note'] as String,
    //     'productPrice': double.parse(doc['productPrice'].toString()),
    //     'productName': doc['productName'] as String,
    //     'productCost': double.parse(doc['productCost'].toString()),
    //     'productId': doc['productId'] as String,
    //   };
    // }).toList();

    setState(() {
      // ordersList = orderSnapshot.docs.map((doc) => doc['order']).toList();
      order = orders;
    });
  }

  @override
  void initState() {
    voided = widget.voide;
    completed = widget.complete;
    super.initState();
    fetchOrderData();
  }

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> filteredMenu = search.isNotEmpty
        ? order
            .where((item) =>
                item[0].contains(search) ||
                item[1].contains(search) ||
                item[2].contains(search))
            .toList()
        : order;
    // print(order);
    print('filteredMenu: $filteredMenu');
    // print(ordersList);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa02e49),
        title: Text('ORDER HISTORY'),
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => OrderPage(status: 'pending')),
              );
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          completed = true;
                          voided = false;
                          fetchOrderData();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: maincolor),
                            color: completed ? maincolor : Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Text(
                            'COMPLETED',
                            style: TextStyle(
                                color: completed ? Colors.white : maincolor,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          completed = false;
                          voided = true;
                          fetchOrderData();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: maincolor),
                            color: voided ? maincolor : Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Text(
                            'VOIDED',
                            style: TextStyle(
                                color: voided ? Colors.white : maincolor,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Color(0xFFa02e49)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFa02e49).withOpacity(0.1),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFa02e49), width: 2.0),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFa02e49), width: 2.0),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Color(0xFFa02e49)),
                        prefixIcon:
                            Icon(Icons.search, color: Color(0xFFa02e49)),
                        prefixIconConstraints: BoxConstraints(minWidth: 40),
                      ),
                      onChanged: (value) {
                        // String upperValue = value.toUpperCase();
                        setState(() {
                          search = value.toUpperCase();
                        });
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Text(
                              'RECEIPT',
                              style: TextStyle(
                                  color: Color(0xFFa02e49),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(
                              'TABLE #',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFFa02e49),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(
                              'NAME',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFFa02e49),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(
                              'AMOUNT',
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
                          itemCount: filteredMenu.length,
                          itemBuilder: (context, index) {
                            // bool hasaddons = false;

                            String receipt = filteredMenu[index][0];
                            String table = filteredMenu[index][1];
                            String customername = filteredMenu[index][2];
                            double amount =
                                double.parse(filteredMenu[index][3].toString());

                            List<dynamic> orderList = filteredMenu[index][4];
                            String status = filteredMenu[index][5];
                            String orderId = filteredMenu[index][6];
                            // if (currentOrder[3].length > 0) {
                            //   addons = currentOrder[3];
                            //   hasaddons = true;
                            // }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => OrderStatusPage(
                                          table: table,
                                          receipt: receipt,
                                          status: status,
                                          orders: orderList,
                                          orderId: orderId,
                                        ),
                                      ),
                                    );
                                    // print(orderList);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          child: FittedBox(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: maincolor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  receipt,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          )),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: Text(
                                            '$table',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color(0xFFa02e49)),
                                          )),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: Text(
                                            '$customername',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color(0xFFa02e49)),
                                          )),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: Text(
                                            '₱${amount.toStringAsFixed(2)}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color(0xFFa02e49)),
                                          )),
                                    ],
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

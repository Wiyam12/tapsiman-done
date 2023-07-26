import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:user/pages/orderdetails.dart';
import 'package:user/pages/pos.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _orders = Hive.box('_orders');
  List<dynamic> dataArray = [];
  List<List<dynamic>> order = [];

  bool last = false;

  List<List<dynamic>> addons = [];

  double grandtotal = 0.0;
  String getCurrentDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMM dd, yyyy').format(now);
    String formattedTime = DateFormat('h:mm a').format(now);
    return '$formattedDate | $formattedTime';
  }

  double calculateTotalAmount(List<dynamic> order) {
    double totalAmount = 0.0;

    for (int i = 0; i < order.length; i++) {
      double itemPrice = order[i]['productPrice'];
      int itemQuantity = order[i]['quantity'];
      totalAmount += itemPrice * itemQuantity;
    }

    return totalAmount;
  }

  Future<void> _getOrder() async {
    for (int i = 0; i < _orders.length; i++) {
      setState(() {
        dataArray.add(_orders.getAt(i));
      });
    }
    print(dataArray);
  }

  void _removeItem(int index) async {
    // Show a confirmation dialog before deleting
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.only(top: 16, bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: Color(0xFFa02e49),
                width: 3.0,
              ),
            ),
            title: Text(
              'WARNING',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              height: 120,
              child: Column(
                children: [
                  FittedBox(child: Text('Are you sure you want to delete')),
                  Text('this order?'),
                  SizedBox(height: 10),
                  Divider(
                    thickness: 2,
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('NO',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFFa02e49),
                                    fontWeight: FontWeight.bold))),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                dataArray.removeAt(index);
                                _orders.deleteAt(index);
                                // Update the 'last' variable after                                                            deletion
                                last = dataArray.length == 0 ? false : true;
                              });
                              Navigator.of(context).pop();
                              if (dataArray.length == 0) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => PosPage()),
                                );
                              }
                            },
                            child: Text('YES',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFFa02e49),
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
    // bool confirm = await showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text("Confirm Deletion"),
    //     content: Text("Are you sure you want to delete this item?"),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, true),
    //         child: Text("Yes"),
    //       ),
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, false),
    //         child: Text("No"),
    //       ),
    //     ],
    //   ),
    // );

    // if (confirm == true) {

    // }
  }

  @override
  void initState() {
    super.initState();
    _getOrder();
  }

  @override
  Widget build(BuildContext context) {
    // List<DataRow> dataRows = [];

    // for (var item in order) {
    //   List<dynamic> addons = item[3];
    //   bool hasAddons = addons.isNotEmpty;

    //   dataRows.add(
    //     DataRow(
    //       cells: [
    //         DataCell(Text(item[0])),
    //         DataCell(Text(item[1].toString())),
    //         DataCell(Text(item[2].toString())),
    //       ],
    //     ),
    //   );

    //   if (hasAddons) {
    //     dataRows.add(
    //       DataRow(
    //         cells: [
    //           DataCell(
    //             Container(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: addons.map<Widget>((addon) {
    //                   return Text('- ${addon[0]}: ${addon[1]} x ${addon[2]}');
    //                 }).toList(),
    //               ),
    //             ),
    //           ),
    //           DataCell(Text('')),
    //           DataCell(Text('')),
    //         ],
    //       ),
    //     );
    //   }
    // }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa02e49),
        title: Text('REVIEW'),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PosPage()),
              );
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        child: Text(
                          '',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: Color(0xFFa02e49),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(
                          'PRODUCT',
                          textAlign: TextAlign.right,
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
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ListView.builder(
                      itemCount: dataArray.length,
                      itemBuilder: (context, index) {
                        // bool hasaddons = false;

                        if (dataArray.length == index + 1) {
                          last = true;
                          print('last');
                        }
                        print(order.length);
                        print(index);

                        String productName = dataArray[index]['productName'];
                        double price = dataArray[index]['productPrice'];
                        int quantity = dataArray[index]['quantity'];

                        double subtotal = 0.0;
                        subtotal = price * quantity;

                        grandtotal += subtotal;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  child: FittedBox(
                                    child: IconButton(
                                        onPressed: () {
                                          _removeItem(index);
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Color(0xFFa02e49),
                                        )),
                                  ),
                                ),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: FittedBox(
                                      child: Row(
                                        children: [
                                          Text(
                                            productName,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFFa02e49)),
                                          ),
                                        ],
                                      ),
                                    )),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Text(
                                      '$quantity',
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: Color(0xFFa02e49)),
                                    )),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Text(
                                      '₱ $price',
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: Color(0xFFa02e49)),
                                    )),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Text(
                                      '₱$subtotal',
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: Color(0xFFa02e49)),
                                    )),
                              ],
                            ),
                            Divider(thickness: 1, color: Color(0xFFa02e49)),
                            if (last)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getCurrentDateTime(),
                                    style: TextStyle(color: Color(0xFFa02e49)),
                                  ),
                                  Text('GRAND TOTAL:',
                                      style:
                                          TextStyle(color: Color(0xFFa02e49))),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Text(
                                        '₱${calculateTotalAmount(dataArray)}',
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
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 120,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Color(0xFFa02e49))),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PosPage(),
                                ),
                              );
                            },
                            child: Text('ADD ORDER')),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Color(0xFFa02e49))),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsPage(),
                                ),
                              );
                            },
                            child: Text('CONFIRM')),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

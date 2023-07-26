import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StockInsightsPage extends StatefulWidget {
  const StockInsightsPage({super.key});

  @override
  State<StockInsightsPage> createState() => _StockInsightsPageState();
}

class _StockInsightsPageState extends State<StockInsightsPage> {
  List<List<dynamic>> productDet = [];
  double averageBasketSize = 0.0;
  int total = 0;
  TextEditingController _inventoryPrice = TextEditingController();
  TextEditingController _inventoryCost = TextEditingController();
  TextEditingController _margin = TextEditingController();

  Color maincolor = Color(0xFFa02e49);
  DateTime today = DateTime.now();
  final dateFormat = DateFormat('dd MMMM - yyyy');
  List<String> _dropdownItems = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];
  String _selectedItem = 'DAILY';
  DateTime endDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day - 1,
    0, // hour value of 0 represents 12:00 AM
    0, // minute value of 0
    0, // second value of 0
    0, // millisecond value of 0
  );

  List<dynamic> productList = [];
  void getTotal() {
    setState(() {
      total = 0;
    });
    for (int i = 0; i < productList.length; i++) {
      List<dynamic> subList = productList[i];
      for (var item in subList) {
        setState(() {
          total += item['quantity'] as int;
        });
      }
    }
  }

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
      countOrders();
      getTotal();
    } else if (_selectedItem == 'WEEKLY') {
      DateTime lastWeek = today.subtract(Duration(days: 7));
      print(lastWeek);
      setState(() {
        endDate = lastWeek;
        _selectedItem = 'WEEKLY';
      });
      countOrders();
      getTotal();
    } else if (_selectedItem == 'MONTHLY') {
      DateTime lastMonth = DateTime(today.year, today.month - 1, today.day);
      print(lastMonth);
      setState(() {
        endDate = lastMonth;
        _selectedItem = 'MONTHLY';
        //
      });
      countOrders();
      getTotal();
    } else if (_selectedItem == 'YEARLY') {
      DateTime lastYear = DateTime(today.year - 1, today.month, today.day);
      print(lastYear);
      setState(() {
        endDate = lastYear;
        _selectedItem = 'YEARLY';
        //
      });
      countOrders();
      getTotal();
    }
  }

  String getStartDateText() {
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
        // endDate = yesterday;
        _selectedItem = 'DAILY';
        // countOrders();
      });
      return '${dateFormat.format(yesterday)}';
    } else if (_selectedItem == 'WEEKLY') {
      DateTime lastWeek = today.subtract(Duration(days: 7));
      print(lastWeek);
      setState(() {
        // endDate = lastWeek;
        _selectedItem = 'WEEKLY';
        // countOrders();
      });
      return '${dateFormat.format(lastWeek)}';
    } else if (_selectedItem == 'MONTHLY') {
      DateTime lastMonth = DateTime(today.year, today.month - 1, today.day);
      print(lastMonth);
      setState(() {
        // endDate = lastMonth;
        _selectedItem = 'MONTHLY';
        // countOrders();
      });

      return '${dateFormat.format(lastMonth)}';
    } else if (_selectedItem == 'YEARLY') {
      DateTime lastYear = DateTime(today.year - 1, today.month, today.day);
      print(lastYear);
      setState(() {
        // endDate = lastYear;
        _selectedItem = 'YEARLY';
        // countOrders();
      });
      return '${dateFormat.format(lastYear)}';
    } else {
      return 'Start Date';
    }
  }

  Future<void> countOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    int totalQuantity = 0;
    double totalCostProdSold = 0.0;
    double totalCost = 0.0;
    double totalRevenue = 0.0;
    double totalPrice = 0.0;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .where('status', isEqualTo: 'ready')
        .where('date', isGreaterThanOrEqualTo: endDate)
        .where('date', isLessThanOrEqualTo: today)
        .get();

    final data = querySnapshot.docs.map((doc) {
      final order = doc['order'] as List<dynamic>;
      // final productPrice = double.parse(doc['productPrice'].toString());
      // final productCost = double.parse(doc['productCost'].toString());
      // print('$productPrice,');
      return order;
    }).toList();

    setState(() {
      productList = [];
      if (mounted) {
        productList = data;
        productDet = data;
        // totalOrders = querySnapshot.size;
        // _totalOrders.text = querySnapshot.size.toString();
        int numBaskets = productDet.length;

        for (List<dynamic> basket in productDet) {
          double basketCost = 0.0;
          double basketRevenue = 0.0;
          for (dynamic product in basket) {
            if (product['quantity'] != null) {
              String productname = product['productName'];

              totalQuantity += (product['quantity'] as num).toInt();
              totalCostProdSold += (product['productCost'] as num).toDouble();
              totalPrice += (product['productPrice'] as num).toDouble() *
                  (product['quantity'] as num).toInt();

              int quantity = (product['quantity'] as num).toInt();
              double productCost = (product['productCost'] as num).toDouble();
              double productPrice = (product['productPrice'] as num).toDouble();
              double cost = quantity * productCost;
              double revenue = quantity * productPrice;

              double marginn = productPrice - productCost;

              basketCost += cost;
              basketRevenue += revenue;
            }
          }
          totalCost += basketCost;
          totalRevenue += basketRevenue;
        }

        _inventoryPrice.text = totalPrice.toString();

        _inventoryCost.text = totalCost.toString();
        double profit = totalRevenue - totalCost;
        double margin = ((totalRevenue - totalCost) / totalRevenue) * 100;

        print('totalQuantity: $totalQuantity');
        print('totalCostProdSold: $totalCostProdSold');
        averageBasketSize = totalQuantity / numBaskets;
        // _avgBasketSize.text = averageBasketSize.toStringAsFixed(2);
        // _totalProdSold.text = totalCostProdSold.toStringAsFixed(2);
        _margin.text = margin.toStringAsFixed(2);
        // _profit.text = profit.toStringAsFixed(2);
        // ranking = [
        //   {'class': 'Transaction Count', 'total': querySnapshot.size},
        //   {'class': 'Avg Basket Size', 'total': averageBasketSize},
        //   {'class': 'Cost of Product Sold', 'total': totalCostProdSold},
        //   {'class': 'Margin', 'total': margin},
        //   {'class': 'Expenses', 'total': double.parse(_totalExpenses.text)},
        //   {'class': 'Profit', 'total': profit},
        // ];
      }
      getTotal();
    });
  }

  @override
  void initState() {
    super.initState();
    countOrders();
  }

  @override
  Widget build(BuildContext context) {
    print('endDate: $endDate');
    print('productList: $productList');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: maincolor,
        title: Text('STOCK INSIGHTS'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _inventoryPrice,
                  // initialValue: '0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFFa02e49),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    // labelText: 'Text ${index + 1}',
                    label: Text('INVENTORY PRICE'),
                    labelStyle:
                        TextStyle(color: Color(0xFFa02e49), fontSize: 12),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
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
                  // initialValue: '0',
                  controller: _inventoryCost,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFFa02e49),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    // labelText: 'Text ${index + 1}',
                    label: Text('INVENTORY COST'),
                    labelStyle:
                        TextStyle(color: Color(0xFFa02e49), fontSize: 12),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
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
                  // initialValue: '0',
                  controller: _margin,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFFa02e49),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    // labelText: 'Text ${index + 1}',
                    label: Text('POTENTIAL SALES MARGIN'),
                    labelStyle:
                        TextStyle(color: Color(0xFFa02e49), fontSize: 12),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFa02e49), width: 2.0),
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
          Divider(thickness: 2, color: maincolor),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Color(0xFFa02e49))),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      width: 2, color: Color(0xFFa02e49)))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              getStartDateText(),
                              style: TextStyle(color: Color(0xFFa02e49)),
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
                        border: Border.all(width: 1, color: Color(0xFFa02e49)),
                        borderRadius: BorderRadius.circular(50)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
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
                                  fontSize: 12, color: Color(0xFFa02e49)),
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
            children: [
              Text(
                'TOP MOVING PRODUCTS',
                style: TextStyle(color: maincolor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            decoration:
                BoxDecoration(border: Border.all(color: maincolor, width: 1)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Text(
                            'PRODUCT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: maincolor,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.17,
                        child: Text(
                          'QTY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: maincolor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.17,
                        child: Text(
                          'PRICE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: maincolor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.17,
                        child: Text(
                          'COST',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: maincolor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.17,
                        child: Text(
                          'MARGIN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: maincolor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 2,
                    color: maincolor,
                  ),
                  SingleChildScrollView(
                      child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: ListView.builder(
                        itemCount: productList.length,
                        itemBuilder: (context, index) {
                          List<dynamic> subList = productList[index];

                          return Column(
                            children: [
                              for (var item in subList)
                                Row(
                                  children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        height: 20,
                                        child: FittedBox(
                                          child: Text(
                                            '${item['productName']}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: maincolor,
                                            ),
                                          ),
                                        )),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.17,
                                      child: Text(
                                        '${item['quantity']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: maincolor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.17,
                                      child: Text(
                                        '${item['productPrice']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: maincolor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.17,
                                      child: Text(
                                        '${item['productCost']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: maincolor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.17,
                                      child: Text(
                                        '${item['productPrice'] - item['productCost']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: maincolor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        }),
                  )),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Text(
                    '   TOTAL',
                    style: TextStyle(
                        color: maincolor, fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Text(
                    '$total',
                    style: TextStyle(
                        color: maincolor, fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      child: Text(
                        'GROSS MARGIN: ${_margin.text}',
                        style: TextStyle(
                            color: maincolor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        'NET MARGIN: ${_margin.text}',
                        style: TextStyle(
                            color: maincolor, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ]),
      )),
    );
  }
}

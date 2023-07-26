import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:d_chart/d_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:user/pages/salessummary.dart';
import 'package:user/pages/stockinsights.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<String> _dropdownItems = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];
  String _selectedItem = 'DAILY';
  int totalOrders = 0;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _totalOrders = TextEditingController();
  TextEditingController _avgBasketSize = TextEditingController();
  TextEditingController _totalProdSold = TextEditingController();
  TextEditingController _margin = TextEditingController();
  TextEditingController _totalExpenses = TextEditingController(text: '0.0');
  TextEditingController _profit = TextEditingController();

  TextEditingController _receiverEmail = TextEditingController();
  double averageBasketSize = 0.0;
  double costProductSold = 0.0;

  List<List<dynamic>> productDet = [];
  List<DChartBarDataCustom> chartData = [];
  List ranking = [
    {'class': 'Transaction Count', 'total': 0},
    {'class': 'Avg Basket Size', 'total': 0},
    {'class': 'Cost of Product Sold', 'total': 0},
    {'class': 'Margin', 'total': 0},
    {'class': 'Expenses', 'total': 0},
    {'class': 'Profit', 'total': 0},
  ];
  Future<void> _loadChartData() async {
    // Simulate loading data (replace this with your actual data fetching).
    await Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          chartData = List.generate(ranking.length, (index) {
            Color currentColor =
                Color((Random().nextDouble() * 0xFFFFFF).toInt());
            return DChartBarDataCustom(
              onTap: () {
                print(
                  '${ranking[index]['class']} => ${ranking[index]['total']}',
                );
              },
              value: ranking[index]['total'].toDouble(),
              label: ranking[index]['class'],
              color: currentColor.withOpacity(1),
            );
          });
        });
      }
    });
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
        .get();
    final data = querySnapshot.docs.map((doc) {
      final order = doc['order'] as List<dynamic>;
      // final productPrice = double.parse(doc['productPrice'].toString());
      // final productCost = double.parse(doc['productCost'].toString());
      // print('$productPrice,');
      return order;
    }).toList();

    double totalExpenses = 0.0;

    final expensessnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    final expensesdata = expensessnapshot.docs.map((doc) {
      final amount = double.parse(doc['amount'].toString());
      totalExpenses += amount;
    }).toList();
    if (mounted) {
      setState(() {
        productDet = data;
        totalOrders = querySnapshot.size;
        _totalOrders.text = querySnapshot.size.toString();
        int numBaskets = productDet.length;

        for (List<dynamic> basket in productDet) {
          double basketCost = 0.0;
          double basketRevenue = 0.0;
          for (dynamic product in basket) {
            if (product['quantity'] != null) {
              totalQuantity += (product['quantity'] as num).toInt();
              totalCostProdSold += (product['productCost'] as num).toDouble() *
                  (product['quantity'] as num).toInt();
              totalPrice += (product['productPrice'] as num).toDouble();

              int quantity = (product['quantity'] as num).toInt();
              double productCost = (product['productCost'] as num).toDouble();
              double productPrice = (product['productPrice'] as num).toDouble();
              double cost = quantity * productCost;
              double revenue = quantity * productPrice;

              basketCost += cost;
              basketRevenue += revenue;
            }
          }
          totalCost += basketCost;
          totalRevenue += basketRevenue;
        }
        double profit = totalRevenue - totalCost;
        double margin = ((totalRevenue - totalCost) / totalRevenue) * 100;

        print('totalQuantity: $totalQuantity');
        print('totalCostProdSold: $totalCostProdSold');
        averageBasketSize = totalQuantity / numBaskets;
        _avgBasketSize.text = averageBasketSize.toStringAsFixed(2);
        _totalProdSold.text = totalCostProdSold.toStringAsFixed(2);
        _margin.text = margin.toStringAsFixed(2);
        _profit.text = profit.toStringAsFixed(2);
        ranking = [
          {'class': 'Transaction Count', 'total': querySnapshot.size},
          {'class': 'Avg Basket Size', 'total': averageBasketSize},
          {'class': 'Cost of Product Sold', 'total': totalCostProdSold},
          {'class': 'Margin', 'total': margin},
          {'class': 'Expenses', 'total': totalExpenses},
          {'class': 'Profit', 'total': profit},
        ];
      });
    }
  }

  // void _AvgBasketSize() {
  //   int totalQuantity = 0;
  //   int numBaskets = productDet.length;

  //   for (List<dynamic> basket in productDet) {
  //     for (dynamic product in basket) {
  //       if (product['quantity'] != null) {
  //         totalQuantity += (product['quantity'] as num).toInt();
  //       }
  //     }
  //   }
  //   print(totalQuantity);
  //   setState(() {
  //     averageBasketSize = totalQuantity / numBaskets;
  //   });
  // }

  Future<void> totalExpenses() async {
    double totalAmount = 0.0;
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    final data = snapshot.docs.map((doc) {
      final amount = double.parse(doc['amount'].toString());
      totalAmount += amount;
    }).toList();
    if (mounted) {
      setState(() {
        _totalExpenses.text = totalAmount.toStringAsFixed(2);
      });
    }
  }

  void sendEmailWithAttachment(List<List<dynamic>> data) async {
    final csvData = ListToCsvConverter().convert(data);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.csv');
    await file.writeAsString(csvData);

    final Email email = Email(
      body: 'Sales Report.',
      subject: 'Sales Performance',
      recipients: [_receiverEmail.text],
      attachmentPaths: [file.path],
    );

    await FlutterEmailSender.send(email);
  }

  @override
  void initState() {
    super.initState();

    countOrders();
    totalExpenses();
    _loadChartData();
    // _AvgBasketSize();
  }

  @override
  void dispose() {
    // Cancel any ongoing asynchronous operations here, if necessary.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('totalOrders: $totalOrders');
    print('productDet: $productDet');
    print('averageBasketSize: $averageBasketSize');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa02e49),
        title: Text('REPORTS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalOrders,
                      enabled: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFa02e49),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        // labelText: 'Text ${index + 1}',
                        label: Text('Transaction Count'),
                        labelStyle:
                            TextStyle(color: Color(0xFFa02e49), fontSize: 12),
                        border: OutlineInputBorder(),

                        disabledBorder: OutlineInputBorder(
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      // initialValue: '0',
                      controller: _avgBasketSize,
                      enabled: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFa02e49),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        // labelText: 'Text ${index + 1}',
                        label: Text('AVG Basket Size'),
                        labelStyle:
                            TextStyle(color: Color(0xFFa02e49), fontSize: 12),
                        border: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      // initialValue: '0',
                      controller: _totalProdSold,
                      enabled: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFa02e49),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        // labelText: 'Text ${index + 1}',
                        label: Text('Cost of Product Sold'),
                        labelStyle:
                            TextStyle(color: Color(0xFFa02e49), fontSize: 12),
                        border: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      // initialValue: '0',
                      controller: _margin,
                      enabled: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFa02e49),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        // labelText: 'Text ${index + 1}',
                        label: Text('MARGIN'),
                        labelStyle:
                            TextStyle(color: Color(0xFFa02e49), fontSize: 12),
                        border: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _totalExpenses,
                      // initialValue: '0',
                      enabled: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFa02e49),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        // labelText: 'Text ${index + 1}',
                        label: Text('Expenses'),
                        labelStyle:
                            TextStyle(color: Color(0xFFa02e49), fontSize: 12),
                        border: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      // initialValue: '0',
                      controller: _profit,
                      enabled: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFa02e49),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        // labelText: 'Text ${index + 1}',
                        label: Text('Profit'),
                        labelStyle:
                            TextStyle(color: Color(0xFFa02e49), fontSize: 12),
                        border: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      child: Text(
                        'SALES PERFORMANCE',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFa02e49)),
                      ),
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
                                if (mounted) {
                                  setState(() {
                                    _selectedItem = newValue!;
                                  });
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                    color: Color(0xFFa02e49).withOpacity(0.2),
                    border: Border.all(width: 2, color: Color(0xFFa02e49))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: chartData.isNotEmpty
                      ? AspectRatio(
                          aspectRatio: 16 / 9,
                          child: DChartBarCustom(
                            showLoading: chartData
                                .isEmpty, // Show loading when chartData is empty.
                            valueAlign: Alignment.topCenter,
                            showDomainLine: true,
                            showDomainLabel: true,
                            showMeasureLine: true,
                            showMeasureLabel: true,
                            spaceDomainLabeltoChart: 10,
                            spaceMeasureLabeltoChart: 5,
                            spaceDomainLinetoChart: 15,
                            spaceMeasureLinetoChart: 20,
                            spaceBetweenItem: 16,
                            measureLabelStyle: TextStyle(
                                fontSize: 9,
                                color: Color(0xFFa02e49),
                                fontWeight: FontWeight.bold),
                            domainLabelStyle: TextStyle(
                                fontSize: 9,
                                color: Color(0xFFa02e49),
                                fontWeight: FontWeight.bold),
                            // Rest of your DChartBarCustom properties...
                            listData: chartData,
                          ),
                        )
                      : SizedBox(),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFFa02e49))),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StockInsightsPage(),
                            ),
                          );
                        },
                        child: Text('STOCKS INSIGHTS')),
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SalesSummaryPage(),
                            ),
                          );
                        },
                        child: Text('SALES SUMMARY')),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFFa02e49))),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Center(
                                child: Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'SALES REPORT',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFa02e49)),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 40,
                                                  child: TextFormField(
                                                    controller: _receiverEmail,
                                                    // key: _keyList[index],
                                                    // initialValue: '${_textFields1[index]}',

                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFa02e49)),
                                                    decoration: InputDecoration(
                                                      // labelText: 'Text ${index + 1}',
                                                      label:
                                                          Text('Enter Email'),
                                                      labelStyle: TextStyle(
                                                          color: Color(
                                                              0xFFa02e49)),

                                                      border:
                                                          OutlineInputBorder(),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFa02e49),
                                                            width: 2.0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFa02e49),
                                                            width: 2.0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFa02e49),
                                                            width: 2.0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFa02e49),
                                                            width: 2.0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.0),
                                                      ),
                                                    ),
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return 'Please enter a value';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(Color(
                                                                0xFFa02e49)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('CANCEL')),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(Color(
                                                                0xFFa02e49)),
                                                  ),
                                                  onPressed: () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      List<List<dynamic>> data =
                                                          [
                                                        [
                                                          'Transaction Count',
                                                          _totalOrders.text
                                                        ],
                                                        [
                                                          'Avg Basket Size',
                                                          _avgBasketSize.text
                                                        ],
                                                        [
                                                          'Cost of Product Sold',
                                                          _totalProdSold.text
                                                        ],
                                                        [
                                                          'Margin',
                                                          _margin.text
                                                        ],
                                                        [
                                                          'Expenses',
                                                          _totalExpenses.text
                                                        ],
                                                        [
                                                          'Profit',
                                                          _profit.text
                                                        ],
                                                      ];

                                                      sendEmailWithAttachment(
                                                          data);
                                                    }

                                                    // Navigator.of(context).pop();
                                                  },
                                                  child: Text('EXPORT')),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Text('EXPORT REPORT')),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

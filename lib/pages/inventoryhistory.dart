import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryHistoryPage extends StatefulWidget {
  const InventoryHistoryPage({super.key});

  @override
  State<InventoryHistoryPage> createState() => _InventoryHistoryPageState();
}

class _InventoryHistoryPageState extends State<InventoryHistoryPage> {
  Color maincolor = Color(0xFFa02e49);
  // List<dynamic> salesSummary = [];

  List<List<dynamic>> inventoryHistory = [];
  String search = '';
  double totalSales = 0.0;
  double totalProfit = 0.0;
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
      fetchData();
    } else if (_selectedItem == 'WEEKLY') {
      DateTime lastWeek = today.subtract(Duration(days: 7));
      print(lastWeek);
      setState(() {
        endDate = lastWeek;
        _selectedItem = 'WEEKLY';
      });
      fetchData();
    } else if (_selectedItem == 'MONTHLY') {
      DateTime lastMonth = DateTime(today.year, today.month - 1, today.day);
      print(lastMonth);
      setState(() {
        endDate = lastMonth;
        _selectedItem = 'MONTHLY';
        //
      });
      fetchData();
    } else if (_selectedItem == 'YEARLY') {
      DateTime lastYear = DateTime(today.year - 1, today.month, today.day);
      print(lastYear);
      setState(() {
        endDate = lastYear;
        _selectedItem = 'YEARLY';
        //
      });
      fetchData();
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

  Future<void> fetchData() async {
    List<List<dynamic>> inventory = [];
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final orderSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('inventoryHistory')
        .where('date', isGreaterThanOrEqualTo: endDate)
        .where('date', isLessThanOrEqualTo: today)
        .orderBy('date', descending: true)
        .get();

    inventory = orderSnapshot.docs.map((doc) {
      final date = doc['date'] as Timestamp;
      final inventoryname = doc['inventoryName'] as String;
      final inventorycost = double.parse(doc['inventoryCost'].toString());
      final inventorystocks = doc['inventoryStocks'] as int;
      return [
        date,
        inventoryname,
        inventorycost,
        inventorystocks,
      ];
    }).toList();

    setState(() {
      // ordersList = orderSnapshot.docs.map((doc) => doc['order']).toList();
      inventoryHistory = inventory;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    print('inventoryHistory: $inventoryHistory');
    List<List<dynamic>> filteredMenu = search.isNotEmpty
        ? inventoryHistory.where((item) => item[1].contains(search)).toList()
        : inventoryHistory;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: maincolor,
        title: Text('INVENTORY HISTORY'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
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
                ),
              ],
            ),
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
                          border:
                              Border.all(width: 1, color: Color(0xFFa02e49)),
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
                            'DATE',
                            style: TextStyle(
                                color: Color(0xFFa02e49),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Text(
                            'INVENTORY NAME',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFa02e49),
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Text(
                            'COST',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFa02e49),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Text(
                            'ADDED STOCK #',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFa02e49),
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
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
                          DateTime timestamp =
                              (filteredMenu[index][0] as Timestamp).toDate();
                          String formattedDate =
                              DateFormat('MMMM d, y').format(timestamp);
                          String Name = filteredMenu[index][1];
                          double Cost =
                              double.parse(filteredMenu[index][2].toString());
                          int Stocks = filteredMenu[index][3];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      child: FittedBox(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: maincolor,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '$formattedDate',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      )),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: Text(
                                        '$Name',
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(color: Color(0xFFa02e49)),
                                      )),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: Text(
                                        '${Cost.toStringAsFixed(2)}',
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(color: Color(0xFFa02e49)),
                                      )),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: Text(
                                        '$Stocks',
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(color: Color(0xFFa02e49)),
                                      )),
                                ],
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
          ]),
        ),
      ),
    );
  }
}

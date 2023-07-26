import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensesReport extends StatefulWidget {
  const ExpensesReport({super.key});

  @override
  State<ExpensesReport> createState() => _ExpensesReportState();
}

class _ExpensesReportState extends State<ExpensesReport> {
  String _selectedItem = 'DAILY';
  double grandtotal = 0.0;
  int totalentry = 0;
  bool empty = false;
  DateTime today = DateTime.now();
  final dateFormat = DateFormat('dd MMMM - yyyy');
  List<String> _dropdownItems = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];

  String getStartDateText() {
    if (_selectedItem == 'DAILY') {
      DateTime yesterday = today.subtract(Duration(days: 1));
      print(yesterday);
      setState(() {
        totalentry = 0;
        _selectedItem = 'DAILY';
        containsdate = [];
      });
      return '${dateFormat.format(yesterday)}';
    } else if (_selectedItem == 'WEEKLY') {
      DateTime lastWeek = today.subtract(Duration(days: 7));
      print(lastWeek);
      setState(() {
        totalentry = 0;
        _selectedItem = 'WEEKLY';
        containsdate = [];
      });
      return '${dateFormat.format(lastWeek)}';
    } else if (_selectedItem == 'MONTHLY') {
      DateTime lastMonth = DateTime(today.year, today.month - 1, today.day);
      print(lastMonth);
      setState(() {
        totalentry = 0;
        _selectedItem = 'MONTHLY';
        containsdate = [];
      });

      return '${dateFormat.format(lastMonth)}';
    } else if (_selectedItem == 'YEARLY') {
      DateTime lastYear = DateTime(today.year - 1, today.month, today.day);
      print(lastYear);
      setState(() {
        totalentry = 0;
        _selectedItem = 'YEARLY';
        containsdate = [];
      });
      return '${dateFormat.format(lastYear)}';
    } else {
      return 'Start Date';
    }
  }

  List<List<dynamic>> filteredExpenses = [];
  List<dynamic> containsdate = [];

  Map<String, List<dynamic>> filteredExpensesMap = {};
  List<List<dynamic>> expenses = [
    // ['GAasdasdhaskhdjkshdjsahdjS', '2023-06-02 00:00:00.000', 1000.0],
    // ['GAS', '2023-06-09 00:00:00.000', 1000.0],
    // ['GAS', '2023-06-02 00:00:00.000', 1000.0],
    // ['GAS', '2023-05-19 00:00:00.000', 1000.0],
    // ['GAS', '2023-05-18 00:00:00.000', 1000.0],
    // ['GAS', '2023-05-17 00:00:00.000', 1000.0],
    // ['GAS', '2023-05-17 00:00:00.000', 1000.0],
    // ['GAS', '2023-05-20 00:00:00.000', 1000.0],
  ];

  List<List<dynamic>> getFilteredExpenses() {
    Map<String, List<dynamic>> filteredExpensesMap = {};

    if (_selectedItem == 'DAILY') {
      filteredExpensesMap = groupExpensesByDate(
        expenses,
        DateTime.now().subtract(Duration(days: 1)),
        DateTime.now().add(Duration(days: 1)),
      );
    } else if (_selectedItem == 'WEEKLY') {
      filteredExpensesMap = groupExpensesByDate(
        expenses,
        DateTime.now().subtract(Duration(days: 7)),
        DateTime.now().add(Duration(days: 1)),
      );
    } else if (_selectedItem == 'MONTHLY') {
      filteredExpensesMap = groupExpensesByDate(
        expenses,
        DateTime.now().subtract(Duration(days: 30)),
        DateTime.now().add(Duration(days: 1)),
      );
    } else if (_selectedItem == 'YEARLY') {
      filteredExpensesMap = groupExpensesByDate(
        expenses,
        DateTime.now().subtract(Duration(days: 365)),
        DateTime.now().add(Duration(days: 1)),
      );
    }

    List<List<dynamic>> filteredExpenses =
        filteredExpensesMap.values.toList().cast<List<dynamic>>();
    print('filteredExpenses: $filteredExpenses');
    return filteredExpenses;
  }

  Map<String, List<dynamic>> groupExpensesByDate(
      List<List<dynamic>> expenses, DateTime startDate, DateTime endDate) {
    Map<String, List<dynamic>> filteredExpensesMap = {};

    for (List<dynamic> expense in expenses) {
      DateTime expenseDate = DateTime.parse(expense[1]);

      if (expenseDate.isAfter(startDate) && expenseDate.isBefore(endDate)) {
        String date = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(expenseDate);
        int totalEntry = 1;
        double totalAmount = expense[2];

        if (filteredExpensesMap.containsKey(date)) {
          List<dynamic> existingEntry = filteredExpensesMap[date]!;
          totalEntry += existingEntry[1] as int; // Cast to int
          totalAmount += existingEntry[2] as double; // Cast to double
        }

        filteredExpensesMap[date] = [date, totalEntry, totalAmount];
      }
    }

    return filteredExpensesMap;
  }

  Future<void> fetchMenuData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        empty = true;
      });
    }

    final data = snapshot.docs.map((doc) {
      final details = doc['details'] as String;
      final amount = doc['amount'] as double;
      final date = doc['date'] as Timestamp;
      final formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(date.toDate());

      return [details, formattedDate, amount];
    }).toList();

    setState(() {
      expenses = data;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMenuData();
  }

  @override
  Widget build(BuildContext context) {
    print(expenses);
    grandtotal = 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa02e49),
        title: Text('EXPENSES REPORT'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          border:
                              Border.all(width: 2, color: Color(0xFFa02e49))),
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
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text(
                        'DATE',
                        style: TextStyle(
                            color: Color(0xFFa02e49),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text('ENTRY',
                          style: TextStyle(
                              color: Color(0xFFa02e49),
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center)),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text('AMOUNT',
                          style: TextStyle(
                              color: Color(0xFFa02e49),
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center))
                ],
              ),
              Divider(
                thickness: 2,
                color: Color(0xFFa02e49),
              ),
              // Row(
              //   children: [
              //     SizedBox(
              //         width: MediaQuery.of(context).size.width * 0.3,
              //         child: Text(
              //           'DATE',
              //           style: TextStyle(
              //             color: Color(0xFFa02e49),
              //           ),
              //           textAlign: TextAlign.center,
              //         )),
              //     SizedBox(
              //         width: MediaQuery.of(context).size.width * 0.3,
              //         child: Text('ENTRY',
              //             style: TextStyle(
              //               color: Color(0xFFa02e49),
              //             ),
              //             textAlign: TextAlign.center)),
              //     SizedBox(
              //         width: MediaQuery.of(context).size.width * 0.3,
              //         child: Text('AMOUNT',
              //             style: TextStyle(
              //               color: Color(0xFFa02e49),
              //             ),
              //             textAlign: TextAlign.center))
              //   ],
              // ),
              SizedBox(
                height: 500,
                child: ListView.builder(
                    itemCount: getFilteredExpenses().length,
                    itemBuilder: (context, index) {
                      List<dynamic> expense = getFilteredExpenses()[index];
                      String date = expense[0];
                      int entry = expense[1];
                      double totalamount = expense[2];
                      totalentry += entry;
                      grandtotal += totalamount;

                      return Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Text(
                                    DateFormat('MMMM dd, yyyy')
                                        .format(DateTime.parse(date)),
                                    style: TextStyle(
                                      color: Color(0xFFa02e49),
                                    ),
                                    textAlign: TextAlign.center,
                                  )),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Text('$entry',
                                      style: TextStyle(
                                        color: Color(0xFFa02e49),
                                      ),
                                      textAlign: TextAlign.center)),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Text('₱$totalamount',
                                      style: TextStyle(
                                        color: Color(0xFFa02e49),
                                      ),
                                      textAlign: TextAlign.center))
                            ],
                          ),
                          if (index + 1 == getFilteredExpenses().length)
                            Column(
                              children: [
                                Divider(
                                  thickness: 2,
                                  color: Color(0xFFa02e49),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Text(
                                          'OVERALL ENTRIES',
                                          style: TextStyle(
                                              color: Color(0xFFa02e49),
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        )),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Text('$totalentry',
                                            style: TextStyle(
                                                color: Color(0xFFa02e49),
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center)),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Text('₱$grandtotal',
                                            style: TextStyle(
                                                color: Color(0xFFa02e49),
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center))
                                  ],
                                )
                              ],
                            )
                        ],
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

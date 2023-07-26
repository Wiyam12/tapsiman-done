import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InventoryDetailsPage extends StatefulWidget {
  const InventoryDetailsPage({super.key, required this.productGroup});

  final String productGroup;

  @override
  State<InventoryDetailsPage> createState() => _InventoryDetailsPageState();
}

class _InventoryDetailsPageState extends State<InventoryDetailsPage> {
  String stocksRadio = 'ADD';
  bool empty = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _costController = TextEditingController();
  TextEditingController _stocksController = TextEditingController();
  TextEditingController _currentStocksController = TextEditingController();
  List<List<dynamic>> menu = [];
  String search = '';
  // filtermenu(String? search) {
  //   String productGroup = widget.productGroup;
  //   setState(() {
  //     List<List<dynamic>> filteredMenu = menu
  //         .where((item) => (item[1] == productGroup && item[0] == search))
  //         .toList();
  //   });
  // }
  Future<void> getProductData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('products')
        .where('productGroup', isEqualTo: widget.productGroup)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.map((doc) {
        final productId = doc.id;
        final imageUrl = doc['imageUrl'] as String;
        final productName = doc['productName'] as String;
        final productPrice = doc['productPrice'] as double;
        final productGroup = doc['productGroup'] as String;
        final productCost = double.parse(doc['productCost'].toString());
        final productStocks = doc['productStocks'] as int;
        return [
          productName,
          productGroup,
          productCost,
          productStocks,
          imageUrl,
          productPrice,
          productId
        ];
      }).toList();

      setState(() {
        menu = data;
      });
    } else {
      setState(() {
        empty = true;
      });
    }
  }

  Future<void> update(String itemName, String productid, stockType) async {
    DateTime today = DateTime.now();
    print(productid);
    print(stockType);

    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    if (stockType == 'ADD') {
      try {
        DocumentReference orderRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('products')
            .doc(productid);
        await orderRef.update({
          'productPrice': double.parse(_priceController.text),
          'productCost': double.parse(_costController.text),
          'productStocks':
              FieldValue.increment(int.parse(_stocksController.text)),
        });

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Product Updated Successfully!"),
          ),
        );

        getProductData();
      } catch (e) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Must have whole number!"),
          ),
        );
      }
    } else {
      try {
        DocumentReference orderRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('products')
            .doc(productid);
        await orderRef.update({
          'productPrice': double.parse(_priceController.text),
          'productCost': double.parse(_costController.text),
          'productStocks':
              FieldValue.increment(-int.parse(_stocksController.text)),
        });
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Product Updated Successfully!"),
          ),
        );
        getProductData();
      } catch (e) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Must have whole number!"),
          ),
        );
      }
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('inventoryHistory')
        .add({
      'date': today,
      'inventoryName': itemName,
      'inventoryCost': double.parse(_costController.text),
      'inventoryStocks': int.parse(_stocksController.text),
    });
    // // Get a reference to the specific order document

    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => ProductPage(),
    //   ),
    // );

    // Update the 'status' field of the order document
  }

  @override
  void initState() {
    super.initState();
    getProductData();
  }

  @override
  Widget build(BuildContext context) {
    print(menu);
    String productGroup = widget.productGroup;
    List<List<dynamic>> filteredMenu = menu
        .where((item) => search == ''
            ? item[1] == productGroup
            : (item[1] == productGroup && item[0].contains(search)))
        .toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa02e49),
        title: Text('$productGroup'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                      prefixIcon: Icon(Icons.search, color: Color(0xFFa02e49)),
                      prefixIconConstraints: BoxConstraints(minWidth: 40),
                    ),
                    onChanged: (value) {
                      setState(() {
                        search = value.toUpperCase();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Text(
                      'INVENTORY NAME',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFa02e49),
                          fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Text(
                      'COST',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFa02e49),
                          fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Text(
                      'STOCK#',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFa02e49),
                          fontWeight: FontWeight.bold),
                    )),
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                )
              ],
            ),
            Divider(
              thickness: 1,
              color: Color(0xFFa02e49),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: ClampingScrollPhysics(),
                itemCount: filteredMenu.length,
                itemBuilder: (context, index) {
                  String itemName = filteredMenu[index][0];
                  double cost = double.parse(filteredMenu[index][2].toString());
                  double stocks =
                      double.parse(filteredMenu[index][3].toString());
                  double price =
                      double.parse(filteredMenu[index][5].toString());
                  String productId = filteredMenu[index][6];

                  return Row(
                    children: <Widget>[
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Text(
                            '$itemName',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFa02e49),
                                fontWeight: FontWeight.bold),
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Text(
                            '${cost.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFa02e49),
                                fontWeight: FontWeight.bold),
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Text(
                            '${stocks.toInt()}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFa02e49),
                                fontWeight: FontWeight.bold),
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: IconButton(
                              onPressed: () {
                                _priceController.text =
                                    filteredMenu[index][5].toString();
                                _costController.text = cost.toString();
                                // _stocksController.text = stocks.toString();
                                _currentStocksController.text =
                                    stocks.toString();

                                showModalBottomSheet(
                                    context: context,
                                    builder: ((context) {
                                      return StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.4,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SingleChildScrollView(
                                                child: Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        '$itemName',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFFa02e49),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                      Divider(
                                                        thickness: 2,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'PRODCUCT PRICING AND COSTING DATABASE',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFFa02e49),
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
                                                            child: SizedBox(
                                                              height: 40,
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    _priceController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                // key: _keyList[index],

                                                                onChanged:
                                                                    (value) {
                                                                  // setState(() {
                                                                  //   _textFields1[index] = value;
                                                                  // });
                                                                },
                                                                decoration:
                                                                    InputDecoration(
                                                                  // labelText: 'Text ${index + 1}',
                                                                  label: Text(
                                                                      'PRICE'),
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Color(0xFFa02e49)),
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedErrorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                ),
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter a value';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child: SizedBox(
                                                              height: 40,
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    _costController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                // key: _keyList[index],

                                                                onChanged:
                                                                    (value) {
                                                                  // setState(() {
                                                                  //   _textFields1[index] = value;
                                                                  // });
                                                                },
                                                                decoration:
                                                                    InputDecoration(
                                                                  // labelText: 'Text ${index + 1}',
                                                                  label: Text(
                                                                      'COST'),
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Color(0xFFa02e49)),
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedErrorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                ),
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter a value';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'CURRENT STOCKS',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFFa02e49)),
                                                          ),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 21,
                                                                child: Radio(
                                                                    fillColor: MaterialStateProperty.resolveWith<
                                                                        Color>((Set<
                                                                            MaterialState>
                                                                        states) {
                                                                      if (states
                                                                          .contains(
                                                                              MaterialState.disabled)) {
                                                                        return Color(
                                                                            0xFFa02e49);
                                                                      }
                                                                      return Color(
                                                                          0xFFa02e49);
                                                                    }),
                                                                    value:
                                                                        'ADD',
                                                                    groupValue:
                                                                        stocksRadio,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        stocksRadio =
                                                                            value!;
                                                                      });
                                                                    }),
                                                              ),
                                                              Text('ADD'),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              SizedBox(
                                                                width: 21,
                                                                child: Radio(
                                                                    fillColor: MaterialStateProperty.resolveWith<
                                                                            Color>(
                                                                        (Set<MaterialState>
                                                                            states) {
                                                                      if (states
                                                                          .contains(
                                                                              MaterialState.disabled)) {
                                                                        return Color(
                                                                            0xFFa02e49);
                                                                      }
                                                                      return Color(
                                                                          0xFFa02e49);
                                                                    }),
                                                                    value:
                                                                        'REMOVE',
                                                                    groupValue:
                                                                        stocksRadio,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        stocksRadio =
                                                                            value!;
                                                                      });
                                                                    }),
                                                              ),
                                                              Text(
                                                                'REMOVE',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFFa02e49),
                                                                    fontSize:
                                                                        12),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                              height: 40,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.3,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      width: 2,
                                                                      color: Color(
                                                                          0xFFa02e49)),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: Center(
                                                                child: Text(
                                                                  _currentStocksController
                                                                      .text,
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xFFa02e49),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              )
                                                              //     TextFormField(
                                                              //   controller:
                                                              //       _currentStocksController,
                                                              //   enabled: false,
                                                              //   style: TextStyle(
                                                              //       color: Color(
                                                              //           0xFFa02e49),

                                                              //       ),
                                                              //   decoration:
                                                              //       InputDecoration(
                                                              //     // labelText: 'Text ${index + 1}',

                                                              //     border:
                                                              //         OutlineInputBorder(),

                                                              //     disabledBorder:
                                                              //         OutlineInputBorder(
                                                              //       borderSide: BorderSide(
                                                              //           color: Color(
                                                              //               0xFFa02e49),
                                                              //           width:
                                                              //               2.0),
                                                              //       borderRadius:
                                                              //           BorderRadius
                                                              //               .circular(
                                                              //                   10.0),
                                                              //     ),
                                                              //   ),
                                                              // ),
                                                              ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Expanded(
                                                            child: SizedBox(
                                                              height: 40,
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    _stocksController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                // key: _keyList[index],

                                                                onChanged:
                                                                    (value) {
                                                                  // setState(() {
                                                                  //   _textFields1[index] = value;
                                                                  // });
                                                                },
                                                                decoration:
                                                                    InputDecoration(
                                                                  // labelText: 'Text ${index + 1}',

                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedErrorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFFa02e49),
                                                                        width:
                                                                            2.0),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                ),
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter a value';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          ElevatedButton(
                                                              style: ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all<
                                                                              Color>(
                                                                          Color(
                                                                              0xFFa02e49))),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                // if (_formKeyNotes.currentState!
                                                                //     .validate()) {
                                                                //   print(_textFieldsNotes);

                                                                //   setState(() {
                                                                //     NoteList = _textFieldsNotes;
                                                                //     showNotes = false;
                                                                //   });
                                                                //   checkNoteList();
                                                                //   print(NoteList);
                                                                // }
                                                              },
                                                              child: Text(
                                                                  'CANCEL')),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          ElevatedButton(
                                                              style: ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStateProperty.all<
                                                                              Color>(
                                                                          Color(
                                                                              0xFFa02e49))),
                                                              onPressed: () {
                                                                update(
                                                                    itemName,
                                                                    productId,
                                                                    stocksRadio);
                                                                // if (_formKeyNotes.currentState!
                                                                //     .validate()) {
                                                                //   print(_textFieldsNotes);

                                                                //   setState(() {
                                                                //     NoteList = _textFieldsNotes;
                                                                //     showNotes = false;
                                                                //   });
                                                                //   checkNoteList();
                                                                //   print(NoteList);
                                                                // }
                                                              },
                                                              child: Text(
                                                                  '$stocksRadio')),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    }));
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Color(0xFFa02e49),
                              )))
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}

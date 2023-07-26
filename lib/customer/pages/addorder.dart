import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/customer/pages/cart.dart';
import 'package:user/customer/pages/home.dart';

import '../components/addcartanimation.dart';

class AddOrder extends StatefulWidget {
  const AddOrder({super.key, required this.productId, required this.type});
  final String productId;
  final String type;

  @override
  State<AddOrder> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AddOrder> {
  // final _orders = Hive.box('_customerOrders');
  String? mystoreId;
  String? productName;
  double? productPrice;
  int? productStocks;
  String? productId;
  double? productCost;
  bool favorite = false;
  String? imgProduct;
  bool isNotAvailable = false;
  String? productGroup;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _noteController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  // List<String> buttonLabels = [
  //   'Egg',
  //   'Tapa',
  //   'Rice',
  // ];

  int quantity = 1;

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> fetchProductData() async {
    final prefs = await SharedPreferences.getInstance();
    String storeId = prefs.getString('storeId') ?? '';
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    setState(() {
      mystoreId = storeId;
    });
    CollectionReference favoriteCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorite');

    QuerySnapshot favquerySnapshot = await favoriteCollectionRef
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();
    bool favExists = favquerySnapshot.docs.isNotEmpty;

    setState(() {
      favorite = favExists;
    });

    final productDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(storeId)
        .collection('products')
        .doc(widget.productId)
        .get();

    if (productDoc.exists) {
      setState(() {
        isNotAvailable = productDoc['isNotAvailable'] as bool;
        imgProduct = productDoc['imageUrl'] as String;
        productStocks = productDoc['productStocks'] as int;
        productName = productDoc['productName'] as String;
        productPrice = double.parse(productDoc['productPrice'].toString());
        productCost = double.parse(productDoc['productCost'].toString());
        productGroup = productDoc['productGroup'] as String;
      });
    }
  }

  Future<void> _addOrder(Map<String, dynamic> newItem) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    if (widget.type == 'add') {
      DocumentReference cartDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc();
      await cartDocRef.set(newItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to Cart Successfully!'),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomePageCustomer(),
        ),
      );
    } else {
      DocumentReference orderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(widget.type);
      await orderRef
          .update({'quantity': quantity, 'note': _noteController.text});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated Cart Order Successfully!'),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CartPage(),
        ),
      );
    }

    // await _orders.add(newItem);
    // final data = _orders.keys.map((key) {
    //   final item = _orders.get(key);
    //   return {
    // "productId": productId,
    // "productName": item["productName"],
    // "productPrice": item['productPrice'],
    // "quantity": item['quantity'],
    // "note": item['note'],
    //   };
    // }).toList();

    // setState(() {
    //   _items = data.reversed.toList();
    // });

    // print(_items);
  }

  Future<void> _addFavorite(Map<String, dynamic> newItem) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    if (favorite) {
      DocumentReference cartDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorite')
          .doc();
      await cartDocRef.set(newItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to Favorite Successfully!'),
        ),
      );
    } else {
      CollectionReference favoriteCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorite');

      QuerySnapshot querySnapshot = await favoriteCollectionRef
          .where('productId', isEqualTo: widget.productId)
          .get();
      WriteBatch batch = FirebaseFirestore.instance.batch();
      querySnapshot.docs.forEach((doc) {
        batch.delete(doc.reference);
      });
      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Favorite removed successfully!"),
        ),
      );
    }
  }

  @override
  void initState() {
    // _orders.clear();

    productId = widget.productId;
    super.initState();
    fetchProductData();
    // _refreshItems();
  }

  AddToCartButtonStateId stateId = AddToCartButtonStateId.idle;
  @override
  Widget build(BuildContext context) {
    // List<bool> isSelectedList = List<bool>.filled(buttonLabels.length, false);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFa02e49),
          elevation: 0.0,
          title: Text('Detail'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  String CstoreId = prefs.getString('storeId') ?? '';
                  setState(() {
                    favorite = !favorite;
                    _addFavorite({
                      "productId": productId,
                      "productName": productName,
                      "productPrice": productPrice,
                      "quantity": quantity,
                      "note": _noteController.text,
                      "productCost": productCost,
                      "imageUrl": imgProduct,
                      "isNotAvailable": isNotAvailable,
                      "productGroup": productGroup,
                      "storeId": CstoreId
                    });
                  });
                },
                icon: favorite
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border))
          ],
        ),
        body: Container(
          color: Color(0xFFa02e49),
          width: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('$productName',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image(
                            image: imgProduct != null
                                ? NetworkImage(imgProduct!)
                                : NetworkImage(
                                    'https://cdn.kommunicate.io/kommunicate/avatar/cato.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextFormField(
                              controller: _noteController,
                              onChanged: (value) {
                                setState(() {
                                  // _textFields1[index] = value;
                                });
                              },
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                // labelText: 'Text ${index + 1}',

                                label: Text('Note'),
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                // errorStyle: TextStyle(color: Colors.orange),
                              ),
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return 'Please enter a value';
                              //   }
                              //   return null;
                              // },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Text(
                    //   'Choose Add On',
                    //   style: TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 25,
                    //       fontWeight: FontWeight.bold),
                    // ),
                    // StatefulBuilder(
                    //     builder: (BuildContext context, StateSetter setState) {
                    //   return Center(
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(16.0),
                    //       child: SizedBox(
                    //         height: 50.0,
                    //         width: MediaQuery.of(context).size.width * 0.7,
                    //         child: ListView.builder(
                    //           scrollDirection: Axis.horizontal,
                    //           itemCount: buttonLabels.length,
                    //           itemBuilder: (context, index) {
                    //             bool isSelected = isSelectedList[index];

                    //             Color backgroundColor =
                    //                 isSelected ? Colors.black : Colors.white;
                    //             Color textColor =
                    //                 isSelected ? Colors.white : Colors.black;

                    //             return Center(
                    //               child: Padding(
                    //                 padding: const EdgeInsets.all(7.0),
                    //                 child: ElevatedButton(
                    //                   onPressed: () {
                    //                     setState(() {
                    //                       isSelectedList[index] =
                    //                           !isSelectedList[index];
                    //                     });
                    //                   },
                    //                   style: ButtonStyle(
                    //                     backgroundColor:
                    //                         MaterialStateProperty.all<Color>(
                    //                             backgroundColor),
                    //                   ),
                    //                   child: Text(
                    //                     buttonLabels[index],
                    //                     style: TextStyle(color: textColor),
                    //                   ),
                    //                 ),
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     ),
                    //   );
                    // }),
                    Container(
                        width: 200,
                        decoration: BoxDecoration(
                            color: Color(0xFFeeeeee),
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(decrementQuantity);
                                },
                                icon: Icon(Icons.remove)),
                            Text('$quantity'),
                            IconButton(
                                onPressed: () {
                                  print('$quantity');
                                  setState(incrementQuantity);
                                },
                                icon: Icon(Icons.add)),
                          ],
                        )),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                            ),
                            Text('₱ ${productPrice?.toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                        // SizedBox(
                        //   width: 150,
                        //   height: 50,
                        //   child: ElevatedButton(
                        //       style: ElevatedButton.styleFrom(
                        //           backgroundColor: Color(0xFFeb5135)),
                        //       onPressed: () {},
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(8.0),
                        //         child: Text(
                        //           'Add to Cart',
                        //           style: TextStyle(fontWeight: FontWeight.bold),
                        //         ),
                        //       )),
                        // )
                        SizedBox(
                          width: 150,
                          child: AddToCartButton(
                            trolley: Image.asset(
                              'images/icons/ic_cart.png',
                              width: 24,
                              height: 24,
                              color: Colors.white,
                            ),
                            text: Text(
                              'Add to cart',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                            ),
                            check: SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(24),
                            backgroundColor: Colors.deepOrangeAccent,
                            onPressed: (id) {
                              if (id == AddToCartButtonStateId.idle) {
                                //handle logic when pressed on idle state button.
                                setState(() {
                                  stateId = AddToCartButtonStateId.loading;
                                  Future.delayed(Duration(seconds: 3), () {
                                    setState(() {
                                      print('done');
                                      _addOrder({
                                        "productId": productId,
                                        "productName": productName,
                                        "productPrice": productPrice,
                                        "quantity": quantity,
                                        "note": _noteController.text,
                                        "productCost": productCost,
                                        "imageUrl": imgProduct,
                                        "storeId": mystoreId
                                      });
                                      stateId = AddToCartButtonStateId.done;
                                    });
                                  });
                                });
                              } else if (id == AddToCartButtonStateId.done) {
                                //handle logic when pressed on done state button.
                                setState(() {
                                  stateId = AddToCartButtonStateId.idle;
                                });
                              }
                            },
                            stateId: stateId,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

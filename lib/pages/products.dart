import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user/pages/addproduct.dart';
import 'package:user/pages/editproduct.dart';
import 'package:user/pages/home.dart';
import 'package:user/pages/subscribe.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? plan;
  int? totalProducts;
  bool maxProduct = false;
  bool expired = false;
  Timestamp? expiration;
  bool addProduct = false;
  final currentTimestamp = Timestamp.now();
  List<List<dynamic>> menu = [
    // ['TAPSILOG', 'TAPSI', 80, AssetImage('assets/images/POS-tapsilog.jpg')],
    // ['BANGSILOG', 'TAPSI', 80, AssetImage('assets/images/POS-bangsilog.jpg')],
    // ['TOCILOG', 'TAPSI', 80, AssetImage('assets/images/POS-tocilog.jpg')],
    // [
    //   'LECHON SILOG',
    //   'TAPSI',
    //   80,
    //   AssetImage('assets/images/POS-lechonsilog.jpg')
    // ],
    // ['LONGSILOG', 'TAPSI', 80, AssetImage('assets/images/POS-longsilog.jpg')],
    // ['CHICKSILOG', 'TAPSI', 80, AssetImage('assets/images/POS-chicksilog.jpg')],
    // ['CORNSILOG', 'TAPSI', 80, AssetImage('assets/images/POS-cornsilog.jpg')],
    // ['HOTSILOG', 'TAPSI', 80, AssetImage('assets/images/POS-hotsilog.jpg')],
    // ['SPAMSILOG', 'TAPSI', 80, AssetImage('assets/images/POS-spamsilog.jpg')],
    // ['SPRITE', 'BEVERAGES', 30, AssetImage('assets/images/spritecan.jpg')],
    // ['COKE', 'BEVERAGES', 30, AssetImage('assets/images/cokecan.jpg')],
    // ['RICE', 'ADD ON', 15, AssetImage('assets/images/rice.jpg')],
    // ['HOTDOG', 'ADD ON', 15, AssetImage('assets/images/hot.jpg')],
    // ['TAPA', 'ADD ON', 15, AssetImage('assets/images/tapa.jpg')],
  ];
  bool empty = false;
  Future<void> fetchMenuData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('products')
        .get();
    if (snapshot.docs.isEmpty) {
      setState(() {
        empty = true;
      });
    }
    final data = snapshot.docs.map((doc) {
      final imageUrl = doc['imageUrl'] as String;
      final productName = doc['productName'] as String;
      final productPrice = double.parse(doc['productPrice'].toString());
      final productGroup = doc['productGroup'] as String;
      final productId = doc.id;
      final isNotAvailable = doc['isNotAvailable'] as bool;
      final productCost = double.parse(doc['productCost'].toString());
      final productStocks = doc['productStocks'] as int;
      return [
        productName,
        productGroup,
        productPrice,
        imageUrl,
        productId,
        isNotAvailable,
        productCost,
        productStocks
      ];
    }).toList();

    setState(() {
      menu = data;
    });
  }

  void deleteProduct(String productId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid;
      // Get the reference to the document using the path
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('products')
          .doc(productId);

      // Delete the document
      await documentReference.delete();
      fetchMenuData();
      print('Product deleted successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Product deleted successfully!"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
      print('Failed to delete product: $e');
    }
    fetchMenuData();
  }

  Future<void> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('products')
        .get();
    // final DocumentSnapshot<Map<String, dynamic>> snapshot =
    //     await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      final data = snapshot.data();
      // Access the data fields from the document
      final userplan = data!['plan'] as String;
      if (userplan == 'starter' || userplan == 'boss') {
        final expiration = data['expiration'] as Timestamp;
        final isExpired =
            expiration.toDate().isBefore(currentTimestamp.toDate());
        print('isExpired: $isExpired');
        setState(() {
          expired = isExpired;
        });
      }
      // Rest of your code
      setState(() {
        totalProducts = querySnapshot.size;
        plan = userplan;
        if (plan == 'free') {
          if (totalProducts! >= 5) {
            maxProduct = true;
          }
        }
      });
    } else {
      setState(() {
        plan = 'No Plan'; // Set a default value or handle it as needed
      });
      // Handle the case when the document does not exist
    }
    setState(() {
      addProduct = true;
    });
  }

  String searchQuery = '';
  @override
  void initState() {
    super.initState();
    fetchMenuData();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    print('maxProduct: $maxProduct');
    print('totalProducts: $totalProducts');
    print('plan: $plan');
    // Filter the menu items based on the search query
    List<List<dynamic>> filteredMenu = menu.where((item) {
      String itemName = item[0].toString().toLowerCase();
      String categoryName = item[1].toString().toLowerCase();
      String query = searchQuery.toLowerCase();

      return itemName.contains(query) || categoryName.contains(query);
    }).toList();

    // Group the filtered menu items by category
    Map<String, List<dynamic>> menuByCategory = {};
    for (var item in filteredMenu) {
      String category = item[1];
      if (menuByCategory.containsKey(category)) {
        menuByCategory[category]!.add(item);
      } else {
        menuByCategory[category] = [item];
      }
    }
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xFFa02e49),
            title: Text('PRODUCTS'),
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_back, color: Colors.white))),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(children: [
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
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (addProduct) {
                        if (expired) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  titlePadding:
                                      EdgeInsets.only(top: 16, bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: BorderSide(
                                      color: Color(0xFFa02e49),
                                      width: 3.0,
                                    ),
                                  ),
                                  title: Text(
                                    'Expired Subscription',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: SizedBox(
                                    height: 120,
                                    child: Column(
                                      children: [
                                        FittedBox(
                                            child: Text(
                                                "Sorry, your subsription is expired!")),
                                        Text('Thank you.'),
                                        SizedBox(height: 10),
                                        Divider(
                                          thickness: 2,
                                        ),
                                        Center(
                                          child: TextButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SubscribePage(),
                                                  ),
                                                );
                                              },
                                              child: Text('Update',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Color(0xFFa02e49),
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        } else {
                          if (maxProduct == true) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    contentPadding: EdgeInsets.zero,
                                    titlePadding:
                                        EdgeInsets.only(top: 16, bottom: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide(
                                        color: Color(0xFFa02e49),
                                        width: 3.0,
                                      ),
                                    ),
                                    title: Text(
                                      'Reached Limit',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: SizedBox(
                                      height: 120,
                                      child: Column(
                                        children: [
                                          FittedBox(
                                              child: Text(
                                                  "You've reached your product limit!")),
                                          Text('Please try again.'),
                                          SizedBox(height: 10),
                                          Divider(
                                            thickness: 2,
                                          ),
                                          Center(
                                            child: TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SubscribePage(),
                                                    ),
                                                  );
                                                },
                                                child: Text('Upgrade',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color:
                                                            Color(0xFFa02e49),
                                                        fontWeight:
                                                            FontWeight.bold))),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddProductPage(),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Icon(Icons.add_circle, color: Color(0xFFa02e49)),
                          Text(
                            'Add Product',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFFa02e49)),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: empty
                    ? Center(
                        child: Text('No Product'),
                      )
                    : ListView.builder(
                        itemCount: menuByCategory.keys.length,
                        itemBuilder: (context, index) {
                          String category =
                              menuByCategory.keys.elementAt(index);
                          List<dynamic> items = menuByCategory[category]!;

                          return Column(
                            children: [
                              ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(
                                            0xFFa02e49,
                                          ),
                                          fontSize: 20),
                                    ),
                                    Divider(
                                        color: Color(
                                      0xFFa02e49,
                                    )),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: ClampingScrollPhysics(),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  String itemName = items[index][0];
                                  double price = items[index][2];
                                  String image = items[index][3];
                                  String productId = items[index][4];
                                  bool isnotavailable = items[index][5];
                                  double productCost = items[index][6];
                                  int productStocks = items[index][7];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProductPage(
                                                    imagelink: image,
                                                    productgroup: category,
                                                    productname: itemName,
                                                    productprice: double.parse(
                                                        price.toString()),
                                                    productcost: productCost,
                                                    productstocks:
                                                        productStocks,
                                                    isnotavailable:
                                                        isnotavailable,
                                                    productId: productId,
                                                  )));
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: ListTile(
                                        leading:
                                            // Image(image: image),
                                            Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(image),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(itemName,
                                                style: TextStyle(
                                                    color: Color(
                                                  0xFFa02e49,
                                                ))),
                                            Text(
                                              '₱${price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                  color: Color(
                                                    0xFFa02e49,
                                                  ),
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        trailing: IconButton(
                                            onPressed: () {
                                              deleteProduct(productId);
                                            },
                                            icon: Icon(Icons.delete,
                                                color: Color(
                                                  0xFFa02e49,
                                                ))),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/customer/pages/addorder.dart';
import 'package:user/customer/pages/cart.dart';

import '../components/navbar.dart';

class HomePageCustomer extends StatefulWidget {
  const HomePageCustomer({super.key});

  @override
  State<HomePageCustomer> createState() => _HomePageCustomerState();
}

class _HomePageCustomerState extends State<HomePageCustomer> {
  String? storeId;
  String? storename;
  bool first = true;
  String? username;
  List<String> buttonLabels = [];
  List<List<dynamic>> menu = [
    // [
    //   'TAPSILOG',
    //   '80',
    //   'TAPSI',
    //   '15-20 minutes',
    //   AssetImage('assets/images/POS-tapsilog.jpg')
    // ],
    // [
    //   'BANGSILOG',
    //   '80',
    //   'TAPSI',
    //   '15-20 minutes',
    //   AssetImage('assets/images/POS-bangsilog.jpg')
    // ],
    // [
    //   'CHICKSILOG',
    //   '80',
    //   'TAPSI',
    //   '15-20 minutes',
    //   AssetImage('assets/images/POS-chicksilog.jpg')
    // ],
    // [
    //   'CORNSILOG',
    //   '80',
    //   'TAPSI',
    //   '15-20 minutes',
    //   AssetImage('assets/images/POS-cornsilog.jpg')
    // ],
    // [
    //   'HOTSILOG',
    //   '80',
    //   'TAPSI',
    //   '15-20 minutes',
    //   AssetImage('assets/images/POS-hotsilog.jpg')
    // ],
    // [
    //   'LECHONSILOG',
    //   '80',
    //   'TAPSI',
    //   '15-20 minutes',
    //   AssetImage('assets/images/POS-lechonsilog.jpg')
    // ],
    // [
    //   'LONGSILOG',
    //   '80',
    //   'TAPSI',
    //   '15-20 minutes',
    //   AssetImage('assets/images/POS-longsilog.jpg')
    // ],
    // [
    //   'SPAMSILOG',
    //   '80',
    //   'TAPSI',
    //   '15-20 minutes',
    //   AssetImage('assets/images/POS-spamsilog.jpg')
    // ],
    // [
    //   'TOCILOG',
    //   '80',
    //   'TAPSI',
    //   '15-20 minutes',
    //   AssetImage('assets/images/POS-tocilog.jpg')
    // ],
    // [
    //   'COKE',
    //   '80',
    //   'BEVERAGES',
    //   '15-20 minutes',
    //   AssetImage('assets/images/cokecan.jpg')
    // ],
    // [
    //   'SPRITE',
    //   '80',
    //   'BEVERAGES',
    //   '15-20 minutes',
    //   AssetImage('assets/images/spritecan.jpg')
    // ],
    // [
    //   'RICE',
    //   '80',
    //   'ADD ON',
    //   '15-20 minutes',
    //   AssetImage('assets/images/rice.jpg')
    // ],
    // [
    //   'TAPA',
    //   '80',
    //   'ADD ON',
    //   '15-20 minutes',
    //   AssetImage('assets/images/tapa.jpg')
    // ],
    // [
    //   'HOTDOG',
    //   '80',
    //   'ADD ON',
    //   '15-20 minutes',
    //   AssetImage('assets/images/hot.jpg')
    // ],

    // ['Product 3', 'Price 3', 'Details 3', AssetImage('images/ambot.png')],
  ];
  // Labels for the buttons
  int selectedIndex = 0; // Track the index of the selected button
  String search = '';
  String selectedGroup = 'All';
  bool empty = false;

  void fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final prefs = await SharedPreferences.getInstance();
    String CstoreId = prefs.getString('storeId') ?? '';

    final DocumentSnapshot<Map<String, dynamic>> usersnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final userdata = usersnapshot.data();
    final name = userdata!['name'] as String;

    setState(() {
      username = name;
    });
    final DocumentSnapshot<Map<String, dynamic>> storesnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(CstoreId)
            .get();
    if (storesnapshot.exists) {
      final storedata = storesnapshot.data();

      final businessname = storedata!['businessname'] as String;
      setState(() {
        storename = businessname;
      });
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(CstoreId)
        .collection('products')
        .where('isNotAvailable', isEqualTo: false)
        .get();

    final productsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(CstoreId)
        .collection('products')
        .where('isNotAvailable', isEqualTo: false)
        .get();

    final productGroups = productsSnapshot.docs
        .map((doc) => doc['productGroup'] as String)
        .toSet()
        .toList();

    final data = snapshot.docs.map((doc) {
      final imageUrl = doc['imageUrl'] as String;
      final productName = doc['productName'] as String;
      final productPrice = double.parse(doc['productPrice'].toString());
      final productGroup = doc['productGroup'] as String;
      final productId = doc.id;
      return [
        productName,
        productPrice,
        productGroup,
        '15-20 minutes',
        imageUrl,
        productId
      ];
    }).toList();

    setState(() {
      if (snapshot.docs.isEmpty) {
        empty = true;
      }
      storeId = CstoreId;
      menu = data;
      buttonLabels = productGroups;
      buttonLabels.insert(0, 'All');
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    print('storeId: $storeId');

    List<List<dynamic>> filteredMenu = menu
        .where((item) => search != ''
            ? item[0].contains(search)
            : (selectedGroup == 'All' || item[2] == selectedGroup))
        .toList();
    return WillPopScope(
      onWillPop: () async {
        // Perform your custom back button behavior here.
        // To disable the back button, simply return false.
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Color(0xFFa02e49),
          actions: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          fit: BoxFit.cover,
                          child: Text(
                            'Hello $username,',
                            style: TextStyle(
                                fontSize: 25,
                                color: Color.fromARGB(255, 207, 207, 207)),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.cover,
                          child: IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => CartPage()),
                                );
                              },
                              icon: Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: SideNavBar(),
        body: SingleChildScrollView(
          child: Container(
            color: Color(0xFFa02e49),
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Welcome to $storename!',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Color(0xFFb8a3a8)),
                      hintText: 'Search',
                      filled: true,
                      fillColor: Color(0xFFbc8390),
                      hintStyle: TextStyle(color: Color(0xFFb8a3a8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      // String upperValue = value.toUpperCase();
                      setState(() {
                        search = value.toUpperCase();
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(
                    height: 40.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: buttonLabels.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedIndex == index;
                        Color backgroundColor =
                            isSelected ? Colors.black : Colors.white;
                        Color textColor =
                            isSelected ? Colors.white : Colors.black;

                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedGroup = buttonLabels[index];
                                selectedIndex = index;
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  backgroundColor),
                            ),
                            child: Text(
                              buttonLabels[index],
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: filteredMenu.length,
                      itemBuilder: (context, index) {
                        String productName = filteredMenu[index][0];
                        String price =
                            filteredMenu[index][1].toStringAsFixed(2);
                        String details = filteredMenu[index][3];
                        String image = filteredMenu[index][4];
                        String productId = filteredMenu[index][5];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddOrder(productId: productId, type: 'add'),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              height: 120,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      height: 100,
                                      width: 100,
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            image,
                                            fit: BoxFit.cover,
                                          )

                                          //  Image(
                                          //   image: image,
                                          //   fit: BoxFit.cover,
                                          // ),
                                          ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$productName',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            color: Colors.grey[300],
                                          ),
                                          Text('$details',
                                              style: TextStyle(
                                                  color: Colors.grey[400])),
                                        ],
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '₱ $price',
                                                style: TextStyle(
                                                    color: Colors.pinkAccent,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 2,
                                                        blurRadius: 5,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(Icons.add))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

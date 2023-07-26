import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user/pages/inventorydetails.dart';
import 'package:user/pages/inventoryhistory.dart';

class InventoryListPage extends StatefulWidget {
  const InventoryListPage({super.key});

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  List<List<dynamic>> menu = [
    [
      'TAPSILOG',
      'RICE MEALS',
      80,
      AssetImage('assets/images/ambot.png'),
    ],
    [
      'BANGSILOG',
      'RICE MEALS',
      80,
      AssetImage('assets/images/ambot.png'),
    ],
    [
      'TOCILOG',
      'RICE MEALS',
      80,
      AssetImage('assets/images/ambot.png'),
    ],
    [
      'COKE',
      'DRINKS',
      80,
      AssetImage('assets/images/ambot.png'),
    ],
    [
      'SPRITE',
      'DRINKS',
      80,
      AssetImage('assets/images/ambot.png'),
    ],
    [
      'TAPSILOG',
      'RICE MEALS',
      80,
      AssetImage('assets/images/ambot.png'),
    ],
    [
      'BANGSILOG',
      'RICE MEALS',
      80,
      AssetImage('assets/images/ambot.png'),
    ],
    [
      'TOCILOG',
      'RICE MEALS',
      80,
      AssetImage('assets/images/ambot.png'),
    ],
    [
      'COKE',
      'DRINKS',
      80,
      AssetImage('assets/images/ambot.png'),
    ],
    [
      'SPRITE',
      'DRINKS',
      80,
      AssetImage('assets/images/ambot.png'),
    ],
  ];
  Future<List<String>> getProductGroups() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('products')
        .get();

    final productGroups = <String>[];

    for (final doc in querySnapshot.docs) {
      final productGroup = doc['productGroup'] as String;
      if (!productGroups.contains(productGroup)) {
        productGroups.add(productGroup);
      }
    }

    return productGroups;
  }

  @override
  void initState() {
    super.initState();
    getProductGroups();
  }

  @override
  Widget build(BuildContext context) {
    List<String> productGroups =
        menu.map((item) => item[1].toString()).toSet().toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa02e49),
        title: Text('INVENTORY LIST'),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => InventoryHistoryPage(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.white),
                    borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'HISTORY',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: FutureBuilder<List<String>>(
                future:
                    getProductGroups(), // Fetch the unique product groups from Firestore
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While waiting for the data to load, show a loading indicator
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    // If an error occurs, display an error message
                    return Center(
                      child: Text('Error fetching product groups'),
                    );
                  } else {
                    final productGroups =
                        snapshot.data!; // Access the fetched product groups

                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: productGroups.length,
                      itemBuilder: (context, index) {
                        String productGroup = productGroups[index];

                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          InventoryDetailsPage(
                                        productGroup: productGroup,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productGroup,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color(0xFFa02e49),
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 1,
                                color: Color(0xFFa02e49),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

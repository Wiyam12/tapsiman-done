import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/customer/pages/home.dart';

class VouchersPage extends StatefulWidget {
  const VouchersPage({super.key});

  @override
  State<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> {
  Color maincolor = Color(0xFFa02e49);
  List<dynamic> vouchers = [];
  bool empty = false;
  double totalCoins = 0.0;

  Future<void> fetchVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    String CstoreId = prefs.getString('storeId') ?? '';
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final DocumentSnapshot<Map<String, dynamic>> usersnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userdata = usersnapshot.data();
    final totalCoin = double.parse(userdata!['coin'].toString());
    setState(() {
      totalCoins = totalCoin;
    });
    final CollectionReference<Map<String, dynamic>> vouchersCollection =
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('voucher');

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await vouchersCollection.orderBy('date', descending: true).get();
    // await vouchersCollection.where('storeId', isEqualTo: CstoreId).get();
    if (querySnapshot.docs.isEmpty) {
      setState(() {
        empty = true;
      });
    }

    for (final docSnapshot in querySnapshot.docs) {
      // Retrieve the document data
      final voucherData = docSnapshot.data();
      final voucherName = voucherData['voucherName'];
      final used = voucherData['used'] as bool;
      final voucherEntry = {'voucherName': voucherName, 'used': used};
      setState(() {
        vouchers.add(voucherEntry);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVouchers();
  }

  @override
  Widget build(BuildContext context) {
    print(vouchers);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Rewards'),
        backgroundColor: maincolor,
        centerTitle: true,
      ),
      body: Container(
        color: maincolor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(children: [
                empty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Center(
                          child: Text(
                            'No Rewards',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: vouchers.length,
                          itemBuilder: (context, index) {
                            String vouchername = vouchers[index]['voucherName'];
                            bool used = vouchers[index]['used'];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  vouchername,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Image.asset(
                                                  'images/voucher.png',
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            if (!used)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            HomePageCustomer(),
                                                      ),
                                                    );
                                                  },
                                                  style: ButtonStyle(
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.0),
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(Color(
                                                                0xFFc96f6f)),
                                                  ),
                                                  child: Text(
                                                    'use',
                                                  ),
                                                ),
                                              ),
                                          ],
                                        )
                                      ]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ]),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Available Coins:  ',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      Text(
                        '$totalCoins',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

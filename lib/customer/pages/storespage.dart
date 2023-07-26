import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/customer/pages/home.dart';
import 'package:user/pages/home.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Color maincolor = Color(0xFFa02e49);
  List<List<String>> stores = [
    // ['TAPSIHAN 1', 'ADDRESS 1'],
    // ['TAPSIHAN 2', 'ADDRESS 2'],
    // ['TAPSIHAN 3', 'ADDRESS 3'],
  ];
  String search = '';
  void fetchData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userlevel', isEqualTo: 'entrep')
        .where('status', isEqualTo: 'approved')
        .get();

    for (var doc in snapshot.docs) {
      List<String> data = [];

      Map<String, dynamic> docData = doc.data()
          as Map<String, dynamic>; // Cast the type to 'Map<String, dynamic>'

      // Add the fields you want to retrieve from each document
      data.add(docData['businessname']);
      data.add(docData['address']);
      data.add(doc.id);
      // ...
      if (docData.containsKey('businessImg')) {
        String businessImg = docData['businessImg'] as String;
        data.add(businessImg);
      } else {
        data.add(
            'noimage'); // Provide a default value or handle the case when 'businessImg' is not present
      }
      setState(() {
        stores.add(data);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> filteredstores = stores
        .where((item) => search != ''
            ? ((item[0].toUpperCase()).contains(search.toUpperCase()) ||
                (item[1].toUpperCase()).contains(search.toUpperCase()))
            : true)
        .toList();

    print('stores: $stores');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: maincolor,
        title: Container(
            decoration: BoxDecoration(
                color: Color(0xFFc64d56),
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Text(
                'Stores',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            )),
        centerTitle: true,
      ),
      body: Container(
        color: maincolor,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.search, color: Color(0xFFb8a3a8)),
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: ListView.builder(
                        itemCount: filteredstores.length,
                        itemBuilder: (BuildContext context, int index) {
                          String storename = filteredstores[index][0];
                          String storeId = filteredstores[index][2];
                          String imglink = filteredstores[index][3];

                          return GestureDetector(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString('storeId', storeId);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => HomePageCustomer(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              // child: Card(
                              //   child: ListTile(
                              //     leading: SizedBox(
                              //       width: 50,
                              //       child: CircleAvatar(
                              //           backgroundColor:
                              //               Color.fromARGB(255, 101, 7, 0),
                              //           child: Image.asset(
                              //             'assets/images/logo.png',
                              //           )),
                              //     ),
                              //     title: Text('Headline'),
                              //     subtitle: Text(
                              //         'Longer supporting text to demonstrate how the text wraps and how the leading and trailing widgets are centered vertically with the text.'),
                              //     trailing: Icon(Icons.favorite_rounded),
                              //   ),
                              // ),
                              child: Container(
                                height: 120,
                                width: 100,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            height: 100,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(100),
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
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: imglink != 'noimage'
                                                    ? Image.network(
                                                        imglink,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.asset(
                                                        'assets/images/logo.png')),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                filteredstores[index][0],
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Container(
                                                width: 150,
                                                child: Text(
                                                  filteredstores[index][1],
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(
                                        Icons.store,
                                        color: maincolor,
                                        size: 50,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                    color: Color(0xFFe7cbd1),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Choose your tapsihan.',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

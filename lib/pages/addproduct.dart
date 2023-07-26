import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/pages/products.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:user/pages/subscribe.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  GlobalKey<AutoCompleteTextFieldState<String>> _autoCompleteKey = GlobalKey();

  final _formKeyAddons = GlobalKey<FormState>();
  final _formKeyProduct = GlobalKey<FormState>();
  final _formKeyNotes = GlobalKey<FormState>();
  File? _selectedImage;

  int radioAddons = 0;
  int radioNotes = 0;

  bool showAddons = false;
  bool showNotes = false;
  bool _isNotAvailable = false;
  String? plan;
  int? totalProducts;
  bool maxProduct = false;
  bool addProduct = false;

  DateTime today = DateTime.now();
  TextEditingController _productGroupController = TextEditingController();
  TextEditingController _productNamecontroller = TextEditingController();
  TextEditingController _productPricecontroller = TextEditingController();
  TextEditingController _productCostcontroller = TextEditingController();
  TextEditingController _productStockscontroller = TextEditingController();

  TextEditingController _productGroupcontroller = TextEditingController();
  List<String> _productGroups = [];

  List<List<dynamic>> addonList = [];
  List<dynamic> NoteList = [];
  checkaddonList() {
    if (addonList.length > 0) {
      setState(() {
        radioAddons = 1;
      });
    } else {
      setState(() {
        radioAddons = 0;
      });
    }
  }

  checkNoteList() {
    if (NoteList.length > 0) {
      setState(() {
        radioNotes = 1;
      });
    } else {
      setState(() {
        radioNotes = 0;
      });
    }
  }

  // for addons
  List<String> _textFields1 = [''];
  List<String> _textFields2 = [''];
  List<String> _textFields3 = [''];
  List<GlobalKey> _keyList = [GlobalKey()];
  List<GlobalKey> _keyList2 = [GlobalKey()];
  List<GlobalKey> _keyList3 = [GlobalKey()];

  // end addons

  // for notes
  List<String> _textFieldsNotes = [''];
  List<GlobalKey> _keyListNotes = [GlobalKey()];
  // end notes

  // image picker
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }
  // end image picker

  Future<void> _uploadProductData() async {
    print(maxProduct);
    setState(() {
      addProduct = true;
    });
    if (maxProduct == true) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.only(top: 16, bottom: 8),
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                height: 120,
                child: Column(
                  children: [
                    FittedBox(
                        child: Text("You've reached your product limit!")),
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
                                builder: (context) => SubscribePage(),
                              ),
                            );
                          },
                          child: Text('Upgrade',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFFa02e49),
                                  fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
              ),
            );
          });
    } else {
      try {
        final user = FirebaseAuth.instance.currentUser;
        final userId = user!.uid;

        // Upload image to Firebase Storage
        final storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('product_images/$userId/${_productNamecontroller.text}');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        // Store product data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('products')
            .add({
          'userId': userId,
          'productGroup': _productGroupcontroller.text.toUpperCase(),
          'productName': _productNamecontroller.text.toUpperCase(),
          'productPrice': double.parse(_productPricecontroller.text),
          'productCost': double.parse(_productCostcontroller.text),
          'productStocks': int.parse(_productStockscontroller.text),
          'isNotAvailable': _isNotAvailable,
          'imageUrl': imageUrl,
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('inventoryHistory')
            .add({
          'date': today,
          'inventoryName': _productNamecontroller.text.toUpperCase(),
          'inventoryCost': double.parse(_productCostcontroller.text),
          'inventoryStocks': int.parse(_productStockscontroller.text),
        });

        // Show success message or navigate to a different screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product data uploaded successfully'),
          ),
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductPage(),
          ),
        );
      } catch (error) {
        setState(() {
          addProduct = false;
        });
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to upload product data. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      // showDialog(
      //   context: context,
      //   builder: (ctx) => AlertDialog(
      //     title: Text('Success'),
      //     content: Text('Product data uploaded successfully.'),
      //     actions: [
      //       TextButton(
      //         onPressed: () {
      //           Navigator.of(ctx).pop();
      //           // Clear the form fields and image selection
      //           _productGroupController.clear();
      //           _productNamecontroller.clear();
      //           _productPricecontroller.clear();
      //           _productCostcontroller.clear();
      //           _productStockscontroller.clear();
      //           setState(() {
      //             _selectedImage = null;
      //           });
      //         },
      //         child: Text('OK'),
      //       ),
      //     ],
      //   ),
      // );
    }
  }

  Future<void> _fetchProductGroups() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final productsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('products')
        .get();

    setState(() {
      _productGroups = productsSnapshot.docs
          .map((doc) => doc['productGroup'] as String)
          .toList();
    });
  }

  Future<void> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    // final DocumentSnapshot<Map<String, dynamic>> snapshot =
    //     await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      final data = snapshot.data();
      // Access the data fields from the document
      final userplan = data!['plan'] as String;

      // Rest of your code
      setState(() {
        plan = userplan;
      });
    } else {
      setState(() {
        plan = 'No Plan'; // Set a default value or handle it as needed
      });
      // Handle the case when the document does not exist
    }
  }

  Future<void> countTotalProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('products')
        .get();

    setState(() {
      totalProducts = querySnapshot.size;
      if (plan == 'free') {
        if (querySnapshot.size > 5) {
          maxProduct = true;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProductGroups();
    getUserData();
    countTotalProducts();
  }

  @override
  Widget build(BuildContext context) {
    checkaddonList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFa02e49),
        title: Text(showAddons
            ? 'ADD ADDONS'
            : showNotes
                ? 'ADD NOTES'
                : 'ADD PRODUCT'),
        leading: IconButton(
            onPressed: () {
              setState(() {
                showAddons
                    ? showAddons = false
                    : showNotes
                        ? showNotes = false
                        : Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductPage(),
                            ),
                          );
              });
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: showAddons
            ? Stack(
                children: [
                  SingleChildScrollView(
                    child: Form(
                      key: _formKeyAddons,
                      child: Column(
                        children: [
                          ..._textFields1.asMap().entries.map((entry) {
                            final index = entry.key;
                            final text = entry.value;
                            // print(index);
                            return Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      key: _keyList[index],
                                      initialValue: '${_textFields1[index]}',
                                      onChanged: (value) {
                                        setState(() {
                                          _textFields1[index] = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        // labelText: 'Text ${index + 1}',
                                        label: Text('Name'),
                                        labelStyle:
                                            TextStyle(color: Color(0xFFa02e49)),
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      key: _keyList2[index],
                                      keyboardType: TextInputType.number,
                                      initialValue: '${_textFields2[index]}',
                                      onChanged: (value) {
                                        setState(() {
                                          _textFields2[index] = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        // labelText: 'Text ${index + 1}',
                                        label: Text('Price'),
                                        labelStyle:
                                            TextStyle(color: Color(0xFFa02e49)),
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        // border: OutlineInputBorder(),
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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      key: _keyList3[index],
                                      keyboardType: TextInputType.number,
                                      initialValue: '${_textFields3[index]}',
                                      onChanged: (value) {
                                        setState(() {
                                          _textFields3[index] = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        // labelText: 'Text ${index + 1}',
                                        label: Text('Cost'),
                                        labelStyle:
                                            TextStyle(color: Color(0xFFa02e49)),
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
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
                                IconButton(
                                  onPressed: () {
                                    print(index);
                                    setState(() {
                                      _textFields1.removeAt(index);
                                      _textFields2.removeAt(index);
                                      _textFields3.removeAt(index);
                                      _keyList.removeAt(index);
                                      _keyList2.removeAt(index);
                                      _keyList3.removeAt(index);
                                    });
                                  },
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            );
                          }).toList(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _textFields1.add('');
                                      _textFields2.add('');
                                      _textFields3.add('');
                                      _keyList.add(GlobalKey());
                                      _keyList2.add(GlobalKey());
                                      _keyList3.add(GlobalKey());
                                    });
                                  },
                                  icon: Icon(Icons.add_circle,
                                      color: Color(0xFFa02e49))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xFFa02e49))),
                                onPressed: () {
                                  setState(() {
                                    showAddons = false;
                                  });
                                },
                                child: Text('CANCEL')),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xFFa02e49))),
                                onPressed: () {
                                  if (_formKeyAddons.currentState!.validate()) {
                                    print(_productGroupController.text);
                                    print(_textFields1);
                                    print(_textFields2);
                                    print(_textFields3);
                                    setState(() {
                                      addonList = List.generate(
                                          _textFields1.length, (index) {
                                        return [
                                          _textFields1[index],
                                          int.parse(_textFields2[index]),
                                          int.parse(_textFields3[index]),
                                        ];
                                      });
                                      showAddons = false;
                                    });
                                    checkaddonList();
                                    print(addonList);
                                  }
                                },
                                child: Text('CONFIRM')),
                          )
                        ],
                      ))
                ],
              )
            : showNotes
                ? Stack(
                    children: [
                      SingleChildScrollView(
                        child: Form(
                          key: _formKeyNotes,
                          child: Column(
                            children: [
                              ..._textFieldsNotes.asMap().entries.map((entry) {
                                final index = entry.key;
                                final text = entry.value;
                                // print(index);
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          key: _keyListNotes[index],
                                          initialValue:
                                              '${_textFieldsNotes[index]}',
                                          onChanged: (value) {
                                            setState(() {
                                              _textFieldsNotes[index] = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            // labelText: 'Text ${index + 1}',
                                            label: Text('Notes ${index + 1}'),
                                            labelStyle: TextStyle(
                                                color: Color(0xFFa02e49)),
                                            border: OutlineInputBorder(),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFa02e49),
                                                  width: 2.0),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFa02e49),
                                                  width: 2.0),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFa02e49),
                                                  width: 2.0),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFa02e49),
                                                  width: 2.0),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
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
                                    IconButton(
                                      onPressed: () {
                                        print(index);
                                        setState(() {
                                          _textFieldsNotes.removeAt(index);

                                          _keyListNotes.removeAt(index);
                                        });
                                      },
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ],
                                );
                              }).toList(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _textFieldsNotes.add('');

                                          _keyListNotes.add(GlobalKey());
                                        });
                                      },
                                      icon: Icon(Icons.add_circle,
                                          color: Color(0xFFa02e49))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Color(0xFFa02e49))),
                                    onPressed: () {
                                      setState(() {
                                        showNotes = false;
                                      });
                                    },
                                    child: Text('CANCEL')),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Color(0xFFa02e49))),
                                    onPressed: () {
                                      if (_formKeyNotes.currentState!
                                          .validate()) {
                                        print(_textFieldsNotes);

                                        setState(() {
                                          NoteList = _textFieldsNotes;
                                          showNotes = false;
                                        });
                                        checkNoteList();
                                        print(NoteList);
                                      }
                                    },
                                    child: Text('CONFIRM')),
                              )
                            ],
                          ))
                    ],
                  )
                : Stack(
                    children: [
                      SingleChildScrollView(
                        child: Form(
                          key: _formKeyProduct,
                          child: Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: double.infinity,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 3,
                                                color: Color(0xFFa02e49)),
                                            borderRadius:
                                                BorderRadius.circular(20),

                                            // image: DecorationImage(

                                            //     image:AssetImage(

                                            //         'assets/images/photo.png'),
                                            //     fit: BoxFit.cover),
                                          ),
                                          child: _selectedImage != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: Image.file(
                                                    _selectedImage!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Image.asset(
                                                  'assets/images/photo.png',
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        Positioned(
                                          bottom: 5,
                                          right: 5,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Color(0xFFa02e49),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                              child: IconButton(
                                                  onPressed: () {
                                                    _pickImage();
                                                  },
                                                  icon: Icon(
                                                      Icons.camera_alt_outlined,
                                                      color: Colors.white))),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: Autocomplete<String>(
                                            optionsBuilder: (TextEditingValue
                                                textEditingValue) {
                                              if (textEditingValue
                                                  .text.isEmpty) {
                                                return const Iterable<
                                                    String>.empty();
                                              }
                                              final query = textEditingValue
                                                  .text
                                                  .toUpperCase();
                                              return _productGroups
                                                  .where((String option) {
                                                return option
                                                    .toUpperCase()
                                                    .contains(query);
                                              });
                                            },
                                            onSelected: (String selection) {
                                              setState(() {
                                                _productGroupController.text =
                                                    selection;
                                              });
                                            },
                                            fieldViewBuilder: (BuildContext
                                                    context,
                                                TextEditingController
                                                    _productGroupController,
                                                FocusNode focusNode,
                                                VoidCallback onFieldSubmitted) {
                                              return TextFormField(
                                                style: TextStyle(
                                                    color: Color(0xFFa02e49)),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  labelText: 'PRODUCT GROUP',
                                                  labelStyle: TextStyle(
                                                      color: Color(0xFFa02e49),
                                                      fontSize: 12),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 8.0,
                                                          horizontal: 16.0),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFa02e49),
                                                        width: 2.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFa02e49),
                                                        width: 2.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFa02e49),
                                                        width: 2.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFa02e49),
                                                        width: 2.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  suffixIcon: IconButton(
                                                    onPressed: () {
                                                      print(
                                                          _productGroupController
                                                              .text);
                                                      _productGroupController
                                                          .clear();
                                                    },
                                                    icon: Icon(Icons.clear,
                                                        color:
                                                            Color(0xFFa02e49)),
                                                  ),
                                                ),
                                                controller:
                                                    _productGroupController,
                                                focusNode: focusNode,
                                                onFieldSubmitted: (value) {
                                                  onFieldSubmitted();
                                                  // print(value);
                                                  // print(_productGroupController
                                                  //     .text);
                                                },
                                                onTapOutside: (event) {
                                                  // print(_productGroupController
                                                  //     .text);
                                                  setState(() {
                                                    _productGroupcontroller
                                                            .text =
                                                        _productGroupController
                                                            .text;
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter a product group';
                                                  }
                                                  return null;
                                                },
                                              );
                                            },
                                          ),

                                          // TextFormField(
                                          //   controller: _productGroupController,
                                          //   style: TextStyle(
                                          //       color: Color(0xFFa02e49)),
                                          //   decoration: InputDecoration(
                                          //     filled: true,
                                          //     fillColor: Colors.white,
                                          //     label: Text('PRODUCT GROUP'),
                                          //     labelStyle: TextStyle(
                                          //         color: Color(0xFFa02e49)),
                                          //     contentPadding:
                                          //         EdgeInsets.symmetric(
                                          //             vertical: 8.0,
                                          //             horizontal: 16.0),
                                          //     enabledBorder: OutlineInputBorder(
                                          //       borderSide: BorderSide(
                                          //           color: Color(0xFFa02e49),
                                          //           width: 2.0),
                                          //       borderRadius:
                                          //           BorderRadius.circular(10.0),
                                          //     ),
                                          //     focusedBorder: OutlineInputBorder(
                                          //       borderSide: BorderSide(
                                          //           color: Color(0xFFa02e49),
                                          //           width: 2.0),
                                          //       borderRadius:
                                          //           BorderRadius.circular(10.0),
                                          //     ),
                                          //     errorBorder: OutlineInputBorder(
                                          //       borderSide: BorderSide(
                                          //           color: Color(0xFFa02e49),
                                          //           width: 2.0),
                                          //       borderRadius:
                                          //           BorderRadius.circular(10.0),
                                          //     ),
                                          //     focusedErrorBorder:
                                          //         OutlineInputBorder(
                                          //       borderSide: BorderSide(
                                          //           color: Color(0xFFa02e49),
                                          //           width: 2.0),
                                          //       borderRadius:
                                          //           BorderRadius.circular(10.0),
                                          //     ),
                                          //   ),
                                          //   onSaved: (value) {
                                          //     setState(() {
                                          //       _productGroupController.text =
                                          //           value!;
                                          //     });
                                          //   },
                                          //   validator: (value) {
                                          //     if (value!.isEmpty) {
                                          //       return 'Please enter a value';
                                          //     }
                                          //     return null;
                                          //   },
                                          // ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: TextFormField(
                                            controller: _productNamecontroller,
                                            style: TextStyle(
                                                color: Color(0xFFa02e49)),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              label: Text('PRODUCT NAME'),
                                              labelStyle: TextStyle(
                                                  color: Color(0xFFa02e49)),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 16.0),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color(0xFFa02e49),
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color(0xFFa02e49),
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color(0xFFa02e49),
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color(0xFFa02e49),
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            onSaved: (value) {
                                              setState(() {
                                                _productNamecontroller.text =
                                                    value!;
                                              });
                                            },
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter a value';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Divider(thickness: 2, color: Color(0xFFa02e49)),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _productPricecontroller,
                                      style:
                                          TextStyle(color: Color(0xFFa02e49)),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        label: Text('PRICE'),
                                        labelStyle:
                                            TextStyle(color: Color(0xFFa02e49)),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 16.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      onSaved: (value) {
                                        setState(() {
                                          _productPricecontroller.text = value!;
                                        });
                                      },
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
                                      controller: _productCostcontroller,
                                      style:
                                          TextStyle(color: Color(0xFFa02e49)),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        label: Text('COST'),
                                        labelStyle:
                                            TextStyle(color: Color(0xFFa02e49)),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 16.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      onSaved: (value) {
                                        setState(() {
                                          _productCostcontroller.text = value!;
                                        });
                                      },
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
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _productStockscontroller,
                                      style:
                                          TextStyle(color: Color(0xFFa02e49)),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        label: Text('STOCKS'),
                                        labelStyle:
                                            TextStyle(color: Color(0xFFa02e49)),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 16.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFFa02e49),
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      onSaved: (value) {
                                        setState(() {
                                          _productStockscontroller.text =
                                              value!;
                                        });
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter a value';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Switch(
                                            value: _isNotAvailable,
                                            activeColor: Color(0xFFa02e49),
                                            onChanged: (value) {
                                              setState(() {
                                                _isNotAvailable = value;
                                                print(_isNotAvailable);
                                              });
                                            },
                                          ),
                                          Text(
                                            'NOT AVAILABLE',
                                            style: TextStyle(
                                                color: Color(0xFFa02e49),
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Divider(thickness: 2, color: Color(0xFFa02e49)),
                              // Row(
                              //   children: [
                              //     // Row(
                              //     //   children: [Switch(value: true, onChanged: (value) {})],
                              //     // ),
                              //     Expanded(
                              //       child: Container(
                              //         child: Row(
                              //           children: [
                              //             Radio(
                              //                 fillColor: MaterialStateProperty
                              //                     .resolveWith<Color>(
                              //                         (Set<MaterialState>
                              //                             states) {
                              //                   if (states.contains(
                              //                       MaterialState.disabled)) {
                              //                     return Color(0xFFa02e49);
                              //                   }
                              //                   return Color(0xFFa02e49);
                              //                 }),
                              //                 value: 1,
                              //                 groupValue: radioAddons,
                              //                 onChanged: (value) {
                              //                   setState(() {
                              //                     showAddons = true;
                              //                     radioAddons = 0;
                              //                   });
                              //                 }),
                              //             GestureDetector(
                              //               onTap: () {
                              //                 setState(() {
                              //                   showAddons = true;
                              //                 });
                              //               },
                              //               child: Text(
                              //                 'Addons',
                              //                 style: TextStyle(
                              //                     color: Color(0xFFa02e49),
                              //                     fontWeight: FontWeight.bold,
                              //                     fontSize: 18),
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //     Expanded(
                              //       child: Container(
                              //         child: Row(
                              //           children: [
                              //             Radio(
                              //                 value: 1,
                              //                 groupValue: radioNotes,
                              //                 fillColor: MaterialStateProperty
                              //                     .resolveWith<Color>(
                              //                         (Set<MaterialState>
                              //                             states) {
                              //                   if (states.contains(
                              //                       MaterialState.disabled)) {
                              //                     return Color(0xFFa02e49);
                              //                   }
                              //                   return Color(0xFFa02e49);
                              //                 }),
                              //                 onChanged: (value) {
                              //                   setState(() {
                              //                     showNotes = true;
                              //                   });
                              //                 }),
                              //             GestureDetector(
                              //               onTap: () {
                              //                 setState(() {
                              //                   showNotes = true;
                              //                 });
                              //               },
                              //               child: Text(
                              //                 'Notes',
                              //                 style: TextStyle(
                              //                     color: Color(0xFFa02e49),
                              //                     fontWeight: FontWeight.bold,
                              //                     fontSize: 18),
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // Divider(thickness: 2, color: Color(0xFFa02e49))
                            ],
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Color(0xFFa02e49))),
                                    onPressed: () {
                                      if (!addProduct) {
                                        if (_formKeyProduct.currentState!
                                            .validate()) {
                                          if (_selectedImage == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'REQUIRED TO PUT AN IMAGE!'),
                                              ),
                                            );
                                          } else {
                                            _uploadProductData();
                                          }
                                        }
                                      }
                                      // print(_productGroupcontroller.text);
                                    },
                                    child: Text(addProduct
                                        ? 'Please wait...'
                                        : 'SAVE')),
                              )
                            ],
                          ))
                    ],
                  ),
      ),
    );
  }
}

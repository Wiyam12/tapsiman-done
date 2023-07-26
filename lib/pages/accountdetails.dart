import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/pages/changepassword.dart';
import 'package:user/pages/home.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  Color maincolor = Color(0xFFa02e49);
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  String? username;
  String? useremail;
  String? businessname;
  String? number;
  bool updating = false;
  String imgLink = '';

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _businessnameController = TextEditingController();
  TextEditingController _numberController = TextEditingController();
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      final data = snapshot.data();
      // Access the data fields from the document
      final name = data!['name'] as String;
      final email = data['email'] as String;
      final business = data['businessname'] as String;
      final num = data['number'] as String;
      String businessImg = '';
      if (data.containsKey('businessImg')) {
        // Check if businessImg field exists in the data map
        businessImg = data['businessImg'] as String;
      }
      // Rest of your code
      setState(() {
        imgLink = businessImg;
        _nameController.text = name;
        _emailController.text = email;
        _businessnameController.text = business;
        _numberController.text = num;
      });
    } else {
      // Handle the case when the document does not exist
    }
  }

  Future<void> updateUser() async {
    setState(() {
      updating = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    if (_selectedImage != null) {
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('business_images/$userId/${_businessnameController.text}');
      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      DocumentReference orderRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await orderRef.update({
        'name': _nameController.text,
        'email': _emailController.text,
        'businessname': _businessnameController.text,
        'number': _numberController.text,
        'businessImg': imageUrl
      });
    } else {
      DocumentReference orderRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await orderRef.update({
        'name': _nameController.text,
        'email': _emailController.text,
        'businessname': _businessnameController.text,
        'number': _numberController.text
      });
    }

    // Get a reference to the specific order document

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Account Updated Successfully!"),
      ),
    );
    _getUserData();
    setState(() {
      updating = false;
    });
    // Update the 'status' field of the order document
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('ACCOUNT DETAILS'),
        backgroundColor: maincolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Stack(
                        children: [
                          Container(
                            height: double.infinity,
                            width: MediaQuery.of(context).size.width * 0.35,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 3, color: Color(0xFFa02e49)),
                              borderRadius: BorderRadius.circular(10),

                              // image: DecorationImage(

                              //     image:AssetImage(

                              //         'assets/images/photo.png'),
                              //     fit: BoxFit.cover),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : imgLink != ''
                                    ? Image.network(
                                        imgLink,
                                        fit: BoxFit.cover,
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
                                    borderRadius: BorderRadius.circular(100)),
                                child: IconButton(
                                    onPressed: () {
                                      _pickImage();
                                    },
                                    icon: Icon(Icons.camera_alt_outlined,
                                        color: Colors.white))),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(
                          color: maincolor, fontWeight: FontWeight.bold),
                      decoration: buildInputDecoration(Icons.people, 'Name'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(
                          color: maincolor, fontWeight: FontWeight.bold),
                      decoration: buildInputDecoration(Icons.email, 'Email'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _businessnameController,
                      style: TextStyle(
                          color: maincolor, fontWeight: FontWeight.bold),
                      decoration: buildInputDecoration(Icons.store, 'Store'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _numberController,
                      style: TextStyle(
                          color: maincolor, fontWeight: FontWeight.bold),
                      decoration:
                          buildInputDecoration(Icons.phone, 'Contact Number'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChangePasswordPage(),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(maincolor),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                              ),
                            ),
                            child: Text(
                              'CHANGE PASSWORD',
                            ),
                          ),
                        ),
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFFa02e49))),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              updateUser();
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) => HomePage(),
                              //   ),
                              // );
                            }
                          },
                          child: Text(updating ? 'Saving...' : 'SAVE')),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

InputDecoration buildInputDecoration(IconData icons, String hinttext) {
  Color maincolor = Color(0xFFa02e49);
  return InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(0.5),
    contentPadding: EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 16.0,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: maincolor, width: 2.0),
      borderRadius: BorderRadius.circular(30.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: maincolor, width: 2.0),
      borderRadius: BorderRadius.circular(30.0),
    ),
    hintText: hinttext,
    hintStyle: TextStyle(color: maincolor),
    prefixIcon: Icon(icons, color: maincolor),
    prefixIconConstraints: BoxConstraints(minWidth: 40),
  );
}

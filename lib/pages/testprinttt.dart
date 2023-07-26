// ignore_for_file: unused_import

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:user/pages/products.dart';

///Test printing
class TestPrinttt {
  void customPrint3Column(
      String column1, String column2, String column3, int fontSize,
      [String separator = "   "]) {
    String output = "$column1$column2$column3";
    blue.BlueThermalPrinter bluetooth = blue.BlueThermalPrinter.instance;
    bluetooth.printCustom(output, fontSize, 1);
  }

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  // sample() async {
  //   //image max 300px X 300px

  //   ///image from File path
  // String filename = 'codehub.png';
  // ByteData bytesData = await rootBundle.load("assets/codehub.png");
  // String dir = (await getApplicationDocumentsDirectory()).path;
  // File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
  //     .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

  // ///image from Asset
  // ByteData bytesAsset = await rootBundle.load("assets/codehub.png");
  // Uint8List imageBytesFromAsset = bytesAsset.buffer
  //     .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

  // ///image from Network
  // var response = await http.get(Uri.parse("assets/codehub.png"));
  // Uint8List bytesNetwork = response.bodyBytes;
  // Uint8List imageBytesFromNetwork = bytesNetwork.buffer
  //     .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

  //   bluetooth.isConnected.then((isConnected) {
  //     if (isConnected == true) {
  //       // bluetooth.printNewLine();
  //       // bluetooth.printCustom("HEADER", Size.boldMedium.val, Align.center.val);
  //       // bluetooth.printNewLine();
  //       // bluetooth.printImage(file.path); //path of your image/logo
  //       // bluetooth.printNewLine();
  //       // bluetooth.printImageBytes(imageBytesFromAsset); //image from Asset
  //       // bluetooth.printNewLine();
  //       // bluetooth.printImageBytes(imageBytesFromNetwork); //image from Network
  //       bluetooth.printNewLine();
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.medium.val);
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val);
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val,
  //           format:
  //               "%-15s %15s %n"); //15 is number off character from left or right
  //       bluetooth.printNewLine();
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldMedium.val);
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldLarge.val);
  //       bluetooth.printLeftRight("LEFT", "RIGHT", Size.extraLarge.val);
  //       bluetooth.printNewLine();
  //       bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val);
  //       bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val,
  //           format:
  //               "%-10s %10s %10s %n"); //10 is number off character from left center and right
  //       bluetooth.printNewLine();
  //       bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val);
  //       bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val,
  //           format: "%-8s %7s %7s %7s %n");
  //       bluetooth.printNewLine();
  //       bluetooth.printCustom("čĆžŽšŠ-H-ščđ", Size.bold.val, Align.center.val,
  //           charset: "windows-1250");
  //       bluetooth.printLeftRight("Številka:", "18000001", Size.bold.val,
  //           charset: "windows-1250");
  //       bluetooth.printCustom("Body left", Size.bold.val, Align.left.val);
  //       bluetooth.printCustom("Body right", Size.medium.val, Align.right.val);
  //       bluetooth.printNewLine();
  //       bluetooth.printCustom("Thank You", Size.bold.val, Align.center.val);
  //       bluetooth.printNewLine();
  //       bluetooth.printQRcode(
  //           "Insert Your Own Text to Generate", 200, 200, Align.center.val);
  //       bluetooth.printNewLine();
  //       bluetooth.printNewLine();
  //       bluetooth
  //           .paperCut(); //some printer not supported (sometime making image not centered)
  //       //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
  //     }
  //   });
  // }

  printReceipt(
      String name,
      int tablenumber,
      String note,
      double totalAmount,
      List<dynamic> dataArray,
      String receipt,
      String businessName,
      double amountreceived,
      double change,
      double useCoins,
      context) async {
    DateTime now = DateTime.now();

    String formattedDate = DateFormat('MMMM d, yyyy H:m:s').format(now);

    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = snapshot.data();
    final address = data!['address'] as String;
    final tin = data!['tin'] as String;
    final firstPart = tin.substring(0, 3);
    final secondPart = tin.substring(3, 6);
    final thirdPart = tin.substring(6, 9);
    final fourthPart = tin.substring(9, 12);

    String mytin = '$firstPart-$secondPart-$thirdPart-$fourthPart';

    final _orders = Hive.box('_orders');
    _orders.clear();
    print('print receipt');
    print('name: $name');
    print('tablenumber: $tablenumber');
    print('note: $note');
    print('totalAmount: $totalAmount');
    print('dataARray: $dataArray');
    double grandtotal = 0.0;
    if (name.length > 8) {
      name = name.substring(0, 8) + "..";
    }
    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printCustom("$businessName", 1, 1);
        bluetooth.printCustom(
            "TIN: $mytin\n$address\n Receipt: $receipt\n", 1, 1);
        // bluetooth.printCustom("TAPSIMAN", 1, 1);
        bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
        // bluetooth.printCustom("PRODUCT\t   QUANTITY\tPRICE", 1, 0);
        bluetooth.print3Column('PRODUCT', 'QUANTITY', 'PRICE', 1);
        for (int i = 0; i < dataArray.length; i++) {
          final quantity = int.parse(dataArray[i]['quantity'].toString());
          String productName = dataArray[i]['productName'];
          final productPrice =
              double.parse(dataArray[i]['productPrice'].toString());
          grandtotal += productPrice * quantity;
          if (productName.length > 8) {
            productName = productName.substring(0, 8) + "..";
          }
          bluetooth.print3Column(
              '$productName', '$quantity', '$productPrice', 1);
          // bluetooth.printCustom(
          //     "$productName\t$quantity\t₱$productPrice", 1, 0);
        }
        bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
        bluetooth.printLeftRight('Total:', ' $totalAmount', 1);
        bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
        if (amountreceived != 0.0) {
          bluetooth.printLeftRight('Cash:', ' $amountreceived', 1);
          bluetooth.printLeftRight('Change:', ' $change', 1);
        }

        // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);

        bluetooth.printLeftRight('Use Coin:', ' $useCoins', 1);
        bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
        bluetooth.printCustom("Thankyou for visiting our store", 1, 1);
        bluetooth.printCustom("$formattedDate", 1, 1);
        bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
        bluetooth.printNewLine();
        bluetooth.paperCut();
      } else {
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
                  'PRINT FAILED',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: SizedBox(
                  height: 120,
                  child: Column(
                    children: [
                      FittedBox(child: Text('NOT CONNECTED TO PRINTER')),
                      Text('Please connect to printer!'),
                      SizedBox(height: 10),
                      Divider(
                        thickness: 2,
                      ),
                      Center(
                        child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK',
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
      }
    });
  }

  sample(String route1, String route2) async {
    // String receipt = 'receipt123';
    // String name = 'customer name';
    // int tablenumber = 5;
    // String note = 'paki over heat';
    // double totalAmount = 99;
    // double grandtotal = 0.0;
    // List<dynamic> dataArray = [
    //   {
    //     'productId': '2pHK2RTUQdSL937VBeTt',
    //     'productName': 'ASD',
    //     'productPrice': 99.0,
    //     'quantity': 1,
    //     'note': ''
    //   }
    // ];
    // if (name.length > 12) {
    //   name = name.substring(0, 12) + "..";
    // }

    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT

//     var response = await http.get("IMAGE_URL");
//     Uint8List bytes = response.bodyBytes;
    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        // bluetooth.printNewLine();

//new format

        // bluetooth.printCustom("BUSINESS NAME", 1, 1);
        // bluetooth.printCustom(
        //     "TIN: 000-000-000-000\n  CAVITE, Brgy.Queen's Row, Dulo, Bacoor City\nReceipt: $receipt\nBIR Accr # 000-000000000-000000",
        //     1,
        //     1);
        // bluetooth.printCustom("TAPSIMAN", 1, 1);
        // bluetooth.printCustom("PRODUCT\t\t\tPRICE", 1, 0);
        // for (int i = 0; i < dataArray.length; i++) {
        //   final quantity = dataArray[i]['quantity'] as int;
        //   String productName = dataArray[i]['productName'];
        //   final productPrice = dataArray[i]['productPrice'] as double;
        //   grandtotal += productPrice * quantity;
        //   if (productName.length > 12) {
        //     productName = productName.substring(0, 12) + "..";
        //   }
        //   bluetooth.printCustom("$productName\t\t\t₱$productPrice", 1, 0);
        // }
        // bluetooth.printLeftRight('', 'Total: ₱$grandtotal', 1);
        bluetooth.printCustom("Test Print", 1, 1);
        bluetooth.printCustom("Test Print", 1, 1);
        bluetooth.printCustom("Test Print", 1, 1);
        bluetooth.printCustom("Test Print", 1, 1);
        bluetooth.printCustom("Test Print", 1, 1);
        bluetooth.printCustom("Test Print", 1, 1);
        bluetooth.printCustom("Test Print", 1, 1);

        // bluetooth.printCustom("TIN: NV", 1, 1);
        // bluetooth.printCustom("PERMIT #: ", 1, 1);
        // bluetooth.printImage(pathImage); //path of your image/logo
        // bluetooth.printNewLine();
//      bluetooth.printImageBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        // bluetooth.printLeftRight("Ticket number:", "e6f225", 1);
        // bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
        // bluetooth.printCustom("Route: TAGBAK - ILOILO CITY", 1, 0);
        // bluetooth.printNewLine();

        // bluetooth.printCustom(
        //     "OFFICIAL RECEIPT #01377\n - - - - - - - - - - - - - - -", 1, 1);
        // bluetooth.drawerPin5();
        // bluetooth.printCustom(" - - - - - - - - - - - - - - -", 1, 0);
        // bluetooth.printNewLine();
        // bluetooth.printLeftRight("LEFT", "RIGHT", 1, format: "%-15s %15s %n");
        // bluetooth.printNewLine();
        // bluetooth.printLeftRight("LEFT", "RIGHT", 2);
        // bluetooth.printLeftRight("LEFT", "RIGHT", 3);
        // bluetooth.printLeftRight("LEFT", "RIGHT", 4);
        // bluetooth.printNewLine();
        // customPrint3Column("Date:   ", "2023-10-09   ", "15:08:46", 1);
        // bluetooth.printLeftRight("Bus Number:", "Bus No. 42", 1);
        // // bluetooth.printNewLine();
        // bluetooth.printLeftRight("Payment Method:", "Cash", 1);
        // bluetooth.printCustom("Type of Passenger:      Regular", 1, 0);
        // bluetooth.printCustom("Origin:\t\t $route1", 1, 0);
        // bluetooth.printCustom("Destination:\t $route2", 1, 0);
        // bluetooth.printLeftRight("Total KM:", "1KM ", 1);
        // bluetooth.printLeftRight("Discount:", "-- ", 1);
        // bluetooth.printLeftRight(
        //     "Total Amount:", "₱14.00 \n - - - - - - - - - - - - - - -", 1);
        // bluetooth.printCustom(
        //     "THIS IS AN OFFICIAL RECEIPT\n - - - - - - - - - - - - - - -",
        //     1,
        //     1);
        // bluetooth.printCustom(" - - - - - - - - - - - - - - -", 1, 0);
        // bluetooth.printLeftRight("Fare:", "₱20.75", 1);
        // bluetooth.printLeftRight("Discount:", "--", 1);
        // bluetooth.printNewLine();
        // bluetooth.printLeftRight(
        //     "Total Amount:", "₱20.75\n\n - - - - - - - - - - - - - - -", 1);
        // bluetooth.drawerPin2();
        // bluetooth.printLeftRight("- - - - - - - - - - - - - - -", "", 1);
        // bluetooth.printCustom(" - - - - - - - - - - - - - - -", 1, 0);
        // bluetooth.printQRcode("https://seapps-inc.com/", 120, 120, 1);
        // bluetooth.printCustom("THANK YOU", 1, 1);
        // bluetooth.printCustom(" - - - - - - - - - - - - - - -", 1, 1);
        // bluetooth.printNewLine();
        // bluetooth.drawerPin2();
        // bluetooth.drawerPin5();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();

        //mistcoop
//         bluetooth.printCustom(
//             "METRO ILOILO TRANSPORT SERCVICE\nCOOP\nPowered by FILIPAY\nTIN: NV\nPERMIT #: ",
//             1,
//             1);
//         // bluetooth.printCustom("COOP", 1, 1);
//         // bluetooth.printCustom("Powered by FILIPAY", 1, 1);
//         // bluetooth.printCustom("TIN: NV", 1, 1);
//         // bluetooth.printCustom("PERMIT #: ", 1, 1);
//         // bluetooth.printImage(pathImage); //path of your image/logo
//         // bluetooth.printNewLine();
// //      bluetooth.printImageBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
//         bluetooth.printLeftRight("Ticket number:", "e6f225", 1);
//         bluetooth.printCustom("Route: TAGBAK - ILOILO CITY", 1, 0);
//         // bluetooth.printNewLine();
//         bluetooth.printCustom(
//             "OFFICIAL RECEIPT #01377\n - - - - - - - - - - - - - - -", 1, 1);
//         // bluetooth.drawerPin5();
//         // bluetooth.printCustom(" - - - - - - - - - - - - - - -", 1, 0);
//         // bluetooth.printNewLine();
//         // bluetooth.printLeftRight("LEFT", "RIGHT", 1, format: "%-15s %15s %n");
//         // bluetooth.printNewLine();
//         // bluetooth.printLeftRight("LEFT", "RIGHT", 2);
//         // bluetooth.printLeftRight("LEFT", "RIGHT", 3);
//         // bluetooth.printLeftRight("LEFT", "RIGHT", 4);
//         // bluetooth.printNewLine();
//         customPrint3Column("Date:   ", "2023-10-09   ", "15:08:46", 1);
//         bluetooth.printLeftRight("Bus Number:", "Bus No. 42", 1);
//         // bluetooth.printNewLine();
//         bluetooth.printLeftRight("Payment Method:", "Cash", 1);
//         bluetooth.printCustom("Type of Passenger:      Regular", 1, 0);
//         bluetooth.printCustom("From:\t\t $route1", 1, 0);
//         bluetooth.printCustom("To:\t\t $route2", 1, 0);
//         bluetooth.printLeftRight("Discount:", "-- ", 1);
//         bluetooth.printLeftRight("Total KM:", "1KM ", 1);
//         bluetooth.printLeftRight("Total Amount:", "₱14.00 ", 1);
//         bluetooth.printCustom(" - - - - - - - - - - - - - - -", 1, 0);
//         // bluetooth.printLeftRight("Fare:", "₱20.75", 1);
//         // bluetooth.printLeftRight("Discount:", "--", 1);
//         // bluetooth.printNewLine();
//         // bluetooth.printLeftRight(
//         //     "Total Amount:", "₱20.75\n\n - - - - - - - - - - - - - - -", 1);
//         // bluetooth.drawerPin2();
//         // bluetooth.printLeftRight("- - - - - - - - - - - - - - -", "", 1);
//         // bluetooth.printCustom(" - - - - - - - - - - - - - - -", 1, 0);
//         // bluetooth.printQRcode("https://seapps-inc.com/", 120, 120, 1);
//         // bluetooth.printCustom("THANK YOU", 1, 1);
//         // bluetooth.printCustom(" - - - - - - - - - - - - - - -", 1, 1);
//         // bluetooth.printNewLine();
//         // bluetooth.drawerPin2();
//         // bluetooth.drawerPin5();
//         bluetooth.printNewLine();
//         bluetooth.paperCut();
        // bluetooth.printCustom("METRO ILOILO TRANSPORT SERCVICE", 1, 1);
      }

      // print(arrproductName);
//       if (isConnected == true) {
//         bluetooth.printNewLine();
//         bluetooth.printCustom("CodeHub POS", 3, 1);
//         bluetooth.printNewLine();
//         bluetooth.printCustom("SALES INVOICE", 3, 1);
//         // bluetooth.printImage(pathImage); //path of your image/logo
//         bluetooth.printNewLine();
// //      bluetooth.printImageBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
//         bluetooth.printLeftRight("LEFT", "RIGHT", 0);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 1);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 1, format: "%-15s %15s %n");
//         bluetooth.printNewLine();
//         bluetooth.printLeftRight("LEFT", "RIGHT", 2);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 3);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 4);
//         bluetooth.printNewLine();
//         bluetooth.print3Column("Col1", "Col2", "Col3", 1);
//         bluetooth.print3Column("Col1", "Col2", "Col3", 1,
//             format: "%-10s %10s %10s %n");
//         bluetooth.printNewLine();
//         bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", 1);
//         bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", 1,
//             format: "%-8s %7s %7s %7s %n");
//         bluetooth.printNewLine();
//         String testString = " čĆžŽšŠ-H-ščđ";
//         bluetooth.printCustom(testString, 1, 1, charset: "windows-1250");
//         bluetooth.printLeftRight("Številka:", "18000001", 1,
//             charset: "windows-1250");
//         bluetooth.printCustom("Body left", 1, 0);
//         bluetooth.printCustom("Body right", 0, 2);
//         bluetooth.printNewLine();
//         bluetooth.printCustom("Thank You", 2, 1);
//         bluetooth.printNewLine();
//         bluetooth.printQRcode("Insert Your Own Text to Generate", 200, 200, 1);
//         bluetooth.printNewLine();
//         bluetooth.printNewLine();
//         bluetooth.paperCut();
//       }
    });
  }
}

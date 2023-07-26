import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'package:user/customer/pages/playandwin.dart';

class FLipCardPage extends StatefulWidget {
  const FLipCardPage({super.key});

  @override
  State<FLipCardPage> createState() => _FLipCardPageState();
}

class _FLipCardPageState extends State<FLipCardPage> {
  Color maincolor = Color(0xFFa02e49);

  // GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  List<GlobalKey<FlipCardState>> cardKey = [];
  List<bool> _cardFlips = [];
  List<String> _cardContents = [];
  List<String> _cardRewards = [];
  int _flippedCardIndex = -1;
  bool _isDisabled = false;
  String? winVoucher;

  Future<void> _addVoucher(String rewards) async {
    double coin = 0.0;
    final prefs = await SharedPreferences.getInstance();
    String CstoreId = prefs.getString('storeId') ?? '';
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;
    final voucherCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('voucher');

    final currentDate = DateTime.now();
    if (rewards == '2') {
      coin = 2;
    } else if (rewards == '0.5') {
      coin = 0.5;
    } else if (rewards == '0.3') {
      coin = 0.3;
    } else if (rewards == '1') {
      coin = 1.0;
    } else if (rewards == '1.5') {
      coin = 1.5;
    } else if (rewards == '1.2') {
      coin = 1.2;
    } else if (rewards == '0.8') {
      coin = 0.8;
    } else if (rewards == '1.7') {
      coin = 1.7;
    } else if (rewards == '2') {
      coin = 2;
    } else if (rewards == '3') {
      coin = 3;
    }
    DocumentReference updateDateToken =
        FirebaseFirestore.instance.collection('users').doc(userId);
    await updateDateToken.update(
        {'dailytokendate': currentDate, 'coin': FieldValue.increment(coin)});
    voucherCollection
        .add({
          'productType': 'voucher',
          'voucherName': '$winVoucher Coin',
          'date': currentDate,
          'storeId': CstoreId,
          'used': false
        })
        .then((value) => print('Expense data added successfully!'))
        .catchError((error) => print('Failed to add expense data: $error'));
  }

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  void _initializeCards() {
    cardKey = List.generate(9, (index) => GlobalKey<FlipCardState>());
    _cardFlips = List.generate(9, (index) => false);
    _cardContents = List.generate(9, (index) => 'Click to flip');
    _cardRewards = _generateRandomRewards();
  }

  List<String> _generateRandomRewards() {
    final random = Random();
    final rewards = [
      '0.3',
      '0.5',
      '0.8',
      '1',
      '1.2',
      '1.5',
      '1.7',
      '2',
      '3',
    ];

    rewards.shuffle(random);
    return rewards;
  }

  void flipcard(int i, String reward) {
    setState(() {
      _isDisabled = true;
      _cardFlips = List.generate(9, (index) => true);
    });
  }

  void _flipCard(int index, String reward) {
    if (_isDisabled) {
      return;
    }
    setState(() {
      winVoucher = reward;
      _isDisabled = true;
    });
    _addVoucher(reward);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    children: [
                      Text(
                        'Congratulations!',
                        style: TextStyle(
                            color: maincolor,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: Center(
                                child: Text(
                                  'You won a $reward Coin!',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        'images/reward-voucher.png',
                        width: MediaQuery.of(context).size.height * 0.2,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlayAndWinPage(),
                ),
              );
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        elevation: 0,
        title: Text('PLAY & WIN'),
        backgroundColor: maincolor,
      ),
      body: Container(
        color: maincolor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.61,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: FlipCard(
                          key: cardKey[index],
                          flipOnTouch: false,
                          // fill: Fill
                          //     .fillBack, // Fill the back side of the card to make in the same size as the front.
                          // direction: FlipDirection.HORIZONTAL, // default
                          // side:
                          //     CardSide.FRONT, // The side to initially display.
                          front: GestureDetector(
                            onTap: () {
                              if (!_isDisabled) {
                                cardKey[index].currentState!.toggleCard();
                                _flipCard(index, _cardRewards[index]);
                              }
                              // cardKey[index].currentState!.toggleCard();
                              // _flipCard(index, _cardRewards[index]);
                            },
                            child: Container(
                              width: 200,
                              height: 500,
                              decoration: BoxDecoration(
                                  color: Color(0xFFc96f6f),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 30.0, horizontal: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'images/logo.png',
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          back: Container(
                            width: 200,
                            height: 500,
                            decoration: BoxDecoration(
                                color: Color(0xFFc96f6f),
                                borderRadius: BorderRadius.circular(30)),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 30.0, horizontal: 10),
                                child: Center(
                                    child: Text(
                                  '${_cardRewards[index]} Coin',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ))),
                          ),
                        )
                        //  FlipCard(
                        //   fill: Fill.fillBack,
                        //   side: CardSide.FRONT,
                        //   // flipOnTouch: true,
                        //   direction: FlipDirection.HORIZONTAL,
                        //   front:
                        //       // Card(
                        //       //   child: InkWell(
                        //       //     onTap: () => _flipCard(index, _cardRewards[index]),
                        //       //     child: Center(
                        //       //       child: Text(
                        //       //         _cardContents[index],
                        //       //         style: TextStyle(fontSize: 20.0),
                        //       //       ),
                        //       //     ),
                        //       //   ),
                        //       // ),
                        //       GestureDetector(
                        //     onTap: () {
                        //       _flipCard(index, _cardRewards[index]);
                        //     },
                        //     child: Container(
                        //       width: 200,
                        //       height: 500,
                        //       decoration: BoxDecoration(
                        //           color: Color(0xFFc96f6f),
                        //           borderRadius: BorderRadius.circular(30)),
                        //       child: Padding(
                        //         padding: const EdgeInsets.symmetric(
                        //             vertical: 30.0, horizontal: 10),
                        //         child: ClipRRect(
                        //           borderRadius: BorderRadius.circular(100),
                        //           child: Container(
                        //             decoration: BoxDecoration(
                        //                 color: Colors.white,
                        //                 image: DecorationImage(
                        //                   image: AssetImage(
                        //                     'images/logo.png',
                        //                   ),
                        //                 )),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        //   back: Card(
                        //     child:
                        //         // Center(
                        //         //   child: Text(
                        //         //     _cardRewards[index],
                        //         //     style: TextStyle(fontSize: 20.0),
                        //         //   ),
                        //         // ),
                        //         Container(
                        //             width: 200,
                        //             height: 500,
                        //             decoration: BoxDecoration(
                        //                 color: Color(0xFFc96f6f),
                        //                 borderRadius: BorderRadius.circular(30)),
                        //             child: Padding(
                        //               padding: const EdgeInsets.symmetric(
                        //                   vertical: 30.0, horizontal: 10),
                        //               child: Text(
                        //                 _cardRewards[index],
                        //                 style: TextStyle(fontSize: 20.0),
                        //               ),
                        //             )),
                        //   ),
                        // ),
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

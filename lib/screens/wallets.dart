// import 'package:flutter3_firestore_driver/screens/auto_update.dart';
// import 'package:flutter3_firestore_driver/screens/profile_update.dart';
import 'package:flutter3_firestore_driver/screens/auto_update.dart';
import 'package:flutter3_firestore_driver/screens/login_ui.dart';
import 'package:flutter3_firestore_driver/screens/profile_update.dart';
import 'package:flutter3_firestore_driver/screens/sign_screen.dart';
// import 'package:flutter3_firestore_driver/screens/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/driver_data.dart';
import '../models/new_trip_history.dart';
//import '../models/users.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Wallets extends StatefulWidget {
  static const String id = 'Wallet';
  Wallets({Key? key}) : super(key: key);

  @override
  State<Wallets> createState() => _WalletsState();
}

class _WalletsState extends State<Wallets> {
  String? _userId;

  DriverData? user;

  double total = 0;

  String commision = "0\$";
  String trips = "0";
  String wallet = "0\$";

  DatabaseReference postListRef = FirebaseDatabase.instance.ref("orders");

  @override
  void initState() {
    super.initState();

    var currentUser_uid = FirebaseAuth.instance.currentUser!.uid;

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("wallets")
    //     .child(currentUser_uid)
    //     .once()
    //     .then((snap) {
    //   if (snap.snapshot.value != null) {
    //     setState(() {
    //       commision =
    //           (snap.snapshot.value as Map)['commision'].toString() + "\$";
    //       trips = (snap.snapshot.value as Map)['trips'].toString();
    //       wallet = (snap.snapshot.value as Map)['wallet'].toString() + "\$";
    //       // user = Users.fromSnapshot(snap.snapshot);

    //       // print("driver_details");
    //       // print(user);
    //     });
    //   }
    // });

    //getUsers();
    // final ordersRef = FirebaseDatabase.instance
    //     .ref("orders")
    //     .orderByChild("driverId")
    //     .equalTo(currentUser_uid)
    //     .get();

    // print("ordersRef");
    // print(ordersRef);

    // FirebaseDatabase.instance
    //     .ref("orders")
    //     .orderByChild("driverId")
    //     .equalTo(currentUser_uid)
    //     .once()
    //     .then((snap) {
    //   if (snap.snapshot.value != null) {
    //     print(snap.snapshot.value);

    //     final myMessages = Map<dynamic, dynamic>.from(
    //         (snap.snapshot.value as DatabaseEvent).snapshot.value
    //             as Map<dynamic, dynamic>);

    //     myMessages.forEach((key, value) {
    //       final currentMessage = Map<String, dynamic>.from(value);
    //       print("currentMessage");
    //       print(currentMessage);
    //     }); //
    //   }
    // });
    // final ref = FirebaseDatabase.instance.ref();

    FirebaseFirestore.instance
        .collection('drivers')
        .doc(currentUser_uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          user = DriverData.fromDocument(documentSnapshot);

          print("user_info");
          print(user);
        });

        // print("driverInfoCounting");
        // print(driverInfo);

        print("newAverageRatings");
        // print(user!.displayName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Profile",
          style: TextStyle(
            fontFamily: 'medium',
            color: Colors.white,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildProfile(),
                    SizedBox(height: 80),
                    // _buildOrderList(),
                  ],
                ),
                // Positioned(
                //     top: 80,
                //     width: MediaQuery.of(context).size.width * 1,
                //     child: _buildBalanceDtl()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 20.0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdateProfile()));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  color: Colors.orangeAccent,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text('Edit Profile',
                                        style: TextStyle(
                                            color: Colors.orangeAccent)),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.orangeAccent,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          InkWell(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => ProfileUpdate()));
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AutoUpdate()));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_taxi,
                                  color: Colors.orangeAccent,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text('Edit Auto',
                                        style: TextStyle(
                                            color: Colors.orangeAccent)),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.orangeAccent,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          // InkWell(
                          //   onTap: () {
                          //     // Navigator.push(
                          //     //     context,
                          //     //     MaterialPageRoute(
                          //     //         builder: (context) => ProfileUpdate()));
                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => WalletScreen()));
                          //   },
                          //   child: Row(
                          //     children: [
                          //       Icon(
                          //         Icons.local_taxi,
                          //         color: Colors.deepOrange,
                          //       ),
                          //       Expanded(
                          //         child: Padding(
                          //           padding: EdgeInsets.only(left: 10),
                          //           child: Text('Wallet',
                          //               style:
                          //                   TextStyle(color: Colors.deepOrange)),
                          //         ),
                          //       ),
                          //       Icon(
                          //         Icons.chevron_right,
                          //         color: Colors.deepOrange,
                          //       )
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 30,
                          // ),
                          InkWell(
                            onTap: () {
                              FirebaseAuth.instance.signOut();

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginUI()));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_outlined,
                                  color: Colors.orangeAccent,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text('Log Out',
                                        style: TextStyle(
                                            color: Colors.orangeAccent)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    var currentUser_uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream:
          postListRef.orderByChild("driverId").equalTo(currentUser_uid).onValue,
      builder: (context, snapshot) {
        List<NewTripHistory> messageList = [];
        if (snapshot.hasData &&
            snapshot.data != null &&
            (snapshot.data! as DatabaseEvent).snapshot.value != null) {
          final myMessages = Map<dynamic, dynamic>.from(
              (snapshot.data! as DatabaseEvent).snapshot.value
                  as Map<dynamic, dynamic>); //typecasting
          myMessages.forEach((key, value) {
            final currentMessage = Map<String, dynamic>.from(value);

            messageList.add(NewTripHistory(
              originAddress: currentMessage['originAddress'],
              destinationAddress: currentMessage['destinationAddress'],
              status: currentMessage['status'],
              userName: currentMessage['userName'],
              userPhone: currentMessage['userPhone'],
              time: currentMessage['time'],
              timestamp: currentMessage['timestamp'].toString(),
              fareAmount: currentMessage['totalPayment'],
            ));
          }); //created a class called message and added all messages in a List of class message
          return ListView.builder(
            itemCount: messageList.length,
            itemBuilder: (context, index) {
              setState(() {
                total = total + double.parse(messageList[index].fareAmount!);
                print("total");
                print(total);
              });
              return GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => OrderDetails(
                  //             orderId: messageList[index].timestamp)));
                },
              );
            },
          );
        } else {
          return Center(
            child: Text(
              'Say Hi...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w400),
            ),
          );
        }
      },
    );
  }

  shadowBox() {
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.deepOrange.shade100,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 0.25))
        ]);
  }

  nameLabel() {
    return TextStyle(fontFamily: 'medium', fontSize: 15, color: Colors.white);
  }

  boldLabel() {
    return TextStyle(
        fontFamily: 'medium', fontSize: 15, color: Colors.deepOrange);
  }

  greyLabel() {
    return TextStyle(color: Colors.deepOrange);
  }

  Widget _buildProfile() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.orangeAccent.shade100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('${user?.photoURL}'
                //'assets/payment.png',
                //'${user?.photoURL}',
                ),
            radius: 24,

            // Image.network(
            //   ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${user?.name}' ' ${user?.name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  )),
              SizedBox(height: 6),
              Text('${user?.email}',
                  style: TextStyle(
                    fontFamily: 'medium',
                    fontSize: 14,
                    color: Colors.white,
                  )),
              SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDtl() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              new BoxShadow(
                color: Colors.black12,
                blurRadius: 20.0,
              )
            ]),
        child: Column(
          children: [
            Column(
              children: [
                Text("My Balance:",
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 16,
                    )),
                SizedBox(height: 8),
                Text(wallet,
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontFamily: 'medium',
                      fontSize: 24,
                    )),
              ],
            ),
            SizedBox(height: 10),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        child: Text(
                          "Total Trips:",
                          style: TextStyle(
                              fontSize: 13, color: Colors.orangeAccent),
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        child: Text(
                          trips,
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'medium',
                              color: Colors.orangeAccent),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        child: Text(
                          "Total Commision:",
                          style: TextStyle(
                              fontSize: 13, color: Colors.orangeAccent),
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        child: Text(
                          commision,
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'medium',
                              color: Colors.orangeAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

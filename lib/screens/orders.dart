import 'dart:async';

import 'package:flutter3_firestore_driver/main_variables/main_variables.dart';
// import 'package:flutter3_firestore_passenger/screens/order_details.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3_firestore_driver/screens/order_details.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../backend/booking_collection.dart';
import '../providers/location_provider.dart';
import '../models/new_trip_history.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/radiant_gradient_mask.dart';

class Orders extends StatefulWidget {
  Orders({Key? key}) : super(key: key);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  String? _userId;
  late final Stream<QuerySnapshot> _orderStream;

  @override
  void initState() {
    super.initState();

    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      print(currentUser.uid);

      setState(() {
        //_user = User.fromDocument(doc);
        _userId = currentUser.uid;
      });
    }

    setState(() {
      _orderStream = FirebaseFirestore.instance
          .collection('orders')
          .where('driverId', isEqualTo: currentUser?.uid)
          .snapshots();
    });

    print("widget.currentLatitude");
  }

  buildNoContent() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.lightGreen),
      ),
    );
  }

  shadowBox() {
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.orangeAccent.shade100,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 0.25))
        ]);
  }

  nameLabel() {
    return TextStyle(fontFamily: 'medium', fontSize: 15);
  }

  boldLabel() {
    return TextStyle(fontFamily: 'medium');
  }

  greyLabel() {
    return TextStyle(color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        title: Text(
          "Bookings",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        //widget
      ), //appBar
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("bookings").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildNoContent();
          }

          return ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () => FirebaseFunction().getCurrentLocation(
                      snapshot.data!.docs[index]['uid'],
                      snapshot.data!.docs[index]['uid'],
                      context,
                      snapshot.data!.docs[index]['clientToken']),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(
                    //       image: AssetImage(Assets.card_bg), fit: BoxFit.cover),
                    // ),
                    child: Column(
                      children: [
                        ListTile(
                          title: RadiantGradientMask(
                            child: Text(
                                snapshot.data!.docs[index]['serviceType'],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(fontSize: 18)),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                  snapshot.data!.docs[index]
                                              ['pickupLocation'] !=
                                          null
                                      ? snapshot.data!.docs[index]
                                          ['pickupLocation']
                                      : "Loading...",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(""),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                      snapshot.data!.docs[index]
                                          ['carSelection'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(fontSize: 13))
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(""),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                      "${DateTime.fromMillisecondsSinceEpoch(snapshot.data!.docs[index]['requestedTime'])}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(fontSize: 13))
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(""),
                                  SizedBox(
                                    width: 15,
                                  ),
                                ],
                              ),
                              // SizedBox(
                              //   height: 20,
                              // ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter3_firestore_driver/main_variables/main_variables.dart';
import 'package:flutter3_firestore_driver/models/user_ride_request_information.dart';
import 'package:flutter3_firestore_driver/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/deal_info.dart';
import '../providers/google_map_provider.dart';
import '../progress/progress_dialog.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompleteTrip extends StatefulWidget {
  String? orderId;
  String? dealId;
  CompleteTrip({Key? key, this.orderId, this.dealId}) : super(key: key);

  @override
  State<CompleteTrip> createState() => _CompleteTripState();
}

class _CompleteTripState extends State<CompleteTrip> {
  startTimer() {
    Timer(const Duration(seconds: 5), () async {
      FirebaseFirestore.instance
          .collection('deals')
          .doc(currentFirebaseUser!.uid)
          .delete()
          .then((value) {
        print("delated deal info");
      });
    });
  }

  List<Item> time = <Item>[
    const Item('5\$'),
    const Item('10\$'),
    const Item('20\$'),
    const Item('custom'),
  ];

  var _value;

  double? originLat;
  double? originLong;

  double? destLat;
  double? destLong;

  String? destName;
  String? originName;

  String? userPhoto;
  String? userName;
  String? userPhone;
  String? driverType;
  String? driverRating;
  String? carBrand;
  String? carModel;
  String? carNumber;
  String? pincode;
  String? duration;
  String? distance;
  String? totalPayment;

  String? startAddress;
  String? destinationAddress;
  String? endAddress;
  String? timeDate;
  String? commision;
  String? subTotalValue;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        //String deviceRegistrationToken = documentSnapshot.data()["token"];

        print("documentSnapshot.data");
        print(documentSnapshot.data());

        var dealInfo2 = DealInfo.fromDocument(documentSnapshot);

        double timeTraveledFareAmountPerMinute =
            (double.parse(dealInfo2.duration!) / 60).truncate().toDouble();
        double distanceTraveledFareAmountPerKilometer =
            (double.parse(dealInfo2.distance!) / 1000).truncate().toDouble();

        double subTotal = double.parse(dealInfo2.totalPayment.toString()) -
            double.parse(dealInfo2.commision.toString());

        setState(() {
          userPhoto = dealInfo2.userPhoto;
          userName = dealInfo2.userName;
          userPhone = dealInfo2.userPhone;
          driverRating = dealInfo2.driverRating;
          driverType = dealInfo2.driverType;
          carBrand = dealInfo2.carBrand;
          carModel = dealInfo2.carModel;
          carNumber = dealInfo2.carNumber;
          pincode = dealInfo2.pincode;
          startAddress = dealInfo2.originAddress;
          endAddress = dealInfo2.destinationAddress;
          distance = distanceTraveledFareAmountPerKilometer.toString();
          duration = timeTraveledFareAmountPerMinute.toString();
          totalPayment = dealInfo2.totalPayment;
          timeDate = dealInfo2.time;
          commision = dealInfo2.commision.toString() + "\$";
          subTotalValue = subTotal.toString() + "\$";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    startTimer();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppbar(),
      body: _buildBody(),
      bottomNavigationBar: _bottomNav(),
    );
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.redAccent.shade100,
      iconTheme: IconThemeData(color: Colors.white),
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'Order ID: ' + widget.orderId!,
        style: TextStyle(
            color: Colors.white, fontFamily: "semibold", fontSize: 16),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLocation(),
          // _buildBoldFont('order Summary', '7 items'),
          _buildItems(),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_city,
                size: 24,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startAddress ?? "not getting address",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: "semibold"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_searching,
                size: 24,
                color: Colors.deepOrange,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      endAddress ?? "end address",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: "semibold"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(thickness: 1, color: Colors.black12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: "semibold")),
              Row(
                children: [
                  Text(timeDate ?? "2022-05-31",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontFamily: "medium")),
                  SizedBox(width: 5),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
          Divider(thickness: 1, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildBoldFont(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.orangeAccent,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$text',
            style: TextStyle(
                color: Colors.black54, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            '$item',
            style: TextStyle(
                color: Colors.black54, fontSize: 14, fontFamily: 'medium'),
          ),
        ],
      ),
    );
  }

  Widget _buildItems() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Driver Information',
              style: TextStyle(
                  color: Colors.black, fontSize: 16, fontFamily: "semibold")),
          Divider(thickness: 1, color: Colors.black12),
          _buildCartAll(),

          Divider(thickness: 1, color: Colors.black12),
          _buildDistance('Distance', 'Rs120.00'),
          _buildDuration('Duration', '-Rs120.00'),
          _buildCommision('Commision fee', 'Rs4.00'),
          _buildTotal('Total', 'Rs5.00'),

          // _buildBill('Tip for Driver', 'Rs10.00'),
        ],
      ),
    );
  }

  chipList() {
    return Wrap(
      spacing: 10.0,
      children: time.map((e) {
        return _buildChip(
          e.text,
        );
      }).toList(),
    );
  }

  Widget _buildChip(name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ChoiceChip(
        label: Text(name),
        labelPadding: const EdgeInsets.symmetric(horizontal: 15),
        selected: _value == name,
        selectedColor: Colors.orangeAccent,
        onSelected: (bool value) {
          setState(() {
            _value = value ? name : null;
          });
        },
        backgroundColor: Colors.grey,
        labelStyle: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBill(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$text',
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            distance ?? "0 km",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'bold'),
          ),
        ],
      ),
    );
  }

  Widget _buildDistance(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$text',
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            distance ?? "0 km",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'bold'),
          ),
        ],
      ),
    );
  }

  Widget _buildDuration(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$text',
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            duration ?? "0 km",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'bold'),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$text',
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            subTotalValue ?? "0 km",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'bold'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommision(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$text',
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            commision ?? "0 km",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'bold'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartAll() {
    return Column(
      children: [
        _buildCartItem(),
      ],
    );
  }

  Widget _buildCartItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildDriverInfo(),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepOrange),
              borderRadius: BorderRadius.circular(100),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SizedBox.fromSize(
                size: Size.fromRadius(40),
                child: FittedBox(
                  //child: Image.asset('images/Elegant.png'),
                  child: Image.network(userPhoto ?? 'images/Elegant.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          userName ?? "Driver name",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'bold',
                              fontSize: 18,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     SizedBox(
                  //       width: 120,
                  //       child: SmoothStarRating(
                  //         rating: double.parse(driverRating ?? "0"),
                  //         color: Colors.black,
                  //         borderColor: Colors.deepOrange,
                  //         allowHalfRating: true,
                  //         starCount: 5,
                  //         size: 15,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          children: [
                            Text(
                              userPhone ?? "Driver Phone",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Column(
              children: [
                Chip(
                  shadowColor: Colors.redAccent.shade100,
                  backgroundColor: Colors.redAccent.shade100,
                  label: Text(totalPayment ?? "0",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomItem() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: Text("Medium size",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black45, fontSize: 12)),
              ),
              Text("Edit",
                  style: TextStyle(
                      color: Colors.blue, fontSize: 12, fontFamily: "medium")),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Container(
                color: Colors.black54,
                child: const Text(" % ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: "semibold")),
              ),
              const SizedBox(width: 5),
              const Text("Note to Restauratn",
                  style: TextStyle(color: Colors.black45, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text("Rs300",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'semibold',
                          fontSize: 14)),
                  SizedBox(width: 10),
                  Text("Rs450",
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      height: 90.0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                    color: Colors.black54, fontFamily: "medium", fontSize: 20),
              ),
              Row(
                children: [
                  Text(totalPayment ?? "0",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'semibold',
                          fontSize: 20)),
                  SizedBox(width: 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              child: const Text("Finish Trip",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "medium",
                  )),
              onPressed: () {
                SystemNavigator.pop();

                Fluttertoast.showToast(msg: "Please Restart App Now");
                //_rateDriverBottomSheet(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrange,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Item {
  const Item(this.text);
  final String text;
}

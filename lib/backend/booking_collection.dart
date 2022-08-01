import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
// import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseFunction {
  final firebaseFirestore = FirebaseFirestore.instance;
  final firebaseUserId = FirebaseAuth.instance;

  double? lat;
  double? lng;
  Location location = Location();
  LocationData? _locationData;

  List testingCoodinates = [
    {"lat": -1.24847, "long": 36.78191},
    {"lat": -1.24851, "long": 36.782},
    {"lat": -1.24852, "long": 36.78216},
    {"lat": -1.24844, "long": 36.78228},
    {"lat": -1.24838, "long": 36.78244},
    {"lat": -1.2487, "long": 36.78312},
    {"lat": -1.24882, "long": 36.78343},
    {"lat": -1.24892, "long": 36.7837},
    {"lat": -1.24896, "long": 36.78397},
    {"lat": -1.24954, "long": 36.78489},
    {"lat": -1.24911, "long": 36.78431},
    {"lat": -1.24929, "long": 36.78461},
    {"lat": -1.24954, "long": 36.78489},
    {"lat": -1.24961, "long": 36.78495},
    {"lat": -1.24985, "long": 36.78511},

    {"lat": -1.25008, "long": 36.78482},
    {"lat": -1.24993, "long": 36.78469},

    {"lat": -1.24993, "long": 36.78469},
    {"lat": -1.24982, "long": 36.78454},
    {"lat": -1.24973, "long": 36.78435},
    {"lat": -1.2493, "long": 36.78317},
    {"lat": -1.24908, "long": 36.78261},
    {"lat": -1.24842, "long": 36.78117},
    {"lat": -1.2482, "long": 36.78069},
    {"lat": -1.24795, "long": 36.78004},
    {"lat": -1.24762, "long": 36.77931},

    {"lat": -1.24759, "long": 36.77925},
    {"lat": -1.24741, "long": 36.77901},

//

    {"lat": -1.24738, "long": 36.77895},
    {"lat": -1.24734, "long": 36.77886},
    {"lat": -1.24736, "long": 36.77884},

    {"lat": -1.24749, "long": 36.77875},
    {"lat": -1.2478, "long": 36.77846},
    {"lat": -1.24814, "long": 36.77804},
    {"lat": -1.24825, "long": 36.77789},
    {"lat": -1.24808, "long": 36.77758},
    {"lat": -1.2481, "long": 36.77744},
    {"lat": -1.24817, "long": 36.77731},
  ];

  // void acessRegistrationToken(
  //     String bookingID, String uid, BuildContext context) async {
  //   final fcmToken = await FirebaseMessaging.instance.getToken().then((values) {
  //     for (var i = 0; testingCoodinates.length > i; i++) {
  //       FirebaseFirestore.instance
  //           .collection("tracking")
  //           .doc("ni6E5jZty8XXe67Cqo3sKWdKvIg2-booking-1659202411390")
  //           .update({
  //         "driverToken": values,
  //         'driverLng': testingCoodinates[i]['lat'],
  //         'driverLng': testingCoodinates[i]['long']
  //       }).then((value) => changeProgress(values!, uid, context));
  //     }
  //   });
  //   FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
  //     FirebaseFirestore.instance
  //         .collection("driverToken")
  //         .doc()
  //         .set({"deviceToken": fcmToken}).then((value) => print("success"));

  //     // Note: This callback is fired at each app startup and whenever a new
  //     // token is generated.

  // })
  // }}

  void acessRegistrationToken(String uid, BuildContext context) async {
    for (var i = 0; testingCoodinates.length > i; i++) {
      await Future.delayed(Duration(seconds: 2)).then((value) {
        FirebaseFirestore.instance.collection("tracking").doc(uid).update({
          "driverToken":
              "d5b-eTUIRlyIkXX-V48r6a:APA91bGd6W2U8rvDGZjIt3jLv6Bi7wuiy72VmFD0hXb-T54DMIRWS7pjl4UV6KVfEgDBhtwHEUcksLQ8Zv9vd5yn-elHZLN806-5DDT0oKggVsjKbrqpebe0yzY_jd7oq2Or01uzGVUz",
          'driverlat': testingCoodinates[i]['lat'],
          'driverLng': testingCoodinates[i]['long']
        });
      });
    }
  }

  void getCurrentLocation(String bookingID, String uid, BuildContext context,
      String clientToken) async {
    _locationData = await location.getLocation();
    if (_locationData != null) {
      lat = _locationData!.latitude;
      lng = _locationData!.longitude;
      acessRegistrationToken(bookingID, context);
      sendPushNotificationToSeller(
          "Driver on their way to pick up your car.", clientToken);
    }
    print("-----$_locationData-------");
  }

  void changeProgress(String value, String uid, BuildContext context) {
    firebaseFirestore.collection("bookings").doc(uid).update({
      "rider": firebaseUserId.currentUser!.uid,
      "assigner": value,
      "vendorAcceptiance": DateTime.now()
    }).then((value) {
      FirebaseMessaging.instance.getToken().then((value) {
        Fluttertoast.showToast(
            msg: "Request Accepted.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            // backgroundColor: Theme.of(context).backgroundColor,
            // textColor: Colors.white,
            fontSize: 14.0);
      }).onError((error, stackTrace) {
        Fluttertoast.showToast(
            msg:
                "Failed to accept.Check your internet connection and try again.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            // backgroundColor: Theme.of(context).backgroundColor,
            // textColor: Colors.white,
            fontSize: 14.0);
      });
    });
  }

  void sendPushNotificationToSeller(String body, String to) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAACFXtVPs:APA91bEa3s6yCpXd0muxFV2qtbGqAgyKXRZMAUxmuqhglC9s6svd6gOT74F1rNZ--vpzUZ5kWGXvyfuugFaJ38xryi5S04P9M-Bwn1Gp1kGfV5qUcRrv7ciPzduEvy_1JOz3nA0VubG9 ',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': '$body',
              'title': 'Barcade Car Wash'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": to,
          },
        ),
      );
    } catch (e) {
      print("error push notification $e");
    }
  }
}

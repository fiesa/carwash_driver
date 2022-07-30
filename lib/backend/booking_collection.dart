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
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  double? lat;
  double? lng;
  Location location = Location();
  LocationData? _locationData;

  void acessRegistrationToken(
      String bookingID, String uid, BuildContext context) async {
    final fcmToken = await FirebaseMessaging.instance.getToken().then(
        (values) => FirebaseFirestore.instance
                .collection("tracking")
                .doc(bookingID)
                .update({
              "driverToken": values,
              'driverlat': lat,
              'driverLng': lng
            }).then((value) => changeProgress(values!, uid, context)));
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      FirebaseFirestore.instance
          .collection("driverToken")
          .doc()
          .set({"deviceToken": fcmToken}).then((value) => print("success"));

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
    });
  }

  void getCurrentLocation(String bookingID, String uid, BuildContext context,
      String clientToken) async {
    _locationData = await location.getLocation();
    if (_locationData != null) {
      lat = _locationData!.latitude;
      lng = _locationData!.longitude;
      acessRegistrationToken(bookingID, uid, context);
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

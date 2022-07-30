import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter3_firestore_driver/main_variables/main_variables.dart';
import 'package:flutter3_firestore_driver/models/deal_info.dart';
import 'package:flutter3_firestore_driver/models/user_ride_request_information.dart';
import 'package:flutter3_firestore_driver/push_notifications/notification_dialog_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //display ride request information - user information who request a ride
        readUserRideRequestInformation(
            remoteMessage.data["rideRequestId"], context);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      //display ride request information - user information who request a ride
      readUserRideRequestInformation(
          remoteMessage!.data["rideRequestId"], context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      //display ride request information - user information who request a ride
      readUserRideRequestInformation(
          remoteMessage!.data["rideRequestId"], context);
    });
  }

  readUserRideRequestInformation(
      String userRideRequestId, BuildContext context) {
    print("userRideRequestId");
    print(userRideRequestId);
    FirebaseFirestore.instance
        .collection('deals')
        .doc(userRideRequestId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');

        var dealInfo = DealInfo.fromDocument(documentSnapshot);

        double originLat = double.parse(dealInfo.originLatitude!);
        double originLng = double.parse(dealInfo.originLongitude!);
        String originAddress = dealInfo.originAddress!;
        double destinationLat = double.parse(dealInfo.destinationLatitude!);
        double destinationLng = double.parse(dealInfo.destinationLongitude!);
        String destinationAddress = dealInfo.destinationAddress!;

        String userName = dealInfo.userName!;
        String userPhone = dealInfo.userPhone!;

        String userPhoto = dealInfo.userPhoto!;
        String pincode = dealInfo.pincode!;
        String commision = dealInfo.commision!;
        String totalPayment = dealInfo.totalPayment!;

        String timestamp = dealInfo.timestamp!;

        String? rideRequestId = dealInfo.driverId!;

        double timeTraveledFareAmountPerMinute =
            (double.parse(dealInfo.duration!) / 60).truncate().toDouble();
        double distanceTraveledFareAmountPerKilometer =
            (double.parse(dealInfo.distance!) / 1000).truncate().toDouble();

        UserRideRequestInformation userRideRequestDetails =
            UserRideRequestInformation();

        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.originAddress = originAddress;

        userRideRequestDetails.destinationLatLng =
            LatLng(destinationLat, destinationLng);
        userRideRequestDetails.destinationAddress = destinationAddress;

        userRideRequestDetails.userName = userName;
        userRideRequestDetails.userPhone = userPhone;
        userRideRequestDetails.userPhoto = userPhoto;
        userRideRequestDetails.pincode = pincode;
        userRideRequestDetails.commision = commision;
        userRideRequestDetails.timestamp = timestamp;
        userRideRequestDetails.totalPayment = totalPayment + "\$";
        userRideRequestDetails.duration =
            timeTraveledFareAmountPerMinute.toString() + " min";
        userRideRequestDetails.distance =
            distanceTraveledFareAmountPerKilometer.toString() + " km";

        userRideRequestDetails.rideRequestId = rideRequestId;

        showDialog(
          context: context,
          builder: (BuildContext context) => NotificationDialogBox(
            userRideRequestDetails: userRideRequestDetails,
          ),
        );

        print("dealInfo5000");
        print(dealInfo);
      } else {
        Fluttertoast.showToast(msg: "This Ride Request Id do not exists.");
      }
    });
    // FirebaseDatabase.instance
    //     .ref()
    //     .child("deals")
    //     .child(userRideRequestId)
    //     .once()
    //     .then((snapData) {
    //   if (snapData.snapshot.value != null) {
    //     audioPlayer.open(Audio("music/music_notification.mp3"));
    //     audioPlayer.play();

    //     double originLat = double.parse(
    //         (snapData.snapshot.value! as Map)["origin"]["latitude"]);
    //     double originLng = double.parse(
    //         (snapData.snapshot.value! as Map)["origin"]["longitude"]);
    //     String originAddress =
    //         (snapData.snapshot.value! as Map)["originAddress"];

    //     double destinationLat = double.parse(
    //         (snapData.snapshot.value! as Map)["destination"]["latitude"]);
    //     double destinationLng = double.parse(
    //         (snapData.snapshot.value! as Map)["destination"]["longitude"]);
    //     String destinationAddress =
    //         (snapData.snapshot.value! as Map)["destinationAddress"];

    //     String userName = (snapData.snapshot.value! as Map)["userName"];
    //     String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

    //     String userPhoto = (snapData.snapshot.value! as Map)["userPhoto"];
    //     String pincode = (snapData.snapshot.value! as Map)["pincode"];
    //     String commision = (snapData.snapshot.value! as Map)["commision"];
    //     String totalPayment = (snapData.snapshot.value! as Map)["totalPayment"];

    //     String timestamp =
    //         (snapData.snapshot.value! as Map)["timestamp"].toString();

    //     String? rideRequestId = snapData.snapshot.key;

    //     double timeTraveledFareAmountPerMinute =
    //         ((snapData.snapshot.value as Map)["duration"] / 60)
    //             .truncate()
    //             .toDouble();
    //     double distanceTraveledFareAmountPerKilometer =
    //         ((snapData.snapshot.value as Map)["distance"] / 1000)
    //             .truncate()
    //             .toDouble();

    //     UserRideRequestInformation userRideRequestDetails =
    //         UserRideRequestInformation();

    //     userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
    //     userRideRequestDetails.originAddress = originAddress;

    //     userRideRequestDetails.destinationLatLng =
    //         LatLng(destinationLat, destinationLng);
    //     userRideRequestDetails.destinationAddress = destinationAddress;

    //     userRideRequestDetails.userName = userName;
    //     userRideRequestDetails.userPhone = userPhone;
    //     userRideRequestDetails.userPhoto = userPhoto;
    //     userRideRequestDetails.pincode = pincode;
    //     userRideRequestDetails.commision = commision;
    //     userRideRequestDetails.timestamp = timestamp;
    //     userRideRequestDetails.totalPayment = totalPayment + "\$";
    //     userRideRequestDetails.duration =
    //         timeTraveledFareAmountPerMinute.toString() + " min";
    //     userRideRequestDetails.distance =
    //         distanceTraveledFareAmountPerKilometer.toString() + " km";

    //     userRideRequestDetails.rideRequestId = rideRequestId;

    //     showDialog(
    //       context: context,
    //       builder: (BuildContext context) => NotificationDialogBox(
    //         userRideRequestDetails: userRideRequestDetails,
    //       ),
    //     );
    //   } else {
    //     Fluttertoast.showToast(msg: "This Ride Request Id do not exists.");
    //   }
    // });
  }

  Future generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token: ");
    print(registrationToken);

    CollectionReference? users =
        FirebaseFirestore.instance.collection('drivers');

    var currentUser = FirebaseAuth.instance.currentUser;

    users
        .doc(currentUser?.uid)
        .update({"token": registrationToken}).then((value) {
      print("User Added");
    }).catchError((error) => print("Failed to add user: $error"));

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("drivers")
    //     .child(currentFirebaseUser!.uid)
    //     .child("token")
    //     .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}

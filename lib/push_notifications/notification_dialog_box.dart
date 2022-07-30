import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter3_firestore_driver/providers/google_map_provider.dart';
import 'package:flutter3_firestore_driver/main_variables/main_variables.dart';
import 'package:flutter3_firestore_driver/screens/new_trip_screen.dart';
import 'package:flutter3_firestore_driver/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.deepOrange.withOpacity(0.6),
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.deepOrange.withOpacity(0.6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            Image.asset(
              'images/logo.png',
              height: 80,
              width: 80,
            ),

            Text(
              "New Ride Request",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),

            const SizedBox(height: 14.0),

            const Divider(
              height: 3,
              thickness: 3,
            ),

            //addresses origin destination
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  //origin location with icon
                  Row(
                    children: [
                      const Icon(
                        Icons.location_city,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestDetails!.originAddress!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  //destination location with icon
                  Row(
                    children: [
                      const Icon(
                        Icons.location_city,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestDetails!.destinationAddress!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          children: [
                            Text(
                              'Distance',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              widget.userRideRequestDetails!.distance!,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          children: [
                            Text(
                              'Duration',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              widget.userRideRequestDetails!.duration!,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              widget.userRideRequestDetails!.totalPayment!,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(
              height: 3,
              thickness: 3,
            ),

            //buttons cancel accept
            Container(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.white,
                      shadowColor: Colors.deepOrangeAccent,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      minimumSize: Size(100, 40), //////// HERE
                    ),
                    onPressed: () {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      //accept the rideRequest
                      acceptRideRequest(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          "Accept".toUpperCase(),
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.deepOrange),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 25.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      shadowColor: Colors.redAccent,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      minimumSize: Size(100, 40), //////// HERE
                    ),
                    onPressed: () {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      FirebaseFirestore.instance
                          .collection('deals')
                          .doc(currentFirebaseUser!.uid)
                          .delete()
                          .then((value) {
                        GoogleMapProvider.pauseLiveLocationUpdates();
                        Fluttertoast.showToast(
                            msg:
                                "Ride Request has been Cancelled, Successfully. Restart App Now.");

                        Future.delayed(const Duration(milliseconds: 3000), () {
                          SystemNavigator.pop();
                        });
                      });

                      //cancel the rideRequest
                      // FirebaseDatabase.instance
                      //     .ref()
                      //     .child("deals")
                      //     .child(widget.userRideRequestDetails!.rideRequestId!)
                      //     .remove()
                      //     .then((value) {
                      //   FirebaseDatabase.instance
                      //       .ref()
                      //       .child("drivers")
                      //       .child(currentFirebaseUser!.uid)
                      //       .child("newRideStatus")
                      //       .set("idle");
                      // }).then((value) {
                      //   FirebaseDatabase.instance
                      //       .ref()
                      //       .child("drivers")
                      //       .child(currentFirebaseUser!.uid)
                      //       .child("tripsHistory")
                      //       .child(
                      //           widget.userRideRequestDetails!.rideRequestId!)
                      //       .remove();

                      //   FirebaseDatabase.instance
                      //       .ref()
                      //       .child("bunkers")
                      //       .child(
                      //           widget.userRideRequestDetails!.rideRequestId!)
                      //       .remove();
                      // }).then((value) {
                      //   Fluttertoast.showToast(
                      //       msg:
                      //           "Ride Request has been Cancelled, Successfully. Restart App Now.");
                      // });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Center(
                        child: Text(
                          "Cancel".toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context) {
    String getRideRequestId = "";

    FirebaseFirestore.instance
        .collection('deals')
        .doc(currentFirebaseUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // FirebaseDatabase.instance
        //     .ref()
        //     .child("drivers")
        //     .child(currentFirebaseUser!.uid)
        //     .child("newRideStatus")
        //     .set("accepted");

        CollectionReference? deals =
            FirebaseFirestore.instance.collection('deals');

        deals
            .doc(widget.userRideRequestDetails!.rideRequestId!)
            .update({"status": "accepted"}).then((value) {
          FirebaseFirestore.instance
              .collection('locations')
              .doc(currentFirebaseUser!.uid)
              .delete()
              .then((value) {
            print("delated locations info");
          });
          print("User Added");
        }).catchError((error) => print("Failed to add user: $error"));

        GoogleMapProvider.pauseLiveLocationUpdates();

        //trip started now - send driver to new tripScreen
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => NewTripScreen(
                      userRideRequestDetails: widget.userRideRequestDetails,
                    )));
      } else {}
    });
    // FirebaseDatabase.instance
    //     .ref()
    //     .child("drivers")
    //     .child(currentFirebaseUser!.uid)
    //     .child("newRideStatus")
    //     .once()
    //     .then((snap) {
    //   if (snap.snapshot.value != null) {
    //     getRideRequestId = snap.snapshot.value.toString();
    //   } else {
    //     Fluttertoast.showToast(msg: "This ride request do not exists.");
    //   }

    //   if (getRideRequestId == widget.userRideRequestDetails!.rideRequestId) {
    //     FirebaseDatabase.instance
    //         .ref()
    //         .child("drivers")
    //         .child(currentFirebaseUser!.uid)
    //         .child("newRideStatus")
    //         .set("accepted");

    //     GoogleMapProvider.pauseLiveLocationUpdates();

    //     //trip started now - send driver to new tripScreen
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (c) => NewTripScreen(
    //                   userRideRequestDetails: widget.userRideRequestDetails,
    //                 )));
    //   } else {
    //     Fluttertoast.showToast(msg: "This Ride Request do not exists.");
    //   }
    // });
  }
}

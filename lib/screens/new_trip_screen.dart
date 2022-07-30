import 'dart:async';

import 'package:flutter3_firestore_driver/main_variables/main_variables.dart';
import 'package:flutter3_firestore_driver/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_firestore_driver/screens/complete_trip.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../models/deal_info.dart';
import '../providers/google_map_provider.dart';
import '../progress/progress_dialog.dart';
import 'ride_summary.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({
    this.userRideRequestDetails,
  });

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Enter Pincode";
  Color? buttonColor = Colors.deepOrange;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

  final pincode = TextEditingController();

  Future<void> drawPolyLineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
        await GoogleMapProvider.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polyLinePositionCoordinates.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.red,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        width: 4,
        geodesic: true,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });
  }

  @override
  void initState() {
    super.initState();

    //saveAssignedDriverDetailsToUserRideRequest();
  }

  createDriverIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  getDriversLocationUpdatesAtRealTime() {
    LatLng oldLatLng = LatLng(0, 0);

    geolocationDriverLivePostion =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      );

      Marker animatingMarker = Marker(
        markerId: const MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: const InfoWindow(title: "This is your Position"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latLngLiveDriverPosition, zoom: 16);
        newTripGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere(
            (element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

      //updating driver location at real time in Database
      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      };
      // FirebaseDatabase.instance
      //     .ref()
      //     .child("locations")
      //     .child(widget.userRideRequestDetails!.rideRequestId!)
      //     .child("driverLocation")
      //     .set(driverLatLngDataMap);

      CollectionReference? locations =
          FirebaseFirestore.instance.collection('driverLocations');

      locations.doc(widget.userRideRequestDetails!.rideRequestId!).set({
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      }).then((value) {
        print("User Added");
      }).catchError((error) => print("Failed to add user: $error"));
    });
  }

  updateDurationTimeAtRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      if (onlineDriverCurrentPosition == null) {
        return;
      }

      var originLatLng = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      ); //Driver current Location

      var destinationLatLng;

      if (rideRequestStatus == "accepted") {
        destinationLatLng =
            widget.userRideRequestDetails!.originLatLng; //user PickUp Location
      } else //arrived
      {
        destinationLatLng = widget
            .userRideRequestDetails!.destinationLatLng; //user DropOff Location
      }

      var directionInformation =
          await GoogleMapProvider.obtainOriginToDestinationDirectionDetails(
              originLatLng, destinationLatLng);

      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }

      isRequestDirectionDetails = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();

    return Scaffold(
      body: Stack(
        children: [
          //google map
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            //circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude);

              var userPickUpLatLng =
                  widget.userRideRequestDetails!.originLatLng;

              drawPolyLineFromOriginToDestination(
                  driverCurrentLatLng, userPickUpLatLng!);

              getDriversLocationUpdatesAtRealTime();
            },
          ),

          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.deepOrange.withOpacity(0.7),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_city,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "From",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    Text(
                                      widget.userRideRequestDetails!
                                              .originAddress!
                                              .substring(0, 27) +
                                          "...",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.deepOrangeAccent.withOpacity(0.7),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_searching,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "To",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    Text(
                                      widget.userRideRequestDetails!
                                              .destinationAddress!
                                              .substring(0, 27) +
                                          "...",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(1),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.deepOrange),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: SizedBox.fromSize(
                                      size: Size.fromRadius(40),
                                      child: FittedBox(
                                        child: Image.network(widget
                                                .userRideRequestDetails!
                                                .userPhoto ??
                                            'images/Elegant.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 120,
                                              child: Text(
                                                widget.userRideRequestDetails!
                                                        .userName ??
                                                    "Driver name",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'bold',
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Duration",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    widget.userRideRequestDetails!
                                                            .duration ??
                                                        "0",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Distance",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    widget.userRideRequestDetails!
                                                            .distance ??
                                                        "0 km",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
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
                                        backgroundColor:
                                            Colors.redAccent.shade100,
                                        label: Text(
                                            widget.userRideRequestDetails!
                                                    .totalPayment ??
                                                "0",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              //[driver has arrived at user PickUp Location] - Arrived Button
                              if (rideRequestStatus == "accepted") {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext Context) {
                                      return ratingContainer();
                                    });
                              }
                              //[user has already sit in driver's car. Driver start trip now] - Lets Go Button
                              else if (rideRequestStatus == "arrived") {
                                rideRequestStatus = "ontrip";

                                CollectionReference? deals = FirebaseFirestore
                                    .instance
                                    .collection('deals');

                                deals
                                    .doc(widget
                                        .userRideRequestDetails!.rideRequestId!)
                                    .update({"status": rideRequestStatus}).then(
                                        (value) {
                                  print("User Added");
                                }).catchError((error) =>
                                        print("Failed to add user: $error"));

                                FirebaseFirestore.instance
                                    .collection('deals')
                                    .doc(widget
                                        .userRideRequestDetails!.rideRequestId!)
                                    .get()
                                    .then((DocumentSnapshot documentSnapshot) {
                                  if (documentSnapshot.exists) {
                                    CollectionReference? orders =
                                        FirebaseFirestore.instance
                                            .collection('orders');

                                    var dealInformation =
                                        DealInfo.fromDocument(documentSnapshot);

                                    orders.doc(dealInformation.timestamp!).set({
                                      "originLatitude":
                                          dealInformation.originLatitude,
                                      "originLongitude":
                                          dealInformation.originLongitude,
                                      "destinationLatitude":
                                          dealInformation.destinationLatitude,
                                      "destinationLongitude":
                                          dealInformation.destinationLongitude,
                                      "time": dealInformation.time,
                                      "userName": dealInformation.userName,
                                      "userPhone": dealInformation.userPhone,
                                      "userEmail": dealInformation.userEmail,
                                      "userId": dealInformation.userId,
                                      "userPhoto": dealInformation.userPhoto,
                                      "originAddress":
                                          dealInformation.originAddress,
                                      "destinationAddress":
                                          dealInformation.destinationAddress,
                                      "driverId": dealInformation.driverId,
                                      "status": "ended",
                                      "driverName": dealInformation.driverName,
                                      "driverPhone":
                                          dealInformation.driverPhone,
                                      "driverPhoto":
                                          dealInformation.driverPhoto,
                                      "driverType": dealInformation.driverType,
                                      "driverRating":
                                          dealInformation.driverRating,
                                      "carBrand": dealInformation.carBrand,
                                      "carModel": dealInformation.carModel,
                                      "carNumber": dealInformation.carNumber,
                                      //"timestamp": FieldValue.serverTimestamp(),
                                      "timestamp": dealInformation.timestamp,

                                      "totalPayment":
                                          dealInformation.totalPayment,
                                      "commision": dealInformation.commision,
                                      "duration": dealInformation.duration,
                                      "distance": dealInformation.distance,
                                      "pincode": dealInformation.pincode,
                                    }).then((value) {
                                      print("User Added");
                                    }).catchError((error) =>
                                        print("Failed to add user: $error"));
                                  } else {
                                    print(
                                        'Document does not exist on the database');
                                  }
                                });

                                setState(() {
                                  buttonTitle = "End Trip"; //end the trip
                                  buttonColor = Colors.red;
                                });
                              }
                              //[user/Driver reached to the dropOff Destination Location] - End Trip Button
                              else if (rideRequestStatus == "ontrip") {
                                endTripNow();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: buttonColor,
                              onPrimary: Colors.white,
                              shadowColor: Colors.greenAccent,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0)),
                              minimumSize: Size(100, 40),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Center(
                                child: Text(
                                  buttonTitle!.toUpperCase(),
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
                  ),
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                //   decoration: BoxDecoration(
                //     color: Colors.deepOrange.shade100,
                //     borderRadius: BorderRadius.circular(10),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.shade300,
                //         blurRadius: 20.0,
                //       ),
                //     ],
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         children: [
                //           Container(
                //             height: 50,
                //             width: 50,
                //             decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(5),
                //                 image: DecorationImage(
                //                     image: NetworkImage(widget
                //                             .userRideRequestDetails!
                //                             .userPhoto ??
                //                         'images/Elegant.png'),
                //                     fit: BoxFit.cover)),
                //           ),
                //           Expanded(
                //             child: Padding(
                //               padding: EdgeInsets.only(left: 10),
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Text(
                //                     widget.userRideRequestDetails!.userName ??
                //                         "Driver name",
                //                     style: TextStyle(
                //                       fontFamily: 'semi-bold',
                //                       fontSize: 18,
                //                       color: Colors.white,
                //                     ),
                //                   ),
                //                   Text(
                //                     widget.userRideRequestDetails!.userPhone ??
                //                         "Driver name",
                //                     style: TextStyle(
                //                       fontFamily: 'semi-bold',
                //                       fontSize: 14,
                //                       color: Colors.white,
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Padding(
                //                 padding: const EdgeInsets.all(5.0),
                //                 child: Column(
                //                   children: [
                //                     Text(
                //                       'Distance',
                //                       style: TextStyle(
                //                         color: Colors.white,
                //                       ),
                //                     ),
                //                     Text(
                //                       widget.userRideRequestDetails!.distance ??
                //                           "0 km",
                //                       style: TextStyle(
                //                         color: Colors.white,
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               Padding(
                //                 padding: const EdgeInsets.all(5.0),
                //                 child: Column(
                //                   children: [
                //                     Text(
                //                       'Duration',
                //                       style: TextStyle(color: Colors.white),
                //                     ),
                //                     Text(
                //                       widget.userRideRequestDetails!.duration ??
                //                           "0",
                //                       style: TextStyle(
                //                         color: Colors.white,
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               Padding(
                //                 padding: const EdgeInsets.all(5.0),
                //                 child: Column(
                //                   children: [
                //                     Text(
                //                       'Total',
                //                       style: TextStyle(color: Colors.white),
                //                     ),
                //                     Text(
                //                       widget.userRideRequestDetails!
                //                               .totalPayment ??
                //                           "0",
                //                       style: TextStyle(
                //                         color: Colors.white,
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //       SizedBox(
                //         height: 30,
                //       ),
                //       ElevatedButton(
                //         onPressed: () async {
                //           //[driver has arrived at user PickUp Location] - Arrived Button
                //           if (rideRequestStatus == "accepted") {
                //             showDialog(
                //                 context: context,
                //                 builder: (BuildContext Context) {
                //                   return ratingContainer();
                //                 });
                //           }
                //           //[user has already sit in driver's car. Driver start trip now] - Lets Go Button
                //           else if (rideRequestStatus == "arrived") {
                //             rideRequestStatus = "ontrip";

                //             CollectionReference? deals =
                //                 FirebaseFirestore.instance.collection('deals');

                //             deals
                //                 .doc(widget
                //                     .userRideRequestDetails!.rideRequestId!)
                //                 .update({"status": rideRequestStatus}).then(
                //                     (value) {
                //               print("User Added");
                //             }).catchError((error) =>
                //                     print("Failed to add user: $error"));

                //             // FirebaseDatabase.instance
                //             //     .ref()
                //             //     .child("deals")
                //             //     .child(widget
                //             //         .userRideRequestDetails!.rideRequestId!)
                //             //     .child("status")
                //             //     .set("ontrip");

                //             FirebaseFirestore.instance
                //                 .collection('deals')
                //                 .doc(widget
                //                     .userRideRequestDetails!.rideRequestId!)
                //                 .get()
                //                 .then((DocumentSnapshot documentSnapshot) {
                //               if (documentSnapshot.exists) {
                //                 CollectionReference? orders = FirebaseFirestore
                //                     .instance
                //                     .collection('orders');

                //                 var dealInformation =
                //                     DealInfo.fromDocument(documentSnapshot);

                //                 orders.doc(dealInformation.timestamp!).set({
                //                   "originLatitude":
                //                       dealInformation.originLatitude,
                //                   "originLongitude":
                //                       dealInformation.originLongitude,
                //                   "destinationLatitude":
                //                       dealInformation.destinationLatitude,
                //                   "destinationLongitude":
                //                       dealInformation.destinationLongitude,
                //                   "time": dealInformation.time,
                //                   "userName": dealInformation.userName,
                //                   "userPhone": dealInformation.userPhone,
                //                   "userEmail": dealInformation.userEmail,
                //                   "userId": dealInformation.userId,
                //                   "userPhoto": dealInformation.userPhoto,
                //                   "originAddress":
                //                       dealInformation.originAddress,
                //                   "destinationAddress":
                //                       dealInformation.destinationAddress,
                //                   "driverId": dealInformation.driverId,
                //                   "status": "ended",
                //                   "driverName": dealInformation.driverName,
                //                   "driverPhone": dealInformation.driverPhone,
                //                   "driverPhoto": dealInformation.driverPhoto,
                //                   "driverType": dealInformation.driverType,
                //                   "driverRating": dealInformation.driverRating,
                //                   "carBrand": dealInformation.carBrand,
                //                   "carModel": dealInformation.carModel,
                //                   "carNumber": dealInformation.carNumber,
                //                   //"timestamp": FieldValue.serverTimestamp(),
                //                   "timestamp": dealInformation.timestamp,

                //                   "totalPayment": dealInformation.totalPayment,
                //                   "commision": dealInformation.commision,
                //                   "duration": dealInformation.duration,
                //                   "distance": dealInformation.distance,
                //                   "pincode": dealInformation.pincode,
                //                 }).then((value) {
                //                   print("User Added");
                //                 }).catchError((error) =>
                //                     print("Failed to add user: $error"));
                //                 // setState(() {
                //                 //   user = Users.fromDocument(documentSnapshot);

                //                 //   print("order_details");
                //                 //   print(user);
                //                 // });
                //               } else {
                //                 print(
                //                     'Document does not exist on the database');
                //               }
                //             });
                //             // FirebaseDatabase.instance
                //             //     .ref()
                //             //     .child("deals")
                //             //     .child(widget
                //             //         .userRideRequestDetails!.rideRequestId!)
                //             //     .once()
                //             //     .then((snap) async {
                //             //   if (snap.snapshot.value != null) {
                //             //     FirebaseDatabase.instance
                //             //         .ref()
                //             //         .child("orders")
                //             //         .child(widget
                //             //             .userRideRequestDetails!.timestamp!)
                //             //         .set(snap.snapshot.value);
                //             //   }
                //             // });

                //             setState(() {
                //               buttonTitle = "End Trip"; //end the trip
                //               buttonColor = Colors.redAccent;
                //             });
                //           }
                //           //[user/Driver reached to the dropOff Destination Location] - End Trip Button
                //           else if (rideRequestStatus == "ontrip") {
                //             endTripNow();
                //           }
                //         },
                //         style: ElevatedButton.styleFrom(
                //           primary: buttonColor,
                //           onPrimary: Colors.white,
                //           shadowColor: Colors.greenAccent,
                //           elevation: 3,
                //           shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(32.0)),
                //           minimumSize: Size(100, 40),
                //         ),
                //         child: Container(
                //           width: MediaQuery.of(context).size.width * 0.8,
                //           child: Center(
                //             child: Text(
                //               buttonTitle!.toUpperCase(),
                //               style: const TextStyle(
                //                 fontSize: 14.0,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }

  endTripNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        message: "Finishing trip...",
      ),
    );

    var tripDirectionDetails =
        await GoogleMapProvider.obtainOriginToDestinationDirectionDetails(
            widget.userRideRequestDetails!.originLatLng!,
            widget.userRideRequestDetails!.destinationLatLng!);

    print("tripDirectionDetails");
    print(tripDirectionDetails);

    //fare amount
    double totalFareAmount =
        GoogleMapProvider.calculateFareAmountFromOriginToDestination(
            tripDirectionDetails!);

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("deals")
    //     .child(widget.userRideRequestDetails!.rideRequestId!)
    //     .child("fareAmount")
    //     .set(totalFareAmount.toString());

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("deals")
    //     .child(widget.userRideRequestDetails!.rideRequestId!)
    //     .child("status")
    //     .set("ended");

    CollectionReference? dealCollection =
        FirebaseFirestore.instance.collection('deals');

    dealCollection
        .doc(widget.userRideRequestDetails!.rideRequestId!)
        .update({"status": "ended"}).then((value) {
      print("User Added");
    }).catchError((error) => print("Failed to add user: $error"));

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("bunkers")
    //     .child(widget.userRideRequestDetails!.rideRequestId!)
    //     .remove();

    //saveFareAmountToDriverEarnings(totalFareAmount);

    // updateDriverWallet(widget.userRideRequestDetails!.totalPayment,
    //     widget.userRideRequestDetails!.commision!);

    geolocationDriverLivePostion!.cancel();

    Navigator.pop(context);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CompleteTrip(
                orderId: widget.userRideRequestDetails!.timestamp!.toString(),
                dealId: widget.userRideRequestDetails!.rideRequestId!)));

    //save fare amount to driver total earnings
  }

  saveFareAmountToDriverEarnings(double totalFareAmount) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) //earnings sub Child exists
      {
        //12
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings = totalFareAmount + oldEarnings;

        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("earnings")
            .set(driverTotalEarnings.toString());
      } else //earnings sub Child do not exists
      {
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("earnings")
            .set(totalFareAmount.toString());
      }
    });
  }

  updateDriverWallet(totalFareAmount, commisionValue) {
    FirebaseDatabase.instance
        .ref()
        .child("wallets")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) //earnings sub Child exists
      {
        //12
        // double oldEarnings = double.parse(snap.snapshot.value.toString());
        // double driverTotalEarnings = totalFareAmount + oldEarnings;

        var wallet = (snap.snapshot.value as Map)['wallet'].toString();
        var commision = (snap.snapshot.value as Map)['commision'].toString();
        var trips = (snap.snapshot.value as Map)['trips'].toString();

        print("totalFareAmount");
        print(totalFareAmount);
        print(commisionValue);

        double oldEarnings = double.parse(wallet);
        double driverTotalEarnings =
            double.parse(totalFareAmount) + oldEarnings;

        double oldCommision = double.parse(commision);
        double driverCommision = double.parse(commisionValue) + oldCommision;

        double oldTrips = double.parse(trips);
        double totalTrips = 1 + oldTrips;

        print("driverTotalEarnings");
        print(driverTotalEarnings);
        print(driverCommision);
        print(totalTrips);

        FirebaseDatabase.instance
            .ref()
            .child("wallets")
            .child(currentFirebaseUser!.uid)
            .update({
          "wallet": driverTotalEarnings,
          "commision": driverCommision,
          "trips": totalTrips
        });
      } else //earnings sub Child do not exists
      {
        // FirebaseDatabase.instance
        //     .ref()
        //     .child("drivers")
        //     .child(currentFirebaseUser!.uid)
        //     .child("earnings")
        //     .set(totalFareAmount.toString());
      }
    });
  }

  saveAssignedDriverDetailsToUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("deals")
        .child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };
    databaseReference.child("driverLocation").set(driverLocationDataMap);

    databaseReference.child("status").set("accepted");

    saveRideRequestIdToDriverHistory();
  }

  saveRideRequestIdToDriverHistory() {
    DatabaseReference tripsHistoryRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("tripsHistory");

    tripsHistoryRef
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .set(true);
  }

  Widget ratingContainer() {
    return AlertDialog(
        contentPadding: EdgeInsets.all(10),
        backgroundColor: Colors.deepOrange.withOpacity(0.5),
        content: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              TextFormField(
                controller: pincode,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.white),
                    labelStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    //hintText: "Please enter Pincode",
                    labelText: 'Please enter Pincode'),
              ),
              SizedBox(
                height: 20,
              ),
              //gradientButton(() {}, 'Begin Trip')
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.deepOrange,
                ),
                child: InkWell(
                  onTap: () async {
                    if (pincode.text ==
                        widget.userRideRequestDetails!.pincode) {
                      Navigator.pop(context);
                      rideRequestStatus = "arrived";

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext c) => ProgressDialog(
                          message: "Loading...",
                        ),
                      );

                      await drawPolyLineFromOriginToDestination(
                          widget.userRideRequestDetails!.originLatLng!,
                          widget.userRideRequestDetails!.destinationLatLng!);

                      Navigator.pop(context);

                      // FirebaseDatabase.instance
                      //     .ref()
                      //     .child("deals")
                      //     .child(widget.userRideRequestDetails!.rideRequestId!)
                      //     .child("status")
                      //     .set(rideRequestStatus);cleat

                      CollectionReference? deals =
                          FirebaseFirestore.instance.collection('deals');

                      deals
                          .doc(widget.userRideRequestDetails!.rideRequestId!)
                          .update({"status": rideRequestStatus}).then((value) {
                        print("User Added");
                      }).catchError(
                              (error) => print("Failed to add user: $error"));

                      setState(() {
                        buttonTitle = "Start Trip"; //start the trip
                        buttonColor = Colors.green;
                      });
                    } else {
                      Fluttertoast.showToast(msg: "Pincode is incorrect");
                      Navigator.pop(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Submit",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'bold',
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  gradientButton(route, text) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Colors.red,
            Colors.black,
          ],
        ),
      ),
      child: InkWell(
        onTap: () async {
          rideRequestStatus = "arrived";

          // FirebaseDatabase.instance
          //     .ref()
          //     .child("deals")
          //     .child(widget.userRideRequestDetails!.rideRequestId!)
          //     .child("status")
          //     .set(rideRequestStatus);
          CollectionReference? deals =
              FirebaseFirestore.instance.collection('deals');

          deals
              .doc(widget.userRideRequestDetails!.rideRequestId!)
              .update({"status": rideRequestStatus}).then((value) {
            print("User Added");
          }).catchError((error) => print("Failed to add user: $error"));

          setState(() {
            buttonTitle = "Start Trip"; //start the trip
            buttonColor = Colors.greenAccent;
          });

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext c) => ProgressDialog(
              message: "Loading...",
            ),
          );

          await drawPolyLineFromOriginToDestination(
              widget.userRideRequestDetails!.originLatLng!,
              widget.userRideRequestDetails!.destinationLatLng!);

          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'bold', fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

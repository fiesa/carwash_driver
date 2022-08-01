import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter3_firestore_driver/models/driver_data.dart';
import 'package:flutter3_firestore_driver/providers/google_map_provider.dart';
import 'package:flutter3_firestore_driver/main_variables/main_variables.dart';
import 'package:flutter3_firestore_driver/main.dart';
import 'package:flutter3_firestore_driver/push_notifications/push_notification_system.dart';
import 'package:flutter3_firestore_driver/push_notifications/trip_info_dialog.dart';
import 'package:flutter3_firestore_driver/screens/tabs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/deal_info.dart';
import '../models/user_ride_request_information.dart';
import '../push_notifications/notification_dialog_box.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'package:rxdart/rxdart.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  final _firestore = FirebaseFirestore.instance;
  late Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);

  late Stream<List<DocumentSnapshot>> stream;
  DriverData? driver;
  // DatabaseReference? referenceRideRequest;
  // StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  StreamSubscription? _locationSubscription;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;
  bool isFinished = false;

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await GoogleMapProvider.searchAddressForGeographicCoOrdinates(
            driverCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);
  }

  readCurrentDriverInformation() async {
    currentFirebaseUser = fAuth.currentUser;

    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      print("user ids");
      print(currentUser.uid);

      FirebaseFirestore.instance
          .collection('drivers')
          .doc(currentUser.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          print('Document data: ${documentSnapshot.data()}');

          setState(() {
            driver = DriverData.fromDocument(documentSnapshot);

            print("driver_details");
            print(driver);
          });

          // setState(() {
          //   user = Users.fromDocument(documentSnapshot);

          //   print("order_details");
          //   print(user);
          // });
        } else {
          print('Document does not exist on the database');
        }
      });

      // setState(() {
      //   //_user = User.fromDocument(doc);
      //   _userId = currentUser.uid;
      // });
    }

    // await FirebaseDatabase.instance
    //     .ref()
    //     .child("drivers")
    //     .child(currentFirebaseUser!.uid)
    //     .once()
    //     .then((DatabaseEvent snap) {
    //   if (snap.snapshot.value != null) {
    //     onlineDriverData.id = (snap.snapshot.value as Map)["id"];
    //     onlineDriverData.name = (snap.snapshot.value as Map)["name"];
    //     onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
    //     onlineDriverData.email = (snap.snapshot.value as Map)["email"];
    //     onlineDriverData.car_brand = (snap.snapshot.value as Map)["carBrand"];
    //     onlineDriverData.car_model = (snap.snapshot.value as Map)["carModel"];
    //     onlineDriverData.car_number = (snap.snapshot.value as Map)["carNumber"];
    //     onlineDriverData.car_type = (snap.snapshot.value as Map)["carType"];

    //     driverVehicleType = (snap.snapshot.value as Map)["carType"];

    //     print("Car Details :: ");
    //     print(onlineDriverData.car_brand);
    //     print(onlineDriverData.car_model);
    //     print(onlineDriverData.car_number);
    //     print(onlineDriverData.car_type);
    //   }
    // });

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();

    var currentUser_uid = FirebaseAuth.instance.currentUser!.uid;

    CollectionReference driverLocations =
        FirebaseFirestore.instance.collection('deals');
    driverLocations.doc(currentUser_uid).snapshots().listen((querySnapshot) {
      if (querySnapshot.exists) {
        print('Document data: ${querySnapshot.data()}');

        var dealInfo = DealInfo.fromDocument(querySnapshot);

        if (dealInfo.status == "waiting") {
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
        }
      } else {
        Fluttertoast.showToast(msg: "This Ride Request Id do not exists.");
      }
    });
    // referenceRideRequest =
    //     FirebaseDatabase.instance.ref().child("bunkers").child(currentUser_uid);

    //Response from a Driver
    // tripRideRequestInfoStreamSubscription =
    //     referenceRideRequest!.onValue.listen((eventSnap) async {
    //   if (eventSnap.snapshot.value == null) {
    //     return;
    //   } else if ((eventSnap.snapshot.value! as Map)["status"] == "waiting") {
    //     FirebaseDatabase.instance
    //         .ref()
    //         .child("deals")
    //         .child(currentUser_uid)
    //         .once()
    //         .then((snapData) {
    //       if (snapData.snapshot.value != null) {
    //         audioPlayer.open(Audio("music/music_notification.mp3"));
    //         audioPlayer.play();

    //         double originLat = double.parse(
    //             (snapData.snapshot.value! as Map)["origin"]["latitude"]);
    //         double originLng = double.parse(
    //             (snapData.snapshot.value! as Map)["origin"]["longitude"]);
    //         String originAddress =
    //             (snapData.snapshot.value! as Map)["originAddress"];

    //         double destinationLat = double.parse(
    //             (snapData.snapshot.value! as Map)["destination"]["latitude"]);
    //         double destinationLng = double.parse(
    //             (snapData.snapshot.value! as Map)["destination"]["longitude"]);
    //         String destinationAddress =
    //             (snapData.snapshot.value! as Map)["destinationAddress"];

    //         String userName = (snapData.snapshot.value! as Map)["userName"];
    //         String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

    //         String userPhoto = (snapData.snapshot.value! as Map)["userPhoto"];
    //         String pincode = (snapData.snapshot.value! as Map)["pincode"];
    //         String commision = (snapData.snapshot.value! as Map)["commision"];
    //         String totalPayment =
    //             (snapData.snapshot.value! as Map)["totalPayment"];

    //         String timestamp =
    //             (snapData.snapshot.value! as Map)["timestamp"].toString();

    //         String? rideRequestId = snapData.snapshot.key;

    //         double timeTraveledFareAmountPerMinute =
    //             ((snapData.snapshot.value as Map)["duration"] / 60)
    //                 .truncate()
    //                 .toDouble();
    //         double distanceTraveledFareAmountPerKilometer =
    //             ((snapData.snapshot.value as Map)["distance"] / 1000)
    //                 .truncate()
    //                 .toDouble();

    //         UserRideRequestInformation userRideRequestDetails =
    //             UserRideRequestInformation();

    //         userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
    //         userRideRequestDetails.originAddress = originAddress;

    //         userRideRequestDetails.destinationLatLng =
    //             LatLng(destinationLat, destinationLng);
    //         userRideRequestDetails.destinationAddress = destinationAddress;

    //         userRideRequestDetails.userName = userName;
    //         userRideRequestDetails.userPhone = userPhone;
    //         userRideRequestDetails.userPhoto = userPhoto;
    //         userRideRequestDetails.pincode = pincode;
    //         userRideRequestDetails.timestamp = timestamp;
    //         userRideRequestDetails.totalPayment = totalPayment;
    //         userRideRequestDetails.duration =
    //             timeTraveledFareAmountPerMinute.toString() + " min";
    //         userRideRequestDetails.distance =
    //             distanceTraveledFareAmountPerKilometer.toString() + " km";

    //         userRideRequestDetails.rideRequestId = rideRequestId;
    //         userRideRequestDetails.commision = commision;

    //         //if ((eventSnap.snapshot.value! as Map)["status"] == "waiting") {
    //         showDialog(
    //           context: context,
    //           builder: (BuildContext context) => NotificationDialogBox(
    //             userRideRequestDetails: userRideRequestDetails,
    //             // tripRideRequestInfoStreamSubscription:
    //             //     tripRideRequestInfoStreamSubscription,
    //           ),
    //         );
    //         //}
    //       }
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //GoogleMapProvider.pauseLiveLocationUpdates();

    driverIsOfflineMode();

    Fluttertoast.showToast(msg: "You are now Offline.");

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        GoogleMapProvider.pauseLiveLocationUpdates();
        return true;
      },
      child: Stack(
        children: [
          isDriverActive != false
              ? GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controllerGoogleMap.complete(controller);
                    newGoogleMapController = controller;

                    locateDriverPosition();
                  },
                )
              : Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.black,
                      Colors.blue,
                    ],
                  )),
                  // color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(),
                      // Lottie.asset('images/splash.json'),
                      //             Container(

                      //                           decoration: BoxDecoration(
                      //   gradient: LinearGradient(
                      //     begin: Alignment.topRight,
                      //     end: Alignment.bottomLeft,
                      //     colors: [
                      //     Color(0xff3fa0d7),
                      //     Color(0xff29ee86),
                      //   ],
                      //   )
                      // ),

                      //               child:
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SwipeableButtonView(
                          buttonText: 'SLIDE TO ONLINE',
                          buttonWidget: Container(
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.grey,
                            ),
                          ),
                          activeColor: Colors.green,
                          isFinished: isDriverActive,
                          onWaitingProcess: () {
                            Future.delayed(Duration(seconds: 2), () async {
                              setState(() {
                                isDriverActive = true;
                              });

                              print("home activer");
                              await driverIsOnlineNow();
                              //await updateDriversLocationAtFirestore();

                              setState(() {
                                statusText = "Now Online";
                                // isDriverActive = true;
                                buttonColor = Colors.transparent;
                              });

                              await Fluttertoast.showToast(
                                  msg: "you are Online Now");
                            });
                          },
                          onFinish: () async {
                            //display Toast
                            await Fluttertoast.showToast(
                                msg: "You are online now");
                          },
                        ),
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }

  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;

    print("here is driver is online");

    await readCurrentDriverInformation();

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // GeoFirestore geoFirestore = GeoFirestore(firestore.collection('places'));

    // await geoFirestore.setLocation(
    //     currentFirebaseUser!.uid,
    //     GeoPoint(
    //         driverCurrentPosition!.latitude, driverCurrentPosition!.longitude));

    // GeoFirePoint myLocation = geo.point(
    //     latitude: driverCurrentPosition!.latitude,
    //     longitude: driverCurrentPosition!.longitude);

    print("myLocation");
    //print(myLocation);

//     stream = radius.switchMap((rad) {
//       final collectionReference = firestore.collection('locations');

//       return geo.collection(collectionRef: collectionReference).within(
//           center: myLocation, radius: rad, field: 'position', strictMode: true);

//       /*
//       ****Example to specify nested object****

//       var collectionReference = _firestore.collection('nestedLocations');
// //          .where('name', isEqualTo: 'darshan');
//       return geo.collection(collectionRef: collectionReference).within(
//           center: center, radius: rad, field: 'address.location.position');

//       */
//     });
    final geo = Geoflutterfire();

    GeoFirePoint geoFirePoint = geo.point(
        latitude: driverCurrentPosition!.latitude,
        longitude: driverCurrentPosition!.longitude);

    firestore.collection('locations').doc(currentFirebaseUser!.uid).set({
      'driverId': driver!.id,
      'driverName': driver!.name,
      'driverEmail': driver!.email,
      'carBrand': driver!.car_brand,
      'carModel': driver!.car_model,
      'carNumber': driver!.car_number,
      'carType': driver!.car_type,
      'priceKm': driver!.price_km,
      'priceMin': driver!.price_min,
      'ratings': driver!.ratings,
      'position': geoFirePoint.data,
      'phone': driver!.phone,
      'driverPhoto': driver!.photoURL,
    }).then((_) {
      print('added ${geoFirePoint.hash} successfully');
    }).catchError((error) => print("Failed to add user: $error"));

    // Geofire.initialize("activeDrivers");

    // Geofire.setLocation(currentFirebaseUser!.uid,
    //     driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    // DatabaseReference ref = FirebaseDatabase.instance
    //     .ref()
    //     .child("drivers")
    //     .child(currentFirebaseUser!.uid)
    //     .child("newRideStatus");

    // ref.set("idle"); //searching for ride request
    // ref.onValue.listen((event) {});
  }

  updateDriversLocationAtFirestore() {
    geolocationSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;

      if (isDriverActive == true) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        final geo = Geoflutterfire();

        GeoFirePoint geoFirePoint = geo.point(
            latitude: driverCurrentPosition!.latitude,
            longitude: driverCurrentPosition!.longitude);

        firestore.collection('locations').doc(currentFirebaseUser!.uid).set({
          'driverId': driver!.id,
          'driverName': driver!.name,
          'driverEmail': driver!.email,
          'carBrand': driver!.car_brand,
          'carModel': driver!.car_model,
          'carNumber': driver!.car_number,
          'carType': driver!.car_type,
          'priceKm': driver!.price_km,
          'priceMin': driver!.price_min,
          'ratings': driver!.ratings,
          'position': geoFirePoint.data,
          'phone': driver!.phone,
          'driverPhoto': driver!.photoURL,
        }).then((_) {
          print('added ${geoFirePoint.hash} successfully');
        }).catchError((error) => print("Failed to add user: $error"));
      }

      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  updateDriversLocationAtRealTime() {
    geolocationSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;

      if (isDriverActive == true) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        // GeoFirestore geoFirestore =
        //     GeoFirestore(firestore.collection('places'));
        // geoFirestore.setLocation(
        //     currentFirebaseUser!.uid,
        //     GeoPoint(driverCurrentPosition!.latitude,
        //         driverCurrentPosition!.longitude));
      }

      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineMode() async {
    //Geofire.removeLocation(currentFirebaseUser!.uid);

    //geoFirestore.removeLocation('tl0Lw0NUddQx5a8kXymO');

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // GeoFirestore geoFirestore = GeoFirestore(firestore.collection('places'));

    // await geoFirestore.removeLocation(
    //     currentFirebaseUser!.uid,
    //     GeoPoint(
    //         driverCurrentPosition!.latitude, driverCurrentPosition!.longitude));

    firestore.collection('locations').doc(currentFirebaseUser!.uid).delete();

    // DatabaseReference? ref = FirebaseDatabase.instance
    //     .ref()
    //     .child("drivers")
    //     .child(currentFirebaseUser!.uid)
    //     .child("newRideStatus");
    // ref.onDisconnect();
    // ref.remove();
    // ref = null;
  }

  driverIsOfflineNow() async {
    //Geofire.removeLocation(currentFirebaseUser!.uid);

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // GeoFirestore geoFirestore = GeoFirestore(firestore.collection('places'));

    // await geoFirestore.removeLocation(
    //     currentFirebaseUser!.uid,
    //     GeoPoint(
    //         driverCurrentPosition!.latitude, driverCurrentPosition!.longitude));

    // DatabaseReference? ref = FirebaseDatabase.instance
    //     .ref()
    //     .child("drivers")
    //     .child(currentFirebaseUser!.uid)
    //     .child("newRideStatus");
    // ref.onDisconnect();
    // ref.remove();
    // ref = null;

    Future.delayed(const Duration(milliseconds: 2000), () {
      //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      SystemNavigator.pop();
    });
  }
}

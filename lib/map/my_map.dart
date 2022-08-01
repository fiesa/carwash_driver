import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MyMap extends StatefulWidget {
  final String? user_id;
  MyMap(this.user_id);
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  // StreamSubscription<loc.LocationData>? locationSubscription;
  late GoogleMapController _controller;
  bool _added = false;

  @override
  void initState() {
    location.changeSettings(
      interval: 300,
      accuracy: loc.LocationAccuracy.HIGH,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('driversLocation').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (_added) {
          mymap(snapshot);
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return GoogleMap(
          mapType: MapType.normal,
          markers: {
            Marker(
                position: LatLng(
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.user_id)['lat'],
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.user_id)['lng'],
                ),
                markerId: MarkerId('id'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueMagenta)),
          },
          initialCameraPosition: CameraPosition(
              target: LatLng(
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.user_id)['lat'],
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.user_id)['lng'],
              ),
              zoom: 14.47),
          onMapCreated: (GoogleMapController controller) async {
            setState(() {
              _controller = controller;
              _added = true;
            });
          },
        );
      },
    ));
  }

  // Future<void> _listenLocation() async {
  //   locationSubscription = location.onLocationChanged().handleError((onError) {
  //     print(onError);
  //     locationSubscription?.cancel();
  //     setState(() {
  //       locationSubscription = null;
  //     });
  //   }).listen((loc.LocationData currentlocation) async {
  //     await FirebaseFirestore.instance.collection('driversLocation').doc().set({
  //       'lat': currentlocation.latitude,
  //       'lng': currentlocation.longitude,
  //     }, SetOptions(merge: true));
  //   });
  // }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.user_id)['lat'],
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.user_id)['lng'],
            ),
            zoom: 14.47)));
  }
}

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapsControllers {
  Completer<GoogleMapController> mainController = Completer();
  // ignore: constant_identifier_names
  static const LOCATION_MARKER_ID = 'location';

//-1.2482091(lat)    36.7818272(long)
  CameraPosition kGooglePlex = const CameraPosition(
    target: LatLng(-1.293061, 36.791523),
    zoom: 8.4746,
  );

  ///setting up markers on the map...
  ///
  Set<Marker> markers = {};
  LatLng? position = const LatLng(-1.293061, 36.791523);

  LatLng? position2 = const LatLng(-1.2482091, 36.7818272);

  ///adding the marker with data.....
  ///
  Future<void> addMarkers(var position) async {
    markers.add(Marker(
        markerId: const MarkerId(LOCATION_MARKER_ID),
        position: position,
        anchor: const Offset(0, 0.85),
        infoWindow: const InfoWindow(
            title: "Test marker", snippet: "This is the direction")));
  }

  //Polylines....
  //variable for the polyline section.....
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  List results = [];

  //add polyline...
  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 80,
    );
    polylines[id] = polyline;

    print("this is--------------------------${polylines[id]}");
    // print("this is--------------------------$polylineCoordinates");
  }

  void getPolyline() async {
    /// add origin marker origin marker
    addMarkers(position);
    addMarkers(position2);

    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyCOxMbgZ4Qu5_VfDaXfboWvhk0NYeXDGug",
      const PointLatLng(-1.293061, 36.791523),
      const PointLatLng(-1.2482091, 36.7818272),
      travelMode: TravelMode.walking,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      print("///-----------${result.points}");
      // results.add(result.points);
      print("this is--------------------------${polylineCoordinates}");
      _addPolyLine(polylineCoordinates);
    } else {
      print("///-----------${result.errorMessage}");
    }
  }
}

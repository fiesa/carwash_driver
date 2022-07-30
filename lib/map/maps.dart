import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'maps_controller.dart';

class Maps extends GetView<MapsControllers> {
  @override
  Widget build(BuildContext context) {
    controller.getPolyline();
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        polylines: Set<Polyline>.of(controller.polylines.values),
        markers: controller.markers,
        initialCameraPosition: controller.kGooglePlex,
        onMapCreated: (GoogleMapController controllers) {
          controller.mainController.complete(controllers);
        },
      ),
    );
  }
}

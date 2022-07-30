import 'package:flutter3_firestore_driver/main_variables/main_variables.dart';
import 'package:flutter3_firestore_driver/providers/location_provider.dart';
import 'package:flutter3_firestore_driver/models/direction_details_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/directions.dart';
import 'http_request_provider.dart';

class GoogleMapProvider {
  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";
    String humanReadableAddress = "";

    var requestResponse = await HttpRequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occurred, Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updateStartLocation(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng origionPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$googleMapKey";

    var responseDirectionApi = await HttpRequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    if (responseDirectionApi == "Error Occurred, Failed. No Response.") {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static pauseLiveLocationUpdates() {
    //geolocationSubscription!.pause();

    if (geolocationSubscription != null) {
      print("geolocationSubscription");
      print(geolocationSubscription);
      geolocationSubscription!.cancel();
      print("canceled");
      print(geolocationSubscription);
    }
    // Geofire.removeLocation(currentFirebaseUser!.uid);

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    firestore.collection('locations').doc(currentFirebaseUser!.uid).delete();
  }

  static resumeLiveLocationUpdates() {
    geolocationSubscription!.resume();
    Geofire.setLocation(currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    print("DistanceDuration");
    print(directionDetailsInfo.duration_value);
    print(directionDetailsInfo.distance_value);

    double timeTraveledFareAmountPerMinute =
        (directionDetailsInfo.duration_value! / 60) * 0.5;
    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.distance_value! / 1000) * 5;

    print("timeTraveledFareAmountPerMinute");
    print(timeTraveledFareAmountPerMinute);
    print("distanceTraveledFareAmountPerKilometer");
    print(distanceTraveledFareAmountPerKilometer);

    //USD
    double totalFareAmount = timeTraveledFareAmountPerMinute +
        distanceTraveledFareAmountPerKilometer;

    print("totalFareAmount");
    print(totalFareAmount);

    print("driverVehicleType");
    print(driverVehicleType);

    if (driverVehicleType == "Simple") {
      double resultFareAmount = (totalFareAmount.truncate()) / 2.0;
      return resultFareAmount;
    } else if (driverVehicleType == "Elegant") {
      double resultFareAmount = totalFareAmount.truncate().toDouble();
      return resultFareAmount;
    } else {
      return totalFareAmount.truncate().toDouble();
    }
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter3_firestore_driver/models/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
StreamSubscription<Position>? geolocationSubscription;
StreamSubscription<Position>? geolocationDriverLivePostion;
AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
Position? driverCurrentPosition;
DriverData onlineDriverData = DriverData();
String? driverVehicleType = "";
bool isDriverActive = false;
String statusText = "Now Offline";
Color buttonColor = Colors.grey;
String googleMapKey = "AIzaSyBCtzBnPcyAW4lMW8o_J6Ur4x-IQkvwuT8";
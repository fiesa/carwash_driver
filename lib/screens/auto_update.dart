import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'tabs.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/driver_data.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AutoUpdate extends StatefulWidget {
  AutoUpdate({Key? key}) : super(key: key);

  @override
  State<AutoUpdate> createState() => _AutoUpdateState();
}

class _AutoUpdateState extends State<AutoUpdate> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String photoURL = '';
  String error = '';

  final carBrand = TextEditingController();

  final carModel = TextEditingController();

  final carType = TextEditingController();

  final carNumber = TextEditingController();

  String? _userId;

  DriverData? user;
  String? imageUrl;

  uploadImage(uid) async {
    //final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    PickedFile? image;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Select Image
      image = (await _imagePicker.getImage(source: ImageSource.gallery))!;
      var file = File(image.path);

      try {
        firebase_storage.UploadTask task = firebase_storage
            .FirebaseStorage.instance
            .ref('drivers/${uid}')
            .putFile(file);

        task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
          print('Task state: ${snapshot.state}');
          print(
              'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
        }, onError: (e) {
          // The final snapshot is also available on the task via `.snapshot`,
          // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
          print(task.snapshot);

          if (e.code == 'permission-denied') {
            print('User does not have permission to upload to this reference.');
          }
        });

        try {
          await task;
          String downloadURL = await firebase_storage.FirebaseStorage.instance
              .ref('drivers/${uid}')
              .getDownloadURL();

          var currentUser = FirebaseAuth.instance.currentUser;

          CollectionReference? users =
              FirebaseFirestore.instance.collection('drivers');

          users.doc(currentUser!.uid).update({
            "photoURL": downloadURL,
          }).then((value) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => TabsScreen()));
          }).catchError((error) => print("Failed to add user: $error"));

          // CollectionReference? users =
          //     FirebaseFirestore.instance.collection('users');

          // var currentUser = FirebaseAuth.instance.currentUser;

          // print(displayName.text);
          // users.doc(uid).update({
          //   "photoURL": downloadURL,
          // }).then((value) {
          //   Navigator.push(
          //       context, MaterialPageRoute(builder: (context) => TabsScreen()));
          //   print("User Added");
          // }).catchError((error) => print("Failed to add user: $error"));
        } on firebase_core.FirebaseException catch (e) {
          // e.g, e.code == 'canceled'
        }
        print('Upload complete.');
      } on firebase_core.FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          print('User does not have permission to upload to this reference.');
        }
        // ...
      }

      //Upload to Firebase
      // var snapshot = await _firebaseStorage
      //     .ref()
      //     .child('images/imageName')
      //     .putFile(file)
      //     .then((p0) {
      //   print("uploaded successfully");
      // }).onError((error, stackTrace) {
      //   print(error);
      // });
      // var downloadUrl = await snapshot.ref.getDownloadURL();
      // setState(() {
      //   imageUrl = downloadUrl;
      // });
    } else {
      print('Permission not granted. Try Again with permission access');
    }
  }

  @override
  void initState() {
    //getRestaurants();
    super.initState();

    var currentUser_uid = FirebaseAuth.instance.currentUser!.uid;

    // final ref = FirebaseDatabase.instance.ref();

    FirebaseFirestore.instance
        .collection('drivers')
        .doc(currentUser_uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          user = DriverData.fromDocument(documentSnapshot);

          print("driver_details");
          print(user);

          carBrand.text = user!.car_brand!;
          carModel.text = user!.car_model!;
          carNumber.text = user!.car_number!;
          carType.text = user!.car_type!;
        });

        // print("driverInfoCounting");
        // print(driverInfo);

        print("newAverageRatings");
        //     print(user!.displayName);
      }
    });
    // FirebaseDatabase.instance
    //     .ref()
    //     .child("drivers")
    //     .child(currentUser_uid)
    //     .once()
    //     .then((snap) {
    //   if (snap.snapshot.value != null) {
    //     setState(() {
    //       user = Users.fromSnapshot(snap.snapshot);

    //       print("driver_details");
    //       print(user);

    //       carBrand.text = user!.carBrand!;
    //       carModel.text = user!.carModel!;
    //       carNumber.text = user!.carNumber!;
    //       carType.text = user!.carType!;
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        elevation: 0.0,
        title: Text('Update Car Info'),
        automaticallyImplyLeading: true,
        /**
				actions: <Widget>[
					FlatButton.icon(
						icon: Icon(Icons.person),
						label: Text(''),
						onPressed: () {
							widget.toggleView();
						},
					),
				],//action
				**/
      ), //appBar
      body: Container(
        color: Colors.grey.shade200,
        child: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              // CollectionReference? users = FirebaseFirestore
                              //     .instance
                              //     .collection('users');

                              var currentUser =
                                  FirebaseAuth.instance.currentUser;

                              //uploadExample();
                              await uploadImage(currentUser?.uid);
                            },
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage('${user?.photoURL}'
                                            //'assets/payment.png',
                                            //'${user?.photoURL}',
                                            ),
                                    radius: 40,

                                    // Image.network(
                                    //   ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                  child: TextFormField(
                    controller: carBrand,
                    decoration: InputDecoration(
                        hintText: 'Car Brand', labelText: 'Car Brand'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                  child: TextFormField(
                    controller: carModel,
                    decoration: InputDecoration(
                        hintText: 'Car Model', labelText: 'Car Model'),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                  child: TextFormField(
                    controller: carNumber,
                    decoration: InputDecoration(
                        hintText: 'Car Number', labelText: 'Car Number'),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                  child: TextFormField(
                    controller: carType,
                    decoration: InputDecoration(
                        hintText: 'Car Type', labelText: 'Car Type'),
                  ),
                ),

                Text(
                  error,
                  style: TextStyle(color: Colors.deepOrange, fontSize: 7.0),
                ), //text

                Column(
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 320.0,
                      height: 45.0,
                      child: ElevatedButton(
                        // shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(7.0)),
                        style: ElevatedButton.styleFrom(
                            // backgroundColor: Colors.orangeAccent
                          primary: Colors.orangeAccent,

                        ),
                        onPressed: () async {
                          var currentUser = FirebaseAuth.instance.currentUser;

                          CollectionReference? users =
                              FirebaseFirestore.instance.collection('drivers');

                          users.doc(currentUser!.uid).update({
                            "id": currentUser.uid,
                            "carBrand": carBrand.text,
                            "carModel": carModel.text,
                            "carNumber": carNumber.text,
                            "carType": carType.text,
                          }).then((value) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TabsScreen()));
                          }).catchError(
                              (error) => print("Failed to add user: $error"));

                          // DatabaseReference ref =
                          //     FirebaseDatabase.instance.ref("drivers");

                          // ref.child(currentUser!.uid).update({
                          //   "id": currentUser.uid,
                          //   "carBrand": carBrand.text,
                          //   "carModel": carModel.text,
                          //   "carNumber": carNumber.text,
                          //   "carType": carType.text,
                          // }).then((value) {
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => TabsScreen()));
                          // }).catchError(
                          //     (error) => print("Failed to add user: $error"));
                        },
                        child:
                            Text('Save', style: TextStyle(color: Colors.white)),
                      ), //rec
                    ), //flat
                  ], //widget
                ), //column
              ],
            ),
          ),
        ),
      ), //textform
    );

    // return TabsScreen();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileInfo {
  //attributes
  String? id;
  String? displayName;
  String? lastName;
  String? email;
  String? phone;
  String? address;
  String? photoURL;

  ProfileInfo({
    this.id,
    this.displayName,
    this.lastName,
    this.email,
    this.phone,
    this.address,
    this.photoURL,
  });

  factory ProfileInfo.fromDocument(DocumentSnapshot doc) {
    return ProfileInfo(
      id: doc.id,
      displayName: doc['displayName'],
      lastName: doc['lastName'],
      email: doc['email'],
      phone: doc['phone'],
      address: doc['address'],
      photoURL: doc['photoURL'],
    );
  }
}

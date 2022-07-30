import 'package:cloud_firestore/cloud_firestore.dart';

class DriverData {
  //attributes
  String? id;
  String? name;
  String? phone;
  String? email;
  String? car_brand;
  String? car_model;
  String? car_number;
  String? car_type;
  String? price_km;
  String? price_min;
  String? ratings;
  String? photoURL;

  DriverData({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.car_brand,
    this.car_model,
    this.car_number,
    this.car_type,
    this.price_km,
    this.price_min,
    this.ratings,
    this.photoURL,
  });

  factory DriverData.fromDocument(DocumentSnapshot doc) {
    return DriverData(
      id: doc.id,
      name: doc['name'],
      phone: doc['phone'],
      email: doc['email'],
      car_brand: doc['carBrand'],
      car_model: doc['carModel'],
      car_number: doc['carNumber'],
      car_type: doc['carType'],
      price_km: doc['priceKm'],
      price_min: doc['priceMin'],
      ratings: doc['ratings'],
      photoURL: doc['photoURL'],
    );
  }
}

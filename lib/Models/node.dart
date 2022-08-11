import 'package:latlong2/latlong.dart';

class Node {

  LatLng? location;
  List? equipment = [];
  String address = '';

  Node({required this.address});

  Node.fromJson(Map<String, dynamic> json) {
    location = LatLng.fromJson(json['location']);
    equipment = json['equipment'];
    address = json['address'];
  }
}
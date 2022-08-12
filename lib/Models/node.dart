import 'package:coupolerseditor/Models/cableend.dart';
import 'package:latlong2/latlong.dart';

class Node {
  LatLng? location;
  List? equipments = [];
  List<CableEnd> cableEnds = [];
  String address = '';

  Node({required this.address});

  Node.fromJson(Map<String, dynamic> json) {
    location = LatLng.fromJson(json['location']);
    equipments = json['equipments'];
    address = json['address'];
  }
}

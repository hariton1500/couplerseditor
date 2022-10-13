import 'dart:math';

import 'package:coupolerseditor/Helpers/enums.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

LayerOptions layerMap(MapSource mapSource) {
    switch (mapSource) {
      case MapSource.google:
        return TileLayerOptions(
            urlTemplate:
                'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&hl=ru-RU&scale=1&xss=1&yss=1&s=G5zdHJ1c3Q%3D&client=gme-google&style=api%3A1.0.0&key=AIzaSyD-9tSrke72PouQMnMX-a7eZSW0jkFMBWY');
      case MapSource.openstreet:
        return TileLayerOptions(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.app',
        );
      case MapSource.yandexsat:
        return TileLayerOptions(
            urlTemplate:
                'https://core-sat.maps.yandex.net/tiles?l=map&v=3.569.0&x={x}&y={y}&z={z}&lang=ru_RU&projection=web_mercator');
      case MapSource.yandexmap:
        return TileLayerOptions(
            urlTemplate:
                'https://core-renderer-tiles.maps.yandex.net/tiles?l=map&x={x}&y={y}&z={z}&lang=ru_RU&projection=web_mercator');
      default:
        return TileLayerOptions(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.app',
        );
    }
  }

  double calculateDistance(LatLng point1, LatLng point2){
    var p = 0.017453292519943295;
    var c = cos;
    /*
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
    */
    var a = 0.5 - c((point2.latitude - point1.latitude) * p)/2 + 
          c(point1.latitude * p) * c(point2.latitude * p) * 
          (1 - c((point2.longitude - point1.longitude) * p))/2;
    return 12742 * asin(sqrt(a));
  }

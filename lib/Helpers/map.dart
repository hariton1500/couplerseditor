import 'package:coupolerseditor/Helpers/enums.dart';
import 'package:flutter_map/flutter_map.dart';

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
      case MapSource.yandex:
        return TileLayerOptions(
            urlTemplate:
                'https://core-sat.maps.yandex.net/tiles?l=map&v=3.569.0&x={x}&y={y}&z={z}&lang=ru_RU');
      default:
        return TileLayerOptions(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.app',
        );
    }
  }

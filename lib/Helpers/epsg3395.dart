import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;

const double _worldWidth = 40075016.68557849;
const int _tileSize = 256;
final List<double> _resolutions = List<double>.generate(
  19,
  (z) => _worldWidth / _tileSize / (1 << z),
);

final Crs _epsg3395 = Proj4Crs.fromFactory(
  code: 'EPSG:3395',
  proj4Projection: proj4.Projection.add(
    'EPSG:3395',
    '+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +type=crs',
  ),
  resolutions: _resolutions,
  bounds: const Rect.fromLTRB(
    -20037508.34,
    -15496570.74,
    20037508.34,
    18764656.23,
  ),
);

Crs epsg3395() => _epsg3395;

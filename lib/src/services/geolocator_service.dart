//import 'dart:html';

import 'package:geolocator/geolocator.dart';

import 'package:permission_handler/permission_handler.dart';

class GeolocatorService {
  Geolocator? geo;

  GeolocatorService() {
    geo = Geolocator();
  }

  Future<Position> determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Error');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Position> getCurrentPosition() async {
    bool hasPermission = await _checkLocationPermission();

    if (!hasPermission) {
      await _requestLocationPermission();
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  Stream<Position> get position {
    return Geolocator.getPositionStream();
  }

  Future<bool> _checkLocationPermission() async {
    return await Permission.location.isGranted;
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();

    if (status != PermissionStatus.granted) {}
  }
}

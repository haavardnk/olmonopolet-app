import 'package:geolocator/geolocator.dart';

import '../models/store.dart';

class LocationHelper {
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    var location = await Geolocator.getLastKnownPosition();
    location ??= await Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 15));

    return location;
  }

  static Future<List<Store>> calculateStoreDistance(List<Store> list) async {
    try {
      final deviceLocation = await determinePosition();
      for (var store in list) {
        if (store.gpsLat != null && store.gpsLng != null) {
          store.distance = Geolocator.distanceBetween(deviceLocation.latitude,
                  deviceLocation.longitude, store.gpsLat!, store.gpsLng!) /
              1000;
        }
      }
    } catch (_) {}
    return list;
  }
}

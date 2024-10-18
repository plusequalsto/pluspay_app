import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pluspay/main.dart';

class PermissionService {
  Future<LocationPermission> requestLocationPermission() async {
    // Request location permission using Geolocator
    LocationPermission permission = await Geolocator.requestPermission();
    return permission; // Return the new permission status
  }

  Future<LocationPermission> locationPermission() async {
    // Check current location permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      logger.d('User permanently denied location permission');
      openAppSettings(); // Open app settings for the user to enable manually
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      logger.d('User granted location permission');
    } else {
      logger.d('User denied location permission');
    }

    return permission;
  }
}

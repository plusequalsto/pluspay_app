import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

// Get device info and generate a unique identifier
Future<Map<String, dynamic>> getDeviceIdentifier() async {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> deviceInfo = {};

  if (Platform.isAndroid) {
    var androidInfo = await deviceInfoPlugin.deviceInfo;
    deviceInfo = androidInfo.data; // Unique ID for Android devices
  } else if (Platform.isIOS) {
    var iosInfo = await deviceInfoPlugin.deviceInfo;
    deviceInfo = iosInfo.data; // Unique ID for iOS devices
  }

  return deviceInfo;
}

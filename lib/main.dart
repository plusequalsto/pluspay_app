import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:pluspay/routes/router_provider.dart';
import 'package:pluspay/routes/routes.dart';
import 'package:pluspay/screens/home_screen/home_screen.dart';
import 'package:pluspay/screens/splash_screen/splash_screen.dart';
import 'package:pluspay/services/permission_service.dart';
import 'package:pluspay/utils/custom_snackbar_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final Logger logger = Logger();
bool _hasLocationPermission = false; // Track permission status
void main() async {
  final router = FluroRouter();
  await dotenv.load(fileName: ".env");
  defineRoutes(router);
  runApp(
    RouterProvider(
      router: router,
      child: Main(
        title: '+Pay',
        router: router,
      ),
    ),
  );
}

class Main extends StatefulWidget {
  final String title;
  final FluroRouter router;
  const Main({
    super.key,
    required this.title,
    required this.router,
  });

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final PermissionService _permissionService = PermissionService();
  bool _loading = true;
  final String _deviceType = Platform.isAndroid ? 'android' : 'ios';
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4)).then((value) async {
      setState(() {
        _loading = false;
      });
    });
    checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    LocationPermission permission =
        await _permissionService.locationPermission();

    // Handle the permission result if needed
    switch (permission) {
      case LocationPermission.denied:
        _requestPermission();
        break;
      case LocationPermission.deniedForever:
        // Handle the case where permission is denied forever
        break;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        // Permission granted, you can proceed with location services
        break;
      default:
        // Handle unexpected cases
        break;
    }
  }

  Future<void> _requestPermission() async {
    // Request location permission using the PermissionService
    LocationPermission permission =
        await _permissionService.requestLocationPermission();

    // Update the state based on the new permission status
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      setState(() {
        _hasLocationPermission = true;
        _loading = false; // Stop loading if permission granted
      });
    } else {
      _showPermissionDeniedMessage(); // Show the permission denied message
      setState(() {
        _loading = false; // Stop loading if permission denied
      });
    }
  }

  void _showPermissionDeniedMessage() {
    CustomSnackBarUtil.showCustomSnackBar(
      'Location permission is required for this app.',
      success: false,
    );
    setState(() {
      _loading = false; // Stop loading if permission denied
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: CustomSnackBarUtil.rootScaffoldMessengerKey,
      navigatorKey: navigatorKey,
      title: widget.title,
      onGenerateRoute: widget.router.generator,
      home: initialNavigation(),
    );
  }

  // Initial navigation logic based on user login and token status
  Widget initialNavigation() {
    if (_loading) {
      return RouterProvider(
        router: widget.router,
        child: SplashScreen(
          deviceType: _deviceType,
        ),
      );
    } else {
      return RouterProvider(
        router: widget.router,
        child: HomeScreen(
          deviceType: _deviceType,
        ),
      );
    }
  }
}

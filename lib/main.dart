import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:pluspay/models/user_model.dart';
import 'package:pluspay/routes/router_provider.dart';
import 'package:pluspay/routes/routes.dart';
import 'package:pluspay/screens/authentication_screen/signin_screen.dart';
import 'package:pluspay/screens/home_screen/home_screen.dart';
import 'package:pluspay/screens/splash_screen/splash_screen.dart';
import 'package:pluspay/services/analytics_service.dart';
import 'package:pluspay/services/devide_identifier.dart';
import 'package:pluspay/services/permission_service.dart';
import 'package:pluspay/services/push_notification_service.dart';
import 'package:pluspay/services/token_refresh_service.dart';
import 'package:pluspay/utils/custom_snackbar_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:realm/realm.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  if (message.notification != null) {
    logger.d('Message received in the background!');
  }
}

final Logger logger = Logger();
void main() async {
  final router = FluroRouter();
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize Realm configuration
  final config = Configuration.local([
    UserModel.schema,
  ]);
  final realm = Realm(config);
  UserModel? userModel;
  final results = realm.all<UserModel>();
  if (results.isNotEmpty) {
    userModel = results[0];
  }
  await PushNotificationService.initialize();
  await AnalyticsService.initialize();
  await PushNotificationService.localNotificationInit();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  PushNotificationService.onNotificationTapBackground();
  PushNotificationService.onNotificationTapForeground();
  PushNotificationService.onNotificationTerminatedState();

  if (userModel != null) {
    // Replace with your actual device token and device type fetching logic
    String? deviceToken = await PushNotificationService.getDeviceToken();
    String deviceType = Platform.isAndroid ? 'android' : 'ios';

    if (deviceToken != null) {
      TokenRefreshService().initialize(
        realm: realm,
        userModel: userModel,
        deviceToken: deviceToken,
        deviceType: deviceType,
      );
      await TokenRefreshService().refreshToken();
    }
  }
  defineRoutes(router);
  runApp(
    RouterProvider(
      router: router,
      child: Main(
        title: '+Pay',
        realm: realm,
        userModel: userModel,
        router: router,
      ),
    ),
  );
}

class Main extends StatefulWidget {
  final String title;
  final Realm realm;
  final UserModel? userModel;
  final FluroRouter router;
  const Main({
    super.key,
    required this.title,
    required this.realm,
    required this.userModel,
    required this.router,
  });

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final PermissionService _permissionService = PermissionService();
  String _deviceToken = '';
  String _deviceType = '';
  Map<String, dynamic> _newDeviceData = {};
  bool _hasLocationPermission = false;
  bool _isDeviceTokenInitialized = false;
  bool _isRefreshTokenRefreshed = false;
  bool _isLoading = true;

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    return results.isNotEmpty ? results[0] : null;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2)).then((value) {
      _getDeviceToken();
    });
    getDeviceInfo();
    checkLocationPermission();
  }

  Future<void> getDeviceInfo() async {
    _newDeviceData = await getDeviceIdentifier();
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
      });
    } else {
      _showPermissionDeniedMessage(); // Show the permission denied message
      setState(() {
        _hasLocationPermission = false; // Stop loading if permission denied
      });
    }
  }

  void _showPermissionDeniedMessage() {
    CustomSnackBarUtil.showCustomSnackBar(
      'Location permission is required for this app.',
      success: false,
    );
  }

  Future<void> _getDeviceToken() async {
    String? deviceToken = await PushNotificationService.getDeviceToken();
    if (Platform.isAndroid) {
      setState(() {
        _deviceToken = deviceToken!;
        _isDeviceTokenInitialized = true;
        _deviceType = 'android';
      });
    } else if (Platform.isIOS) {
      setState(() {
        _deviceToken = deviceToken!;
        _isDeviceTokenInitialized = true;
        _deviceType = 'ios';
      });
    }

    if (widget.userModel != null && _isDeviceTokenInitialized) {
      _startTokenRefreshService();
    } else {
      setState(() {
        _isLoading = false; // Set loading to false once done
      });
    }
  }

  Future<void> _startTokenRefreshService() async {
    // Initialize TokenRefreshService
    TokenRefreshService().initialize(
      realm: widget.realm,
      userModel: widget.userModel!,
      deviceToken: _deviceToken,
      deviceType: _deviceType,
    );

    // Refresh the token and update the state
    bool isRefreshed = await TokenRefreshService().refreshToken();
    setState(() {
      _isRefreshTokenRefreshed = isRefreshed;
      _isLoading = false; // Set loading to false once done
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d(
        'Device Token: $_deviceToken, \nDevice Type: $_deviceType, \nDeviceInfo: $_newDeviceData');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: CustomSnackBarUtil.rootScaffoldMessengerKey,
      navigatorKey: navigatorKey,
      title: widget.title,
      onGenerateRoute: widget.router.generator,
      home: _isLoading == true && _hasLocationPermission == false
          ? RouterProvider(
              router: widget.router,
              child: SplashScreen(
                deviceType: _deviceType,
              ),
            )
          : initialNavigation(),
    );
  }

  // Initial navigation logic based on user login and token status
  Widget initialNavigation() {
    UserModel? userModel = getUserData(widget.realm);
    if (_isDeviceTokenInitialized) {
      return userModel?.id != null && _isRefreshTokenRefreshed
          ? RouterProvider(
              router: widget.router,
              child: HomeScreen(
                realm: widget.realm,
                deviceToken: _deviceToken,
                deviceType: _deviceType,
              ),
            )
          : RouterProvider(
              router: widget.router,
              child: SigninScreen(
                realm: widget.realm,
                deviceToken: _deviceToken,
                deviceType: _deviceType,
              ),
            );
    } else {
      return RouterProvider(
        router: widget.router,
        child: SplashScreen(
          deviceType: _deviceType,
        ),
      );
    }
  }
}

import 'package:fluro/fluro.dart';
import 'package:pluspay/screens/home_screen/home_screen.dart';
import 'package:pluspay/screens/splash_screen/splash_screen.dart';

void defineRoutes(FluroRouter router) {
  // Splash Screen
  router.define(
    '/splash',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        String deviceType = args['deviceType'];
        return SplashScreen(
          deviceType: deviceType,
        );
      },
    ),
  );
  // Home Screen
  router.define(
    '/home',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        String deviceType = args['deviceType'];
        return HomeScreen(
          deviceType: deviceType,
        );
      },
    ),
  );
}

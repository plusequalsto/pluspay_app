import 'package:fluro/fluro.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:pluspay/models/products.dart';
import 'package:pluspay/screens/checkout_screen/checkout_screen.dart';
import 'package:pluspay/screens/home_screen/home_screen.dart';
import 'package:pluspay/screens/dont_touch/payment_screen.dart';
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
  // Home Screen
  router.define(
    '/checkout',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Map<String, int> cart = args['cart'];
        List<Products> products = args['products'];
        String deviceType = args['deviceType'];
        return CheckoutScreen(
          cart: cart,
          products: products,
          deviceType: deviceType,
        );
      },
    ),
  );
  // Payment Screen
  router.define(
    '/payment',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        final Terminal terminal = args['terminal'];
        String deviceType = args['deviceType'];
        return PaymentScreen(
          terminal: terminal,
          deviceType: deviceType,
        );
      },
    ),
  );
}

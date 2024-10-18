import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pluspay/routes/router_provider.dart';
import 'package:pluspay/routes/routes.dart';
import 'package:pluspay/screens/home_screen/home_screen.dart';
import 'package:pluspay/screens/splash_screen/splash_screen.dart';
import 'package:pluspay/utils/custom_snackbar_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final Logger logger = Logger();
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

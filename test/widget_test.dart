// import 'package:fluro/fluro.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:pluspay/main.dart';
// import 'package:pluspay/models/user_model.dart';
// import 'package:pluspay/screens/home_screen/home_screen.dart';
// import 'package:pluspay/screens/splash_screen/splash_screen.dart';
// import 'package:realm/realm.dart';

// void main() {
//   testWidgets(
//       'Main app initializes and displays the loading indicator, then navigates to HomeScreen',
//       (WidgetTester tester) async {
//     final config = Configuration.local([
//       UserModel.schema,
//     ]);
//     final realm = Realm(config);
//     UserModel? userModel;
//     final results = realm.all<UserModel>();
//     if (results.isNotEmpty) {
//       userModel = results[0];
//     }
//     final router = FluroRouter();

//     // Build the app and trigger a frame.
//     await tester.pumpWidget(Main(
//       title: '+Pay',
//       realm: realm,
//       userModel: userModel,
//       router: router,
//     ));

//     // Verify that a CircularProgressIndicator is present initially (SplashScreen is shown).
//     expect(find.byType(CircularProgressIndicator), findsOneWidget);
//     expect(find.byType(SplashScreen), findsOneWidget);

//     // Simulate a delay to let the SplashScreen finish.
//     await tester.pumpAndSettle(
//         const Duration(seconds: 8)); // Wait for the splash screen duration.

//     // After the delay, verify that the HomeScreen is shown.
//     expect(find.byType(HomeScreen), findsOneWidget);
//   });
// }

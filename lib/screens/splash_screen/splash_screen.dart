import 'package:flutter/material.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  final String deviceType;
  const SplashScreen({
    super.key,
    required this.deviceType,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svgs/PlusPay.svg',
                width: screenRatio * 128,
              ),
              Container(
                width: screenSize.width * 0.4, // Set the desired width of the progress bar
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      20), // Adjust the radius for rounded ends
                  color: AppColors.backgroundColor, // Background color to match
                ),
                child: const LinearProgressIndicator(
                  value: null, // Use null for indeterminate
                  backgroundColor:
                      Colors.transparent, // Make background color transparent
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentColor),
                  minHeight: 4, // Adjust the height of the progress bar
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

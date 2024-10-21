import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';

class NoShopsWidget extends StatelessWidget {
  final double screenRatio;
  const NoShopsWidget({
    super.key,
    required this.screenRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'No shops added',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: screenRatio * 8,
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(height: screenRatio * 4),
        Text(
          'Press the \'+\' icon at the bottom',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: screenRatio * 8,
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

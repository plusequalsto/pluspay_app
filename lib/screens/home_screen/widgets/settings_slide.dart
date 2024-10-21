import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';

class SettingsSlide extends StatelessWidget {
  final double screenRatio;
  final TextEditingController currencyController;
  final TextEditingController languageController;
  final TextEditingController timezoneController;
  final TextEditingController taxRateController;

  const SettingsSlide({
    super.key,
    required this.screenRatio,
    required this.currencyController,
    required this.languageController,
    required this.timezoneController,
    required this.taxRateController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenRatio * 4),
      child: Column(
        children: [
          Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: screenRatio * 10,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenRatio * 16),
          TextField(
            controller: currencyController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Currency',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Currency',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            keyboardType: TextInputType.name,
          ),
          SizedBox(height: screenRatio * 8),
          TextField(
            controller: languageController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Language',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Language',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            keyboardType: TextInputType.name,
          ),
          SizedBox(height: screenRatio * 8),
          TextField(
            controller: timezoneController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'TimeZone',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'TimeZone',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            keyboardType: TextInputType.name,
          ),
          SizedBox(height: screenRatio * 8),
          TextField(
            controller: taxRateController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Tax Rate',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Tax Rate',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            keyboardType: TextInputType.name,
          ),
        ],
      ),
    );
  }
}

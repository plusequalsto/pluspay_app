import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';

class BusinessInfoSlide extends StatelessWidget {
  final double screenRatio;
  final TextEditingController businessNameController;
  final TextEditingController tradingNameController;

  const BusinessInfoSlide({
    super.key,
    required this.screenRatio,
    required this.businessNameController,
    required this.tradingNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenRatio * 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Business Information',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: screenRatio * 10,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenRatio * 16),
          TextField(
            controller: businessNameController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Business Name',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Business Name',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: screenRatio * 8),
          TextField(
            controller: tradingNameController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Trading Name',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Trading Name',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }
}

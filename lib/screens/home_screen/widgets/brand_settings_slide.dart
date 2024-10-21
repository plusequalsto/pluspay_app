import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';

class BrandSettingsSlide extends StatelessWidget {
  final double screenRatio;
  final TextEditingController logoUrlController;
  final TextEditingController primaryColorController;
  final TextEditingController secondaryColorController;
  final TextEditingController fontController;
  const BrandSettingsSlide({
    super.key,
    required this.screenRatio,
    required this.logoUrlController,
    required this.primaryColorController,
    required this.secondaryColorController,
    required this.fontController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenRatio * 4),
      child: Column(
        children: [
          Text(
            'Brand Settings',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: screenRatio * 10,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenRatio * 16),
          TextField(
            controller: logoUrlController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Logo URL',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Logo URL',
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
            controller: primaryColorController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Primary Color',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Primary Color',
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
            controller: secondaryColorController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Secondary Color',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Secondary Color',
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
            controller: fontController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Font',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Font',
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

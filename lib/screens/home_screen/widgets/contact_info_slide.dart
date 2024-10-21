import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';

class ContactInfoSlide extends StatelessWidget {
  final double screenRatio;
  final TextEditingController contactInfoController;

  const ContactInfoSlide({
    super.key,
    required this.screenRatio,
    required this.contactInfoController,
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
            'Contact Information',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: screenRatio * 10,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenRatio * 16),
          TextField(
            controller: contactInfoController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Contact Info',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Contact Info',
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

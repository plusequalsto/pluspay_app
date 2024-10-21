import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';

class ContactInfoSlide extends StatelessWidget {
  final double screenRatio;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController postcodeController;
  final TextEditingController countryController;

  const ContactInfoSlide({
    super.key,
    required this.screenRatio,
    required this.emailController,
    required this.phoneController,
    required this.streetController,
    required this.cityController,
    required this.postcodeController,
    required this.countryController,
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
          // Email
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Email',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Email',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: screenRatio * 8),
          // Phone
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Phone',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Phone',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: screenRatio * 8),
          // Street
          TextField(
            controller: streetController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Street',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Street',
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
          // City
          TextField(
            controller: cityController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'City',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'City',
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
          // Postcode
          TextField(
            controller: postcodeController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Postcode',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Postcode',
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
          // Country
          TextField(
            controller: countryController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenRatio * 8,
                vertical: screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Country',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Country',
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

// shop_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';

class ShopCardWidget extends StatelessWidget {
  final double screenRatio;
  final String businessName;
  final String tradingName;
  final String email;
  final String phone;
  final String address;

  const ShopCardWidget({
    super.key,
    required this.screenRatio,
    required this.businessName,
    required this.tradingName,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      color: AppColors.backgroundColor,
      child: Padding(
        padding: EdgeInsets.all(screenRatio * 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              businessName.isNotEmpty ? businessName : 'No Name',
              style: TextStyle(
                fontSize: screenRatio * 8,
                color: AppColors.textSecondary,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenRatio * 4),
            Text(
              'Trading Name: ${tradingName.isNotEmpty ? tradingName : 'N/A'}',
              style: TextStyle(
                fontSize: screenRatio * 6,
                color: AppColors.textSecondary,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: screenRatio),
            Text(
              'Contact: ${email.isNotEmpty ? email : 'N/A'}',
              style: TextStyle(
                fontSize: screenRatio * 6,
                color: AppColors.textSecondary,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: screenRatio),
            Text(
              'Phone: ${phone.isNotEmpty ? phone : 'N/A'}',
              style: TextStyle(
                fontSize: screenRatio * 6,
                color: AppColors.textSecondary,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: screenRatio),
            Text(
              'Address: $address',
              style: TextStyle(
                fontSize: screenRatio * 6,
                color: AppColors.textSecondary,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

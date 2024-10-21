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

  final VoidCallback onEdit;

  const ShopCardWidget({
    super.key,
    required this.screenRatio,
    required this.businessName,
    required this.tradingName,
    required this.email,
    required this.phone,
    required this.address,
    required this.onEdit,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                PopupMenuTheme(
                  data: const PopupMenuThemeData(
                    color: AppColors
                        .backgroundColor, // Background color for the menu
                    textStyle: TextStyle(
                      color: AppColors.textSecondary, // Text color
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: screenRatio * 8,
                      color: AppColors.primaryColor,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit(); // Call the edit function
                      } else if (value == 'delete') {
                        // onDelete(); // Call the delete function
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ],
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

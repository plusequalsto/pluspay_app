// shop_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';
import 'package:pluspay/widgets/custom_dialog.dart';

class ShopCardWidget extends StatelessWidget {
  final double screenRatio;
  final Map<String, dynamic> shopData;

  final Function() onEdit;
  final Function() onTap;

  const ShopCardWidget({
    super.key,
    required this.screenRatio,
    required this.shopData,
    required this.onEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      color: AppColors.backgroundColor,
      child: InkWell(
        // onTap: shopData['verified'] ? onTap : null,
        onTap: () async {
          if (shopData['verified']) {
            onTap();
          } else {
            bool? verify = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialog(
                  screenSize: MediaQuery.of(context).size,
                  screenRatio: screenRatio,
                  title: 'Shop is not verified',
                  content: 'Do you want to verify now?',
                  action1: 'Cancel',
                  action2: 'Verify',
                ); // Use the separate dialog widget
              },
            );
            logger.d(verify);
          }
        },
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
                    shopData['businessName'].isNotEmpty
                        ? shopData['businessName']
                        : 'No Name',
                    style: TextStyle(
                      fontSize: screenRatio * 8,
                      color: AppColors.textSecondary,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: !shopData['verified']
                        ? screenRatio * 30
                        : screenRatio * 24,
                    height: 16,
                    decoration: BoxDecoration(
                        color: !shopData['verified']
                            ? AppColors.errorColor.withOpacity(0.1)
                            : AppColors.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            !shopData['verified'] ? 'unverified' : 'verified',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenRatio * 4,
                              color: !shopData['verified']
                                  ? AppColors.errorColor
                                  : AppColors.successColor,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Icon(
                            !shopData['verified']
                                ? Icons.close_rounded
                                : Icons.check_rounded,
                            size: screenRatio * 4,
                            color: !shopData['verified']
                                ? AppColors.errorColor
                                : AppColors.successColor,
                          )
                        ],
                      ),
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
                'Trading Name: ${shopData['tradingName'].isNotEmpty ? shopData['tradingName'] : 'N/A'}',
                style: TextStyle(
                  fontSize: screenRatio * 6,
                  color: AppColors.textSecondary,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: screenRatio),
              Text(
                'Contact: ${shopData['contactInfo']['email'].isNotEmpty ? shopData['contactInfo']['email'] : 'N/A'}',
                style: TextStyle(
                  fontSize: screenRatio * 6,
                  color: AppColors.textSecondary,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: screenRatio),
              Text(
                'Phone: ${shopData['contactInfo']['phone'].isNotEmpty ? shopData['contactInfo']['phone'] : 'N/A'}',
                style: TextStyle(
                  fontSize: screenRatio * 6,
                  color: AppColors.textSecondary,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: screenRatio),
              Text(
                'Address: ${shopData['contactInfo']['address']['street'].isNotEmpty ? shopData['contactInfo']['address']['street'] : 'N/A'}',
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
      ),
    );
  }
}

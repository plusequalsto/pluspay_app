import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';

class CustomDialog extends StatelessWidget {
  final Size screenSize;
  final double screenRatio;
  final String title, content, action1, action2;
  const CustomDialog({
    super.key,
    required this.screenSize,
    required this.screenRatio,
    required this.title,
    required this.content,
    required this.action1,
    required this.action2,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenRatio * 8),
      ),
      backgroundColor: AppColors.backgroundColor,
      child: Container(
        width: screenSize.width * 0.4,
        height: screenSize.height * 0.26,
        padding: EdgeInsets.all(screenRatio * 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 10,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              content,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenRatio * 8,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Return false to indicate cancel
                  },
                  child: Text(
                    action1,
                    style: TextStyle(
                      color: AppColors.accentColor,
                      fontSize: screenRatio * 6,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Return true to indicate confirmation
                  },
                  child: Text(
                    action2,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: screenRatio * 6,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

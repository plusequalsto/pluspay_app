import 'package:flutter/material.dart';
import 'package:pluspay/constants/app_colors.dart';

class CustomDrawerListItem extends StatelessWidget {
  final String assetPath;
  final String name;
  final VoidCallback onTap;

  const CustomDrawerListItem({
    super.key,
    required this.assetPath,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        width: screenSize.width,
        height: screenRatio * 16,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(width: screenRatio * 4),
              // SizedBox(
              //   width: screenSize.width * 0.08,
              //   child: SvgPicture.asset(assetPath),
              // ),
              SizedBox(width: screenRatio * 4),
              Text(
                name,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: screenRatio * 8,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(width: screenRatio * 4),
            ],
          ),
        ),
      ),
    );
  }
}

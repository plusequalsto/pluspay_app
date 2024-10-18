import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/models/products.dart';

class CustomCard extends StatelessWidget {
  final double screenRatio;
  final Products product;
  final Function() onIncrease;
  final Function() onDecrease;
  final int quantity; // New parameter to track quantity in the cart

  const CustomCard({
    super.key,
    required this.screenRatio,
    required this.product,
    required this.onIncrease,
    required this.onDecrease,
    required this.quantity, // Pass the quantity to the card
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      color: AppColors.backgroundColor,
      child: ListTile(
        leading: Container(
          color: AppColors.accentColor,
          width: screenRatio * 18,
          height: screenRatio * 18,
          margin: const EdgeInsets.all(8.0),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${product.currency.toUpperCase()} ${product.price.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 10,
                color: AppColors.subText,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${product.stock}", // Displaying stock is optional, you can remove this line if not needed
              style: TextStyle(
                fontSize: 10,
                color: AppColors.subText,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.remove,
                color:
                    quantity > 0 ? AppColors.primaryColor : AppColors.subText,
              ),
              onPressed:
                  quantity > 0 ? onDecrease : null, // Disable if quantity is 0
            ),
            Text(
              "$quantity", // Show quantity, which will start at 0
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add,
                color: AppColors.primaryColor,
              ),
              onPressed: onIncrease,
            ),
          ],
        ),
      ),
    );
  }
}

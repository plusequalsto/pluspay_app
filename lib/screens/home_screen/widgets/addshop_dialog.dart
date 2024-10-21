import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';
import 'package:pluspay/screens/home_screen/widgets/brand_settings_slide.dart';
import 'package:pluspay/screens/home_screen/widgets/business_info_slide.dart';
import 'package:pluspay/screens/home_screen/widgets/contact_info_slide.dart';
import 'package:pluspay/screens/home_screen/widgets/settings_slide.dart';

class AddShopDialog extends StatefulWidget {
  final Size screenSize;
  final double screenRatio;
  const AddShopDialog({
    super.key,
    required this.screenSize,
    required this.screenRatio,
  });

  @override
  State<AddShopDialog> createState() => _AddShopDialogState();
}

class _AddShopDialogState extends State<AddShopDialog> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController tradingNameController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();
  final TextEditingController logoUrlController = TextEditingController();
  final TextEditingController primaryColorController = TextEditingController();
  final TextEditingController secondaryColorController =
      TextEditingController();
  final TextEditingController fontController = TextEditingController();
  final TextEditingController stripeAccountIdController =
      TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController timezoneController = TextEditingController();
  final TextEditingController taxRateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    businessNameController.dispose();
    tradingNameController.dispose();
    contactInfoController.dispose();
    logoUrlController.dispose();
    primaryColorController.dispose();
    secondaryColorController.dispose();
    fontController.dispose();
    stripeAccountIdController.dispose();
    currencyController.dispose();
    languageController.dispose();
    timezoneController.dispose();
    taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d(_currentPageIndex);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.screenRatio * 8),
        ),
        backgroundColor: AppColors.backgroundColor,
        child: Container(
          width: widget.screenSize.width * 0.4,
          height: _currentPageIndex == 0
              ? widget.screenSize.height * 0.42
              : _currentPageIndex == 1
                  ? widget.screenSize.height * 0.34
                  : _currentPageIndex == 1
                      ? widget.screenSize.height * 0.56
                      : widget.screenSize.height * 0.56,
          padding: EdgeInsets.all(widget.screenRatio * 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPageIndex = page; // Update the current page index
                    });
                  },
                  children: [
                    // Slide 1: Business name and Trading name
                    BusinessInfoSlide(
                      screenRatio: widget.screenRatio,
                      businessNameController: businessNameController,
                      tradingNameController: tradingNameController,
                    ),
                    // Slide 2: Contact Info
                    ContactInfoSlide(
                      screenRatio: widget.screenRatio,
                      contactInfoController: contactInfoController,
                    ),
                    // Slide 3: Brand Settings
                    BrandSettingsSlide(
                      screenRatio: widget.screenRatio,
                      logoUrlController: logoUrlController,
                      primaryColorController: primaryColorController,
                      secondaryColorController: secondaryColorController,
                      fontController: fontController,
                    ),
                    // Slide 4: Settings
                    SettingsSlide(
                      screenRatio: widget.screenRatio,
                      currencyController: currencyController,
                      languageController: languageController,
                      timezoneController: timezoneController,
                      taxRateController: taxRateController,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentPageIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        : null, // Disable button on the first page
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(
                        widget.screenSize.width * 0.3,
                        widget.screenRatio * 24,
                      ),
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: widget.screenRatio * 8,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _currentPageIndex < 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(
                        widget.screenSize.width * 0.3,
                        widget.screenRatio * 24,
                      ),
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: widget.screenRatio * 8,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSlide() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.screenRatio * 4),
      child: Column(
        children: [
          Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: widget.screenRatio * 10,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: widget.screenRatio * 16),
          TextField(
            controller: currencyController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.screenRatio * 8,
                vertical: widget.screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Currency',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: widget.screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Currency',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: widget.screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            keyboardType: TextInputType.name,
          ),
          SizedBox(height: widget.screenRatio * 8),
          TextField(
            controller: languageController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.screenRatio * 8,
                vertical: widget.screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Language',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: widget.screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Language',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: widget.screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            keyboardType: TextInputType.name,
          ),
          SizedBox(height: widget.screenRatio * 8),
          TextField(
            controller: timezoneController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.screenRatio * 8,
                vertical: widget.screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'TimeZone',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: widget.screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'TimeZone',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: widget.screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
            ),
            keyboardType: TextInputType.name,
          ),
          SizedBox(height: widget.screenRatio * 8),
          TextField(
            controller: taxRateController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.screenRatio * 8,
                vertical: widget.screenRatio * 4,
              ),
              border: const OutlineInputBorder(),
              labelText: 'Tax Rate',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: widget.screenRatio * 6,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.normal,
              ),
              hintText: 'Tax Rate',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: widget.screenRatio * 6,
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

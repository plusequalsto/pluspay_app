import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pluspay/api/user_api.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';
import 'package:pluspay/models/user_model.dart';
import 'package:pluspay/screens/home_screen/widgets/brand_settings_slide.dart';
import 'package:pluspay/screens/home_screen/widgets/business_info_slide.dart';
import 'package:pluspay/screens/home_screen/widgets/contact_info_slide.dart';
import 'package:pluspay/screens/home_screen/widgets/settings_slide.dart';
import 'package:pluspay/utils/custom_snackbar_util.dart';
import 'package:realm/realm.dart';

class AddShopDialog extends StatefulWidget {
  final Size screenSize;
  final double screenRatio;
  final Realm realm;
  final String? deviceToken, deviceType;
  final UserModel? userModel;
  const AddShopDialog({
    super.key,
    required this.screenSize,
    required this.screenRatio,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
    required this.userModel,
  });

  @override
  State<AddShopDialog> createState() => _AddShopDialogState();
}

class _AddShopDialogState extends State<AddShopDialog> {
  UserModel? userModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController tradingNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController logoUrlController = TextEditingController();
  final TextEditingController primaryColorController = TextEditingController();
  final TextEditingController secondaryColorController =
      TextEditingController();
  final TextEditingController fontController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController timezoneController = TextEditingController();
  final TextEditingController taxRateController = TextEditingController();
  Map<String, dynamic> collectData() {
    return {
      "businessName": businessNameController.text,
      "tradingName": tradingNameController.text,
      "contactInfo": {
        "email": emailController.text,
        // Assuming you need additional fields for phone and address
        "phone": phoneController.text, // Add a controller for phone if needed
        "address": {
          "street": streetController.text, // Add a controller for street
          "city": cityController.text, // Add a controller for city
          "postcode": postcodeController.text, // Add a controller for postcode
          "country": countryController.text, // Add a controller for country
        },
      },
      "brandSettings": {
        "logoUrl": logoUrlController.text,
        "primaryColor": primaryColorController.text,
        "secondaryColor": secondaryColorController.text,
        "font": fontController.text,
      },
      "settings": {
        "currency": currencyController.text,
        "language": languageController.text,
        "timezone": timezoneController.text,
        "taxRate": double.tryParse(taxRateController.text) ?? 0.0,
      },
    };
  }

  void submitData(data) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      printBuisnessDetails(data);
      try {
        final response = await UserApi().addShopDetails(
          userModel!.id,
          data,
          widget.deviceToken!,
          widget.deviceType!,
          userModel!.accessToken,
        );
        final jsonResponse = response;
        final status = jsonResponse['status'];
        logger.d('Add shop data: $status');
        if (status == 201) {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } else if (status == 401) {
          logger.d('Invalid token');
          CustomSnackBarUtil.showCustomSnackBar('Invalid token',
              success: false);
        } else {
          // Handle different statuses
          String errorMessage;
          switch (status) {
            case 400:
              errorMessage = 'Bad request: Please check your input';
              break;
            case 500:
              errorMessage = 'Server error: Please try again later';
              break;
            default:
              errorMessage = 'Unexpected error: Please try again';
          }

          // Show error message
          CustomSnackBarUtil.showCustomSnackBar(errorMessage, success: false);
        }
      } on RealmException catch (e) {
        // Handle Realm-specific exceptions
        logger.d('RealmException: $e');
        CustomSnackBarUtil.showCustomSnackBar('Database error: ${e.message}',
            success: false);
      } on SocketException catch (e) {
        // Handle network-specific exceptions
        logger.d('NetworkException: $e');
        CustomSnackBarUtil.showCustomSnackBar(
            'Network error: Please check your internet connection',
            success: false);
      }
    } else {
      CustomSnackBarUtil.showCustomSnackBar(
          'Please fill in all required fields',
          success: false);
    }
  }

  void printBuisnessDetails(Map<String, dynamic> data) {
    logger.d('Collect Data: $data');
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        setState(() {
          userModel = getUserData(widget.realm);
        });
        _currentPageIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    businessNameController.dispose();
    tradingNameController.dispose();
    emailController.dispose();
    logoUrlController.dispose();
    primaryColorController.dispose();
    secondaryColorController.dispose();
    fontController.dispose();
    currencyController.dispose();
    languageController.dispose();
    timezoneController.dispose();
    taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d(_currentPageIndex);
    final heights = {
      0: widget.screenSize.height * 0.42,
      1: widget.screenSize.height * 0.76,
      2: widget.screenSize.height * 0.56,
      3: widget.screenSize.height * 0.56,
    };
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
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: widget.screenSize.width * 0.4,
            height: heights[_currentPageIndex],
            padding: EdgeInsets.all(widget.screenRatio * 6),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPageIndex =
                              page; // Update the current page index
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
                          emailController: emailController,
                          phoneController: phoneController,
                          streetController: streetController,
                          cityController: cityController,
                          postcodeController: postcodeController,
                          countryController: countryController,
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
                        onPressed: _currentPageIndex < 3
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              }
                            : () {
                                final data = collectData();
                                submitData(data);
                              },
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
                          _currentPageIndex < 3 ? 'Next' : 'Submit',
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
        ),
      ),
    );
  }
}

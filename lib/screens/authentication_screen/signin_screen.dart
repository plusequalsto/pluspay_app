import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/api/auth_api.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';
import 'package:pluspay/models/user_model.dart';
import 'package:pluspay/utils/custom_snackbar_util.dart';
import 'package:realm/realm.dart';

class SigninScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const SigninScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _pobscureText = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  @override
  void initState() {
    super.initState();
  }

  void _validateEmail(String value) {
    bool isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
    if (isValid != _isEmailValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
    logger.d('Email is valid: $_isEmailValid');
  }

  void _validatePassword(String value) {
    bool isValid = RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:"<>?]).{8,}$')
        .hasMatch(value);
    if (isValid != _isPasswordValid) {
      setState(() {
        _isPasswordValid = isValid;
      });
    }
    logger.d('Password is valid: $_isPasswordValid');
  }

  void onSignIn() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        final response = await AuthApi().signin(
            email, password, null, widget.deviceToken!, widget.deviceType!);

        final jsonResponse = response;
        final status = jsonResponse['status'];
        logger.d('Signin status: $status');
        if (status == 200) {
          final accessToken = jsonResponse['accessToken'] as String;
          final refreshToken = jsonResponse['refreshToken'] as String;
          final userData = jsonResponse['user'] as Map<String, dynamic>;
          logger.d('Signin userData: $userData');
          final userModel =
              UserModel(userData['id'], accessToken, refreshToken);
          // Save to Realm
          widget.realm.write(() {
            widget.realm.add(userModel);
          });
          if (mounted) {
            CustomSnackBarUtil.showCustomSnackBar("Sign in successful",
                success: true);
            Navigator.popAndPushNamed(
              context,
              '/home',
              arguments: {
                'realm': widget.realm,
                'deviceToken': widget.deviceToken,
                'deviceType': widget.deviceType,
              },
            );
          }
        } else if (status == 401) {
          logger.d('Unauthorized: Invalid email or password');
          CustomSnackBarUtil.showCustomSnackBar(
              'Unauthorized: Invalid email or password',
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
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;
    logger.i(screenRatio);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Padding(
                padding: EdgeInsets.all(screenRatio * 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenRatio * 16),
                    SvgPicture.asset(
                      'assets/svgs/PlusPay.svg',
                      width: screenRatio * 64,
                    ),
                    SizedBox(height: screenRatio * 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sign in to your account',
                        style: TextStyle(
                          fontSize: screenRatio * 8,
                          color: AppColors.subText,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: screenRatio * 8),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenRatio * 8,
                                vertical: screenRatio * 4,
                              ),
                              border: const OutlineInputBorder(),
                              labelText: 'Email ID',
                              labelStyle: TextStyle(
                                color: _isEmailValid
                                    ? AppColors.textSecondary
                                    : AppColors.errorColor,
                                fontSize: screenRatio * 6,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontWeight: FontWeight.normal,
                              ),
                              hintText: 'Email ID',
                              hintStyle: TextStyle(
                                color: _isEmailValid
                                    ? AppColors.textSecondary
                                    : AppColors.errorColor,
                                fontSize: screenRatio * 6,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                              errorStyle: TextStyle(
                                color: AppColors.errorColor,
                                fontSize: screenRatio * 4,
                                fontWeight: FontWeight.normal,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors
                                      .errorColor, // Set the color for the error border
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors
                                      .errorColor, // Set the color for the focused error border
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: _validateEmail,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email ID is required';
                              } else if (!_isEmailValid) {
                                return 'Enter valid Email ID';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: screenRatio * 8),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenRatio * 8,
                                vertical: screenRatio * 4,
                              ),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: _isPasswordValid
                                    ? AppColors.textSecondary
                                    : AppColors.errorColor,
                                fontSize: screenRatio * 6,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontWeight: FontWeight.normal,
                              ),
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                color: _isPasswordValid
                                    ? AppColors.textSecondary
                                    : AppColors.errorColor,
                                fontSize: screenRatio * 6,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                              errorStyle: TextStyle(
                                color: AppColors.errorColor,
                                fontSize: screenRatio * 4,
                                fontWeight: FontWeight.normal,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.errorColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.errorColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _pobscureText = !_pobscureText;
                                  });
                                },
                                child: Icon(
                                  color: _isPasswordValid
                                      ? AppColors.primaryColor
                                      : AppColors.errorColor,
                                  _pobscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: screenRatio * 8,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            onChanged: _validatePassword,
                            obscureText: _pobscureText,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              } else if (!_isPasswordValid) {
                                return 'Enter valid Password';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenRatio * 16),
                    ElevatedButton(
                      onPressed: (_emailController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty)
                          ? onSignIn
                          : null,
                      style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenSize.width * 1.0, screenRatio * 28),
                        foregroundColor: (_emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty)
                            ? AppColors.textPrimary
                            : AppColors.textPrimary,
                        backgroundColor: (_emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty)
                            ? AppColors.primaryColor
                            : AppColors.primaryColorLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: screenRatio * 8,
                          color: (_emailController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty)
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: screenRatio * 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Sign in to your account',
                          style: TextStyle(
                            fontSize: screenRatio * 6,
                            color: AppColors.subText,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

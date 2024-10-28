import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/api/user_api.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';
import 'package:pluspay/models/user_model.dart';
import 'package:pluspay/screens/home_screen/widgets/no_shops_widget.dart';
import 'package:pluspay/screens/home_screen/widgets/shop_card_widget.dart';
import 'package:pluspay/utils/custom_snackbar_util.dart';
import 'package:pluspay/widgets/custom_drawer.dart';
import 'package:realm/realm.dart';

class HomeScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const HomeScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? userModel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> shopData = [];
  Map<String, int> cart = {}; // Map to keep track of product quantities

  @override
  void initState() {
    super.initState();
    setState(() {
      userModel = getUserData(widget.realm);
    });
    _handleRefresh();
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
  }

  Future<void> _handleRefresh() async {
    // userModel = getUserData(widget.realm);
    logger.d('Access token: ${userModel!.accessToken}');
    try {
      if (userModel != null) {
        final jsonResponse = await UserApi()
            .getShopDetails(userModel!.id, userModel!.accessToken);
        final status = jsonResponse['status'];
        if (status == 200) {
          final shop = jsonResponse['shop'];
          setState(() {
            shopData = shop;
          });
        }
      }
    } on SocketException catch (e) {
      logger.d('NetworkException: $e');
      CustomSnackBarUtil.showCustomSnackBar(
          "Network error. Please try again later.");
    } on Exception catch (e) {
      logger.d('Failed to fetch data: $e');
      CustomSnackBarUtil.showCustomSnackBar("Failed to fetch data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;
    double appBarHeight = AppBar().preferredSize.height;
    double availableHeight =
        screenSize.height - appBarHeight - MediaQuery.of(context).padding.top;
    return Scaffold(
      key: _scaffoldKey, // Ensure the key is set here
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textPrimary,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                'assets/svgs/drawer_icon.svg', // Replace with your custom icon asset path
                width: screenRatio * 10,
              ),
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
            );
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Home',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: screenRatio * 9,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(
        realm: widget.realm,
        deviceToken: widget.deviceToken,
        deviceType: widget.deviceType,
        onClose: () {
          Navigator.of(context).pop();
        },
        itemName: (String name) {
          logger.d(name);
        },
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: AppColors.backgroundColor,
        onRefresh: _handleRefresh,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              width: screenSize.width,
              padding: EdgeInsets.all(screenRatio),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenSize.width,
                    height: (availableHeight) - (screenRatio * 2),
                    child: shopData.isEmpty
                        ? NoShopsWidget(
                            screenRatio: screenRatio,
                          )
                        : ListView.builder(
                            itemCount: shopData.length,
                            itemBuilder: (context, index) {
                              final shop = shopData[index];
                              return ShopCardWidget(
                                screenRatio: screenRatio,
                                shopData: shop ?? [],
                                onEdit: () {
                                  logger.d(shop);
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/edit_shop', // Named route
                                    (Route<dynamic> route) => true,
                                    arguments: {
                                      'realm': widget.realm,
                                      'screenSize': screenSize,
                                      'screenRatio': screenRatio,
                                      'shop': shop,
                                      'deviceToken': widget.deviceToken,
                                      'deviceType': widget.deviceType,
                                    },
                                  );
                                },
                                onTap: () {
                                  logger.d('can');
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/shop', // Named route
                                    (Route<dynamic> route) =>
                                        true, // This removes all previous routes
                                    arguments: {
                                      'realm': widget.realm,
                                      'shop': shop,
                                      'deviceToken': widget.deviceToken,
                                      'deviceType': widget.deviceType,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          logger.d('Add shops pressed');

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/add_shop', // Named route
            (Route<dynamic> route) => true,
            arguments: {
              'realm': widget.realm,
              'screenSize': screenSize,
              'screenRatio': screenRatio,
              'deviceToken': widget.deviceToken,
              'deviceType': widget.deviceType,
            },
          ).then((shopAdded) {
            if (shopAdded == true) {
              _handleRefresh();
              CustomSnackBarUtil.showCustomSnackBar(
                "Shop details successfully added",
                success: true,
              );
            }
          });
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.backgroundColor,
        child: Icon(
          Icons.add,
          size: screenRatio * 16,
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}

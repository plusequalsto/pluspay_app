import 'package:pluspay/api/auth_api.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';
import 'package:pluspay/models/user_model.dart';
import 'package:pluspay/screens/authentication_screen/signin_screen.dart';
import 'package:pluspay/screens/home_screen/home_screen.dart';
import 'package:pluspay/utils/custom_snackbar_util.dart';
import 'package:pluspay/widgets/custom_drawer_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pluspay/widgets/custom_dialog.dart';
import 'package:realm/realm.dart';

class CustomDrawer extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  final VoidCallback onClose;
  final Function(String) itemName;

  const CustomDrawer({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
    required this.onClose,
    required this.itemName,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    return results.isNotEmpty ? results[0] : null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return SizedBox(
      width: screenSize.width * 0.75,
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        backgroundColor: AppColors.backgroundColor,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: statusBarHeight,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/svgs/cross.svg',
                        width: screenRatio * 12,
                        height: screenRatio * 12,
                      ),
                      onPressed: widget.onClose,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/home.svg",
                    name: "Home",
                    onTap: () {
                      widget.itemName('Home');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            realm: widget.realm,
                            deviceToken: widget.deviceToken,
                            deviceType: widget.deviceType,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                  const Divider(
                    indent: 8,
                    endIndent: 8,
                    color: AppColors.primaryColorLight,
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/logout.svg",
                    name: "Logout",
                    onTap: () async {
                      // Show the confirmation dialog
                      bool? confirmLogout = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialog(
                            screenSize: screenSize,
                            screenRatio: screenRatio,
                            title: 'Confirm Logout',
                            content: 'Are you sure you want to log out?',
                            action1: 'Cancel',
                            action2: 'Logout',
                          ); // Use the separate dialog widget
                        },
                      );

                      // If the user confirmed the logout, proceed with the logout action
                      if (confirmLogout == true) {
                        UserModel? userModel = getUserData(widget.realm);
                        if (userModel != null) {
                          widget.itemName('Logout');
                          final response = await AuthApi()
                              .signout(userModel.id, userModel.accessToken);
                          final jsonResponse = response;
                          logger.i(jsonResponse);
                          final status = jsonResponse['status'];

                          widget.realm.write(() {
                            widget.realm.delete(userModel);
                          });

                          if (status == 200) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SigninScreen(
                                  realm: widget.realm,
                                  deviceToken: widget.deviceToken,
                                  deviceType: widget.deviceType,
                                ),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          } else {
                            CustomSnackBarUtil.showCustomSnackBar(
                              "Logout failed. Please try again.",
                              success: false,
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

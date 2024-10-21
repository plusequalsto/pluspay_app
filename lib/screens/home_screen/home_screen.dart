import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';
import 'package:pluspay/models/products.dart';
import 'package:pluspay/screens/home_screen/widgets/addshop_dialog.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Products> products = [];
  List<Products> filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  Map<String, int> cart = {}; // Map to keep track of product quantities

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleRefresh() async {}

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
                    height: availableHeight * 0.24,
                    child: GestureDetector(
                      onTap: () {
                        logger.d('No Shops pressed');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddShopDialog(
                              screenSize: screenSize,
                              screenRatio: screenRatio,
                            );
                          },
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(screenRatio * 4),
                        decoration: BoxDecoration(
                          color: AppColors.shadowLight,
                          border: Border.all(
                            color: AppColors.shadowDark,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(screenRatio * 4),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Add Shops',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: screenRatio * 8,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Icon(
                              Icons.add,
                              size: screenRatio * 16,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenSize.width,
                    height: (availableHeight * 0.76) - (screenRatio * 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'No shops added',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: screenRatio * 8,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
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

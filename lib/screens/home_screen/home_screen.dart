import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';
import 'package:pluspay/models/products.dart';
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
    loadProducts(); // Load products when the screen initializes
  }

  // Load products from the JSON asset file
  Future<void> loadProducts() async {
    final String response =
        await rootBundle.loadString('assets/products/products.json');
    final Map<String, dynamic> data = jsonDecode(response);
    final List<dynamic> productList = data['products'];
    setState(() {
      products = productList.map((json) => Products.fromJson(json)).toList();
      filteredProducts =
          products; // Initialize filteredProducts with all products
    });
  }

  void filterProducts(String query) {
    final filtered = products.where((product) {
      final nameLower = product.name.toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();
    setState(() {
      filteredProducts = filtered;
    });
  }

  void addToCart(Products product) {
    setState(() {
      cart[product.sku] =
          (cart[product.sku] ?? 0) + 1; // Increment the quantity
      product.stock--; // Decrease stock (if applicable)
    });
    logger.d(cart);
  }

  void removeFromCart(Products product) {
    setState(() {
      if (cart[product.sku] != null && cart[product.sku]! > 0) {
        cart[product.sku] = cart[product.sku]! - 1; // Decrement the quantity
        if (cart[product.sku] == 0) {
          cart.remove(product.sku); // Remove from cart if quantity is 0
        }
        product.stock++; // Increase stock (if applicable)
      }
    });
    logger.d(cart);
  }

  Future<void> _handleRefresh() async {}

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height * 0.24,
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
                      child: GestureDetector(
                        onTap: () {
                          logger.d('No Shops pressed');
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'No Shops',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

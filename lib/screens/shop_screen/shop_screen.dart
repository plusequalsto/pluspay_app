import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';
import 'package:pluspay/models/products.dart';
import 'package:pluspay/screens/home_screen/home_screen.dart';
import 'package:pluspay/widgets/custom_card.dart';
import 'package:badges/badges.dart' as badges;
import 'package:pluspay/widgets/custom_drawer.dart';
import 'package:realm/realm.dart';

class ShopScreen extends StatefulWidget {
  final Realm realm;
  final Map<String, dynamic> shop;
  final String? deviceToken, deviceType;
  const ShopScreen({
    super.key,
    required this.realm,
    required this.shop,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
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
    if (product.stock > 0) {
      setState(() {
        cart[product.sku] = (cart[product.sku] ?? 0) + 1;
        product.stock--;
      });
    }
  }

  void removeFromCart(Products product) {
    if (cart[product.sku] != null && cart[product.sku]! > 0) {
      setState(() {
        cart[product.sku] = cart[product.sku]! - 1;
        if (cart[product.sku] == 0) {
          cart.remove(product.sku);
        }
        product.stock++;
      });
    }
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  realm: widget.realm,
                  deviceToken: widget.deviceToken,
                  deviceType: widget.deviceType,
                ),
              ),
            );
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.shop['businessName'],
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: screenRatio * 9,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/checkout', // Named route
                  (Route<dynamic> route) =>
                      true, // false removes all previous routes
                  arguments: {
                    'realm': widget.realm,
                    'shop': widget.shop,
                    'cart': cart,
                    'products': products,
                    'deviceToken': widget.deviceToken,
                    'deviceType': widget.deviceType,
                  },
                );
              },
              child: cart.isNotEmpty
                  ? badges.Badge(
                      badgeContent: Text(
                        '${cart.values.fold(0, (prev, element) => prev + element)}', // Total items in cart
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textPrimary,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      badgeAnimation: badges.BadgeAnimation.fade(),
                      child: const Icon(
                        Icons.shopping_basket_rounded,
                        color: AppColors.backgroundColor,
                      ),
                    )
                  : const Icon(
                      Icons.shopping_basket_rounded,
                      color: AppColors.backgroundColor,
                    ),
            ),
          ),
        ],
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
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Center(
          child: SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: filterProducts,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: AppColors.subText,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  // Use Scrollbar with ListView
                  Expanded(
                    child: products.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Scrollbar(
                            child: ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                final quantity = cart[product.sku] ??
                                    0; // Get quantity from cart

                                return CustomCard(
                                  screenRatio: screenRatio,
                                  product: product,
                                  onIncrease: () {
                                    product.stock > 0
                                        ? addToCart(product)
                                        : null;
                                  },
                                  onDecrease: () {
                                    logger.d('decrease');
                                    removeFromCart(product);
                                  },
                                  quantity:
                                      quantity, // Pass the quantity to the card
                                );
                              },
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

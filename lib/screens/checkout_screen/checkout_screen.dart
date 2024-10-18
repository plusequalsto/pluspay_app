import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';
import 'package:pluspay/models/products.dart'; // Make sure to import your Products model
import 'package:http/http.dart' as http;
import 'package:pluspay/utils/calculate_total.dart';
// import 'package:rive/rive.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<Products> products;
  final String deviceType;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.products,
    required this.deviceType,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Define VAT and Discount rates
  static const double vatRate = 0.2; // 20%
  static const double discountRate = 0.1; // 10%

  bool isScanning = false;
  String scanStatus = "Scan readers";
  Terminal? terminal0;
  Location? selectedLocation;
  List<Reader> readers = [];
  Reader? reader;
  late final locationId;
  double subtotal = 0;
  // double total = 0;

  static const bool isSimulated = true; //if testing >> true otherwise false

  //Tap & Pay
  StreamSubscription? onConnectionStatusChangeSub;

  var connectionStatus = ConnectionStatus.notConnected;

  StreamSubscription? onPaymentStatusChangeSub;

  PaymentStatus paymentStatus = PaymentStatus.notReady;

  StreamSubscription? onUnexpectedReaderDisconnectSub;

  StreamSubscription? discoverReaderSub;
  bool isPaymentSuccessful = false;
  PaymentIntent? paymentIntent0;

  Future<Reader?> tryConnectReader(Terminal terminal, Reader reader) async {
    String? getLocationId() {
      final locationId = selectedLocation?.id ?? reader.locationId;
      if (locationId == null) throw AssertionError('Missing location');

      return locationId;
    }

    final locationId = getLocationId();

    return await terminal.connectMobileReader(
      reader,
      locationId: locationId!,
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
  }

  Future<String> getConnectionToken() async {
    http.Response response = await http.post(
      Uri.parse("https://api.stripe.com/v1/terminal/connection_tokens"),
      headers: {
        'Authorization':
            'Bearer ${dotenv.env[isSimulated ? 'STRIPE_TEST_SECRET' : 'STRIPE_LIVE_SECRET']}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
    );
    Map jsonResponse = json.decode(response.body);
    logger.d(jsonResponse);
    if (jsonResponse['secret'] != null) {
      return jsonResponse['secret'];
    } else {
      return "";
    }
  }

  Future<void> connectReader(Terminal terminal, Reader reader) async {
    // Ensure we have a locationId
    final locationId = selectedLocation?.id ?? reader.locationId;
    if (locationId == null) throw AssertionError('Missing location');
    try {
      await tryConnectReader(terminal, reader);
    } catch (error) {
      // Check if the error indicates a redeemed token
      if (error is TerminalException && error.message.contains("redeemed")) {
        logger.d("Connection token redeemed. Fetching a new token...");

        // Fetch a new connection token
        final newConnectionToken = await getConnectionToken();

        // Initialize a new terminal instance with the new token
        final terminalWithNewToken = await Terminal.getInstance(
          shouldPrintLogs: false,
          fetchToken: () async {
            return newConnectionToken;
          },
        );

        // Retry connecting to the reader
        try {
          await terminalWithNewToken.connectMobileReader(
            reader,
            locationId: locationId, // Pass the locationId here
          );
          logger.d("Successfully connected to the reader with a new token.");
        } catch (retryError) {
          logger.e('Error reconnecting to reader: ${retryError.toString()}');
          showSnackBar("Failed to connect to reader: ${retryError.toString()}");
        }
      } else {
        logger.e('Error connecting to reader: ${error.toString()}');
        showSnackBar("Failed to connect to reader: ${error.toString()}");
      }
    }
  }

  void stopDiscoverReaders() {
    unawaited(discoverReaderSub?.cancel());
    setState(() {
      discoverReaderSub = null;
      isScanning = false;
      scanStatus = "Scan readers";
      readers = const [];
    });
  }

  Future<void> confirmPaymentIntent(
      Terminal terminal, PaymentIntent paymentIntent) async {
    try {
      showSnackBar('Processing!');

      final processedPaymentIntent =
          await terminal.confirmPaymentIntent(paymentIntent);
      paymentIntent0 = processedPaymentIntent;
      // Show the animation for a while and then reset the state
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          isPaymentSuccessful = false;
        });
      });
      setState(() {
        isPaymentSuccessful = true;
      });
      showSnackBar('Payment processed!');
    } catch (e) {
      showSnackBar('Inside collect payment exception ${e.toString()}');

      logger.d(e.toString());
    }
    // navigate to payment success screen
  }

  Future<bool> collectPaymentMethod(
      Terminal terminal, PaymentIntent paymentIntent) async {
    final collectingPaymentMethod = terminal.collectPaymentMethod(
      paymentIntent,
      skipTipping: true,
    );

    try {
      final paymentIntentWithPaymentMethod = await collectingPaymentMethod;
      paymentIntent0 = paymentIntentWithPaymentMethod;
      await confirmPaymentIntent(terminal, paymentIntent0!).then((value) {});
      return true;
    } on TerminalException catch (exception) {
      switch (exception.code) {
        case TerminalExceptionCode.canceled:
          showSnackBar('Collecting Payment method is cancelled!');
          return false;
        default:
          rethrow;
      }
    }
  }

  Future<bool> createPaymentIntent(Terminal terminal, String amount) async {
    final paymentIntent =
        await terminal.createPaymentIntent(PaymentIntentParameters(
      amount:
          (double.parse(double.parse(amount).toStringAsFixed(2)) * 100).ceil(),
      currency: "gbp",
      captureMethod: CaptureMethod.automatic,
      paymentMethodTypes: [PaymentMethodType.cardPresent],
    ));
    paymentIntent0 = paymentIntent;
    if (paymentIntent0 == null) {
      showSnackBar('Payment intent is not created!');
    }

    return await collectPaymentMethod(terminal, paymentIntent0!);
  }

  void startDiscoverReaders(Terminal terminal) {
    isScanning = true;
    readers = [];
    final discoverReaderStream =
        terminal.discoverReaders(const LocalMobileDiscoveryConfiguration(
      isSimulated: isSimulated,
    ));
    setState(() {
      discoverReaderSub = discoverReaderStream.listen((readers) {
        scanStatus = "Tap on Any To connect ";
        setState(() => readers = readers);

        // Automatically connect to the first available reader
        if (readers.isNotEmpty) {
          connectReader(terminal, readers.first).then((_) async {
            stopDiscoverReaders();
            bool status = await createPaymentIntent(
                terminal,
                calculateTotal(
                        widget.cart, widget.products, vatRate, discountRate)
                    .toStringAsFixed(2));
            if (status) {
              showSnackBar(
                  'Payment Collected: ${calculateTotal(widget.cart, widget.products, vatRate, discountRate).toStringAsFixed(2)}');
            } else {
              showSnackBar('Payment Canceled');
            }
          }).catchError((error) {
            showSnackBar(
                "Failed to connect to the reader: ${error.toString()}");
          });
        }
      }, onDone: () {
        setState(() {
          discoverReaderSub = null;
          readers = const [];
        });
      });
    });
  }

  Future<void> fetchLocations() async {
    final locations = await terminal0!.listLocations();
    selectedLocation = locations.first;
    logger.d(selectedLocation);
    if (selectedLocation == null) {
      throw AssertionError(
          'Please create location on stripe dashboard to proceed further!');
    }
  }

  Future<void> requestPermissions() async {
    final permissions = [
      Permission.locationWhenInUse,
      Permission.bluetooth,
      if (Platform.isAndroid) ...[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ],
    ];

    for (final permission in permissions) {
      final result = await permission.request();
      if (result == PermissionStatus.denied ||
          result == PermissionStatus.permanentlyDenied) return;
    }
  }

  Future<void> initTerminal() async {
    final terminal = await Terminal.getInstance(
      shouldPrintLogs: false,
      fetchToken: () async {
        return await getConnectionToken();
      },
    );
    terminal0 = terminal;
    showSnackBar("Initialized Stripe Terminal");

    onConnectionStatusChangeSub =
        terminal.onConnectionStatusChange.listen((status) {
      logger.d('Connection Status Changed: ${status.name}');
      connectionStatus = status;
      scanStatus = connectionStatus.name;
    });
    onUnexpectedReaderDisconnectSub =
        terminal.onUnexpectedReaderDisconnect.listen((reader) {
      logger.d('Reader Unexpected Disconnected: ${reader.label}');
    });
    onPaymentStatusChangeSub = terminal.onPaymentStatusChange.listen((status) {
      logger.d('Payment Status Changed: ${status.name}');
      paymentStatus = status;
    });
    if (terminal0 == null) {
      logger.d('Please try again later!');
    }
  }

  Future<void> _initTerminal() async {
    await requestPermissions();
    await initTerminal();
    await fetchLocations();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSnackBar("Wait initializing Stripe Terminal");
    });
    calculateSubtotal();
    _initTerminal();
  }

  Future<void> _disconnectReader() async {
    try {
      await terminal0!.disconnectReader();
      showSnackBar("Disconnected from reader.");
    } catch (e) {
      showSnackBar("Failed to disconnect from the reader: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    unawaited(onConnectionStatusChangeSub?.cancel());
    unawaited(discoverReaderSub?.cancel());
    unawaited(onUnexpectedReaderDisconnectSub?.cancel());
    unawaited(onPaymentStatusChangeSub?.cancel());
    super.dispose();
  }

  Products? getProductBySku(String sku) {
    return widget.products.firstWhere(
      (product) => product.sku == sku,
      orElse: () => Products(
          sku: '',
          name: '',
          description: '',
          price: 0,
          currency: '',
          category: '',
          stock: 0,
          tags: []), // Create a dummy product
    );
  }

  void calculateSubtotal() {
    for (var entry in widget.cart.entries) {
      final sku = entry.key;
      final quantity = entry.value;

      // Fetch the product by SKU
      Products? product = getProductBySku(sku);
      if (product != null) {
        subtotal += product.price * quantity; // Accumulate subtotal
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    // final double screenRatio = screenSize.height / screenSize.width;

    // Calculate VAT and total
    double vat = subtotal * vatRate;
    double discount = subtotal * discountRate;
    logger.d(widget.cart);
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
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenSize.width,
                        height: screenSize.height * 0.08,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await _disconnectReader(); // Disconnect from the reader
                                  Navigator.of(context).pop();
                                },
                                child: const Icon(
                                  Icons.cancel_outlined,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: widget.cart.isEmpty
                            ? const Center(child: Text('Your cart is empty.'))
                            : ListView.builder(
                                itemCount: widget.cart.length,
                                itemBuilder: (context, index) {
                                  final sku = widget.cart.keys.elementAt(index);
                                  final quantity = widget.cart[sku];
                                  final product = getProductBySku(sku);
                                  return product != null
                                      ? ListTile(
                                          title: Text(
                                              product.name), // Product name
                                          subtitle: Text(
                                              'Quantity: $quantity'), // Quantity
                                          trailing: Text(
                                              '\$${(product.price * quantity!).toStringAsFixed(2)}'), // Total price
                                        )
                                      : const ListTile(
                                          title: Text('Product not found'),
                                        );
                                },
                              ),
                      ),
                      // Summary Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                            Text('VAT (20%): \$${vat.toStringAsFixed(2)}'),
                            Text(
                                'Discount (10%): -\$${discount.toStringAsFixed(2)}'),
                            const Divider(),
                            Text(
                                'Total: \$${calculateTotal(widget.cart, widget.products, vatRate, discountRate).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          isScanning
                              ? stopDiscoverReaders()
                              : startDiscoverReaders(terminal0!);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: Text(
                          'Collect Payment',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isPaymentSuccessful)
                    Lottie.asset(
                      'assets/animations/success.json',
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

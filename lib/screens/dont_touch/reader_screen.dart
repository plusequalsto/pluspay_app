import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pluspay/constants/app_colors.dart';
import 'package:pluspay/main.dart';

class ReaderScreen extends StatefulWidget {
  final String deviceType;
  const ReaderScreen({
    super.key,
    required this.deviceType,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool isScanning = false;
  String scanStatus = "Scan readers";
  Terminal? _terminal;
  Location? _selectedLocation;
  List<Reader> _readers = [];
  Reader? _reader;
  late final locationId;

  static const bool _isSimulated = true; //if testing >> true otherwise false

  //Tap & Pay
  StreamSubscription? _onConnectionStatusChangeSub;

  var _connectionStatus = ConnectionStatus.notConnected;

  StreamSubscription? _onPaymentStatusChangeSub;

  PaymentStatus _paymentStatus = PaymentStatus.notReady;

  StreamSubscription? _onUnexpectedReaderDisconnectSub;

  StreamSubscription? _discoverReaderSub;

  void _startDiscoverReaders(Terminal terminal) {
    isScanning = true;
    _readers = [];
    final discoverReaderStream =
        terminal.discoverReaders(const LocalMobileDiscoveryConfiguration(
      isSimulated: _isSimulated,
    ));
    setState(() {
      _discoverReaderSub = discoverReaderStream.listen((readers) {
        scanStatus = "Tap on Any To connect ";
        setState(() => _readers = readers);

        // Automatically connect to the first available reader
        if (_readers.isNotEmpty) {
          _connectReader(terminal, _readers.first).then((_) {
            _stopDiscoverReaders();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/payment', // Named route
              (Route<dynamic> route) =>
                  true, // This removes all previous routes
              arguments: {
                'terminal': terminal,
                'deviceType': widget.deviceType,
              },
            );
          }).catchError((error) {
            showSnackBar(
                "Failed to connect to the reader: ${error.toString()}");
          });
        }
      }, onDone: () {
        setState(() {
          _discoverReaderSub = null;
          _readers = const [];
        });
      });
    });
  }

  void _stopDiscoverReaders() {
    unawaited(_discoverReaderSub?.cancel());
    setState(() {
      _discoverReaderSub = null;
      isScanning = false;
      scanStatus = "Scan readers";
      _readers = const [];
    });
  }

  Future<void> _connectReader(Terminal terminal, Reader reader) async {
    // Ensure we have a locationId
    final locationId = _selectedLocation?.id ?? reader.locationId;
    if (locationId == null) throw AssertionError('Missing location');
    try {
      await _tryConnectReader(terminal, reader);
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

  Future<Reader?> _tryConnectReader(Terminal terminal, Reader reader) async {
    String? getLocationId() {
      final locationId = _selectedLocation?.id ?? reader.locationId;
      if (locationId == null) throw AssertionError('Missing location');

      return locationId;
    }

    final locationId = getLocationId();

    return await terminal.connectMobileReader(
      reader,
      locationId: locationId!,
    );
  }

  Future<void> _fetchLocations() async {
    final locations = await _terminal!.listLocations();
    _selectedLocation = locations.first;
    logger.d(_selectedLocation);
    if (_selectedLocation == null) {
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

  Future<void> _initTerminal() async {
    await requestPermissions();
    await initTerminal();
    await _fetchLocations();
  }

  Future<String> getConnectionToken() async {
    http.Response response = await http.post(
      Uri.parse("https://api.stripe.com/v1/terminal/connection_tokens"),
      headers: {
        'Authorization':
            'Bearer ${dotenv.env[_isSimulated ? 'STRIPE_TEST_SECRET' : 'STRIPE_LIVE_SECRET']}',
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

  Future<void> initTerminal() async {
    final terminal = await Terminal.getInstance(
      shouldPrintLogs: false,
      fetchToken: () async {
        return await getConnectionToken();
      },
    );
    _terminal = terminal;
    showSnackBar("Initialized Stripe Terminal");

    _onConnectionStatusChangeSub =
        terminal.onConnectionStatusChange.listen((status) {
      logger.d('Connection Status Changed: ${status.name}');
      _connectionStatus = status;
      scanStatus = _connectionStatus.name;
    });
    _onUnexpectedReaderDisconnectSub =
        terminal.onUnexpectedReaderDisconnect.listen((reader) {
      logger.d('Reader Unexpected Disconnected: ${reader.label}');
    });
    _onPaymentStatusChangeSub = terminal.onPaymentStatusChange.listen((status) {
      logger.d('Payment Status Changed: ${status.name}');
      _paymentStatus = status;
    });
    if (_terminal == null) {
      logger.d('Please try again later!');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSnackBar("Wait initializing Stripe Terminal");
    });

    _initTerminal();
  }

  @override
  void dispose() {
    unawaited(_onConnectionStatusChangeSub?.cancel());
    unawaited(_discoverReaderSub?.cancel());
    unawaited(_onUnexpectedReaderDisconnectSub?.cancel());
    unawaited(_onPaymentStatusChangeSub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: screenSize.width,
                height: screenSize.height * 0.08,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_rounded,
                      color: AppColors.primaryColor,
                    ),
                    Icon(
                      Icons.shopping_basket_rounded,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
              Text(
                scanStatus,
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.textSecondary,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_readers.isNotEmpty)
                ..._readers.map(
                  (reader) => TextButton(
                    onPressed: () async {
                      setState(() {
                        isScanning = false;
                      });
                      await _connectReader(_terminal!, reader).then((v) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/payment', // Named route
                          (Route<dynamic> route) =>
                              true, // This removes all previous routes
                          arguments: {
                            'terminal': _terminal!,
                            'deviceType': widget.deviceType,
                          },
                        );
                      });
                    },
                    child: Text(
                      reader.serialNumber,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          isScanning
              ? _stopDiscoverReaders()
              : _startDiscoverReaders(_terminal!);
        },
        label: Text(
          isScanning ? 'Stop Scanning' : 'Scan Reader',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(
          isScanning ? Icons.stop : Icons.scanner,
          color: AppColors.backgroundColor,
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

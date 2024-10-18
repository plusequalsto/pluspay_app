// lib/services/terminal_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:permission_handler/permission_handler.dart';

class ReaderManager {
  Terminal? _terminal;
  Location? _selectedLocation;
  StreamSubscription? _onConnectionStatusChangeSub;
  StreamSubscription? _onPaymentStatusChangeSub;
  StreamSubscription? _onUnexpectedReaderDisconnectSub;
  StreamSubscription? _discoverReaderSub;

  static const bool _isSimulated = true; // Set to true for testing

  Future<void> initTerminal() async {
    await requestPermissions();
    _terminal = await Terminal.getInstance(
      shouldPrintLogs: false,
      fetchToken: () async {
        return await getConnectionToken();
      },
    );

    _onConnectionStatusChangeSub =
        _terminal!.onConnectionStatusChange.listen((status) {
      // Handle connection status changes
    });

    _onUnexpectedReaderDisconnectSub =
        _terminal!.onUnexpectedReaderDisconnect.listen((reader) {
      // Handle unexpected reader disconnection
    });

    _onPaymentStatusChangeSub = _terminal!.onPaymentStatusChange.listen((status) {
      // Handle payment status changes
    });
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

  Future<String> getConnectionToken() async {
    final response = await http.post(
      Uri.parse("https://api.stripe.com/v1/terminal/connection_tokens"),
      headers: {
        'Authorization':
            'Bearer ${dotenv.env[_isSimulated ? 'STRIPE_TEST_SECRET' : 'STRIPE_LIVE_SECRET']}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
    );

    Map jsonResponse = json.decode(response.body);
    if (jsonResponse['secret'] != null) {
      return jsonResponse['secret'];
    } else {
      throw Exception("Failed to retrieve connection token.");
    }
  }

  Future<List<Reader>> discoverReaders() async {
    if (_terminal == null) throw Exception("Terminal not initialized.");
    final discoverReaderStream = _terminal!.discoverReaders(
      const LocalMobileDiscoveryConfiguration(isSimulated: _isSimulated),
    );

    final readers = await discoverReaderStream.first;
    return readers;
  }

  Future<void> connectReader(Reader reader) async {
    if (_terminal == null) throw Exception("Terminal not initialized.");
    final locationId = _selectedLocation?.id ?? reader.locationId;

    if (locationId == null) throw AssertionError('Missing location');

    try {
      await _terminal!.connectMobileReader(reader, locationId: locationId);
    } catch (error) {
      // Handle errors related to connecting the reader
      throw Exception("Failed to connect to reader: ${error.toString()}");
    }
  }

  Future<void> fetchLocations() async {
    if (_terminal == null) throw Exception("Terminal not initialized.");
    final locations = await _terminal!.listLocations();
    _selectedLocation = locations.first;
    if (_selectedLocation == null) {
      throw Exception('No location available. Please create a location on the Stripe dashboard.');
    }
  }

  void dispose() {
    _onConnectionStatusChangeSub?.cancel();
    _onPaymentStatusChangeSub?.cancel();
    _onUnexpectedReaderDisconnectSub?.cancel();
    _discoverReaderSub?.cancel();
  }
}
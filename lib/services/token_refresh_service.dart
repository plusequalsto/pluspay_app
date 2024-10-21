import 'dart:async';
import 'dart:io';
import 'package:pluspay/models/user_model.dart';
import 'package:pluspay/api/auth_api.dart';
import 'package:pluspay/main.dart';
import 'package:realm/realm.dart';

class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  Timer? timer;
  UserModel? userModel;
  Realm? realm;
  String? deviceToken;
  String? deviceType;

  factory TokenRefreshService() {
    return _instance;
  }

  TokenRefreshService._internal();

  // Initialize method with boolean return
  void initialize({
    required Realm realm,
    required UserModel userModel,
    required String deviceToken,
    required String deviceType,
  }) {
    if (deviceToken.isEmpty || deviceType.isEmpty) {
      logger.d('Initialization failed: Insufficient data');
      return; // Exit the method early
    }
    this.realm = realm;
    this.userModel = userModel;
    this.deviceToken = deviceToken;
    this.deviceType = deviceType;
    _startTokenRefreshTimer();
  }

  void _startTokenRefreshTimer() {
    if (timer != null) {
      logger.d('Existing token refresh timer is canceled');
      timer?.cancel();
    }
    timer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      logger.d('Token refresh timer triggered at ${DateTime.now()}');
      await refreshToken();
    });
  }

  Future<bool> refreshToken({int retries = 3}) async {
    if (userModel == null || deviceToken == null || deviceType == null) {
      logger.d('Token refresh skipped: insufficient data.');
      return false;
    }
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final response = await AuthApi().refreshToken(userModel!.accessToken,
            userModel!.refreshToken, deviceToken, deviceType);
        final status = response['status'];
        if (status == 200) {
          _updateTokens(response['accessToken'], response['refreshToken']);
          return true;
        } else {
          logger.d(
              'Token refresh attempt $attempt failed: ${response['message']}');
        }
      } on SocketException catch (e) {
        logger.d('NetworkException on attempt $attempt: $e');
        if (attempt == retries - 1) {
          return false;
        }
      } catch (e) {
        logger.d('Exception on attempt $attempt: $e');
        return false;
      }
    }
    return false;
  }

  void _updateTokens(String newAccessToken, String newRefreshToken) {
    realm?.write(() {
      userModel!.accessToken = newAccessToken;
      userModel!.refreshToken = newRefreshToken;
    });
    // Optionally validate if tokens have been updated correctly
    if (userModel!.accessToken == newAccessToken &&
        userModel!.refreshToken == newRefreshToken) {
      logger.d('Tokens updated successfully');
    } else {
      logger.d('Token update failed');
    }
  }

  // Dispose method with boolean return
  bool dispose() {
    if (timer == null) {
      logger.d('Dispose failed: Timer is not active.');
      return false;
    }
    timer?.cancel();
    timer = null;
    realm = null;
    userModel = null;
    logger.d('Timer and resources disposed successfully.');
    return true;
  }
}

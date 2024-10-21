import 'package:pluspay/constants/api_constants.dart';
import 'package:pluspay/services/api_service.dart';

class UserApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addBusiness(
    String userId,
    String businessName,
    String tradingName,
    Map<String, dynamic> contactInfo, // Pass contactInfo as a Map
    Map<String, dynamic> brandSettings, // Pass brandSettings as a Map
    String stripeAccountId,
    Map<String, dynamic> settings, // Pass settings as a Map
    String? accessToken,
    String? deviceToken,
    String? deviceType,
  ) async {
    // Construct the request body
    final Map<String, dynamic> requestBody = {
      'businessName': businessName,
      'tradingName': tradingName,
      'contactInfo': contactInfo, // Use the contactInfo Map directly
      'brandSettings': brandSettings, // Use the brandSettings Map directly
      'stripeAccountId': stripeAccountId,
      'settings': settings, // Use the settings Map directly
      'deleted': false,
      'deletedAt': null,
    };

    // Make the API call
    return _apiService.post(
        ApiConstants.addbusinessUrl(userId), accessToken, requestBody);
  }
}

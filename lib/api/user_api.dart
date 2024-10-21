import 'package:pluspay/constants/api_constants.dart';
import 'package:pluspay/services/api_service.dart';

class UserApi {
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseURL);

  Future<Map<String, dynamic>> addShopDetails(String userId,
      Map<String, dynamic> data, String? deviceToken, String? deviceType,
      [String? accessToken]) async {
    // Construct the request body
    final Map<String, dynamic> requestBody = {
      'businessName': data['businessName'],
      'tradingName': data['tradingName'],
      'contactInfo': data['contactInfo'], // Use the contactInfo Map directly
      'brandSettings':
          data['brandSettings'], // Use the brandSettings Map directly
      'settings': data['settings'], // Use the settings Map directly
    };

    // Make the API call
    return _apiService.post(
        ApiConstants.addshopdetailsUrl(userId), accessToken, requestBody);
  }

  Future<Map<String, dynamic>> getShopDetails(String userId,
      [String? accessToken]) async {
    // Make the API call
    return _apiService.get(ApiConstants.getshopdetailsUrl(userId), accessToken);
  }
}

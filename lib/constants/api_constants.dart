class ApiConstants {
  static const String baseURL =
      'https://pluspay-api-1e324f8fc96f.herokuapp.com/api/v1';
  // static const String baseURL = 'http://80.177.32.233:4200/api/v1';
  // static const String baseURL = 'http://localhost:4200/api/v1';

  static const String signup = '/auth/signup';
  static const String signin = '/auth/signin';

  static const String refreshtoken = '/auth/refreshtoken';

  static String addshopdetailsUrl(String userId) {
    return '/user/addshopdetails/$userId';
  }

  static String getshopdetailsUrl(String userId) {
    return '/user/getshopdetails/$userId';
  }

  static String getSignoutUrl(String userId) {
    return '/auth/signout/$userId';
  }
}

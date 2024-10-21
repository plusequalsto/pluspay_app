class ApiConstants {
  // static const String baseURL =
  //     'https://qiot-pneumothorax-api-b70842062523.herokuapp.com/api/v1';
  static const String baseURL = 'http://80.177.32.233:4200/api/v1';

  static const String signup = '/auth/signup';
  static const String signin = '/auth/signin';

  static const String refreshtoken = '/auth/refreshtoken';

  static String getSignoutUrl(String userId) {
    return '/auth/signout/$userId';
  }
}

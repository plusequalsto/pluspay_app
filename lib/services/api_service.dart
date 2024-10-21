import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pluspay/main.dart';
import 'package:pluspay/utils/api_helpers.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> get(String endpoint, String? accessToken) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = ApiHelper.buildHeaders(accessToken);
    final response = await http.get(url, headers: headers);
    ApiHelper.handleError(response);
    return ApiHelper.parseResponse(response);
  }

  Future<Map<String, dynamic>> post(
      String endpoint, String? accessToken, Map<String, dynamic> data,
      {File? file}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    logger.d(
        'endpoint: $endpoint, \nurl: $url, \naccessToken: $accessToken, \ndata: $data');
    if (accessToken == null) {
      final headers = ApiHelper.buildHeaders();
      final response =
          await http.post(url, headers: headers, body: json.encode(data));
      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    } else {
      if (file != null) {
        // Multipart request for file upload
        var request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $accessToken';

        // Add fields
        data.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        // Add file
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        // Send request
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        return ApiHelper.parseResponse(
            http.Response(responseBody, response.statusCode));
      } else {
        // Standard JSON request
        final headers = ApiHelper.buildHeaders(accessToken);
        final response =
            await http.post(url, headers: headers, body: json.encode(data));

        ApiHelper.handleError(response);
        return ApiHelper.parseResponse(response);
      }
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, String? accessToken, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    if (accessToken == null) {
      final headers = ApiHelper.buildHeaders();
      final response =
          await http.put(url, headers: headers, body: json.encode(data));
      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    } else {
      final headers = ApiHelper.buildHeaders(accessToken);
      final response =
          await http.put(url, headers: headers, body: json.encode(data));
      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    }
  }

  Future<Map<String, dynamic>> delete(
      String endpoint, String? accessToken) async {
    final url = Uri.parse('$baseUrl$endpoint');
    logger.d('endpoint: $endpoint, \nurl: $url, \naccessToken: $accessToken');
    if (accessToken == null) {
      final headers = ApiHelper.buildHeaders();
      final response = await http.delete(url, headers: headers);
      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    } else {
      final headers = ApiHelper.buildHeaders(accessToken);
      final response = await http.delete(url, headers: headers);
      ApiHelper.handleError(response);
      return ApiHelper.parseResponse(response);
    }
  }
}

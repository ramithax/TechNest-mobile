import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/token_response.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      print('STATUS: ${response.statusCode}');
      print('DATA: ${response.data}');

      final tokenResponse = TokenResponse.fromJson(response.data);

      final userId = _getUserIdFromToken(tokenResponse.accessToken);

      await _tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        userId: userId,
      );

      return tokenResponse;
    } on DioException catch (e) {
      print('DIO ERROR TYPE: ${e.type}');
      print('DIO ERROR: ${e.message}');
      print('STATUS: ${e.response?.statusCode}');
      print('RESPONSE: ${e.response?.data}');
      print('REQUEST URL: ${e.requestOptions.uri}');

      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      }

      if (e.response?.data is String) {
        throw Exception(e.response!.data);
      }

      throw Exception('Unable to connect to the server');
    }
  }

  Future<TokenResponse?> refreshToken() async {
    final userId = await _tokenStorage.getUserId();
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (userId == null || refreshToken == null) {
      return null;
    }

    try {
      final response = await _apiService.dio.post(
        ApiConstants.refreshToken,
        data: {'userId': userId, 'refreshToken': refreshToken},
      );

      final tokenResponse = TokenResponse.fromJson(response.data);

      await _tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        userId: userId,
      );

      return tokenResponse;
    } catch (_) {
      await _tokenStorage.clearTokens();
      return null;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  int _getUserIdFromToken(String token) {
    final parts = token.split('.');

    if (parts.length != 3) {
      throw Exception('Invalid access token');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = jsonDecode(decoded);

    final userId =
        payloadMap['nameid'] ??
        payloadMap['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];

    if (userId == null) {
      throw Exception('User ID not found in access token');
    }

    return int.parse(userId.toString());
  }
}

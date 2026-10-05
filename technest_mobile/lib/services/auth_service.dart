import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );

      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER DATA: ${response.data}');
    } on DioException catch (e) {
      print('REGISTER DIO ERROR TYPE: ${e.type}');
      print('REGISTER DIO ERROR: ${e.message}');
      print('REGISTER STATUS: ${e.response?.statusCode}');
      print('REGISTER RESPONSE: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        if (e.response?.data is String) {
          throw Exception(e.response!.data);
        }

        throw Exception('Email already taken');
      }

      if (e.response?.data is String) {
        throw Exception(e.response!.data);
      }

      throw Exception('Unable to connect to the server');
    }
  }

  Future<TokenResponse> googleLogin() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      if (kIsWeb) {
        // Web only supports clientId.
        await googleSignIn.initialize(
          clientId: '351018255426-6ca2scclrhsa6n6m0rf5gd6s40perbka.apps.googleusercontent.com',
        );
      } else {
        // Android uses the Web OAuth client as the serverClientId
        // so the backend can validate the Google ID token.
        await googleSignIn.initialize(
          serverClientId: '351018255426-6ca2scclrhsa6n6m0rf5gd6s40perbka.apps.googleusercontent.com',
        );
      }

      final account = await googleSignIn.authenticate();

      final authentication = account.authentication;

      final idToken = authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google ID token not received');
      }

      print('Google ID token received');

      final response = await _apiService.dio.post(
        ApiConstants.googleLogin,
        data: {'idToken': idToken},
      );

      print('GOOGLE LOGIN STATUS: ${response.statusCode}');
      print('GOOGLE LOGIN DATA: ${response.data}');

      final tokenResponse = TokenResponse.fromJson(response.data);

      final userId = _getUserIdFromToken(tokenResponse.accessToken);

      await _tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        userId: userId,
      );

      return tokenResponse;
    } on GoogleSignInException catch (e) {
      print('GOOGLE SIGN-IN ERROR CODE: ${e.code}');
      print('GOOGLE SIGN-IN ERROR: ${e.description}');

      throw Exception(e.description ?? 'Google sign-in failed');
    } on DioException catch (e) {
      print('GOOGLE LOGIN DIO ERROR TYPE: ${e.type}');
      print('GOOGLE LOGIN DIO ERROR: ${e.message}');
      print('GOOGLE LOGIN STATUS: ${e.response?.statusCode}');
      print('GOOGLE LOGIN RESPONSE: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Google authentication failed');
      }

      if (e.response?.data is String) {
        throw Exception(e.response!.data);
      }

      throw Exception('Unable to connect to the server');
    } catch (e) {
      print('GOOGLE LOGIN ERROR: $e');

      throw Exception(e.toString().replaceFirst('Exception: ', ''));
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

  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
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

  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      print('FORGOT PASSWORD STATUS: ${response.statusCode}');
      print('FORGOT PASSWORD DATA: ${response.data}');
    } on DioException catch (e) {
      print('FORGOT PASSWORD ERROR TYPE: ${e.type}');
      print('FORGOT PASSWORD ERROR: ${e.message}');
      print('FORGOT PASSWORD STATUS: ${e.response?.statusCode}');
      print('FORGOT PASSWORD RESPONSE: ${e.response?.data}');

      if (e.response?.data is String) {
        throw Exception(e.response!.data);
      }

      throw Exception('Unable to send password reset request');
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.resetPassword,
        data: {'token': token, 'newPassword': newPassword},
      );

      print('RESET PASSWORD STATUS: ${response.statusCode}');
      print('RESET PASSWORD DATA: ${response.data}');
    } on DioException catch (e) {
      print('RESET PASSWORD ERROR TYPE: ${e.type}');
      print('RESET PASSWORD ERROR: ${e.message}');
      print('RESET PASSWORD STATUS: ${e.response?.statusCode}');
      print('RESET PASSWORD RESPONSE: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        if (e.response?.data is String) {
          throw Exception(e.response!.data);
        }

        throw Exception('Invalid or expired reset link');
      }

      if (e.response?.data is String) {
        throw Exception(e.response!.data);
      }

      throw Exception('Unable to reset password');
    }
  }

  Future<TokenResponse> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final response = await _apiService.dio.put(
        ApiConstants.updateProfile,
        data: {'name': name.trim(), 'email': email.trim()},
      );

      print('UPDATE PROFILE STATUS: ${response.statusCode}');
      print('UPDATE PROFILE DATA: ${response.data}');

      final tokenResponse = TokenResponse.fromJson(response.data);

      final userId = _getUserIdFromToken(tokenResponse.accessToken);

      await _tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        userId: userId,
      );

      return tokenResponse;
    } on DioException catch (e) {
      print('UPDATE PROFILE ERROR TYPE: ${e.type}');
      print('UPDATE PROFILE ERROR: ${e.message}');
      print('UPDATE PROFILE STATUS: ${e.response?.statusCode}');
      print('UPDATE PROFILE RESPONSE: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        if (e.response?.data is String) {
          throw Exception(e.response!.data);
        }

        throw Exception('Email already taken');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Your session has expired. Please login again.');
      }

      if (e.response?.data is String) {
        throw Exception(e.response!.data);
      }

      throw Exception('Unable to update profile');
    }
  }
}

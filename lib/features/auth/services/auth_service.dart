import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/local_storage/shared_prefs_helper.dart';
import '../../../core/network/api_client.dart';
import '../../profile/models/user_profile_models.dart';
import '../models/auth_models.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  Future<OtpResponseModel> requestOtp(String phone) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.requestOtp,
        data: {'phone': phone},
      );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null;
      return OtpResponseModel.fromJson(data);
    } on DioException catch (e) {
      final data = e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : null;
      return OtpResponseModel.fromJson(data);
    } catch (e) {
      return OtpResponseModel(success: false, message: e.toString());
    }
  }

  Future<VerifyOtpResponseModel> verifyOtp(String phone, String otp) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': phone,
          'otp': otp,
          'role': AppStrings.customerRole,
        },
      );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null;
      return VerifyOtpResponseModel.fromJson(data);
    } on DioException catch (e) {
      final data = e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : null;
      return VerifyOtpResponseModel.fromJson(data);
    } catch (e) {
      return VerifyOtpResponseModel(success: false, message: e.toString());
    }
  }

  Future<String?> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      if (data is Map<String, dynamic>) {
        final newAccess = data['data']?['accessToken'] ?? data['accessToken'];
        final newRefresh =
            data['data']?['refreshToken'] ?? data['refreshToken'] ?? refreshToken;

        if (newAccess != null && newAccess.toString().isNotEmpty) {
          final accessStr = newAccess.toString();
          await SharedPrefsHelper.saveAccessToken(accessStr);
          if (newRefresh != null) {
            await SharedPrefsHelper.saveRefreshToken(newRefresh.toString());
          }
          return accessStr;
        }
      }
      return null;
    } catch (e) {
      debugPrint('AuthService: Refresh token failed: $e');
      return null;
    }
  }

  Future<SessionVerificationResult> verifySession({String? token}) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;
      final response = await _apiClient.get(
        ApiEndpoints.userProfile,
        options: options,
      );

      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      if (data is Map<String, dynamic>) {
        final isSuccess = data['success'] == true;
        final userJson = data['data'];

        if (isSuccess && userJson != null && userJson is Map<String, dynamic>) {
          return SessionVerificationResult(
            isValid: true,
            isOffline: false,
            userData: Data.fromJson(userJson),
            profile: UserProfileModel.fromJson(data),
          );
        }
      }
      return const SessionVerificationResult(isValid: false, isOffline: false);
    } on SocketException {
      return const SessionVerificationResult(isValid: false, isOffline: true);
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      final bool isOffline = errorStr.contains('connection') ||
          errorStr.contains('network') ||
          errorStr.contains('socket');
      return SessionVerificationResult(isValid: false, isOffline: isOffline);
    }
  }

  Future<OnboardingStatusResponse> getOnboardingStatus() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.onboardingStatus);
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null;
      return OnboardingStatusResponse.fromJson(data);
    } on DioException catch (e) {
      final data = e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : null;
      return OnboardingStatusResponse.fromJson(data);
    } catch (e) {
      return OnboardingStatusResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<bool> submitBasicInfo(String fullName) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.onboardingBasicInfo,
        data: {'fullName': fullName},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['success'] == true;
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('AuthService.submitBasicInfo error: $e');
      return false;
    }
  }
}

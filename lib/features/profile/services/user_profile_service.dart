import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../models/user_profile_models.dart';

class UserProfileService {
  final ApiClient _apiClient;

  UserProfileService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userProfile);
      var data = response.data;

      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        return UserProfileModel.fromJson(data);
      }
      return UserProfileModel(
        success: false,
        message: 'Invalid response format',
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return UserProfileModel.fromJson(responseData);
      } else if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is Map<String, dynamic>) {
            return UserProfileModel.fromJson(decoded);
          }
        } catch (_) {}
      }
      return UserProfileModel(
        success: false,
        message: e.response?.statusMessage ?? 'Failed to fetch profile',
      );
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return UserProfileModel(success: false, message: e.toString());
    }
  }

  Future<UserProfileModel> updateUserProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    final Map<String, dynamic> body = {};
    if (name != null && name.trim().isNotEmpty) body['name'] = name.trim();
    if (email != null && email.trim().isNotEmpty) body['email'] = email.trim();
    if (phone != null && phone.trim().isNotEmpty) body['phone'] = phone.trim();

    try {
      final response = await _apiClient.put(
        ApiEndpoints.userProfile,
        data: body,
      );

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return UserProfileModel.fromJson(data);
      }

      return UserProfileModel(
        success: true,
        message: AppStrings.profileUpdatedSuccessfully,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return UserProfileModel.fromJson(responseData);
      } else if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is Map<String, dynamic>) {
            return UserProfileModel.fromJson(decoded);
          }
        } catch (_) {}
      }
      return UserProfileModel(
        success: false,
        message: e.response?.statusMessage ?? AppStrings.failedToUpdateProfile,
      );
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return UserProfileModel(success: false, message: e.toString());
    }
  }
}

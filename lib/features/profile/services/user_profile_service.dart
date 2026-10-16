import 'dart:convert';
import 'dart:io';
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
      final response = await _apiClient.get(ApiEndpoints.customerProfile);
      var data = response.data;

      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        return UserProfileModel.fromJson(data);
      }
      return UserProfileModel(
        success: false,
        message: AppStrings.invalidResponseFormat,
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
        message: e.response?.statusMessage ?? AppStrings.failedToFetchProfile,
      );
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return UserProfileModel(success: false, message: e.toString());
    }
  }

  Future<UserProfileModel> updateUserProfile({
    String? name,
    String? fullName,
    String? email,
    String? phone,
    File? avatarFile,
  }) async {
    final effectiveName = fullName ?? name;
    final Map<String, dynamic> formMap = {};
    if (effectiveName != null && effectiveName.trim().isNotEmpty) {
      formMap['fullName'] = effectiveName.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      formMap['email'] = email.trim();
    }
    if (phone != null && phone.trim().isNotEmpty) {
      formMap['phone'] = phone.trim();
    }
    if (avatarFile != null) {
      final fileName = avatarFile.path.split(RegExp(r'[\\/]')).last;
      formMap['avatar'] = await MultipartFile.fromFile(
        avatarFile.path,
        filename: fileName,
      );
    }

    try {
      final response = await _apiClient.put(
        ApiEndpoints.customerProfile,
        data: FormData.fromMap(formMap),
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

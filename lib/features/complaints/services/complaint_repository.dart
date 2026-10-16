import 'package:dio/dio.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/network/api_client.dart';
import '../models/complaint_list_response.dart';
import '../models/complaint_detail_response.dart';

class ComplaintRepository {
  final ApiClient _apiClient;

  ComplaintRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  Future<ComplaintListResponse?> fetchMyComplaints({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'size': size};
      if (status != null && status.isNotEmpty) params['status'] = status;

      final response = await _apiClient.get(
        ApiEndpoints.myComplaints,
        queryParameters: params,
      );

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return ComplaintListResponse.fromJson(dataMap);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ComplaintDetailResponse?> fetchComplaintDetails(String id) async {
    try {
      final response =
          await _apiClient.get(ApiEndpoints.complaintDetails(id));

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return ComplaintDetailResponse.fromJson(dataMap);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns (success, message).
  Future<(bool, String)> fileComplaint({
    required String category,
    required String title,
    required String description,
    List<String> attachmentPaths = const [],
  }) async {
    try {
      final formData = FormData.fromMap({
        'category': category,
        'title': title,
        'description': description,
        if (attachmentPaths.isNotEmpty)
          'attachments': [
            for (final path in attachmentPaths)
              await MultipartFile.fromFile(path),
          ],
      });

      final response = await _apiClient.post(
        ApiEndpoints.complaints,
        data: formData,
      );

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      final ok = dataMap?[AppStrings.apiSuccess] as bool? ?? false;
      final msg = dataMap?['message'] as String? ?? '';
      return (ok, msg);
    } catch (e) {
      return (false, e.toString());
    }
  }

  /// Returns (success, message).
  Future<(bool, String)> reopenComplaint(
      String id, String reason) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.reopenComplaint(id),
        data: {'reason': reason},
      );

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      final ok = dataMap?[AppStrings.apiSuccess] as bool? ?? false;
      final msg = dataMap?['message'] as String? ?? '';
      return (ok, msg);
    } catch (e) {
      return (false, e.toString());
    }
  }
}

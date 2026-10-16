import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/network/api_client.dart';
import 'package:vegon_user/features/dashboard/models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  Future<NotificationListResponse?> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'size': size},
      );
      final dataMap = response.data;
      if (dataMap is Map<String, dynamic>) {
        return NotificationListResponse.fromJson(dataMap);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<int?> getUnreadCount() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notificationsUnreadCount,
      );
      final dataMap = response.data;
      if (dataMap is Map<String, dynamic>) {
        return UnreadCountResponse.fromJson(dataMap).unreadCount;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.markNotificationRead(notificationId),
      );
      final dataMap = response.data;
      if (dataMap is Map<String, dynamic>) {
        return dataMap['success'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.notificationsReadAll,
      );
      final dataMap = response.data;
      if (dataMap is Map<String, dynamic>) {
        return dataMap['success'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

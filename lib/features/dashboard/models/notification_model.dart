class NotificationItem {
  final String id;
  final String recipientId;
  final String recipientRole;
  final String type;
  final String title;
  final String body;
  final String? data;
  final bool read;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.recipientId,
    required this.recipientRole,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.read,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      recipientId: json['recipientId'] as String? ?? '',
      recipientRole: json['recipientRole'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] as String?,
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  NotificationItem copyWith({bool? read}) {
    return NotificationItem(
      id: id,
      recipientId: recipientId,
      recipientRole: recipientRole,
      type: type,
      title: title,
      body: body,
      data: data,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}

class NotificationListData {
  final List<NotificationItem> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  NotificationListData({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory NotificationListData.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    final items = rawContent is List
        ? rawContent
            .whereType<Map<String, dynamic>>()
            .map((e) => NotificationItem.fromJson(e))
            .toList()
        : <NotificationItem>[];
    return NotificationListData(
      content: items,
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 20,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class NotificationListResponse {
  final bool success;
  final String? message;
  final NotificationListData? data;

  NotificationListResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return NotificationListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: rawData is Map<String, dynamic>
          ? NotificationListData.fromJson(rawData)
          : null,
    );
  }
}

class UnreadCountResponse {
  final bool success;
  final int unreadCount;

  UnreadCountResponse({required this.success, required this.unreadCount});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final count = rawData is Map<String, dynamic>
        ? rawData['unreadCount'] as int? ?? 0
        : 0;
    return UnreadCountResponse(
      success: json['success'] as bool? ?? false,
      unreadCount: count,
    );
  }
}

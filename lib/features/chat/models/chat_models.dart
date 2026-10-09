class ChatOption {
  final String id;
  final String label;

  const ChatOption({required this.id, required this.label});

  factory ChatOption.fromJson(Map<String, dynamic> json) => ChatOption(
    id: json['id']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
  );
}

abstract final class ChatOptionId {
  static const String orders = 'ORDERS';
  static String forOrder(String orderId) => 'ORDER:$orderId';
}

class ChatTurnRequest {
  final String? text;
  final String? optionId;
  final String? conversationId;
  final Map<String, dynamic>? context;
  final double? latitude;
  final double? longitude;

  const ChatTurnRequest({
    this.text,
    this.optionId,
    this.conversationId,
    this.context,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    final requestConversationId = conversationId;
    final requestLatitude = latitude;
    final requestLongitude = longitude;
    if (optionId != null) {
      json['optionId'] = optionId;
    } else if (text != null) {
      json['text'] = text;
    }
    if (requestConversationId != null &&
        RegExp(r'^[A-Za-z0-9_-]{1,40}$').hasMatch(requestConversationId)) {
      json['conversationId'] = requestConversationId;
    }
    if (context != null) json['context'] = context;
    if (requestLatitude != null &&
        requestLongitude != null &&
        requestLatitude >= -90 &&
        requestLatitude <= 90 &&
        requestLongitude >= -180 &&
        requestLongitude <= 180) {
      json['latitude'] = requestLatitude;
      json['longitude'] = requestLongitude;
    }
    return json;
  }
}

class ChatOrder {
  final String optionId;
  final String orderId;
  final String orderNumber;
  final String status;
  final String statusLabel;
  final num total;
  final int itemCount;
  final String? placedAt;

  const ChatOrder({
    required this.optionId,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.total,
    required this.itemCount,
    this.placedAt,
  });

  factory ChatOrder.fromJson(Map<String, dynamic> json) => ChatOrder(
    optionId: json['optionId']?.toString() ?? '',
    orderId: json['orderId']?.toString() ?? '',
    orderNumber: json['orderNumber']?.toString() ?? '',
    status: json['status']?.toString() ?? '',
    statusLabel: json['statusLabel']?.toString() ?? '',
    total: json['total'] is num ? json['total'] as num : 0,
    itemCount: json['itemCount'] is num
        ? (json['itemCount'] as num).toInt()
        : 0,
    placedAt: json['placedAt']?.toString(),
  );
}

class ChatReply {
  final String conversationId;
  final String reply;
  final List<ChatOption> options;
  final List<ChatOrder> orders;
  final Map<String, dynamic>? context;
  final bool ratingPrompt;

  const ChatReply({
    required this.conversationId,
    required this.reply,
    required this.options,
    required this.orders,
    required this.context,
    required this.ratingPrompt,
  });

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List? ?? const [];
    final rawOrders = json['orders'] as List? ?? const [];
    final rawContext = json['context'];
    final conversationId = json['conversationId']?.toString() ?? '';

    return ChatReply(
      conversationId: RegExp(r'^[A-Za-z0-9_-]{1,40}$').hasMatch(conversationId)
          ? conversationId
          : '',
      reply: json['reply']?.toString() ?? '',
      options: rawOptions
          .whereType<Map>()
          .map((item) => ChatOption.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      orders: rawOrders
          .whereType<Map>()
          .map((item) => ChatOrder.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      context: rawContext is Map<String, dynamic> ? rawContext : null,
      ratingPrompt: json['ratingPrompt'] == true,
    );
  }
}

class ChatEntry {
  final String text;
  final bool fromCustomer;
  final ChatReply? reply;
  final bool retryable;

  const ChatEntry({
    required this.text,
    required this.fromCustomer,
    this.reply,
    this.retryable = false,
  });
}

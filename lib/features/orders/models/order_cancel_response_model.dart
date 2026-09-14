import 'package:vegon_user/features/orders/models/order_history_response_model.dart';

class OrderCancelResponseModel {
  final bool? success;
  final String? message;
  final OrderHistoryItem? data;
  final String? timestamp;

  OrderCancelResponseModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory OrderCancelResponseModel.fromJson(Map<String, dynamic> json) =>
      OrderCancelResponseModel(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] == null
            ? null
            : OrderHistoryItem.fromJson(json['data'] as Map<String, dynamic>),
        timestamp: json['timestamp'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
        'timestamp': timestamp,
      };
}

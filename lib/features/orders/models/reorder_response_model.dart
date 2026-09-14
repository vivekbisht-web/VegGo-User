import 'package:vegon_user/features/cart/models/cart_models.dart';

class ReorderResponseModel {
  final bool? success;
  final String? message;
  final List<CartModel>? data;
  final String? timestamp;

  ReorderResponseModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory ReorderResponseModel.fromJson(Map<String, dynamic> json) =>
      ReorderResponseModel(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: (json['data'] as List<dynamic>?)
            ?.map((e) => CartModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        timestamp: json['timestamp'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.map((e) => e.toJson()).toList(),
        'timestamp': timestamp,
      };
}

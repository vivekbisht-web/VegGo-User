class DeliverySlotsResponseModel {
  final bool? success;
  final String? message;
  final List<dynamic>? data; // You can change this to a specific DeliverySlot model later if it has structure
  final String? timestamp;

  DeliverySlotsResponseModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory DeliverySlotsResponseModel.fromJson(Map<String, dynamic> json) =>
      DeliverySlotsResponseModel(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] as List<dynamic>?,
        timestamp: json['timestamp'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data,
    'timestamp': timestamp,
  };
}

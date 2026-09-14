class RateOrderResponseModel {
  final bool? success;
  final String? message;
  final String? errorCode;
  final String? timestamp;
  final dynamic data;

  RateOrderResponseModel({
    this.success,
    this.message,
    this.errorCode,
    this.timestamp,
    this.data,
  });

  factory RateOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      RateOrderResponseModel(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        errorCode: json['errorCode'] as String?,
        timestamp: json['timestamp'] as String?,
        data: json['data'],
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'errorCode': errorCode,
        'timestamp': timestamp,
        'data': data,
      };
}

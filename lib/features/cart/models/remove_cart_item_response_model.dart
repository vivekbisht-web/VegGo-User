class RemoveCartItemResponseModel {
  final bool? success;
  final String? message;
  final String? errorCode;
  final String? timestamp;

  RemoveCartItemResponseModel({
    this.success,
    this.message,
    this.errorCode,
    this.timestamp,
  });

  factory RemoveCartItemResponseModel.fromJson(Map<String, dynamic> json) =>
      RemoveCartItemResponseModel(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        errorCode: json['errorCode'] as String?,
        timestamp: json['timestamp'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'errorCode': errorCode,
        'timestamp': timestamp,
      };
}

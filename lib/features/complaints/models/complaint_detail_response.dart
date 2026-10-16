import 'complaint_model.dart';

class ComplaintDetailResponse {
  final bool success;
  final String message;
  final ComplaintModel? data;

  ComplaintDetailResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ComplaintDetailResponse.fromJson(Map<String, dynamic> json) =>
      ComplaintDetailResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        data: json['data'] == null
            ? null
            : ComplaintModel.fromJson(json['data'] as Map<String, dynamic>),
      );
}

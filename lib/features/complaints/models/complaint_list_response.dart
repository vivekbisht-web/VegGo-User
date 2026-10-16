import 'complaint_model.dart';

class ComplaintListResponse {
  final bool success;
  final String message;
  final ComplaintPageData? data;

  ComplaintListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ComplaintListResponse.fromJson(Map<String, dynamic> json) =>
      ComplaintListResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        data: json['data'] == null
            ? null
            : ComplaintPageData.fromJson(json['data'] as Map<String, dynamic>),
      );
}

class ComplaintPageData {
  final List<ComplaintModel> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;
  final bool last;

  ComplaintPageData({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
    required this.last,
  });

  factory ComplaintPageData.fromJson(Map<String, dynamic> json) =>
      ComplaintPageData(
        content: (json['content'] as List<dynamic>? ?? [])
            .map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalElements: json['totalElements'] as int? ?? 0,
        totalPages: json['totalPages'] as int? ?? 0,
        page: json['page'] as int? ?? 0,
        size: json['size'] as int? ?? 20,
        last: json['last'] as bool? ?? true,
      );
}

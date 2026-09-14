//
class SubcategoryItem {
  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final bool active;

  SubcategoryItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.active,
  });

  factory SubcategoryItem.fromJson(Map<String, dynamic> json) {
    return SubcategoryItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      active: json['active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'name': name,
      'active': active,
    };
  }
}

class SubcategoriesPageResponse {
  final bool success;
  final String message;
  final List<SubcategoryItem> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  SubcategoriesPageResponse({
    required this.success,
    required this.message,
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory SubcategoriesPageResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<SubcategoryItem> items = [];
    int page = 0;
    int size = 20;
    int totalElements = 0;
    int totalPages = 1;

    if (rawData is Map<String, dynamic>) {
      final rawContent = rawData['content'] ?? rawData['subcategories'];
      if (rawContent is List) {
        items = rawContent
            .whereType<Map<String, dynamic>>()
            .map((e) => SubcategoryItem.fromJson(e))
            .toList();
      }
      page = (rawData['page'] as num?)?.toInt() ?? 0;
      size = (rawData['size'] as num?)?.toInt() ?? 20;
      totalElements =
          (rawData['totalElements'] as num?)?.toInt() ?? items.length;
      totalPages = (rawData['totalPages'] as num?)?.toInt() ?? 1;
    } else if (rawData is List) {
      items = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => SubcategoryItem.fromJson(e))
          .toList();
      totalElements = items.length;
    }

    return SubcategoriesPageResponse(
      success: json['success'] as bool? ?? true,
      message: json['message']?.toString() ?? '',
      content: items,
      page: page,
      size: size,
      totalElements: totalElements,
      totalPages: totalPages,
    );
  }
}

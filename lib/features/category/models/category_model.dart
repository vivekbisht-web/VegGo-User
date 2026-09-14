//
class CategoryItem {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final bool active;

  CategoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.active,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['categoryName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconUrl:
          json['iconUrl']?.toString() ??
          json['icon']?.toString() ??
          json['image']?.toString() ??
          json['imageUrl']?.toString() ??
          '',
      active: json['active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'active': active,
    };
  }
}

class CategoriesPageResponse {
  final bool success;
  final String message;
  final List<CategoryItem> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  CategoriesPageResponse({
    required this.success,
    required this.message,
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory CategoriesPageResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<CategoryItem> items = [];
    int page = 0;
    int size = 20;
    int totalElements = 0;
    int totalPages = 1;

    if (rawData is Map<String, dynamic>) {
      final rawContent = rawData['content'] ?? rawData['categories'];
      if (rawContent is List) {
        items = rawContent
            .whereType<Map<String, dynamic>>()
            .map((e) => CategoryItem.fromJson(e))
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
          .map((e) => CategoryItem.fromJson(e))
          .toList();
      totalElements = items.length;
    }

    return CategoriesPageResponse(
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

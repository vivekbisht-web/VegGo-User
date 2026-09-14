//
class CategoryDataModel {
  final String id;
  final String name;
  final String description;
  final bool active;
  final String? image;

  CategoryDataModel({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
    this.image,
  });

  factory CategoryDataModel.fromJson(Map<String, dynamic> json) {
    return CategoryDataModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['categoryName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      active: json['active'] as bool? ?? json['isActive'] as bool? ?? true,
      image:
          json['iconUrl']?.toString() ??
          json['icon']?.toString() ??
          json['imageUrl']?.toString(),
    );
  }
}

class GetCategoriesResponseModel {
  final bool success;
  final String message;
  final List<CategoryDataModel> categories;

  GetCategoriesResponseModel({
    required this.success,
    required this.message,
    required this.categories,
  });

  factory GetCategoriesResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['categories'];
    List<CategoryDataModel> list = [];
    if (rawData is Map<String, dynamic>) {
      final content = rawData['content'] ?? rawData['categories'];
      if (content is List) {
        list = content
            .whereType<Map<String, dynamic>>()
            .map((e) => CategoryDataModel.fromJson(e))
            .toList();
      }
    } else if (rawData is List) {
      list = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => CategoryDataModel.fromJson(e))
          .toList();
    }

    return GetCategoriesResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message']?.toString() ?? '',
      categories: list,
    );
  }
}

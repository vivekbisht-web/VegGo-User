//
import 'package:vegon_user/core/constants/app_strings.dart';

class CategoryProductItem {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String description;
  final String shopId;
  final String shopName;
  final String category;
  final String imageUrl;
  final String unit;
  final int discountPercent;
  final bool bestSeller;

  CategoryProductItem({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.shopId,
    required this.shopName,
    required this.category,
    required this.imageUrl,
    required this.unit,
    required this.discountPercent,
    required this.bestSeller,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(clean);
    }
    return null;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) {
      final clean = value.replaceAll(RegExp(r'[^\d]'), '');
      return int.tryParse(clean) ?? 0;
    }
    return 0;
  }

  factory CategoryProductItem.fromJson(Map<String, dynamic> json) {
    return CategoryProductItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: _parseDouble(json['price']),
      originalPrice: _parseNullableDouble(json['originalPrice']),
      description: json['description']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl:
          json['imageUrl']?.toString() ??
          json['image']?.toString() ??
          json['iconUrl']?.toString() ??
          '',
      unit: json['unit']?.toString() ?? AppStrings.kg1,
      discountPercent: _parseInt(json['discountPercent'] ?? json['discount']),
      bestSeller:
          json['bestSeller'] as bool? ?? json['isBestSeller'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'description': description,
      'shopId': shopId,
      'shopName': shopName,
      'category': category,
      'imageUrl': imageUrl,
      'image': imageUrl,
      'unit': unit,
      'discountPercent': discountPercent,
      'bestSeller': bestSeller,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'description': description,
      'shopId': shopId,
      'shopName': shopName,
      'category': category,
      'image': imageUrl,
      'imageUrl': imageUrl,
      'unit': unit,
      'discount': discountPercent > 0 ? '$discountPercent% OFF' : null,
      'discountPercent': discountPercent,
      'bestSeller': bestSeller,
      'isBestSeller': bestSeller,
      'rating': 4.7,
    };
  }
}

class ProductsPageResponse {
  final bool success;
  final String message;
  final List<CategoryProductItem> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  ProductsPageResponse({
    required this.success,
    required this.message,
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory ProductsPageResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<CategoryProductItem> items = [];
    int page = 0;
    int size = 10;
    int totalElements = 0;
    int totalPages = 1;

    if (rawData is Map<String, dynamic>) {
      final rawContent = rawData['content'] ?? rawData['products'];
      if (rawContent is List) {
        items = rawContent
            .whereType<Map<String, dynamic>>()
            .map((e) => CategoryProductItem.fromJson(e))
            .toList();
      }
      page = (rawData['page'] as num?)?.toInt() ?? 0;
      size = (rawData['size'] as num?)?.toInt() ?? 10;
      totalElements =
          (rawData['totalElements'] as num?)?.toInt() ?? items.length;
      totalPages = (rawData['totalPages'] as num?)?.toInt() ?? 1;
    } else if (rawData is List) {
      items = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => CategoryProductItem.fromJson(e))
          .toList();
      totalElements = items.length;
    }

    return ProductsPageResponse(
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

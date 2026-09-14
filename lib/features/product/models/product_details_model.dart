//
import 'package:vegon_user/core/constants/app_strings.dart';

class ProductDetailsResponse {
  final bool success;
  final String message;
  final ProductDetailsData? data;
  final String? timestamp;

  ProductDetailsResponse({
    required this.success,
    required this.message,
    this.data,
    this.timestamp,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ProductDetailsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      timestamp: json['timestamp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'timestamp': timestamp,
    };
  }
}

class RelatedProductsResponse {
  final bool success;
  final String message;
  final List<ProductDetailsData> data;
  final String? timestamp;

  RelatedProductsResponse({
    required this.success,
    required this.message,
    required this.data,
    this.timestamp,
  });

  factory RelatedProductsResponse.fromJson(Map<String, dynamic> json) {
    List<ProductDetailsData> items = [];
    final rawData = json['data'];
    if (rawData is List) {
      items = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductDetailsData.fromJson(e))
          .toList();
    }

    return RelatedProductsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: items,
      timestamp: json['timestamp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'timestamp': timestamp,
    };
  }
}

class ProductDetailsData {
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

  ProductDetailsData({
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

  factory ProductDetailsData.fromJson(Map<String, dynamic> rawJson) {
    final Map<String, dynamic> json = (rawJson['product'] is Map<String, dynamic>)
        ? rawJson['product'] as Map<String, dynamic>
        : ((rawJson['catalogProduct'] is Map<String, dynamic>)
            ? rawJson['catalogProduct'] as Map<String, dynamic>
            : rawJson);

    final String resolvedId = rawJson['productId']?.toString() ??
        rawJson['catalogProductId']?.toString() ??
        json['id']?.toString() ??
        json['_id']?.toString() ??
        rawJson['id']?.toString() ??
        '';

    return ProductDetailsData(
      id: resolvedId,
      name: json['name']?.toString() ?? rawJson['name']?.toString() ?? '',
      price: _parseDouble(json['price'] ?? rawJson['price']),
      originalPrice: _parseNullableDouble(json['originalPrice'] ?? rawJson['originalPrice']),
      description: json['description']?.toString() ?? rawJson['description']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? rawJson['shopId']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? rawJson['shopName']?.toString() ?? '',
      category: json['category']?.toString() ?? rawJson['category']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ??
          json['image']?.toString() ??
          json['iconUrl']?.toString() ??
          rawJson['imageUrl']?.toString() ??
          rawJson['image']?.toString() ??
          '',
      unit: json['unit']?.toString() ?? rawJson['unit']?.toString() ?? AppStrings.kg1,
      discountPercent: _parseInt(
        json['discountPercent'] ?? json['discount'] ?? rawJson['discountPercent'] ?? rawJson['discount'],
      ),
      bestSeller: json['bestSeller'] as bool? ??
          json['isBestSeller'] as bool? ??
          rawJson['bestSeller'] as bool? ??
          false,
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
      'discountPercent': discountPercent,
      'discount': discountPercent > 0 ? '$discountPercent% OFF' : null,
      'bestSeller': bestSeller,
      'isBestSeller': bestSeller,
    };
  }
}

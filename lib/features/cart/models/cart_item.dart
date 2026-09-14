//
class CartItem {
  final String id;
  final String? productId;
  final String name;
  final double price;
  final String image;
  final String unit;
  final String? variantId;
  final int? stockCount;
  final int? maxQuantityPerUser;
  final bool isAvailable;
  final String? storeId;
  int quantity;

  CartItem({
    required this.id,
    this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.unit,
    this.variantId,
    this.stockCount,
    this.maxQuantityPerUser,
    this.isAvailable = true,
    this.storeId,
    this.quantity = 1,
  });

  String get cartKey => (variantId != null && variantId!.isNotEmpty)
      ? '${id}_$variantId'
      : '${id}_$unit';

  static double _parsePrice(dynamic priceVal) {
    if (priceVal == null) return 0.0;
    if (priceVal is num) return priceVal.toDouble();
    if (priceVal is String) {
      final clean = priceVal.replaceAll(RegExp(r'[^\d.]'), '');
      final parsed = double.tryParse(clean);
      if (parsed != null &&
          !parsed.isNaN &&
          !parsed.isInfinite &&
          parsed >= 0) {
        return parsed;
      }
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'image': image,
      'unit': unit,
      'variantId': variantId,
      'stockCount': stockCount,
      'maxQuantityPerUser': maxQuantityPerUser,
      'isAvailable': isAvailable,
      'storeId': storeId,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? json['id']?.toString(),
      name:
          json['name']?.toString() ??
          json['productName']?.toString() ??
          'Fresh Product',
      price: _parsePrice(json['price'] ?? json['unitPrice']),
      image: json['image']?.toString() ?? json['productImageUrl']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '1 unit',
      variantId: json['variantId']?.toString(),
      stockCount: json['stockCount'] is int
          ? json['stockCount'] as int
          : int.tryParse(json['stockCount']?.toString() ?? ''),
      maxQuantityPerUser: json['maxQuantityPerUser'] is int
          ? json['maxQuantityPerUser'] as int
          : int.tryParse(json['maxQuantityPerUser']?.toString() ?? ''),
      isAvailable: json['isAvailable'] as bool? ?? true,
      storeId: json['storeId']?.toString(),
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toInt()
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
    );
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    String? image,
    String? unit,
    String? variantId,
    int? stockCount,
    int? maxQuantityPerUser,
    bool? isAvailable,
    String? storeId,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      unit: unit ?? this.unit,
      variantId: variantId ?? this.variantId,
      stockCount: stockCount ?? this.stockCount,
      maxQuantityPerUser: maxQuantityPerUser ?? this.maxQuantityPerUser,
      isAvailable: isAvailable ?? this.isAvailable,
      storeId: storeId ?? this.storeId,
      quantity: quantity ?? this.quantity,
    );
  }
}

import 'package:vegon_user/features/cart/models/cart_item.dart';


class CartModel {
  final String id;
  final String userId;
  final String cartLabel;
  final List<CartItem> items;
  final double totalAmount;
  final int itemCount;
  final double deliveryFee;
  final double estimatedTax;
  final double promoDiscount;

  const CartModel({
    required this.id,
    required this.userId,
    required this.cartLabel,
    required this.items,
    required this.totalAmount,
    required this.itemCount,
    required this.deliveryFee,
    required this.estimatedTax,
    required this.promoDiscount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? itemsJson = json['items'] as List<dynamic>?;
    return CartModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      cartLabel: json['cartLabel']?.toString() ?? '',
      items: itemsJson != null
          ? itemsJson
                .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      totalAmount: _parseDouble(json['totalAmount']),
      itemCount: json['itemCount'] is int
          ? json['itemCount'] as int
          : int.tryParse(json['itemCount']?.toString() ?? '0') ?? 0,
      deliveryFee: _parseDouble(json['deliveryFee']),
      estimatedTax: _parseDouble(json['estimatedTax']),
      promoDiscount: _parseDouble(json['promoDiscount']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'cartLabel': cartLabel,
    'items': items.map((e) => e.toJson()).toList(),
    'totalAmount': totalAmount,
    'itemCount': itemCount,
    'deliveryFee': deliveryFee,
    'estimatedTax': estimatedTax,
    'promoDiscount': promoDiscount,
  };

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }
}

class CartResponse {
  final bool success;
  final String message;
  final List<CartModel> data;
  final String timestamp;

  const CartResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? dataJson = json['data'] as List<dynamic>?;
    return CartResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: dataJson != null
          ? dataJson
                .map((e) => CartModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.map((e) => e.toJson()).toList(),
    'timestamp': timestamp,
  };
}

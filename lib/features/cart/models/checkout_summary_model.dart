class CheckoutSummaryModel {
  final bool? success;
  final String? message;
  final CheckoutSummaryData? data;
  final String? timestamp;

  CheckoutSummaryModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory CheckoutSummaryModel.fromJson(Map<String, dynamic> json) =>
      CheckoutSummaryModel(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] == null
            ? null
            : CheckoutSummaryData.fromJson(
                json['data'] as Map<String, dynamic>,
              ),
        timestamp: json['timestamp'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
    'timestamp': timestamp,
  };
}

class CheckoutSummaryData {
  final List<CheckoutCart>? carts;
  final int? totalItemCount;
  final double? grandTotal;

  CheckoutSummaryData({this.carts, this.totalItemCount, this.grandTotal});

  factory CheckoutSummaryData.fromJson(Map<String, dynamic> json) =>
      CheckoutSummaryData(
        carts:
            (json['carts'] as List<dynamic>?)
                ?.map((e) => CheckoutCart.fromJson(e as Map<String, dynamic>))
                .toList(),
        totalItemCount: json['totalItemCount'] as int?,
        grandTotal: (json['grandTotal'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'carts': carts?.map((e) => e.toJson()).toList(),
    'totalItemCount': totalItemCount,
    'grandTotal': grandTotal,
  };
}

class CheckoutCart {
  final String? cartId;
  final String? cartLabel;
  final int? itemCount;
  final double? subtotal;
  final double? deliveryFee;
  final double? estimatedTax;
  final double? promoDiscount;
  final double? total;

  CheckoutCart({
    this.cartId,
    this.cartLabel,
    this.itemCount,
    this.subtotal,
    this.deliveryFee,
    this.estimatedTax,
    this.promoDiscount,
    this.total,
  });

  factory CheckoutCart.fromJson(Map<String, dynamic> json) => CheckoutCart(
    cartId: json['cartId'] as String?,
    cartLabel: json['cartLabel'] as String?,
    itemCount: json['itemCount'] as int?,
    subtotal: (json['subtotal'] as num?)?.toDouble(),
    deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
    estimatedTax: (json['estimatedTax'] as num?)?.toDouble(),
    promoDiscount: (json['promoDiscount'] as num?)?.toDouble(),
    total: (json['total'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'cartId': cartId,
    'cartLabel': cartLabel,
    'itemCount': itemCount,
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'estimatedTax': estimatedTax,
    'promoDiscount': promoDiscount,
    'total': total,
  };
}

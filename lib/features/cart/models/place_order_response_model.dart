class PlaceOrderResponseModel {
  final bool? success;
  final String? message;
  final PlaceOrderData? data;
  final String? timestamp;

  PlaceOrderResponseModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory PlaceOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      PlaceOrderResponseModel(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] == null
            ? null
            : PlaceOrderData.fromJson(json['data'] as Map<String, dynamic>),
        timestamp: json['timestamp'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
    'timestamp': timestamp,
  };
}

class PlaceOrderData {
  final List<PlaceOrder>? orders;
  final List<dynamic>? issues;
  final PaymentHoldModel? paymentHold;

  PlaceOrderData({this.orders, this.issues, this.paymentHold});

  factory PlaceOrderData.fromJson(Map<String, dynamic> json) => PlaceOrderData(
    orders: (json['orders'] as List<dynamic>?)
        ?.map((e) => PlaceOrder.fromJson(e as Map<String, dynamic>))
        .toList(),
    issues: json['issues'] as List<dynamic>?,
    paymentHold: json['paymentHold'] == null
        ? null
        : PaymentHoldModel.fromJson(
            json['paymentHold'] as Map<String, dynamic>,
          ),
  );

  Map<String, dynamic> toJson() => {
    'orders': orders?.map((e) => e.toJson()).toList(),
    'issues': issues,
    'paymentHold': paymentHold?.toJson(),
  };
}

class PaymentHoldModel {
  final String? paymentOrderId;
  final String? razorpayOrderId;
  final String? razorpayKeyId;
  final String? currency;
  final double? totalAmount;
  final List<PaymentAllocationModel>? allocations;

  PaymentHoldModel({
    this.paymentOrderId,
    this.razorpayOrderId,
    this.razorpayKeyId,
    this.currency,
    this.totalAmount,
    this.allocations,
  });

  factory PaymentHoldModel.fromJson(Map<String, dynamic> json) =>
      PaymentHoldModel(
        paymentOrderId: json['paymentOrderId'] as String?,
        razorpayOrderId: json['razorpayOrderId'] as String?,
        razorpayKeyId: json['razorpayKeyId'] as String?,
        currency: json['currency'] as String?,
        totalAmount: (json['totalAmount'] as num?)?.toDouble(),
        allocations: (json['allocations'] as List<dynamic>?)
            ?.map(
              (e) => PaymentAllocationModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'paymentOrderId': paymentOrderId,
    'razorpayOrderId': razorpayOrderId,
    'razorpayKeyId': razorpayKeyId,
    'currency': currency,
    'totalAmount': totalAmount,
    'allocations': allocations?.map((e) => e.toJson()).toList(),
  };
}

class PaymentAllocationModel {
  final String? orderId;
  final String? orderNumber;
  final double? amount;

  PaymentAllocationModel({this.orderId, this.orderNumber, this.amount});

  factory PaymentAllocationModel.fromJson(Map<String, dynamic> json) =>
      PaymentAllocationModel(
        orderId: json['orderId'] as String?,
        orderNumber: json['orderNumber'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'orderNumber': orderNumber,
    'amount': amount,
  };
}

class PlaceOrder {
  final String? id;
  final String? userId;
  final String? orderNumber;
  final String? status;
  final double? totalAmount;
  final double? deliveryFee;
  final double? estimatedTax;
  final double? promoDiscount;
  final String? deliveryAddress;
  final double? latitude;
  final double? longitude;
  final String? paymentMethod;
  final int? itemCount;
  final List<String>? itemThumbnails;
  final bool? canTrack;
  final bool? canReorder;
  final bool? canCancel;
  final List<PlaceOrderItem>? items;

  PlaceOrder({
    this.id,
    this.userId,
    this.orderNumber,
    this.status,
    this.totalAmount,
    this.deliveryFee,
    this.estimatedTax,
    this.promoDiscount,
    this.deliveryAddress,
    this.latitude,
    this.longitude,
    this.paymentMethod,
    this.itemCount,
    this.itemThumbnails,
    this.canTrack,
    this.canReorder,
    this.canCancel,
    this.items,
  });

  factory PlaceOrder.fromJson(Map<String, dynamic> json) => PlaceOrder(
    id: json['id'] as String?,
    userId: json['userId'] as String?,
    orderNumber: json['orderNumber'] as String?,
    status: json['status'] as String?,
    totalAmount: (json['totalAmount'] as num?)?.toDouble(),
    deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
    estimatedTax: (json['estimatedTax'] as num?)?.toDouble(),
    promoDiscount: (json['promoDiscount'] as num?)?.toDouble(),
    deliveryAddress: json['deliveryAddress'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    paymentMethod: json['paymentMethod'] as String?,
    itemCount: json['itemCount'] as int?,
    itemThumbnails: (json['itemThumbnails'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList(),
    canTrack: json['canTrack'] as bool?,
    canReorder: json['canReorder'] as bool?,
    canCancel: json['canCancel'] as bool?,
    items: (json['items'] as List<dynamic>?)
        ?.map((e) => PlaceOrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'orderNumber': orderNumber,
    'status': status,
    'totalAmount': totalAmount,
    'deliveryFee': deliveryFee,
    'estimatedTax': estimatedTax,
    'promoDiscount': promoDiscount,
    'deliveryAddress': deliveryAddress,
    'latitude': latitude,
    'longitude': longitude,
    'paymentMethod': paymentMethod,
    'itemCount': itemCount,
    'itemThumbnails': itemThumbnails,
    'canTrack': canTrack,
    'canReorder': canReorder,
    'canCancel': canCancel,
    'items': items?.map((e) => e.toJson()).toList(),
  };
}

class PlaceOrderItem {
  final String? id;
  final String? productId;
  final String? productName;
  final int? quantity;
  final double? price;
  final String? unit;
  final double? subTotal;

  String? get productTitle => productName;

  PlaceOrderItem({
    this.id,
    this.productId,
    this.productName,
    this.quantity,
    this.price,
    this.unit,
    this.subTotal,
  });

  factory PlaceOrderItem.fromJson(Map<String, dynamic> json) => PlaceOrderItem(
    id: json['id'] as String?,
    productId: json['productId'] as String?,
    productName: (json['productName'] ?? json['productTitle'] ?? json['name'] ?? json['title']) as String?,
    quantity: json['quantity'] as int?,
    price: (json['price'] as num?)?.toDouble(),
    unit: json['unit'] as String?,
    subTotal: (json['subTotal'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'price': price,
    'unit': unit,
    'subTotal': subTotal,
  };
}


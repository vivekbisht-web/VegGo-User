class OrderHistoryResponseModel {
  final bool? success;
  final String? message;
  final OrderHistoryData? data;
  final String? timestamp;

  OrderHistoryResponseModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory OrderHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    OrderHistoryData? parsedData;
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      parsedData = OrderHistoryData.fromJson(rawData);
    } else if (rawData is List) {
      parsedData = OrderHistoryData(
        content: rawData
            .whereType<Map<String, dynamic>>()
            .map((e) => OrderHistoryItem.fromJson(e))
            .toList(),
        totalElements: rawData.length,
        totalPages: 1,
        page: 0,
        size: rawData.length,
      );
    }
    return OrderHistoryResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: parsedData,
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
        'timestamp': timestamp,
      };
}

class OrderHistoryData {
  final List<OrderHistoryItem>? content;
  final int? page;
  final int? size;
  final int? totalElements;
  final int? totalPages;

  OrderHistoryData({
    this.content,
    this.page,
    this.size,
    this.totalElements,
    this.totalPages,
  });

  factory OrderHistoryData.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'] ?? json['orders'] ?? json['items'] ?? json['data'];
    List<OrderHistoryItem> items = [];
    if (rawContent is List) {
      items = rawContent
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderHistoryItem.fromJson(e))
          .toList();
    }
    return OrderHistoryData(
      content: items,
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? items.length,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? items.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content?.map((e) => e.toJson()).toList(),
        'page': page,
        'size': size,
        'totalElements': totalElements,
        'totalPages': totalPages,
      };
}

class OrderHistoryItem {
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
  final List<OrderProductItem>? items;
  final String? createdAt;
  final String? updatedAt;

  OrderHistoryItem({
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
    this.createdAt,
    this.updatedAt,
  });

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) =>
      OrderHistoryItem(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? json['orderId']?.toString(),
        userId: json['userId']?.toString(),
        orderNumber: json['orderNumber']?.toString() ?? json['orderNo']?.toString() ?? json['id']?.toString(),
        status: json['status']?.toString() ?? json['orderStatus']?.toString(),
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ??
            (json['total'] as num?)?.toDouble() ??
            (json['amount'] as num?)?.toDouble(),
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
        estimatedTax: (json['estimatedTax'] as num?)?.toDouble() ?? (json['tax'] as num?)?.toDouble(),
        promoDiscount: (json['promoDiscount'] as num?)?.toDouble() ?? (json['discount'] as num?)?.toDouble(),
        deliveryAddress: json['deliveryAddress']?.toString() ?? json['address']?.toString(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        paymentMethod: json['paymentMethod']?.toString(),
        itemCount: (json['itemCount'] as num?)?.toInt() ??
            (json['items'] is List ? (json['items'] as List).length : null),
        itemThumbnails: (json['itemThumbnails'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        canTrack: json['canTrack'] as bool? ?? true,
        canReorder: json['canReorder'] as bool? ?? true,
        canCancel: json['canCancel'] as bool? ?? true,
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => OrderProductItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt']?.toString() ?? json['orderDate']?.toString() ?? json['timestamp']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
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
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class OrderProductItem {
  final String? id;
  final String? productId;
  final String? productName;
  final int? quantity;
  final double? price;
  final String? unit;
  final double? subTotal;

  OrderProductItem({
    this.id,
    this.productId,
    this.productName,
    this.quantity,
    this.price,
    this.unit,
    this.subTotal,
  });

  factory OrderProductItem.fromJson(Map<String, dynamic> json) =>
      OrderProductItem(
        id: json['id']?.toString() ?? json['_id']?.toString(),
        productId: json['productId']?.toString() ?? json['id']?.toString(),
        productName: json['productName']?.toString() ??
            json['name']?.toString() ??
            json['title']?.toString(),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        price: (json['price'] as num?)?.toDouble() ??
            (json['unitPrice'] as num?)?.toDouble(),
        unit: json['unit']?.toString() ?? json['weight']?.toString(),
        subTotal: (json['subTotal'] as num?)?.toDouble() ??
            (json['subtotal'] as num?)?.toDouble(),
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

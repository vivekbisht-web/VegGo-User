import 'order_history_response_model.dart';

enum OrderStatus {
  placed,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled,
}

class OrderItemModel {
  final String id;
  final String title;
  final String weight;
  final double price;
  final int quantity;
  final String imagePath;

  const OrderItemModel({
    required this.id,
    required this.title,
    required this.weight,
    required this.price,
    required this.quantity,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'weight': weight,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imagePath: json['imagePath']?.toString() ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final DateTime orderDate;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double discount;
  final double platformCharge;
  final double totalAmount;
  final String deliveryAddress;
  final String paymentMethod;
  final List<OrderItemModel> items;

  // ── original fields — kept as they were ──
  final String? driverName;
  final String? driverPhone;
  final String? estimatedDeliveryTime;

  // ── new fields from updated API response ──
  final String orderNumber;
  final String? shopName;
  final String? shopBusinessPhone;
  final String? deliveryAgentName;
  final String? deliveryAgentPhone;
  final bool canTrack;
  final bool canReorder;
  final bool canCancel;

  const OrderModel({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.discount,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.items,
    this.platformCharge = 0.0,
    this.driverName,
    this.driverPhone,
    this.estimatedDeliveryTime,
    this.orderNumber = '',
    this.shopName,
    this.shopBusinessPhone,
    this.deliveryAgentName,
    this.deliveryAgentPhone,
    this.canTrack = false,
    this.canReorder = false,
    this.canCancel = false,
  });

  String get primaryThumbnail => items.isNotEmpty ? items.first.imagePath : '';

  bool get hasThumbnail => primaryThumbnail.isNotEmpty;

  String get displayOrderNumber => orderNumber.isNotEmpty ? orderNumber : id;

  String get statusText {
    switch (status) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onTheWay:
        return 'On the way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderDate': orderDate.toIso8601String(),
      'status': status.name,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'discount': discount,
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'items': items.map((i) => i.toJson()).toList(),
      'driverName': driverName,
      'driverPhone': driverPhone,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'orderNumber': orderNumber,
      'shopName': shopName,
      'shopBusinessPhone': shopBusinessPhone,
      'deliveryAgentName': deliveryAgentName,
      'deliveryAgentPhone': deliveryAgentPhone,
      'canTrack': canTrack,
      'canReorder': canReorder,
      'canCancel': canCancel,
    };
  }

  static OrderStatus parseStatus(String? statusStr) {
    if (statusStr == null || statusStr.isEmpty) return OrderStatus.placed;
    final s = statusStr.toUpperCase().replaceAll('-', '_').replaceAll(' ', '_');
    switch (s) {
      case 'PLACED':
      case 'PENDING':
      case 'ORDER_PLACED':
        return OrderStatus.placed;
      case 'CONFIRMED':
      case 'ACCEPTED':
        return OrderStatus.confirmed;
      case 'PREPARING':
      case 'PACKED':
      case 'PROCESSING':
        return OrderStatus.preparing;
      case 'ON_THE_WAY':
      case 'OUT_FOR_DELIVERY':
      case 'DISPATCHED':
      case 'SHIPPED':
        return OrderStatus.onTheWay;
      case 'DELIVERED':
      case 'COMPLETED':
        return OrderStatus.delivered;
      case 'CANCELLED':
      case 'CANCELED':
      case 'REJECTED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.placed;
    }
  }

  /// Builds an [OrderModel] from the raw API history item.
  ///
  /// `itemThumbnails` in the API is a flat list at the ORDER level,
  /// parallel by index to `items`. We zip them together here so each
  /// [OrderItemModel] gets its own `imagePath`, falling back to '' if
  /// missing or mismatched in length.
  factory OrderModel.fromHistoryItem(OrderHistoryItem item) {
    final DateTime date =
        DateTime.tryParse(item.createdAt ?? '') ?? DateTime.now();

    final List<dynamic> rawItems = item.items ?? [];
    final List<String> thumbnails = (item.itemThumbnails ?? [])
        .map((e) => e.toString())
        .toList();

    final List<OrderItemModel> mappedItems = [];
    for (var i = 0; i < rawItems.length; i++) {
      final p = rawItems[i];
      mappedItems.add(
        OrderItemModel(
          id: (p?.id ?? p?.productId ?? '').toString(),
          title: (p?.productName ?? '').toString(),
          weight: (p?.unit ?? '1 unit').toString(),
          price: (p?.price as num?)?.toDouble() ?? 0.0,
          quantity: (p?.quantity as num?)?.toInt() ?? 1,
          imagePath: i < thumbnails.length ? thumbnails[i] : '',
        ),
      );
    }

    return OrderModel(
      id: item.id ?? '',
      orderDate: date,
      status: parseStatus(item.status),
      subtotal:
          (item.totalAmount ?? 0.0) -
          (item.deliveryFee ?? 0.0) +
          (item.promoDiscount ?? 0.0),
      deliveryFee: item.deliveryFee ?? 0.0,
      tax: item.estimatedTax ?? 0.0,
      discount: item.promoDiscount ?? 0.0,
      platformCharge: item.platformCharge ?? 0.0,
      totalAmount: item.totalAmount ?? 0.0,
      deliveryAddress: item.deliveryAddress ?? '',
      paymentMethod: item.paymentMethod ?? 'COD',
      items: mappedItems,

      estimatedDeliveryTime: null,
      orderNumber: item.orderNumber ?? '',

      canTrack: item.canTrack ?? false,
      canReorder: item.canReorder ?? false,
      canCancel: item.canCancel ?? false,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? json['orderNumber']?.toString() ?? '',
      orderDate:
          DateTime.tryParse(
            json['orderDate']?.toString() ??
                json['createdAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      status: parseStatus(json['status']?.toString()),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      tax:
          (json['tax'] as num?)?.toDouble() ??
          (json['estimatedTax'] as num?)?.toDouble() ??
          0.0,
      discount:
          (json['discount'] as num?)?.toDouble() ??
          (json['promoDiscount'] as num?)?.toDouble() ??
          0.0,
      platformCharge:
          (json['platformCharge'] as num?)?.toDouble() ??
          (json['platformFee'] as num?)?.toDouble() ??
          0.0,
      totalAmount:
          (json['totalAmount'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0.0,
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? 'COD',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
      estimatedDeliveryTime: json['estimatedDeliveryTime']?.toString(),
      orderNumber: json['orderNumber']?.toString() ?? '',
      shopName: json['shopName']?.toString(),
      shopBusinessPhone: json['shopBusinessPhone']?.toString(),
      deliveryAgentName: json['deliveryAgentName']?.toString(),
      deliveryAgentPhone: json['deliveryAgentPhone']?.toString(),
      canTrack: json['canTrack'] as bool? ?? false,
      canReorder: json['canReorder'] as bool? ?? false,
      canCancel: json['canCancel'] as bool? ?? false,
    );
  }
}

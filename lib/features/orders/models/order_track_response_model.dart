import 'package:vegon_user/features/orders/models/order_history_response_model.dart';

class OrderTrackResponseModel {
  final bool? success;
  final String? message;
  final OrderTrackData? data;
  final String? timestamp;

  OrderTrackResponseModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory OrderTrackResponseModel.fromJson(Map<String, dynamic> json) =>
      OrderTrackResponseModel(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] == null
            ? null
            : OrderTrackData.fromJson(json['data'] as Map<String, dynamic>),
        timestamp: json['timestamp'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
    'timestamp': timestamp,
  };
}

class OrderTrackData {
  final String? orderId;
  final String? orderNumber;
  final String? status;
  final String? deliveryAddress;
  final String? estimatedDeliveryWindow;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? shopName;
  final String? shopBusinessPhone;
  final String? deliveryAgentName;
  final String? deliveryAgentPhone;
  final List<OrderStatusTimeline>? statusTimeline;
  final List<OrderProductItem>? items;
  final double? total;
  final bool? hasBeenRated;
  final String? dropOtp;

  OrderTrackData({
    this.orderId,
    this.orderNumber,
    this.status,
    this.deliveryAddress,
    this.estimatedDeliveryWindow,
    this.currentLatitude,
    this.currentLongitude,
    this.shopName,
    this.shopBusinessPhone,
    this.deliveryAgentName,
    this.deliveryAgentPhone,
    this.statusTimeline,
    this.items,
    this.total,
    this.hasBeenRated,
    this.dropOtp,
  });

  factory OrderTrackData.fromJson(Map<String, dynamic> json) => OrderTrackData(
    orderId: json['orderId'] as String?,
    orderNumber: json['orderNumber'] as String?,
    status: json['status'] as String?,
    deliveryAddress: json['deliveryAddress'] as String?,
    estimatedDeliveryWindow: json['estimatedDeliveryWindow'] as String?,
    currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
    currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
    shopName: json['shopName'] as String?,
    shopBusinessPhone: json['shopBusinessPhone'] as String?,
    deliveryAgentName: json['deliveryAgentName'] as String?,
    deliveryAgentPhone: json['deliveryAgentPhone'] as String?,
    statusTimeline: (json['statusTimeline'] as List<dynamic>?)
        ?.map((e) => OrderStatusTimeline.fromJson(e as Map<String, dynamic>))
        .toList(),
    items: (json['items'] as List<dynamic>?)
        ?.map((e) => OrderProductItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: (json['total'] as num?)?.toDouble(),
    hasBeenRated: json['hasBeenRated'] as bool?,
    dropOtp: json['dropOtp'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'orderNumber': orderNumber,
    'status': status,
    'deliveryAddress': deliveryAddress,
    'estimatedDeliveryWindow': estimatedDeliveryWindow,
    'currentLatitude': currentLatitude,
    'currentLongitude': currentLongitude,
    'shopName': shopName,
    'shopBusinessPhone': shopBusinessPhone,
    'deliveryAgentName': deliveryAgentName,
    'deliveryAgentPhone': deliveryAgentPhone,
    'statusTimeline': statusTimeline?.map((e) => e.toJson()).toList(),
    'items': items?.map((e) => e.toJson()).toList(),
    'total': total,
    'hasBeenRated': hasBeenRated,
    'dropOtp': dropOtp,
  };
}

class OrderStatusTimeline {
  final int? step;
  final String? label;
  final String? completedAt;
  final bool? current;

  OrderStatusTimeline({this.step, this.label, this.completedAt, this.current});

  factory OrderStatusTimeline.fromJson(Map<String, dynamic> json) =>
      OrderStatusTimeline(
        step: json['step'] as int?,
        label: json['label'] as String?,
        completedAt: json['completedAt'] as String?,
        current: json['current'] as bool?,
      );

  Map<String, dynamic> toJson() => {
    'step': step,
    'label': label,
    'completedAt': completedAt,
    'current': current,
  };
}

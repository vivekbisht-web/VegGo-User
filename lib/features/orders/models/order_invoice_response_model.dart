class OrderInvoiceResponseModel {
  final bool? success;
  final String? message;
  final OrderInvoiceData? data;
  final String? timestamp;

  OrderInvoiceResponseModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory OrderInvoiceResponseModel.fromJson(Map<String, dynamic> json) =>
      OrderInvoiceResponseModel(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] == null
            ? null
            : OrderInvoiceData.fromJson(json['data'] as Map<String, dynamic>),
        timestamp: json['timestamp'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
        'timestamp': timestamp,
      };
}

class OrderInvoiceData {
  final String? orderNumber;
  final String? orderDate;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final List<OrderInvoiceItem>? items;
  final double? subtotal;
  final double? deliveryFee;
  final double? estimatedTax;
  final double? promoDiscount;
  final double? total;
  final String? paymentMethod;
  final String? invoiceUrl;

  OrderInvoiceData({
    this.orderNumber,
    this.orderDate,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.items,
    this.subtotal,
    this.deliveryFee,
    this.estimatedTax,
    this.promoDiscount,
    this.total,
    this.paymentMethod,
    this.invoiceUrl,
  });

  factory OrderInvoiceData.fromJson(Map<String, dynamic> json) =>
      OrderInvoiceData(
        orderNumber: json['orderNumber'] as String?,
        orderDate: json['orderDate'] as String?,
        customerName: json['customerName'] as String?,
        customerPhone: json['customerPhone'] as String?,
        deliveryAddress: json['deliveryAddress'] as String?,
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => OrderInvoiceItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal: (json['subtotal'] as num?)?.toDouble(),
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
        estimatedTax: (json['estimatedTax'] as num?)?.toDouble(),
        promoDiscount: (json['promoDiscount'] as num?)?.toDouble(),
        total: (json['total'] as num?)?.toDouble(),
        paymentMethod: json['paymentMethod'] as String?,
        invoiceUrl: (json['invoiceUrl'] ??
                json['pdfUrl'] ??
                json['downloadUrl'] ??
                json['url']) as String?,
      );

  Map<String, dynamic> toJson() => {
        'orderNumber': orderNumber,
        'orderDate': orderDate,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'deliveryAddress': deliveryAddress,
        'items': items?.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'estimatedTax': estimatedTax,
        'promoDiscount': promoDiscount,
        'total': total,
        'paymentMethod': paymentMethod,
        'invoiceUrl': invoiceUrl,
      };
}

class OrderInvoiceItem {
  final String? productName;
  final int? quantity;
  final double? unitPrice;
  final String? unit;
  final double? subTotal;

  OrderInvoiceItem({
    this.productName,
    this.quantity,
    this.unitPrice,
    this.unit,
    this.subTotal,
  });

  factory OrderInvoiceItem.fromJson(Map<String, dynamic> json) =>
      OrderInvoiceItem(
        productName: json['productName'] as String?,
        quantity: json['quantity'] as int?,
        unitPrice: (json['unitPrice'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
        subTotal: (json['subTotal'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'unit': unit,
        'subTotal': subTotal,
      };
}

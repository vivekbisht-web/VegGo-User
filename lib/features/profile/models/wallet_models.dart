import 'package:intl/intl.dart';

class WalletBalanceResponse {
  final bool success;
  final String? message;
  final WalletBalanceData? data;
  final String? timestamp;

  WalletBalanceResponse({
    required this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? WalletBalanceData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      timestamp: json['timestamp'] as String?,
    );
  }
}

class WalletBalanceData {
  final String? userId;
  final double balance;

  WalletBalanceData({
    this.userId,
    required this.balance,
  });

  factory WalletBalanceData.fromJson(Map<String, dynamic> json) {
    return WalletBalanceData(
      userId: json['userId'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WalletTransactionResponse {
  final bool success;
  final String? message;
  final WalletTransactionData? data;
  final String? timestamp;

  WalletTransactionResponse({
    required this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory WalletTransactionResponse.fromJson(Map<String, dynamic> json) {
    return WalletTransactionResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? WalletTransactionData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      timestamp: json['timestamp'] as String?,
    );
  }
}

class WalletTransactionData {
  final List<WalletTransactionItem> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  WalletTransactionData({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory WalletTransactionData.fromJson(Map<String, dynamic> json) {
    final list = json['content'] as List<dynamic>? ?? [];
    final items = list
        .whereType<Map<String, dynamic>>()
        .map((item) => WalletTransactionItem.fromJson(item))
        .toList();

    return WalletTransactionData(
      content: items,
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 20,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class WalletTransactionItem {
  final String id;
  final String type;
  final String? reason;
  final double amount;
  final double? balanceAfter;
  final String? referenceId;
  final String? description;
  final String? createdAt;

  WalletTransactionItem({
    required this.id,
    required this.type,
    this.reason,
    required this.amount,
    this.balanceAfter,
    this.referenceId,
    this.description,
    this.createdAt,
  });

  bool get isCredit => type.toUpperCase() == 'CREDIT';

  String get displayTitle {
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    if (reason != null && reason!.trim().isNotEmpty) {
      return reason!.replaceAll('_', ' ');
    }
    return isCredit ? 'Credit' : 'Debit';
  }

  String get formattedDate {
    if (createdAt == null || createdAt!.isEmpty) {
      return '';
    }
    try {
      final dateTime = DateTime.parse(createdAt!).toLocal();
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (_) {
      return createdAt!;
    }
  }

  factory WalletTransactionItem.fromJson(Map<String, dynamic> json) {
    return WalletTransactionItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'CREDIT',
      reason: json['reason'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      referenceId: json['referenceId'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

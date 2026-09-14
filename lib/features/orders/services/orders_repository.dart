import 'package:dio/dio.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/network/api_client.dart';
import 'package:vegon_user/features/orders/models/order_cancel_response_model.dart';
import 'package:vegon_user/features/orders/models/order_details_response_model.dart';
import 'package:vegon_user/features/orders/models/order_history_response_model.dart';
import 'package:vegon_user/features/orders/models/order_invoice_response_model.dart';
import 'package:vegon_user/features/orders/models/order_track_response_model.dart';
import 'package:vegon_user/features/orders/models/rate_order_response_model.dart';
import 'package:vegon_user/features/orders/models/reorder_response_model.dart';

class OrdersRepository {
  final ApiClient _apiClient;

  OrdersRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  Future<OrderHistoryResponseModel?> getOrderHistory({
    int? page,
    int? size,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (page != null && size != null) {
        queryParameters['page'] = page;
        queryParameters['size'] = size;
      }
      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
      }

      Response response;
      try {
        response = await _apiClient.get(
          ApiEndpoints.orders,
          queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
        );
      } catch (e) {
        // Fallback: Try without query parameters if query params caused 500 on backend
        if (queryParameters.isNotEmpty) {
          response = await _apiClient.get(ApiEndpoints.orders);
        } else {
          rethrow;
        }
      }

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return OrderHistoryResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<OrderDetailsResponseModel?> getOrderDetails(String orderId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.orderDetails(orderId));

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return OrderDetailsResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<OrderTrackResponseModel?> getOrderTrack(String orderId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.orderTrack(orderId));

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return OrderTrackResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<OrderInvoiceResponseModel?> getOrderInvoice(String orderId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.orderInvoice(orderId));

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return OrderInvoiceResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<OrderCancelResponseModel?> cancelOrder(String orderId) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.cancelOrder(orderId));

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return OrderCancelResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<RateOrderResponseModel?> rateOrder(
    String orderId,
    int ratingValue,
    String comment,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.rateOrder(orderId),
        data: {'ratingValue': ratingValue, 'comment': comment},
      );

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null) {
        return RateOrderResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<ReorderResponseModel?> reorder(String orderId) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.reorder(orderId));

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null) {
        return ReorderResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

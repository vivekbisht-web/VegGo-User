//
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/network/api_client.dart';
import '../models/product_details_model.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  Future<ProductDetailsResponse> fetchProductDetails(
    String catalogProductId, {
    double? latitude,
    double? longitude,
  }) async {
    if (catalogProductId.trim().isEmpty) {
      return ProductDetailsResponse(
        success: false,
        message: 'Invalid product ID',
      );
    }

    try {
      final endpoint = ApiEndpoints.productDetails(catalogProductId.trim());
      final queryParams = <String, dynamic>{};

      if (latitude != null) {
        queryParams['latitude'] = latitude;
      }
      if (longitude != null) {
        queryParams['longitude'] = longitude;
      }

      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return ProductDetailsResponse.fromJson(data);
      }

      return ProductDetailsResponse(
        success: response.statusCode == 200,
        message: 'Product retrieved successfully',
      );
    } on DioException catch (e) {
      debugPrint('Dio error fetching product details: ${e.message}');
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return ProductDetailsResponse.fromJson(responseData);
      } else if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is Map<String, dynamic>) {
            return ProductDetailsResponse.fromJson(decoded);
          }
        } catch (_) {}
      }
      return ProductDetailsResponse(
        success: false,
        message: e.message ?? 'Failed to retrieve product details',
      );
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      return ProductDetailsResponse(success: false, message: e.toString());
    }
  }

  Future<RelatedProductsResponse> fetchRelatedProducts(
    String catalogProductId, {
    double? latitude,
    double? longitude,
  }) async {
    if (catalogProductId.trim().isEmpty) {
      return RelatedProductsResponse(
        success: false,
        message: 'Invalid product ID',
        data: [],
      );
    }

    try {
      final endpoint = ApiEndpoints.relatedProducts(catalogProductId.trim());
      final queryParams = <String, dynamic>{};

      if (latitude != null) {
        queryParams['latitude'] = latitude;
      }
      if (longitude != null) {
        queryParams['longitude'] = longitude;
      }

      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return RelatedProductsResponse.fromJson(data);
      }

      return RelatedProductsResponse(
        success: response.statusCode == 200,
        message: 'Related products retrieved successfully',
        data: [],
      );
    } on DioException catch (e) {
      debugPrint('Dio error fetching related products: ${e.message}');
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return RelatedProductsResponse.fromJson(responseData);
      } else if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is Map<String, dynamic>) {
            return RelatedProductsResponse.fromJson(decoded);
          }
        } catch (_) {}
      }
      return RelatedProductsResponse(
        success: false,
        message: e.message ?? 'Failed to retrieve related products',
        data: [],
      );
    } catch (e) {
      debugPrint('Error fetching related products: $e');
      return RelatedProductsResponse(
        success: false,
        message: e.toString(),
        data: [],
      );
    }
  }
}

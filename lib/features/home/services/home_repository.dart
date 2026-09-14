//
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/network/api_client.dart';
import 'package:vegon_user/features/category/models/category_product_model.dart';
import 'package:vegon_user/features/home/models/banner_models.dart';
import 'package:vegon_user/features/home/models/category_models.dart';
import 'package:vegon_user/features/home/models/shop_models.dart';

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  Future<GetBannersResponseModel> fetchBanners() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.banners);
      if (response.statusCode == 200) {
        return GetBannersResponseModel.fromJson(response.data);
      }
      return GetBannersResponseModel(
        success: false,
        message: 'Failed to load banners (${response.statusCode})',
        banners: [],
      );
    } catch (e) {
      debugPrint('HomeRepository.fetchBanners error: $e');
      return GetBannersResponseModel(
        success: false,
        message: e.toString(),
        banners: [],
      );
    }
  }

  Future<GetCategoriesResponseModel> fetchCategories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.categories);
      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is Map<String, dynamic>) {
        return GetCategoriesResponseModel.fromJson(data);
      }
      return GetCategoriesResponseModel(
        success: response.statusCode == 200,
        message: '',
        categories: [],
      );
    } catch (e) {
      debugPrint('HomeRepository.fetchCategories error: $e');
      return GetCategoriesResponseModel(
        success: false,
        message: e.toString(),
        categories: [],
      );
    }
  }

  Future<GetShopsResponseModel> fetchNearbyShops({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;

      final response = await _apiClient.get(
        ApiEndpoints.shops,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is Map<String, dynamic>) {
        return GetShopsResponseModel.fromJson(data);
      }
      return GetShopsResponseModel(
        success: response.statusCode == 200,
        message: '',
        shops: [],
      );
    } catch (e) {
      debugPrint('HomeRepository.fetchNearbyShops error: $e');
      return GetShopsResponseModel(
        success: false,
        message: e.toString(),
        shops: [],
      );
    }
  }

  Future<List<CategoryProductItem>> fetchDailyDeals({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;

      final response = await _apiClient.get(
        ApiEndpoints.productDeals,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        final rawList = data['data'] ?? data['content'] ?? data['products'];
        if (rawList is List) {
          return rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => CategoryProductItem.fromJson(e))
              .toList();
        }
      }
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => CategoryProductItem.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('HomeRepository.fetchDailyDeals error: $e');
      return [];
    }
  }

  Future<ProductsPageResponse> fetchProducts({
    String? categoryId,
    String? subcategoryId,
    String? query,
    double? minPrice,
    double? maxPrice,
    double? latitude,
    double? longitude,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }
      if (subcategoryId != null && subcategoryId.isNotEmpty) {
        queryParams['subcategoryId'] = subcategoryId;
      }
      if (query != null && query.trim().isNotEmpty) {
        queryParams['query'] = query.trim();
      }
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;

      final response = await _apiClient.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is Map<String, dynamic>) {
        return ProductsPageResponse.fromJson(data);
      }
      return ProductsPageResponse(
        success: response.statusCode == 200,
        message: '',
        content: [],
        page: page,
        size: size,
        totalElements: 0,
        totalPages: 1,
      );
    } catch (e) {
      debugPrint('HomeRepository.fetchProducts error: $e');
      return ProductsPageResponse(
        success: false,
        message: e.toString(),
        content: [],
        page: page,
        size: size,
        totalElements: 0,
        totalPages: 1,
      );
    }
  }
}

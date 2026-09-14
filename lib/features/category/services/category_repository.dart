//
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/category_product_model.dart';
import '../models/subcategory_model.dart';

class CategoryRepository {
  final ApiClient _apiClient;

  CategoryRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  Future<CategoriesPageResponse> fetchCategories({
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _apiClient.get(
        ApiEndpoints.categories,
        queryParameters: queryParams,
      );

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return CategoriesPageResponse.fromJson(data);
      }

      return CategoriesPageResponse(
        success: response.statusCode == 200,
        message: '',
        content: [],
        page: page,
        size: size,
        totalElements: 0,
        totalPages: 1,
      );
    } on DioException catch (e) {
      debugPrint('Dio error fetching categories: ${e.message}');
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return CategoriesPageResponse.fromJson(responseData);
      } else if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is Map<String, dynamic>) {
            return CategoriesPageResponse.fromJson(decoded);
          }
        } catch (_) {}
      }
      return CategoriesPageResponse(
        success: false,
        message: e.message ?? 'Failed to fetch categories',
        content: [],
        page: page,
        size: size,
        totalElements: 0,
        totalPages: 1,
      );
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return CategoriesPageResponse(
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

  Future<SubcategoriesPageResponse> fetchSubcategories(
    String categoryId, {
    int page = 0,
    int size = 20,
  }) async {
    if (categoryId.isEmpty) {
      return SubcategoriesPageResponse(
        success: true,
        message: '',
        content: [],
        page: page,
        size: size,
        totalElements: 0,
        totalPages: 1,
      );
    }

    try {
      final endpoint = ApiEndpoints.subcategories(categoryId);
      final response = await _apiClient.get(
        endpoint,
        queryParameters: {'page': page, 'size': size},
      );

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return SubcategoriesPageResponse.fromJson(data);
      }

      return SubcategoriesPageResponse(
        success: response.statusCode == 200,
        message: '',
        content: [],
        page: page,
        size: size,
        totalElements: 0,
        totalPages: 1,
      );
    } on DioException catch (e) {
      debugPrint('Dio error fetching subcategories: ${e.message}');
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return SubcategoriesPageResponse.fromJson(responseData);
      } else if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is Map<String, dynamic>) {
            return SubcategoriesPageResponse.fromJson(decoded);
          }
        } catch (_) {}
      }
      return SubcategoriesPageResponse(
        success: false,
        message: e.message ?? 'Failed to fetch subcategories',
        content: [],
        page: page,
        size: size,
        totalElements: 0,
        totalPages: 1,
      );
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      return SubcategoriesPageResponse(
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

  Future<ProductsPageResponse> fetchProducts({
    String? categoryId,
    String? subcategoryId,
    String? query,
    double? minPrice,
    double? maxPrice,
    double? latitude,
    double? longitude,
    int page = 0,
    int size = 10,
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
      if (minPrice != null) {
        queryParams['minPrice'] = minPrice;
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice;
      }
      if (latitude != null) {
        queryParams['latitude'] = latitude;
      }
      if (longitude != null) {
        queryParams['longitude'] = longitude;
      }

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
    } on DioException catch (e) {
      debugPrint('Dio error fetching products: ${e.message}');
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return ProductsPageResponse.fromJson(responseData);
      } else if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is Map<String, dynamic>) {
            return ProductsPageResponse.fromJson(decoded);
          }
        } catch (_) {}
      }
      return ProductsPageResponse(
        success: false,
        message: e.message ?? 'Failed to fetch products',
        content: [],
        page: page,
        size: size,
        totalElements: 0,
        totalPages: 1,
      );
    } catch (e) {
      debugPrint('Error fetching products: $e');
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

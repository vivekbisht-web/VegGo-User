import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/network/api_client.dart';
import 'package:vegon_user/features/product/models/wishlist_response_model.dart';

class WishlistRepository {
  final ApiClient _apiClient;

  WishlistRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  Future<WishlistResponseModel?> getWishlist() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.wishlist);

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return WishlistResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<WishlistActionResponseModel?> addToWishlist(String productId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.wishlist,
        queryParameters: {'productId': productId},
      );

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return WishlistActionResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<WishlistActionResponseModel?> removeFromWishlist(String productId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.removeFromWishlist(productId),
      );

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return WishlistActionResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

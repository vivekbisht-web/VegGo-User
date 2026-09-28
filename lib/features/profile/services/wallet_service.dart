import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../models/wallet_models.dart';

class WalletService {
  final ApiClient _apiClient;

  WalletService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  Future<WalletBalanceResponse> getWalletBalance() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.walletBalance);
      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      if (data is Map<String, dynamic>) {
        return WalletBalanceResponse.fromJson(data);
      }
      return WalletBalanceResponse(
        success: false,
        message: AppStrings.invalidResponseFormat,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return WalletBalanceResponse.fromJson(responseData);
      }
      return WalletBalanceResponse(
        success: false,
        message: e.response?.statusMessage ?? AppStrings.failedToLoadWallet,
      );
    } catch (e) {
      return WalletBalanceResponse(success: false, message: e.toString());
    }
  }

  Future<WalletTransactionResponse> getWalletTransactions({
    String? type,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (type != null && type.isNotEmpty && type.toUpperCase() != 'ALL') {
        queryParameters['type'] = type.toUpperCase();
      }

      final response = await _apiClient.get(
        ApiEndpoints.walletTransactions,
        queryParameters: queryParameters,
      );

      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      if (data is Map<String, dynamic>) {
        return WalletTransactionResponse.fromJson(data);
      }
      return WalletTransactionResponse(
        success: false,
        message: AppStrings.invalidResponseFormat,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return WalletTransactionResponse.fromJson(responseData);
      }
      return WalletTransactionResponse(
        success: false,
        message: e.response?.statusMessage ?? AppStrings.failedToLoadTransactions,
      );
    } catch (e) {
      return WalletTransactionResponse(success: false, message: e.toString());
    }
  }
}

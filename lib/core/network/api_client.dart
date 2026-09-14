//
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import '../../features/auth/controllers/auth_controller.dart';
import '../local_storage/shared_prefs_helper.dart';
import '../constants/api_endpoints.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        followRedirects: true,
        maxRedirects: 5,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode && _dio.httpClientAdapter is IOHttpClientAdapter) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = SharedPrefsHelper.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final lat = SharedPrefsHelper.getLatitude();
          final lng = SharedPrefsHelper.getLongitude();
          if (lat != null && lat != 0.0 && lng != null && lng != 0.0) {
            options.headers['X-Latitude'] = lat.toString();
            options.headers['X-Longitude'] = lng.toString();
          }
          return handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Prevent infinite retry recursion
            if (e.requestOptions.extra['isRetry'] == true) {
              return handler.next(e);
            }

            final accessToken = SharedPrefsHelper.getAccessToken();

            if (accessToken != null && accessToken.isNotEmpty) {
              bool refreshSuccess = false;
              final refreshToken = SharedPrefsHelper.getRefreshToken();

              if (refreshToken != null && refreshToken.isNotEmpty) {
                try {
                  final dioRefresh = Dio(
                    BaseOptions(baseUrl: _dio.options.baseUrl),
                  );
                  final refreshResponse = await dioRefresh.post(
                    ApiEndpoints.refreshToken,
                    data: {'refreshToken': refreshToken},
                  );

                  if (refreshResponse.statusCode == 200) {
                    final data = refreshResponse.data;
                    String? newAccess;
                    String? newRefresh;

                    if (data is Map<String, dynamic>) {
                      newAccess =
                          data['data']?['accessToken'] ?? data['accessToken'];
                      newRefresh =
                          data['data']?['refreshToken'] ??
                          data['refreshToken'] ??
                          refreshToken;
                    }

                    if (newAccess != null && newAccess.isNotEmpty) {
                      await SharedPrefsHelper.saveAccessToken(newAccess);
                      await SharedPrefsHelper.saveRefreshToken(newRefresh!);
                      refreshSuccess = true;

                      final options = e.requestOptions;
                      options.extra['isRetry'] = true;
                      options.headers['Authorization'] = 'Bearer $newAccess';
                      final retryResponse = await _dio.fetch(options);
                      return handler.resolve(retryResponse);
                    }
                  }
                } catch (refreshErr) {
                  // Refresh failed, proceed to logout
                }
              }

              if (!refreshSuccess) {
                if (Get.isRegistered<AuthController>()) {
                  Get.find<AuthController>().forceLogout();
                } else {
                  final authController = Get.put(AuthController());
                  authController.forceLogout();
                }
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception("Unexpected Error Occurred");
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception("Unexpected Error Occurred");
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception("Unexpected Error Occurred");
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception("Unexpected Error Occurred");
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          "Connection Timeout. Please check your internet connection.",
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String errorMessage =
            "Server Error: $statusCode - ${error.response?.statusMessage}";

        final responseData = error.response?.data;
        if (responseData is Map) {
          final nestedData = responseData['data'];
          final message =
              responseData['message'] ??
              responseData['error'] ??
              (nestedData is Map ? nestedData['message'] : null) ??
              (nestedData is Map ? nestedData['error'] : null);
          if (message != null && message.toString().isNotEmpty) {
            errorMessage = message.toString();
          }
        } else if (responseData is String && responseData.isNotEmpty) {
          errorMessage = responseData;
        }

        return Exception(errorMessage);
      case DioExceptionType.cancel:
        return Exception("Request to API server was cancelled");
      case DioExceptionType.connectionError:
        return Exception(
          "No Internet Connection. Please connect to a network.",
        );
      case DioExceptionType.unknown:
        return Exception("An unknown error occurred");
      default:
        return Exception("Something went wrong");
    }
  }
}

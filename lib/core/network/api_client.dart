//
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import '../../features/auth/controllers/auth_controller.dart';
import '../local_storage/shared_prefs_helper.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_strings.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const ApiException({required this.message, this.statusCode, this.errorCode});

  @override
  String toString() => 'Exception: $message';
}

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
          if (kDebugMode) {
            debugPrint(
              '[API] ${options.method} ${options.uri} Authorization: '
              '${options.headers['Authorization'] ?? 'No access token'}',
            );
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
          requestHeader: false,
          requestBody: false,
          responseHeader: true,
          responseBody: false,
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

  ApiException _handleDioError(DioException error) {
    final responseData = error.response?.data;
    final errorCode = responseData is Map
        ? responseData['errorCode']?.toString()
        : null;
    var message = AppStrings.unexpectedError;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = AppStrings.networkError;
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        message =
            'Server Error: $statusCode - ${error.response?.statusMessage}';
        if (responseData is Map) {
          final nestedData = responseData['data'];
          final responseMessage =
              responseData['message'] ??
              responseData['error'] ??
              (nestedData is Map ? nestedData['message'] : null) ??
              (nestedData is Map ? nestedData['error'] : null);
          if (responseMessage != null &&
              responseMessage.toString().isNotEmpty) {
            message = responseMessage.toString();
          }
        } else if (responseData is String && responseData.isNotEmpty) {
          message = responseData;
        }
        break;
      case DioExceptionType.cancel:
        message = AppStrings.networkError;
        break;
      case DioExceptionType.connectionError:
        message = AppStrings.networkError;
        break;
      case DioExceptionType.unknown:
        message = AppStrings.unexpectedError;
        break;
      default:
        message = AppStrings.unexpectedError;
    }
    return ApiException(
      message: message,
      statusCode: error.response?.statusCode,
      errorCode: errorCode,
    );
  }
}

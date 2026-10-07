import 'package:dio/dio.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/local_storage/shared_prefs_helper.dart';
import 'package:vegon_user/core/network/api_client.dart';
import '../mocks/chat_mock_responses.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final ApiClient _apiClient;
  final bool isMockMode;

  ChatRepository({ApiClient? apiClient, bool? mockMode})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl),
      isMockMode =
          mockMode ??
          const bool.fromEnvironment('CHAT_MOCK_MODE', defaultValue: false);

  Future<ChatReply> sendTurn(ChatTurnRequest request) async {
    if (request.text != null && request.text!.length > 200) {
      throw const FormatException('Text exceeds the chat limit');
    }
    if (isMockMode) return ChatMockResponses.forRequest(request);

    final response = await _apiClient.post(
      ApiEndpoints.customerChat,
      data: request.toJson(),
      options: Options(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: _sessionHeaders,
      ),
    );
    final data = response.data;
    if (data is! Map<String, dynamic> || data['data'] is! Map) {
      throw const FormatException('Invalid chat reply');
    }
    if (data['success'] != true) {
      throw ApiException(
        message: data['message']?.toString() ?? '',
        statusCode: response.statusCode,
        errorCode: data['errorCode']?.toString(),
      );
    }
    return ChatReply.fromJson(Map<String, dynamic>.from(data['data'] as Map));
  }

  Future<void> rateChat({
    required String conversationId,
    int? rating,
    List<String> tags = const [],
    required int messageCount,
    required List<String> ordersDiscussed,
    bool skipped = false,
  }) async {
    if (isMockMode) return;
    final payload = skipped
        ? <String, dynamic>{'conversationId': conversationId, 'skipped': true}
        : <String, dynamic>{
            'conversationId': conversationId,
            'rating': rating,
            'tags': tags.take(5).toList(),
            'endReason': 'user_closed',
            'messageCount': messageCount,
            'ordersDiscussed': ordersDiscussed.take(5).toList(),
          };
    await _apiClient.post(
      ApiEndpoints.customerChatRating,
      data: payload,
      options: Options(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: _sessionHeaders,
      ),
    );
  }

  Map<String, String> get _sessionHeaders {
    final token = SharedPrefsHelper.getAccessToken();
    if (token == null || token.isEmpty) return const {};
    return {'Authorization': 'Bearer $token'};
  }
}

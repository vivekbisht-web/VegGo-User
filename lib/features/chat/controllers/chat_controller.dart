import 'dart:async';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/local_storage/shared_prefs_helper.dart';
import 'package:vegon_user/core/network/api_client.dart';
import 'package:vegon_user/features/chat/models/chat_models.dart';
import 'package:vegon_user/features/chat/services/chat_repository.dart';
import 'package:vegon_user/features/chat/utils/chat_access_state.dart';
import 'package:vegon_user/features/home/controllers/location_controller.dart';

class ChatController extends GetxController {
  ChatController({
    ChatRepository? repository,
    this.initialOrderId,
    this.initialOrderNumber,
  }) : _repository = repository ?? ChatRepository();

  final ChatRepository _repository;
  final String? initialOrderId;
  final String? initialOrderNumber;

  final RxList<ChatEntry> entries = <ChatEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSendingRating = false.obs;
  final RxBool ended = false.obs;
  final RxBool rated = false.obs;
  final RxInt rateLimitSeconds = 0.obs;
  final RxnInt selectedRating = RxnInt();
  final RxList<String> selectedTags = <String>[].obs;
  final RxString ratingError = ''.obs;
  final RxInt messageCount = 0.obs;
  final RxSet<String> ordersDiscussed = <String>{}.obs;

  String? conversationId;
  final Rxn<Map<String, dynamic>> currentContext = Rxn<Map<String, dynamic>>();
  ChatTurnRequest? _retryRequest;
  ChatEntry? _retryUserEntry;
  Timer? _rateLimitTimer;

  bool get isMockMode => _repository.isMockMode;
  Map<String, dynamic>? get context => currentContext.value;
  bool get canSend =>
      !isLoading.value && !ended.value && rateLimitSeconds.value == 0;

  @override
  void onInit() {
    super.onInit();
    if (!ChatAccessState.canUseChat) {
      Get.back<void>();
      return;
    }
    startNewChat(
      initialOptionId: initialOrderId == null
          ? null
          : ChatOptionId.forOrder(initialOrderId!),
      initialBubble: initialOrderNumber,
    );
  }

  Future<bool> sendText(String value) async {
    if (value.trim().isEmpty || value.length > 200 || !canSend) return false;
    final text = value;
    final userEntry = ChatEntry(text: text, fromCustomer: true);
    entries.add(userEntry);
    messageCount.value++;
    _retryUserEntry = userEntry;
    return _sendRequest(_request(text: text), userEntry: userEntry);
  }

  Future<void> chooseOption(ChatOption option) async {
    if (!canSend) return;
    final userEntry = ChatEntry(text: option.label, fromCustomer: true);
    entries.add(userEntry);
    messageCount.value++;
    _retryUserEntry = userEntry;
    await _sendRequest(_request(optionId: option.id), userEntry: userEntry);
  }

  Future<void> chooseOrder(ChatOrder order) async {
    if (!canSend || order.optionId.isEmpty) return;
    final userEntry = ChatEntry(text: order.orderNumber, fromCustomer: true);
    entries.add(userEntry);
    messageCount.value++;
    _retryUserEntry = userEntry;
    await _sendRequest(
      _request(optionId: order.optionId),
      userEntry: userEntry,
    );
  }

  Future<void> changeOrder() async {
    if (!canSend) return;
    final userEntry = const ChatEntry(
      text: AppStrings.chatChangeOrder,
      fromCustomer: true,
    );
    entries.add(userEntry);
    messageCount.value++;
    _retryUserEntry = userEntry;
    await _sendRequest(
      _request(optionId: ChatOptionId.orders),
      userEntry: userEntry,
    );
  }

  Future<void> retryLastRequest() async {
    final request = _retryRequest;
    if (request == null || !canSend) return;
    await _sendRequest(request, userEntry: _retryUserEntry);
  }

  Future<void> startNewChat({
    String? initialOptionId,
    String? initialBubble,
  }) async {
    _rateLimitTimer?.cancel();
    entries.clear();
    conversationId = null;
    currentContext.value = null;
    ended.value = false;
    rated.value = false;
    isLoading.value = false;
    isSendingRating.value = false;
    rateLimitSeconds.value = 0;
    selectedRating.value = null;
    selectedTags.clear();
    ratingError.value = '';
    messageCount.value = 0;
    ordersDiscussed.clear();
    _retryRequest = null;
    _retryUserEntry = null;

    if (initialBubble != null && initialBubble.isNotEmpty) {
      entries.add(ChatEntry(text: initialBubble, fromCustomer: true));
      messageCount.value = 1;
    }
    await _sendRequest(
      _request(optionId: initialOptionId, includeContext: false),
      userEntry: entries.isNotEmpty ? entries.last : null,
    );
  }

  void selectRating(int value) {
    if (isSendingRating.value) return;
    selectedRating.value = value;
    selectedTags.clear();
    ratingError.value = '';
  }

  void toggleTag(String tag) {
    if (isSendingRating.value) return;
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else if (selectedTags.length < 5) {
      selectedTags.add(tag);
    }
  }

  List<String> get ratingTags {
    final value = selectedRating.value;
    if (value == null) return const [];
    return value >= 4
        ? const [
            AppStrings.chatTagQuickAnswers,
            AppStrings.chatTagEasyToUse,
            AppStrings.chatTagHelpful,
          ]
        : const [
            AppStrings.chatTagDidNotUnderstand,
            AppStrings.chatTagWrongAnswer,
            AppStrings.chatTagTooSlow,
          ];
  }

  Future<void> submitRating({bool skip = false}) async {
    if (isSendingRating.value || rated.value) return;
    if (!skip && selectedRating.value == null) {
      ratingError.value = AppStrings.chatPickRating;
      return;
    }
    final id = conversationId;
    if (id == null) return;

    isSendingRating.value = true;
    ratingError.value = '';
    try {
      await _repository.rateChat(
        conversationId: id,
        rating: selectedRating.value,
        tags: selectedTags.toList(),
        messageCount: messageCount.value,
        ordersDiscussed: ordersDiscussed.toList(),
        skipped: skip,
      );
      _finishRating();
    } on ApiException catch (error) {
      if (error.statusCode == 409 && error.errorCode == 'ALREADY_RATED') {
        _finishRating();
      } else if (error.statusCode == 400 &&
          error.errorCode == 'RATING_REQUIRED') {
        ratingError.value = AppStrings.chatPickRating;
      } else if (error.statusCode == 429) {
        _beginRateLimit();
      } else {
        ratingError.value = AppStrings.chatSomethingWrong;
      }
    } catch (_) {
      ratingError.value = AppStrings.chatSomethingWrong;
    } finally {
      isSendingRating.value = false;
    }
  }

  Future<bool> _sendRequest(
    ChatTurnRequest request, {
    ChatEntry? userEntry,
  }) async {
    if (isLoading.value) return false;
    isLoading.value = true;
    _retryRequest = null;
    try {
      final reply = await _repository.sendTurn(request);
      conversationId = reply.conversationId.isEmpty
          ? null
          : reply.conversationId;
      currentContext.value = reply.context;
      final orderNumber = currentContext.value?['orderNumber']?.toString();
      if (orderNumber != null &&
          orderNumber.isNotEmpty &&
          orderNumber.length <= 30 &&
          ordersDiscussed.length < 5) {
        ordersDiscussed.add(orderNumber);
      }
      entries.add(
        ChatEntry(text: reply.reply, fromCustomer: false, reply: reply),
      );
      ended.value = reply.ratingPrompt;
      _retryRequest = null;
      _retryUserEntry = null;
      return true;
    } on ApiException catch (error) {
      if (error.statusCode == 403) {
        entries.add(ChatEntry(text: error.message, fromCustomer: false));
        return false;
      }
      if (error.statusCode == 400) {
        if (request.text != null && userEntry != null) {
          entries.remove(userEntry);
          if (messageCount.value > 0) messageCount.value--;
        }
        if (error.errorCode == 'RATING_REQUIRED') {
          ratingError.value = AppStrings.chatPickRating;
        } else {
          entries.add(ChatEntry(text: error.message, fromCustomer: false));
        }
        return false;
      }
      if (error.statusCode == 429) {
        entries.add(
          const ChatEntry(text: AppStrings.chatRateLimit, fromCustomer: false),
        );
        _beginRateLimit();
        return true;
      }
      if (error.statusCode == 409 && error.errorCode == 'ALREADY_RATED') {
        _finishRating();
        return true;
      }
      _appendRetry(request, userEntry);
      return true;
    } catch (_) {
      _appendRetry(request, userEntry);
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  void _appendRetry(ChatTurnRequest request, ChatEntry? userEntry) {
    _retryRequest = request;
    _retryUserEntry = userEntry;
    entries.add(
      const ChatEntry(
        text: AppStrings.chatSomethingWrong,
        fromCustomer: false,
        retryable: true,
      ),
    );
  }

  void _finishRating() {
    rated.value = true;
    entries.add(
      const ChatEntry(text: AppStrings.chatRatingThanks, fromCustomer: false),
    );
  }

  void _beginRateLimit() {
    _rateLimitTimer?.cancel();
    rateLimitSeconds.value = 10;
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (rateLimitSeconds.value <= 1) {
        rateLimitSeconds.value = 0;
        timer.cancel();
      } else {
        rateLimitSeconds.value--;
      }
    });
  }

  ChatTurnRequest _request({
    String? text,
    String? optionId,
    bool includeContext = true,
  }) {
    final (latitude, longitude) = _repository.isMockMode || !includeContext
        ? (null, null)
        : _location();
    return ChatTurnRequest(
      text: text,
      optionId: optionId,
      conversationId: conversationId,
      context: includeContext ? currentContext.value : null,
      latitude: latitude,
      longitude: longitude,
    );
  }

  (double?, double?) _location() {
    if (Get.isRegistered<LocationController>()) {
      final location = Get.find<LocationController>();
      return (location.latitude, location.longitude);
    }
    try {
      return (
        SharedPrefsHelper.getLatitude(),
        SharedPrefsHelper.getLongitude(),
      );
    } catch (_) {
      return (null, null);
    }
  }

  @override
  void onClose() {
    _rateLimitTimer?.cancel();
    entries.clear();
    super.onClose();
  }
}

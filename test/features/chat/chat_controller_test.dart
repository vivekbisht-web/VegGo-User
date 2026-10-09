import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/chat/controllers/chat_controller.dart';
import 'package:vegon_user/features/chat/mocks/chat_mock_responses.dart';
import 'package:vegon_user/features/chat/models/chat_models.dart';
import 'package:vegon_user/features/chat/services/chat_repository.dart';

void main() {
  late ChatController controller;

  setUp(() {
    Get.testMode = true;
    controller = ChatController(repository: ChatRepository(mockMode: true));
    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  test('starts with the greeting and order fixture', () async {
    await Future<void>.delayed(Duration.zero);

    expect(
      controller.entries.last.reply?.reply,
      ChatMockResponses.greeting.reply,
    );
    expect(controller.entries.last.reply?.orders, hasLength(1));
    expect(controller.entries.last.reply?.options, hasLength(5));
    expect(controller.messageCount.value, 0);
  });

  test('echoes options and carries conversation context', () async {
    await Future<void>.delayed(Duration.zero);

    await controller.chooseOption(ChatMockResponses.detailsOption);

    expect(
      controller.entries.last.reply?.reply,
      ChatMockResponses.orderDetails.reply,
    );
    expect(controller.context?['orderId'], ChatMockResponses.orderId);
    expect(controller.messageCount.value, 1);
  });

  test('direct order entry sends its order option on the first turn', () async {
    await controller.startNewChat(
      initialOptionId: ChatOptionId.forOrder(ChatMockResponses.orderId),
      initialBubble: ChatMockResponses.orderNumber,
    );

    expect(controller.entries.first.text, ChatMockResponses.orderNumber);
    expect(
      controller.entries.last.reply?.context?['orderId'],
      ChatMockResponses.orderId,
    );
    expect(controller.messageCount.value, 1);
  });

  test(
    'requires a star and finishes rating before allowing a new chat',
    () async {
      await Future<void>.delayed(Duration.zero);
      await controller.chooseOption(ChatMockResponses.endOption);

      expect(controller.ended.value, isTrue);
      await controller.submitRating();
      expect(controller.ratingError.value, AppStrings.chatPickRating);

      controller.selectRating(5);
      controller.toggleTag(AppStrings.chatTagHelpful);
      await controller.submitRating();

      expect(controller.rated.value, isTrue);
      expect(controller.entries.last.text, AppStrings.chatRatingThanks);
    },
  );

  test('serializes one action and validates request fields', () {
    const request = ChatTurnRequest(
      text: 'typed text',
      optionId: 'opaque-option',
      conversationId: 'invalid id',
      latitude: 91,
      longitude: 0,
    );

    expect(request.toJson(), {'optionId': 'opaque-option'});
  });
}

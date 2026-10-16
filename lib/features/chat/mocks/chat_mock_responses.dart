import '../models/chat_models.dart';

abstract final class ChatMockResponses {
  static const orderId = '6f1c2a9e-0000-0000-0000-000000000001';
  static const conversationId = 'c_3f9a1b2c4d5e';
  static const orderNumber = '#DM-7K2Q9XA1';
  static const detailsOption = ChatOption(
    id: 'DETAILS',
    label: 'Yes, show details',
  );
  static const endOption = ChatOption(id: 'END', label: "No, that's all");

  static const order = ChatOrder(
    optionId: 'ORDER:$orderId',
    orderId: orderId,
    orderNumber: orderNumber,
    status: 'PLACED',
    statusLabel: 'Waiting for a shop',
    total: 145.00,
    itemCount: 3,
    placedAt: '2026-10-05T12:07:00Z',
  );

  static ChatReply get greeting => ChatReply(
    conversationId: conversationId,
    reply:
        "Hi Rahul! Here's your most recent order. Want to see more about it?",
    options: const [
      detailsOption,
      ChatOption(id: 'ORDERS', label: 'My orders'),
      ChatOption(id: 'DEALS', label: "Today's deals"),
      ChatOption(id: 'SEARCH', label: 'Search a product'),
      ChatOption(id: 'CART', label: 'My cart'),
    ],
    orders: const [order],
    context: null,
    ratingPrompt: false,
  );

  static ChatReply get orderDetails => ChatReply(
    conversationId: conversationId,
    reply:
        'Got it, order $orderNumber: out for delivery, total ₹118.\nWhat would you like to know about it?',
    options: const [
      ChatOption(id: 'TRACK:$orderId', label: 'Track order'),
      ChatOption(id: 'PRICE:$orderId', label: 'Price details'),
      ChatOption(id: 'ITEMS:$orderId', label: 'Items'),
      ChatOption(id: 'PARTNER:$orderId', label: 'Delivery partner'),
      ChatOption(id: 'SLOT:$orderId', label: 'Address & slot'),
      ChatOption(id: 'INVOICE:$orderId', label: 'Invoice'),
      ChatOption(id: 'ORDERS', label: 'Another order'),
      endOption,
    ],
    orders: const [],
    context: const {
      'orderId': orderId,
      'orderNumber': orderNumber,
      'statusLabel': 'Out for delivery',
    },
    ratingPrompt: false,
  );

  static ChatReply get tracking => ChatReply(
    conversationId: conversationId,
    reply:
        'Order $orderNumber: Out for delivery\n✓ Order placed\n✓ Shop accepted (Fresh Mart)\n✓ Being prepared\n✓ Delivery partner accepted (Amit)\n→ Out for delivery (on the way)\n○ Delivered',
    options: const [ChatOption(id: 'END', label: "No, that's all")],
    orders: const [],
    context: orderDetails.context,
    ratingPrompt: false,
  );

  static ChatReply get pricing => ChatReply(
    conversationId: conversationId,
    reply:
        'For order $orderNumber the total is ₹118.\nItems ₹120 + Delivery ₹20 + Platform fee ₹5 − Promo (SAVE10) ₹27.\nPayment method: Online payment.',
    options: const [ChatOption(id: 'END', label: "No, that's all")],
    orders: const [],
    context: orderDetails.context,
    ratingPrompt: false,
  );

  static ChatReply get orderList => ChatReply(
    conversationId: conversationId,
    reply: 'Here are your last 5 orders. Tap one to talk about it:',
    options: const [ChatOption(id: 'END', label: 'End chat')],
    orders: List<ChatOrder>.unmodifiable(List.filled(5, order)),
    context: null,
    ratingPrompt: false,
  );

  static ChatReply get finished => ChatReply(
    conversationId: conversationId,
    reply: 'Glad I could help! How would you rate this conversation?',
    options: const [],
    orders: const [],
    context: null,
    ratingPrompt: true,
  );

  static ChatReply forRequest(ChatTurnRequest request) {
    final optionId = request.optionId;
    if (optionId == null) return greeting;
    if (optionId == 'END') return finished;
    if (optionId == 'DETAILS' || optionId.startsWith('ORDER:')) {
      return orderDetails;
    }
    if (optionId.startsWith('TRACK:')) return tracking;
    if (optionId.startsWith('PRICE:')) return pricing;
    if (optionId == 'ORDERS') return orderList;
    return ChatReply(
      conversationId: conversationId,
      reply: 'Here is the information available for your request.',
      options: const [ChatOption(id: 'END', label: 'End chat')],
      orders: const [],
      context: null,
      ratingPrompt: false,
    );
  }
}

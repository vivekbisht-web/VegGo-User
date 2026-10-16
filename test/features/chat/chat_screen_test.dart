import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vegon_user/features/chat/controllers/chat_controller.dart';
import 'package:vegon_user/features/chat/services/chat_repository.dart';
import 'package:vegon_user/features/chat/screens/chat_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(ChatController(repository: ChatRepository(mockMode: true)));
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('renders greeting, order card and server menu options', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: ChatScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Hi Rahul!'), findsOneWidget);
    expect(find.text('#DM-7K2Q9XA1'), findsOneWidget);
    expect(find.text('Waiting for a shop'), findsOneWidget);
    expect(find.text('Yes, show details'), findsOneWidget);
    expect(find.text("Today's deals"), findsOneWidget);
  });

  testWidgets('shows order context after selecting a server option', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: ChatScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, show details'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Talking about'), findsOneWidget);
    expect(find.textContaining('Out for delivery'), findsOneWidget);
    expect(find.text('Track order'), findsOneWidget);
  });
}

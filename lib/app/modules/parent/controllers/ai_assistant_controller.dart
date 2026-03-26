import 'package:get/get.dart';
import '../../../../common/services/parent/parent_ai_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class AIAssistantController extends GetxController {
  final ParentAiService _aiService = Get.find<ParentAiService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final messages =
      [
        {
          'sender': 'ai',
          'text':
              'Hello! I\'m your AI School Assistant. I can help you with fee details, attendance, the school calendar, and more. What\'s on your mind today?',
          'time': '09:12 AM',
        },
        {
          'sender': 'user',
          'text': 'What is the fee policy for this term?',
          'time': '09:13 AM',
        },
        {
          'sender': 'ai',
          'text':
              'For Term 2, fees should be settled by Oct 15th. We have an early payment discount of 5% valid until Sept 30th. You can view the full policy document below.',
          'time': '09:13 AM',
          'attachment': 'Fee_Policy_2024.pdf',
        },
      ].obs;
  final inputText = ''.obs;
  final isTyping = false.obs;

  void sendMessage() {
    if (inputText.trim().isEmpty) return;
    final question = inputText.value.trim();
    messages.add({
      'sender': 'user',
      'text': question,
      'time': 'Just now',
    });
    inputText.value = '';
    isTyping.value = true;
    _aiService
        .ask(
          prompt: question,
          childId: _parentContext.selectedChildId.value,
        )
        .then((data) {
          final answer = data['answer']?.toString() ?? 'No response received.';
          messages.add({
            'sender': 'ai',
            'text': answer,
            'time': 'Just now',
          });
        })
        .catchError((_) {
          messages.add({
            'sender': 'ai',
            'text': 'Sorry, I could not fetch an answer right now.',
            'time': 'Just now',
          });
        })
        .whenComplete(() {
      isTyping.value = false;
    });
  }
}

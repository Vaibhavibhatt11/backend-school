import 'package:get/get.dart';

class AIAssistantController extends GetxController {
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
    messages.add({
      'sender': 'user',
      'text': inputText.value,
      'time': 'Just now',
    });
    inputText.value = '';
    // Simulate AI typing
    isTyping.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isTyping.value = false;
      messages.add({
        'sender': 'ai',
        'text': 'I\'ll help you with that shortly.',
        'time': 'Just now',
      });
    });
  }
}

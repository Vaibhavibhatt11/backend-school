import 'package:get/get.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? data; // for structured responses

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.data,
  });
}

class AiAssistantController extends GetxController {
  final messages = <Message>[].obs;
  final inputText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Add initial AI message
    messages.add(
      Message(
        text:
            'Hello, Mr. Smith! I’m ready to assist you. What can I help you with regarding your classes or students today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void sendMessage() {
    if (inputText.value.trim().isEmpty) return;
    // Add user message
    messages.add(
      Message(text: inputText.value, isUser: true, timestamp: DateTime.now()),
    );
    // Simulate AI response
    _simulateAIResponse(inputText.value);
    inputText.value = '';
  }

  void _simulateAIResponse(String userMessage) {
    // Mock response
    Future.delayed(const Duration(seconds: 1), () {
      if (userMessage.toLowerCase().contains('policy')) {
        messages.add(
          Message(
            text:
                'Attendance Policy (Seniors):\n• Students must maintain a minimum of 90% attendance.\n• Late arrival (15+ mins) counts as a half-day absence.\n• Medical notes must be submitted within 48 hours.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        messages.add(
          Message(
            text:
                'I understand you said: "$userMessage". How can I help further?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }
    });
  }

  void quickReply(String reply) {
    inputText.value = reply;
    sendMessage();
  }
}

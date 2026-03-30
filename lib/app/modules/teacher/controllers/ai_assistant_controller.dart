import 'package:get/get.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

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
    messages.clear();
  }

  void sendMessage() {
    final text = inputText.value.trim();
    if (text.isEmpty) return;

    messages.add(Message(text: text, isUser: true, timestamp: DateTime.now()));
    messages.add(
      Message(
        text: 'AI assistant is not configured for this module yet.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    inputText.value = '';
  }

  void quickReply(String reply) {
    inputText.value = reply;
    sendMessage();
  }
}

import 'package:get/get.dart';
import '../../../../common/services/parent/parent_ai_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class AIAssistantController extends GetxController {
  final ParentAiService _aiService = Get.find<ParentAiService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  /// Chat history comes only from user sends + `POST /parent/ai/ask` responses (no demo thread).
  final messages = <Map<String, dynamic>>[].obs;
  final inputText = ''.obs;
  final isTyping = false.obs;

  /// Quick prompts from `GET /parent/ai/career` when backend returns a list (see handoff).
  final suggestionPrompts = <String>[].obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadSuggestionPrompts(),
    );
    loadSuggestionPrompts();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  Future<void> loadSuggestionPrompts() async {
    try {
      final data = await _aiService.getCareerSuggestions(
        childId: _parentContext.selectedChildId.value,
      );
      final raw =
          data['suggestions'] ??
          data['prompts'] ??
          data['chips'] ??
          data['quickPrompts'] ??
          data['items'];
      if (raw is List) {
        final labels = raw
            .map((e) {
              if (e is String) return e.trim();
              if (e is Map) {
                return (e['label'] ?? e['text'] ?? e['title'] ?? '').toString().trim();
              }
              return e.toString().trim();
            })
            .where((s) => s.isNotEmpty)
            .take(8)
            .toList();
        suggestionPrompts.assignAll(labels);
        return;
      }
      suggestionPrompts.clear();
    } catch (_) {
      suggestionPrompts.clear();
    }
  }

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
          final answer = data['answer'] ??
              data['reply'] ??
              data['message'] ??
              data['text'];
          final text = answer?.toString().trim();
          messages.add({
            'sender': 'ai',
            'text': (text != null && text.isNotEmpty) ? text : 'No response received.',
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

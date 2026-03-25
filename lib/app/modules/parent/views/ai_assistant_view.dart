import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/ai_assistant_controller.dart';

class AIAssistantView extends GetView<AIAssistantController> {
  const AIAssistantView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'AI School Assistant',
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                if (msg['sender'] == 'ai') {
                  return _buildAIMessage(msg);
                } else {
                  return _buildUserMessage(msg);
                }
              },
            ),
          ),
          // Typing indicator
          Obx(
            () =>
                controller.isTyping.value
                    ? Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              'https://via.placeholder.com/32',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? AppColors.surfaceDark
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('AI is typing...'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox(),
          ),
          // Suggestion chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSuggestionChip('Next Holiday?'),
                _buildSuggestionChip('Attendance Report'),
                _buildSuggestionChip('Exam Schedule'),
                _buildSuggestionChip('Uniform Policy'),
              ],
            ),
          ),
          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => controller.inputText.value = val,
                    decoration: InputDecoration(
                      hintText: 'Ask about fees, schedules...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.surfaceDark : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: controller.sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ParentBottomNavBar(
        currentIndex: 0,
      ), // AI is from home, but we set index 0 for home
    );
  }

  Widget _buildAIMessage(Map<String, dynamic> msg) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://via.placeholder.com/32'),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(msg['text']!),
                  if (msg['attachment'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            msg['attachment']!,
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    msg['time']!,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(Map<String, dynamic> msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg['text']!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg['time']!,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://via.placeholder.com/32'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: () {
          controller.inputText.value = label;
          controller.sendMessage();
        },
        backgroundColor: AppColors.primary.withOpacity(0.1),
        labelStyle: const TextStyle(color: AppColors.primary),
      ),
    );
  }
}

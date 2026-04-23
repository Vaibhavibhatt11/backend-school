import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_communication_controller.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_communication_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffCommunicationConversationView extends StatefulWidget {
  const StaffCommunicationConversationView({super.key});

  @override
  State<StaffCommunicationConversationView> createState() =>
      _StaffCommunicationConversationViewState();
}

class _StaffCommunicationConversationViewState
    extends State<StaffCommunicationConversationView> {
  late final StaffCommunicationController controller;
  final TextEditingController _messageController = TextEditingController();
  StaffRecipient? _recipient;
  bool _isResolving = true;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffCommunicationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveRecipient());
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: _recipient == null ? 'Conversation' : _recipient!.name,
      ),
      body: _isResolving
          ? const Center(child: CircularProgressIndicator())
          : _recipient == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Recipient could not be loaded.',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                )
              : Obx(() {
                  final messages =
                      controller.messagesForRecipient(_recipient!).toList();
                  final sending = controller.isSendingMessage.value;
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _recipient!.name.isEmpty
                                          ? '?'
                                          : _recipient!.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _recipient!.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? AppColors.textDark
                                              : AppColors.textLight,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _recipient!.subtitle,
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_recipient!.contact.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                _recipient!.contact,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                FilledButton.tonalIcon(
                                  onPressed: _generateAiDraft,
                                  icon: const Icon(Icons.auto_awesome_rounded),
                                  label: const Text('AI draft'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _messageController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.cleaning_services_rounded),
                                  label: const Text('Clear'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: messages.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'No messages yet. Send the first update from below.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  return Align(
                                    alignment: message.isOutgoing
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      constraints: const BoxConstraints(
                                        maxWidth: 320,
                                      ),
                                      decoration: BoxDecoration(
                                        color: message.isOutgoing
                                            ? AppColors.primary
                                            : (isDark
                                                ? AppColors.surfaceDark
                                                : Colors.white),
                                        borderRadius: BorderRadius.circular(18),
                                        border: message.isOutgoing
                                            ? null
                                            : Border.all(
                                                color: isDark
                                                    ? AppColors.borderDark
                                                    : AppColors.borderLight,
                                              ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.body,
                                            style: TextStyle(
                                              color: message.isOutgoing
                                                  ? Colors.white
                                                  : (isDark
                                                      ? AppColors.textDark
                                                      : AppColors.textLight),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _messageMeta(message.timestamp),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: message.isOutgoing
                                                  ? Colors.white70
                                                  : (isDark
                                                      ? AppColors.textSecondaryDark
                                                      : AppColors.textSecondaryLight),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      SafeArea(
                        top: false,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  minLines: 1,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Write a message...',
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.backgroundDark
                                        : AppColors.backgroundLight,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              FilledButton(
                                onPressed: sending ? null : _sendMessage,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: const Size(54, 54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: sending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
    );
  }

  Future<void> _resolveRecipient() async {
    final rawArgs = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    final audience = StaffMessageAudienceX.fromValue(
      (rawArgs['audience'] ?? 'parent').toString(),
    );
    final recipientId = (rawArgs['recipientId'] ?? '').toString();
    final manualName = (rawArgs['manualName'] ?? '').toString();
    final manualContact = (rawArgs['manualContact'] ?? '').toString();

    if (manualName.trim().isNotEmpty) {
      _recipient = controller.buildManualRecipient(
        audience: audience,
        name: manualName,
        contact: manualContact,
      );
      controller.ensureConversationSeedForRecipient(_recipient!);
      setState(() => _isResolving = false);
      return;
    }

    StaffRecipient? recipient = controller.findRecipient(audience, recipientId);
    if (recipient == null) {
      await controller.loadRecipients(audience, showErrors: false);
      recipient = controller.findRecipient(audience, recipientId);
    }
    if (recipient != null) {
      controller.ensureConversationSeedForRecipient(recipient);
    }
    if (!mounted) return;
    setState(() {
      _recipient = recipient;
      _isResolving = false;
    });
  }

  Future<void> _sendMessage() async {
    if (_recipient == null) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final sent = await controller.sendMessageToRecipient(
      recipient: _recipient!,
      message: text,
    );
    if (sent) {
      _messageController.clear();
      setState(() {});
    }
  }

  Future<void> _generateAiDraft() async {
    if (_recipient == null) return;
    final current = _messageController.text.trim();
    final prompt = current.isEmpty
        ? 'Draft a concise and professional message to ${_recipient!.audience.singularLabel.toLowerCase()} ${_recipient!.name}.'
        : 'Rewrite this into a clear professional message to ${_recipient!.audience.singularLabel.toLowerCase()} ${_recipient!.name}: $current';
    final reply = await controller.generateAiDraft(prompt: prompt);
    if (reply == null || reply.isEmpty || !mounted) return;
    setState(() {
      _messageController.text = reply;
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
    });
  }

  String _messageMeta(DateTime timestamp) {
    final local = timestamp.toLocal();
    final hour = local.hour == 0
        ? 12
        : local.hour > 12
            ? local.hour - 12
            : local.hour;
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute $suffix';
  }
}

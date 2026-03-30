import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bottom sheet: real `POST /staff/ai/assist` when server has `OPENAI_API_KEY`.
class StaffAiAssistantSheet extends StatefulWidget {
  const StaffAiAssistantSheet({super.key, this.initialContext = 'general'});

  final String initialContext;

  static Future<void> open({String initialContext = 'general'}) {
    return Get.bottomSheet<void>(
      StaffAiAssistantSheet(initialContext: initialContext),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<StaffAiAssistantSheet> createState() => _StaffAiAssistantSheetState();
}

class _StaffAiAssistantSheetState extends State<StaffAiAssistantSheet> {
  final _prompt = TextEditingController();
  String _contextType = 'general';
  bool _loading = false;
  String _reply = '';

  static const _contexts = <String, String>{
    'general': 'General',
    'lesson': 'Lesson plan',
    'quiz': 'Quiz / questions',
    'homework': 'Homework',
    'communication': 'Parent message',
  };

  @override
  void initState() {
    super.initState();
    if (_contexts.containsKey(widget.initialContext)) {
      _contextType = widget.initialContext;
    }
  }

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _prompt.text.trim();
    if (text.isEmpty) {
      AppToast.show('Enter a prompt');
      return;
    }
    setState(() {
      _loading = true;
      _reply = '';
    });
    try {
      final svc = Get.find<StaffService>();
      final data = await svc.aiAssist(prompt: text, contextType: _contextType);
      final r = data['reply']?.toString() ?? '';
      setState(() => _reply = r.isEmpty ? '(Empty response)' : r);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.smart_toy_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'AI Teaching Assistant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    const Spacer(),
                    IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                Text(
                  'Uses your school backend. Configure OPENAI_API_KEY on the server for live answers.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _contextType,
                  decoration: const InputDecoration(
                    labelText: 'Context',
                    border: OutlineInputBorder(),
                  ),
                  items: _contexts.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: _loading ? null : (v) => setState(() => _contextType = v ?? 'general'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _prompt,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'What do you need?',
                    hintText: 'e.g. Draft a 40-minute lesson on fractions for Grade 7',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(_loading ? 'Working…' : 'Get AI response'),
                ),
                if (_reply.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Response', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  SelectableText(_reply),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

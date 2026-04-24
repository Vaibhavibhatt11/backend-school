import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_communication_controller.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_communication_models.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffCommunicationRecipientsView extends StatefulWidget {
  const StaffCommunicationRecipientsView({super.key});

  @override
  State<StaffCommunicationRecipientsView> createState() =>
      _StaffCommunicationRecipientsViewState();
}

class _StaffCommunicationRecipientsViewState
    extends State<StaffCommunicationRecipientsView> {
  late final StaffCommunicationController controller;
  late final StaffMessageAudience audience;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffCommunicationController>();
    final rawArgs = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    audience = StaffMessageAudienceX.fromValue(
      (rawArgs['audience'] ?? 'parent').toString(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadRecipients(audience, showErrors: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isParent = audience == StaffMessageAudience.parent;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: isParent ? 'Message Parents' : 'Message Students',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => controller.loadRecipients(audience, showErrors: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openManualCompose,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Manual Compose'),
      ),
      body: Obx(() {
        final loading = isParent
            ? controller.isParentsLoading.value
            : controller.isStudentsLoading.value;
        final error = isParent
            ? controller.parentRecipientsError.value
            : controller.studentRecipientsError.value;
        final recipients = isParent
            ? controller.parentRecipients.toList()
            : controller.studentRecipients.toList();
        final threads = controller.threadsForAudience(audience).take(4).toList();
        final query = _searchController.text.trim().toLowerCase();
        final filteredRecipients = recipients.where((item) {
          if (query.isEmpty) return true;
          final haystack = '${item.name} ${item.subtitle} ${item.contact} ${item.badge}'
              .toLowerCase();
          return haystack.contains(query);
        }).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isParent ? 'Parent Directory' : 'Student Directory',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isParent
                        ? 'Search guardians, open conversations, and send direct updates.'
                        : 'Search active students, follow up on class work, and keep messages in one flow.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: isParent
                          ? 'Search parent name or phone'
                          : 'Search student or admission number',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (threads.isNotEmpty) ...[
              _DirectoryHeader(title: 'Recent Conversations'),
              const SizedBox(height: 10),
              ...threads.map(
                (thread) => _RecipientTile(
                  title: thread.recipientName,
                  subtitle: thread.lastMessage,
                  badge: _relativeTime(thread.updatedAt),
                  onTap: thread.recipientId == null
                      ? null
                      : () => SafeNavigation.toNamed(
                            AppRoutes.STAFF_COMMUNICATION_CONVERSATION,
                            arguments: {
                              'audience': audience.value,
                              'recipientId': thread.recipientId,
                            },
                          ),
                ),
              ),
              const SizedBox(height: 18),
            ],
            _DirectoryHeader(
              title: 'All ${audience.label}',
              trailing: filteredRecipients.isEmpty
                  ? null
                  : Text(
                      '${filteredRecipients.length}',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            if (loading && recipients.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredRecipients.isEmpty)
              _EmptyDirectoryState(
                label: error.isNotEmpty
                    ? error
                    : 'No ${audience.label.toLowerCase()} found for this search.',
                ctaLabel: 'Compose manually',
                onTap: _openManualCompose,
              )
            else
              ...filteredRecipients.map(
                (recipient) => _RecipientTile(
                  title: recipient.name,
                  subtitle: recipient.subtitle,
                  badge: recipient.badge,
                  secondary: recipient.contact,
                  onTap: () {
                    controller.ensureConversationSeedForRecipient(recipient);
                    SafeNavigation.toNamed(
                      AppRoutes.STAFF_COMMUNICATION_CONVERSATION,
                      arguments: {
                        'audience': audience.value,
                        'recipientId': recipient.id,
                      },
                    );
                  },
                ),
              ),
          ],
        );
      }),
    );
  }

  Future<void> _openManualCompose() async {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Manual ${audience.singularLabel} Message'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '${audience.singularLabel} name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Phone or email (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed != true || nameController.text.trim().isEmpty) {
      return;
    }
    SafeNavigation.toNamed(
      AppRoutes.STAFF_COMMUNICATION_CONVERSATION,
      arguments: {
        'audience': audience.value,
        'manualName': nameController.text.trim(),
        'manualContact': contactController.text.trim(),
      },
    );
  }

  String _relativeTime(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _DirectoryHeader extends StatelessWidget {
  const _DirectoryHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _RecipientTile extends StatelessWidget {
  const _RecipientTile({
    required this.title,
    required this.subtitle,
    required this.badge,
    this.secondary = '',
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String secondary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              title.isEmpty ? '?' : title[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            if (secondary.isNotEmpty)
              Text(
                secondary,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (badge.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDirectoryState extends StatelessWidget {
  const _EmptyDirectoryState({
    required this.label,
    required this.ctaLabel,
    required this.onTap,
  });

  final String label;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onTap,
            child: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}

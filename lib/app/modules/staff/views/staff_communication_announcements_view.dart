import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/core/widgets/custom_app_bar.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_communication_controller.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_communication_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffCommunicationAnnouncementsView extends StatefulWidget {
  const StaffCommunicationAnnouncementsView({super.key});

  @override
  State<StaffCommunicationAnnouncementsView> createState() =>
      _StaffCommunicationAnnouncementsViewState();
}

class _StaffCommunicationAnnouncementsViewState
    extends State<StaffCommunicationAnnouncementsView> {
  late final StaffCommunicationController controller;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffCommunicationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAnnouncements(showErrors: true);
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
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: 'Announcements',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => controller.loadAnnouncements(showErrors: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openComposer,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Notice'),
      ),
      body: Obx(() {
        final items = controller.announcementResults(
          query: _searchController.text,
          filter: _selectedFilter,
        );
        final loading = controller.isAnnouncementsLoading.value;
        final error = controller.announcementError.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                    'School Notices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create, review, and publish notices using the same communication center workflow.',
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
                      hintText: 'Search title, audience, or content',
                      prefixIcon: const Icon(Icons.search_rounded),
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
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const ['ALL', 'SENT', 'DRAFT', 'IMPORTANT']
                        .map(
                          (filter) => Padding(
                            padding: EdgeInsets.zero,
                            child: _AnnouncementFilterChip._internal(filter),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (loading && items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              _EmptyAnnouncementState(
                label: error.isNotEmpty
                    ? error
                    : 'No announcements available for this filter.',
                onTap: _openComposer,
              )
            else
              ...items.map(
                (item) => _AnnouncementCard(
                  item: item,
                  onPublish: item.status.toUpperCase() == 'DRAFT'
                      ? () => controller.publishAnnouncement(item)
                      : null,
                ),
              ),
          ],
        );
      }),
    );
  }

  Future<void> _openComposer() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final audienceController = TextEditingController(text: 'ALL');
    bool sendNow = true;
    final confirmed = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Create Announcement'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      minLines: 4,
                      maxLines: 7,
                      decoration: const InputDecoration(labelText: 'Content'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: audienceController,
                      decoration: const InputDecoration(
                        labelText: 'Audience (ALL, Grade 10-A, PARENT, STUDENT)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () async {
                              final prompt = contentController.text.trim().isEmpty
                                  ? 'Draft a school announcement titled "${titleController.text.trim().isEmpty ? 'School update' : titleController.text.trim()}".'
                                  : 'Improve this announcement for staff communication: ${contentController.text.trim()}';
                              final reply =
                                  await controller.generateAiDraft(prompt: prompt);
                              if (reply == null || reply.isEmpty) return;
                              contentController.text = reply;
                            },
                            icon: const Icon(Icons.auto_awesome_rounded),
                            label: const Text('AI Draft'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: sendNow,
                      onChanged: (value) => setDialogState(() => sendNow = value),
                      title: const Text('Publish immediately'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    if (confirmed != true) return;
    final created = await controller.createAnnouncement(
      title: titleController.text,
      content: contentController.text,
      audience: audienceController.text,
      sendNow: sendNow,
    );
    if (created && mounted) {
      setState(() {});
    }
  }

  void updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }
}

class _AnnouncementFilterChip extends StatelessWidget {
  const _AnnouncementFilterChip._internal(this.filter);

  final String filter;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<
        _StaffCommunicationAnnouncementsViewState>();
    final selected = state?._selectedFilter == filter;
    return ChoiceChip(
      label: Text(filter),
      selected: selected,
      onSelected: (_) {
        if (state == null) return;
        state.updateFilter(filter);
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.item, this.onPublish});

  final StaffAnnouncementRecord item;
  final VoidCallback? onPublish;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isUrgent
              ? Colors.redAccent
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusPill(
                label: item.status.toUpperCase(),
                color: item.status.toUpperCase() == 'SENT'
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 8),
              _StatusPill(
                label: item.audience.isEmpty ? 'ALL' : item.audience,
                color: AppColors.primary,
              ),
              if (item.isUrgent) ...[
                const SizedBox(width: 8),
                const _StatusPill(label: 'URGENT', color: Colors.redAccent),
              ],
              const Spacer(),
              Text(
                _formatDate(item.updatedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.content.isEmpty ? 'No content preview available.' : item.content,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (onPublish != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onPublish,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Publish'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final months = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = value.toLocal();
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyAnnouncementState extends StatelessWidget {
  const _EmptyAnnouncementState({required this.label, required this.onTap});

  final String label;
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
            child: const Text('Create notice'),
          ),
        ],
      ),
    );
  }
}

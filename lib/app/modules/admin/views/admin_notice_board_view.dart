import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_shell_controller.dart';
import 'package:erp_frontend/app/navbar/admin_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_notice_board_controller.dart';

class AdminNoticeBoardView extends GetView<AdminNoticeBoardController> {
  final bool embedded;
  const AdminNoticeBoardView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = SafeArea(
      child: DefaultTabController(
        length: 6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (embedded && Get.isRegistered<AdminShellController>()) {
                        Get.find<AdminShellController>().setTab(0);
                        return;
                      }
                      if (Get.key.currentState?.canPop() ?? false) {
                        Get.back();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Communication Center',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Staff chat, broadcasts, notifications, and circulars',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _HeaderActionButton(
                    icon: Icons.search,
                    tooltip: 'Search Circulars',
                    onTap: () {
                      showSearch<Notice?>(
                        context: context,
                        delegate: _NoticeSearchDelegate(controller),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: TabBar(
                isScrollable: true,
                indicator: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorPadding: const EdgeInsets.all(6),
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                tabs: const [
                  Tab(text: 'Staff Chat'),
                  Tab(text: 'SMS/WhatsApp'),
                  Tab(text: 'Email'),
                  Tab(text: 'App Notifications'),
                  Tab(text: 'Parent Communication'),
                  Tab(text: 'Circulars'),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TabBarView(
                  children: [
                    _StaffChatTab(controller: controller, isDark: isDark),
                    _ChannelCampaignTab(
                      controller: controller,
                      isDark: isDark,
                      channel: 'SMS/WHATSAPP',
                    ),
                    _ChannelCampaignTab(
                      controller: controller,
                      isDark: isDark,
                      channel: 'EMAIL',
                    ),
                    _ChannelCampaignTab(
                      controller: controller,
                      isDark: isDark,
                      channel: 'APP',
                    ),
                    _ParentCommunicationTab(controller: controller, isDark: isDark),
                    _CircularAnnouncementsTab(controller: controller, isDark: isDark),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
    if (embedded) {
      return Scaffold(
        body: content,
        floatingActionButton: FloatingActionButton(
          heroTag: 'admin_notices_fab_embedded',
          onPressed: controller.onAddNotice,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }
    return Scaffold(
      body: content,
      floatingActionButton: FloatingActionButton(
        heroTag: 'admin_notices_fab',
        onPressed: controller.onAddNotice,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AdminBottomNavBar(currentIndex: 3), // Notices tab
    );
  }

}

class _StaffChatTab extends StatelessWidget {
  const _StaffChatTab({required this.controller, required this.isDark});

  final AdminNoticeBoardController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          FilledButton.icon(
            onPressed: () => controller.openStaffChatDialog(),
            icon: const Icon(Icons.chat_rounded),
            label: const Text('Start Staff Chat'),
          ),
          const SizedBox(height: 12),
          if (controller.staffChats.isEmpty)
            _CommEmpty(
              isDark: isDark,
              title: 'No staff chats',
              message: 'Create staff chat threads for internal communication.',
            )
          else
            ...controller.staffChats.map(
              (item) => _CommCard(
                isDark: isDark,
                title: item.staffName,
                subtitle: item.topic,
                details: [
                  'Last message: ${item.lastMessage.isEmpty ? '-' : item.lastMessage}',
                  'Updated: ${item.updatedAt}',
                ],
                actions: [
                  OutlinedButton(
                    onPressed: () => controller.openStaffChatDialog(existing: item),
                    child: const Text('Edit'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.deleteStaffChat(item),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChannelCampaignTab extends StatelessWidget {
  const _ChannelCampaignTab({
    required this.controller,
    required this.isDark,
    required this.channel,
  });

  final AdminNoticeBoardController controller;
  final bool isDark;
  final String channel;

  @override
  Widget build(BuildContext context) {
    final campaigns = channel == 'SMS/WHATSAPP'
        ? controller.smsCampaigns
        : channel == 'EMAIL'
            ? controller.emailCampaigns
            : controller.appNotifications;
    final sentCount = campaigns.where((e) => e.status == 'SENT').length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatPill(label: 'Total', value: '${campaigns.length}'),
            _StatPill(label: 'Sent', value: '$sentCount'),
            FilledButton.icon(
              onPressed: () => controller.openChannelCampaignDialog(channel: channel),
              icon: const Icon(Icons.add_alert_rounded),
              label: Text('Create ${channel == 'APP' ? 'App' : channel}'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (campaigns.isEmpty)
          _CommEmpty(
            isDark: isDark,
            title: 'No campaigns',
            message: 'Create channel campaigns and send to target audience.',
          )
        else
          ...campaigns.map(
            (item) => _CommCard(
              isDark: isDark,
              title: item.title,
              subtitle: item.audience,
              details: [
                item.message,
                'Status: ${item.status}',
                'Created: ${item.createdAt}',
              ],
              actions: [
                OutlinedButton(
                  onPressed: () => controller.openChannelCampaignDialog(
                    channel: channel,
                    existing: item,
                  ),
                  child: const Text('Edit'),
                ),
                if (item.status != 'SENT')
                  OutlinedButton(
                    onPressed: () =>
                        controller.sendChannelCampaign(channel: channel, item: item),
                    child: const Text('Send'),
                  ),
                FilledButton.tonal(
                  onPressed: () => controller.deleteChannelCampaign(
                    channel: channel,
                    item: item,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ParentCommunicationTab extends StatelessWidget {
  const _ParentCommunicationTab({required this.controller, required this.isDark});

  final AdminNoticeBoardController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        FilledButton.icon(
          onPressed: () => controller.openParentCommunicationDialog(),
          icon: const Icon(Icons.family_restroom_rounded),
          label: const Text('New Parent Communication'),
        ),
        const SizedBox(height: 12),
        if (controller.parentCommunications.isEmpty)
          _CommEmpty(
            isDark: isDark,
            title: 'No parent communications',
            message: 'Start direct parent communication and track replies.',
          )
        else
          ...controller.parentCommunications.map(
            (item) => _CommCard(
              isDark: isDark,
              title: item.parentName,
              subtitle: item.subject,
              details: [
                item.message,
                'Status: ${item.status}',
                'Updated: ${item.updatedAt}',
              ],
              actions: [
                OutlinedButton(
                  onPressed: () =>
                      controller.openParentCommunicationDialog(existing: item),
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CircularAnnouncementsTab extends StatelessWidget {
  const _CircularAnnouncementsTab({
    required this.controller,
    required this.isDark,
  });

  final AdminNoticeBoardController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatPill(label: 'All', value: '${controller.notices.length}'),
            _StatPill(
              label: 'Draft',
              value:
                  '${controller.notices.where((e) => e.status == 'DRAFT').length}',
            ),
            FilledButton.icon(
              onPressed: controller.onAddNotice,
              icon: const Icon(Icons.campaign_rounded),
              label: const Text('Create Circular'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.notices.isEmpty)
          _CommEmpty(
            isDark: isDark,
            title: 'No circular announcements',
            message: 'Create circulars and publish them to selected audience.',
          )
        else
          ...controller.notices.map(
            (notice) => _NoticeCard(
              notice: notice,
              isDark: isDark,
              onTap: () => controller.onNoticeTap(notice),
            ),
          ),
      ],
    );
  }
}

class _CommCard extends StatelessWidget {
  const _CommCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.actions,
  });

  final bool isDark;
  final String title;
  final String subtitle;
  final List<String> details;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
          const SizedBox(height: 10),
          ...details
              .where((e) => e.trim().isNotEmpty)
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(e),
                  )),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}

class _CommEmpty extends StatelessWidget {
  const _CommEmpty({
    required this.isDark,
    required this.title,
    required this.message,
  });

  final bool isDark;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.notice,
    required this.isDark,
    required this.onTap,
  });

  final Notice notice;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notice.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  notice.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            notice.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          notice.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _statusColor(notice.status),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          notice.time,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notice.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notice.description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: notice.audiences
                        .map(
                          (aud) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              aud,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PUBLISHED':
      case 'SENT':
        return Colors.green;
      case 'SCHEDULED':
        return Colors.amber;
      case 'DRAFT':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class _NoticeSearchDelegate extends SearchDelegate<Notice?> {
  _NoticeSearchDelegate(this.controller);

  final AdminNoticeBoardController controller;

  @override
  String get searchFieldLabel => 'Search notices';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = controller.searchNotices(query);
    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No notices matched your search.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final notice = results[index];
        return _NoticeCard(
          notice: notice,
          isDark: isDark,
          onTap: () {
            close(context, notice);
            controller.onNoticeTap(notice);
          },
        );
      },
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
        ),
      ),
    );
  }
}

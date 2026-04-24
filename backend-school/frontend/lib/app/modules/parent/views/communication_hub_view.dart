import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/fonts/common_textstyle.dart';
import '../../../../common/theme/app_color.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../widgets/app_scaffold.dart';
import '../controllers/communication_hub_controller.dart';

class CommunicationHubView extends GetView<CommunicationHubController> {
  const CommunicationHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Communication Center',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(context, 16),
              Responsive.h(context, 12),
              Responsive.w(context, 16),
              Responsive.h(context, 10),
            ),
            child: Column(
              children: [
                _header(context),
                SizedBox(height: Responsive.h(context, 10)),
                _tabs(context),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final tab = controller.selectedTab.value;
              if (controller.isLoading.value &&
                  controller.announcements.isEmpty &&
                  controller.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              switch (tab) {
                case 'announcements':
                  return _AnnouncementList(items: controller.announcements);
                case 'notifications':
                  return _NotificationList(items: controller.notifications);
                case 'meeting':
                  return _MeetingSection(controller: controller);
                case 'ptc':
                  return _ParentTeacherCommunicationSection(controller: controller);
                case 'circulars':
                  return _CircularList(items: controller.circulars);
                default:
                  return _TeacherMessageList(items: controller.teacherMessages);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primaryDark.withValues(alpha: 0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 10)),
            decoration: BoxDecoration(
              color: AppColor.base.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.forum_rounded, color: AppColor.base, size: Responsive.w(context, 24)),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Text(
              'Teacher messages, announcements, notifications, meetings, and circulars in one place.',
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColor.base,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    const tabs = [
      ('teacherMessages', 'Teacher Messages'),
      ('announcements', 'Announcements'),
      ('notifications', 'Notifications'),
      ('meeting', 'Book Meeting'),
      ('ptc', 'Parent-Teacher Chat'),
      ('circulars', 'Circulars'),
    ];
    return SizedBox(
      height: Responsive.h(context, 36),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => Obx(() {
          final key = tabs[i].$1;
          final label = tabs[i].$2;
          final active = controller.selectedTab.value == key;
          return InkWell(
            onTap: () => controller.changeTab(key),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 14),
                vertical: Responsive.h(context, 8),
              ),
              decoration: BoxDecoration(
                color: active ? AppColor.primary : AppColor.cardBackground,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: AppTextStyle.caption(context).copyWith(
                  color: active ? AppColor.base : AppColor.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(context, 8)),
        itemCount: tabs.length,
      ),
    );
  }
}

class _TeacherMessageList extends StatelessWidget {
  const _TeacherMessageList({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _Empty(text: 'No teacher messages');
    return ListView.builder(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final m = items[i];
        return _Card(
          title: (m['title'] ?? '').toString(),
          subtitle: (m['description'] ?? '').toString(),
          foot: '${(m['teacherName'] ?? m['postedBy'] ?? 'Teacher')} • ${(m['time'] ?? '')}',
          icon: Icons.person_rounded,
        );
      },
    );
  }
}

class _AnnouncementList extends StatelessWidget {
  const _AnnouncementList({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _Empty(text: 'No announcements');
    return ListView.builder(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final m = items[i];
        return _Card(
          title: (m['title'] ?? '').toString(),
          subtitle: (m['description'] ?? '').toString(),
          foot: '${(m['postedBy'] ?? 'School')} • ${(m['time'] ?? '')}',
          icon: Icons.campaign_rounded,
        );
      },
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _Empty(text: 'No notifications');
    return ListView.builder(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final m = items[i];
        return _Card(
          title: (m['title'] ?? '').toString(),
          subtitle: (m['description'] ?? '').toString(),
          foot: '${(m['section'] ?? 'General')} • ${(m['time'] ?? '')}',
          icon: Icons.notifications_active_rounded,
          highlight: m['unread'] == true,
        );
      },
    );
  }
}

class _CircularList extends StatelessWidget {
  const _CircularList({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _Empty(text: 'No circulars');
    return ListView.builder(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final m = items[i];
        return _Card(
          title: (m['title'] ?? '').toString(),
          subtitle: (m['description'] ?? '').toString(),
          foot: '${(m['attachment'] ?? 'No attachment')} • ${(m['time'] ?? '')}',
          icon: Icons.description_rounded,
        );
      },
    );
  }
}

class _MeetingSection extends StatefulWidget {
  const _MeetingSection({required this.controller});
  final CommunicationHubController controller;

  @override
  State<_MeetingSection> createState() => _MeetingSectionState();
}

class _MeetingSectionState extends State<_MeetingSection> {
  final _teacher = TextEditingController();
  final _purpose = TextEditingController();
  final _time = TextEditingController(text: '10:00 AM');
  DateTime? _date;

  @override
  void dispose() {
    _teacher.dispose();
    _purpose.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      children: [
        _Section(
          title: 'Book a meeting',
          child: Column(
            children: [
              TextField(controller: _teacher, decoration: const InputDecoration(labelText: 'Teacher name')),
              SizedBox(height: Responsive.h(context, 8)),
              TextField(controller: _purpose, decoration: const InputDecoration(labelText: 'Purpose')),
              SizedBox(height: Responsive.h(context, 8)),
              TextField(controller: _time, decoration: const InputDecoration(labelText: 'Preferred time')),
              SizedBox(height: Responsive.h(context, 8)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _date == null ? 'Select date' : '${_date!.day}/${_date!.month}/${_date!.year}',
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: now,
                        lastDate: DateTime(now.year + 2),
                        initialDate: now,
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: const Text('Choose Date'),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(context, 10)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_teacher.text.trim().isEmpty || _purpose.text.trim().isEmpty || _date == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fill teacher, purpose and date')),
                      );
                      return;
                    }
                    widget.controller.bookMeeting(
                      teacher: _teacher.text.trim(),
                      purpose: _purpose.text.trim(),
                      date: _date!,
                      timeSlot: _time.text.trim().isEmpty ? '10:00 AM' : _time.text.trim(),
                    );
                    _teacher.clear();
                    _purpose.clear();
                    setState(() => _date = null);
                  },
                  child: const Text('Book Meeting'),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.h(context, 12)),
        Obx(() {
          final list = widget.controller.meetings;
          if (list.isEmpty) return const _Empty(text: 'No meetings booked');
          return Column(
            children: list.map((m) {
              final date = m['date'] as DateTime?;
              final label = date == null ? '-' : '${date.day}/${date.month}/${date.year}';
              return _Card(
                title: '${(m['teacher'] ?? '')} • ${(m['status'] ?? '')}',
                subtitle: (m['purpose'] ?? '').toString(),
                foot: '$label • ${(m['timeSlot'] ?? '')}',
                icon: Icons.groups_rounded,
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _ParentTeacherCommunicationSection extends StatefulWidget {
  const _ParentTeacherCommunicationSection({required this.controller});
  final CommunicationHubController controller;

  @override
  State<_ParentTeacherCommunicationSection> createState() => _ParentTeacherCommunicationSectionState();
}

class _ParentTeacherCommunicationSectionState extends State<_ParentTeacherCommunicationSection> {
  final _teacher = TextEditingController(text: 'Ms. Neha Shah');
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _teacher.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      children: [
        _Section(
          title: 'Parent-teacher communication',
          child: Column(
            children: [
              TextField(controller: _teacher, decoration: const InputDecoration(labelText: 'Teacher')),
              SizedBox(height: Responsive.h(context, 8)),
              TextField(controller: _subject, decoration: const InputDecoration(labelText: 'Subject line')),
              SizedBox(height: Responsive.h(context, 8)),
              TextField(
                controller: _message,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Message'),
              ),
              SizedBox(height: Responsive.h(context, 10)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_teacher.text.trim().isEmpty || _subject.text.trim().isEmpty || _message.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    widget.controller.sendParentMessage(
                      teacher: _teacher.text.trim(),
                      subject: _subject.text.trim(),
                      message: _message.text.trim(),
                    );
                    _subject.clear();
                    _message.clear();
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Send Message'),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.h(context, 12)),
        Obx(() {
          final chat = widget.controller.chatMessages;
          if (chat.isEmpty) return const _Empty(text: 'No conversation yet');
          return Column(
            children: chat.map((c) {
              final fromParent = c['fromParent'] == true;
              return Align(
                alignment: fromParent ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.78,
                  margin: EdgeInsets.only(bottom: Responsive.h(context, 10)),
                  padding: EdgeInsets.all(Responsive.w(context, 12)),
                  decoration: BoxDecoration(
                    color: fromParent ? AppColor.primary.withValues(alpha: 0.1) : AppColor.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (c['subject'] ?? '').toString(),
                        style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: Responsive.h(context, 4)),
                      Text((c['message'] ?? '').toString(), style: AppTextStyle.bodySmall(context)),
                      SizedBox(height: Responsive.h(context, 4)),
                      Text(
                        '${(fromParent ? 'You' : c['to'])} • ${(c['time'] ?? '')}',
                        style: AppTextStyle.caption(context),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 12)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: Responsive.h(context, 10)),
          child,
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.subtitle,
    required this.foot,
    required this.icon,
    this.highlight = false,
  });
  final String title;
  final String subtitle;
  final String foot;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 10)),
      padding: EdgeInsets.all(Responsive.w(context, 12)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? AppColor.primary.withValues(alpha: 0.5) : AppColor.borderLight,
          width: highlight ? 1.4 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColor.primary, size: Responsive.w(context, 20)),
          SizedBox(width: Responsive.w(context, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.w700)),
                SizedBox(height: Responsive.h(context, 4)),
                Text(subtitle, style: AppTextStyle.bodySmall(context)),
                SizedBox(height: Responsive.h(context, 4)),
                Text(foot, style: AppTextStyle.caption(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(context, 24)),
        child: Text(text, style: AppTextStyle.bodyMedium(context).copyWith(color: AppColor.textMuted)),
      ),
    );
  }
}

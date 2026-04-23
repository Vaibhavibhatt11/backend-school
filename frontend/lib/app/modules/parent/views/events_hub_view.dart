import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/fonts/common_textstyle.dart';
import '../../../../common/theme/app_color.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../widgets/app_scaffold.dart';
import '../controllers/events_hub_controller.dart';

class EventsHubView extends GetView<EventsHubController> {
  const EventsHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Events Center',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(context, 16),
              Responsive.h(context, 12),
              Responsive.w(context, 16),
              Responsive.h(context, 8),
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
              switch (controller.selectedTab.value) {
                case 'competition':
                  return _EventList(
                    title: 'Competitions',
                    items: controller.competitions,
                    controller: controller,
                  );
                case 'sports':
                  return _EventList(
                    title: 'Sports Activities',
                    items: controller.sportsActivities,
                    controller: controller,
                  );
                case 'registration':
                  return _RegistrationsList(controller: controller);
                case 'photos':
                  return _PhotosGrid(controller: controller);
                default:
                  return _EventList(
                    title: 'All Events',
                    items: controller.allEvents,
                    controller: controller,
                  );
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
            child: Icon(Icons.emoji_events_rounded, color: AppColor.base, size: Responsive.w(context, 24)),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Text(
              'All events, competitions, sports, registrations, and photos in one place.',
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
      ('all', 'All Events'),
      ('competition', 'Competitions'),
      ('sports', 'Sports Activities'),
      ('registration', 'Registrations'),
      ('photos', 'Event Photos'),
    ];
    return SizedBox(
      height: Responsive.h(context, 36),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(context, 8)),
        itemBuilder: (_, i) => Obx(() {
          final key = tabs[i].$1;
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
                tabs[i].$2,
                style: AppTextStyle.caption(context).copyWith(
                  color: active ? AppColor.base : AppColor.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({
    required this.title,
    required this.items,
    required this.controller,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final EventsHubController controller;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _Empty(text: 'No items in $title');
    return ListView(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      children: [
        Text(
          title,
          style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: Responsive.h(context, 10)),
        ...items.map((e) => _EventCard(item: e, controller: controller)),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.item, required this.controller});
  final Map<String, dynamic> item;
  final EventsHubController controller;

  @override
  Widget build(BuildContext context) {
    final id = (item['id'] ?? '').toString();
    final registered = controller.isRegistered(id);
    final date = item['date'] as DateTime?;
    final dateText = date == null ? '-' : '${date.day}/${date.month}/${date.year}';
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 10)),
      padding: EdgeInsets.all(Responsive.w(context, 12)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (item['title'] ?? '').toString(),
                  style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _typePill(context, (item['type'] ?? '').toString()),
            ],
          ),
          SizedBox(height: Responsive.h(context, 6)),
          Text((item['description'] ?? '').toString(), style: AppTextStyle.bodySmall(context)),
          SizedBox(height: Responsive.h(context, 6)),
          Text(
            'Venue: ${(item['venue'] ?? '')} • Date: $dateText',
            style: AppTextStyle.caption(context),
          ),
          SizedBox(height: Responsive.h(context, 10)),
          SizedBox(
            width: double.infinity,
            child: registered
                ? OutlinedButton(
                    onPressed: () => controller.cancelRegistration(id),
                    child: const Text('Cancel Registration'),
                  )
                : ElevatedButton(
                    onPressed: () => controller.registerForEvent(id),
                    child: const Text('Register Now'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _typePill(BuildContext context, String type) {
    final isSports = type == 'sports';
    final color = isSports ? AppColor.info : AppColor.orange;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 8),
        vertical: Responsive.h(context, 4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isSports ? 'SPORTS' : 'COMPETITION',
        style: AppTextStyle.caption(context).copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _RegistrationsList extends StatelessWidget {
  const _RegistrationsList({required this.controller});
  final EventsHubController controller;

  @override
  Widget build(BuildContext context) {
    final registrations = controller.registrations;
    if (registrations.isEmpty) {
      return const _Empty(text: 'No event registrations yet');
    }
    return ListView(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      children: [
        Text(
          'My Event Registrations',
          style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: Responsive.h(context, 10)),
        ...registrations.map((e) => _EventCard(item: e, controller: controller)),
      ],
    );
  }
}

class _PhotosGrid extends StatelessWidget {
  const _PhotosGrid({required this.controller});
  final EventsHubController controller;

  @override
  Widget build(BuildContext context) {
    final photos = controller.eventPhotos;
    if (photos.isEmpty) return const _Empty(text: 'No event photos available');
    return GridView.builder(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) {
        final p = photos[i];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.borderLight),
            gradient: LinearGradient(
              colors: [
                AppColor.primary.withValues(alpha: 0.2),
                AppColor.info.withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Center(
                    child: Icon(Icons.photo_library_rounded, size: 36, color: AppColor.primaryDark),
                  ),
                ),
                Text(
                  (p['title'] ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: Responsive.h(context, 2)),
                Text(
                  (p['event'] ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption(context),
                ),
              ],
            ),
          ),
        );
      },
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
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyle.bodyMedium(context).copyWith(color: AppColor.textMuted),
        ),
      ),
    );
  }
}

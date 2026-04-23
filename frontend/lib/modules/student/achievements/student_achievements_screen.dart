import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/section_header.dart';
import 'student_achievements_controller.dart';

class StudentAchievementsScreen extends GetView<StudentAchievementsController> {
  const StudentAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Achievements',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Academic achievements'),
            AppCard(child: Text('Grades, ranks, and academic awards.', style: AppTextStyle.bodySmall(context))),
            SectionHeader(title: 'Competition certificates'),
            AppCard(child: Text('Certificates from competitions.', style: AppTextStyle.bodySmall(context))),
            SectionHeader(title: 'Activity records'),
            AppCard(child: Text('Clubs, sports, and activities.', style: AppTextStyle.bodySmall(context))),
            SectionHeader(title: 'Digital certificates'),
            AppCard(child: Text('Download and share certificates.', style: AppTextStyle.bodySmall(context))),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }
}

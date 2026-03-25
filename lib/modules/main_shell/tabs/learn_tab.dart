import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../common/routes/common_routes_screens.dart';
import '../../../widgets/module_tile.dart';

class LearnTab extends StatelessWidget {
  const LearnTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.authBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(context, 20),
                  Responsive.h(context, 20),
                  Responsive.w(context, 20),
                  Responsive.h(context, 8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Learn', style: AppTextStyle.headlineLarge(context)),
                    SizedBox(height: Responsive.h(context, 4)),
                    Text(
                      'Timetable, homework, materials & exams',
                      style: AppTextStyle.bodySmall(context),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
                child: Column(
                  children: [
                    ModuleTile(
                      title: 'Timetable',
                      subtitle: 'Monthly schedule & exam dates',
                      icon: Icons.calendar_month_rounded,
                      onTap: () => Get.toNamed(CommonScreenRoutes.studentTimetable),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    ModuleTile(
                      title: 'Homework',
                      subtitle: 'Assignments & submissions',
                      icon: Icons.assignment_rounded,
                      onTap: () => Get.toNamed(CommonScreenRoutes.studentHomework),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    ModuleTile(
                      title: 'Study Materials',
                      subtitle: 'Notes, PDFs & video classes',
                      icon: Icons.menu_book_rounded,
                      onTap: () => Get.toNamed(CommonScreenRoutes.studentStudyMaterials),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    ModuleTile(
                      title: 'Exams',
                      subtitle: 'Schedule, results & report cards',
                      icon: Icons.quiz_rounded,
                      onTap: () => Get.toNamed(CommonScreenRoutes.studentExams),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    // AI options commented for now
                    // ModuleTile(
                    //   title: 'AI Study Assistant',
                    //   subtitle: 'Explain, summarize & practice',
                    //   icon: Icons.smart_toy_rounded,
                    //   onTap: () => Get.toNamed(CommonScreenRoutes.studentAiStudyAssistant),
                    // ),
                    // SizedBox(height: Responsive.h(context, 10)),
                    // ModuleTile(
                    //   title: 'AI Career Advisor',
                    //   subtitle: 'Career guidance & suggestions',
                    //   icon: Icons.work_rounded,
                    //   onTap: () => Get.toNamed(CommonScreenRoutes.studentAiCareerAdvisor),
                    // ),
                    SizedBox(height: Responsive.h(context, 24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

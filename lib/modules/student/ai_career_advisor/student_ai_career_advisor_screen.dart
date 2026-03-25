import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_card.dart';
import 'student_ai_career_advisor_controller.dart';

class StudentAiCareerAdvisorScreen extends GetView<StudentAiCareerAdvisorController> {
  const StudentAiCareerAdvisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'AI Career Advisor',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get career guidance and course recommendations based on your interests and strengths.',
              style: AppTextStyle.bodySmall(context),
            ),
            SizedBox(height: Responsive.h(context, 24)),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Career assessment', style: AppTextStyle.titleMedium(context)),
                  SizedBox(height: Responsive.h(context, 8)),
                  Text('Answer a few questions to get personalized career suggestions.', style: AppTextStyle.bodySmall(context)),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }
}

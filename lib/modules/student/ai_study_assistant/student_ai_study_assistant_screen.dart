import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/section_header.dart';
import '../components/student_module_action.dart';
import 'student_ai_study_assistant_controller.dart';

class StudentAiStudyAssistantScreen extends GetView<StudentAiStudyAssistantController> {
  const StudentAiStudyAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'AI Study Assistant',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ask AI: explain problems, summarize chapters, solve doubts, create quizzes, and prepare for exams.',
              style: AppTextStyle.bodySmall(context),
            ),
            SizedBox(height: Responsive.h(context, 16)),
            SectionHeader(title: 'Quick actions'),
            StudentModuleAction(title: 'Explain math problem', icon: Icons.calculate_rounded, onTap: controller.askExplain),
            StudentModuleAction(title: 'Summarize chapter', icon: Icons.summarize_rounded, onTap: controller.askSummarize),
            StudentModuleAction(title: 'Solve doubts', icon: Icons.help_rounded, onTap: controller.askDoubts),
            StudentModuleAction(title: 'Create quiz / paper', icon: Icons.quiz_rounded, onTap: controller.createQuiz),
            StudentModuleAction(title: 'AI exam preparation', icon: Icons.school_rounded, onTap: controller.examPrep),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }
}

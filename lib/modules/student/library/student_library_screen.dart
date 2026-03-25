import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/section_header.dart';
import 'student_library_controller.dart';

class StudentLibraryScreen extends GetView<StudentLibraryController> {
  const StudentLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Library',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Books issued'),
            Obx(() => AppCard(
                  child: Text(
                    'Currently issued: ${controller.booksIssued.value}',
                    style: AppTextStyle.bodyMedium(context),
                  ),
                )),
            SectionHeader(title: 'Browse & issue'),
            AppCard(child: Text('Search books and issue/return.', style: AppTextStyle.bodySmall(context))),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }
}

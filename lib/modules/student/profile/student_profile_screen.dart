import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/utils/responsive.dart';
import '../../../common/routes/common_routes_screens.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/module_tile.dart';
import 'student_profile_controller.dart';

class StudentProfileScreen extends GetView<StudentProfileController> {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile',
      showProfileIcon: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal details, parent info, class, ID card, academic records, medical info, and documents.',
              style: AppTextStyle.bodySmall(context),
            ),
            SizedBox(height: Responsive.h(context, 16)),
            ModuleTile(
              title: 'Personal details',
              icon: Icons.person_outline_rounded,
              onTap: () => Get.toNamed(CommonScreenRoutes.profilePersonalDetails),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            ModuleTile(
              title: 'Parent details',
              icon: Icons.family_restroom_rounded,
              onTap: () => Get.toNamed(CommonScreenRoutes.profileParentDetails),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            ModuleTile(
              title: 'Class & section',
              icon: Icons.class_rounded,
              onTap: () => Get.toNamed(CommonScreenRoutes.profileClassSection),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            // ID card section commented for now
            // ModuleTile(
            //   title: 'Student ID card',
            //   icon: Icons.badge_rounded,
            //   onTap: () => Get.toNamed(CommonScreenRoutes.profileIdCard),
            // ),
            // SizedBox(height: Responsive.h(context, 8)),
            ModuleTile(
              title: 'Academic records',
              icon: Icons.school_rounded,
              onTap: () => Get.toNamed(CommonScreenRoutes.profileAcademicRecords),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            ModuleTile(
              title: 'Medical information',
              icon: Icons.medical_information_rounded,
              onTap: () => Get.toNamed(CommonScreenRoutes.profileMedical),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            ModuleTile(
              title: 'Documents storage',
              icon: Icons.folder_rounded,
              onTap: () => Get.toNamed(CommonScreenRoutes.profileDocuments),
            ),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }
}

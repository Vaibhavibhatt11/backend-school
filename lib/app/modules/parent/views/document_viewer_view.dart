import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/document_viewer_controller.dart';

class DocumentViewerView extends GetView<DocumentViewerController> {
  const DocumentViewerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_new),
        //   onPressed: () => Get.back(),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: controller.print,
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: controller.share,
          ),
        ],
      ),
      body: Column(
        children: [
          // Document title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.documentTitle.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    '${controller.studentName.value} • ${controller.studentClass.value}',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Center(
                child: Image.network(
                  'https://via.placeholder.com/400x500',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Page controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: controller.prevPage,
                ),
                Obx(
                  () => Text(
                    'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: controller.nextPage,
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: controller.download,
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ParentBottomNavBar(currentIndex: 4), // Profile
    );
  }
}

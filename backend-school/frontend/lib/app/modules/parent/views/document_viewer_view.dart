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
              child: Obx(() {
                final url = controller.previewUrl.value.trim();
                if (url.isNotEmpty &&
                    (url.startsWith('https://') || url.startsWith('http://'))) {
                  return Center(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _docPlaceholder(),
                    ),
                  );
                }
                return _docPlaceholder();
              }),
            ),
          ),
          // Page controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: controller.prevPage,
                ),
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.documents.isEmpty
                          ? 'No documents'
                          : 'Document ${controller.selectedIndex.value + 1} of ${controller.documents.length}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: controller.nextPage,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ElevatedButton.icon(
                      onPressed: controller.download,
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
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

  Widget _docPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 80,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 12),
            Text(
              'Preview appears when the API includes a document URL (url / fileUrl / previewUrl).',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

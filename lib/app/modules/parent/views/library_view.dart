import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../navbar/parent_bottom_nav_bar.dart';
import '../controllers/library_controller.dart';

class LibraryView extends GetView<LibraryController> {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'School Library',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.PARENT_NOTIFICATIONS),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: controller.search,
                    decoration: InputDecoration(
                      hintText: 'Search books, authors...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.surfaceDark : Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [_buildTab('Browse', 0), _buildTab('My History', 1)],
              ),
            ),
            const SizedBox(height: 24),
            // Recommended
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recommended',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('See All')),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: Obx(
                () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.recommendedBooks.length,
                  itemBuilder: (context, index) {
                    final book = controller.recommendedBooks[index];
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                book['new'] as bool
                                    ? const Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: AppColors.primary,
                                          child: Text(
                                            'New',
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book['title']! as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            book['author']! as String,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Categories
            const Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2,
              children: [
                _buildCategoryCard(Icons.science, 'Science'),
                _buildCategoryCard(Icons.menu_book, 'Literature'),
                _buildCategoryCard(Icons.history_edu, 'History'),
                _buildCategoryCard(Icons.calculate, 'Math'),
              ],
            ),
            const SizedBox(height: 24),
            // Active Loans
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Loans',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Text(
                      '${controller.activeLoans.length} Active',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(
              () => Column(
                children:
                    controller.activeLoans.map((loan) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 60,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loan['title']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    loan['author']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        loan['due']!,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              loan['status'] == 'On Time'
                                                  ? Colors.green.withOpacity(
                                                    0.1,
                                                  )
                                                  : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          loan['status']!,
                                          style: TextStyle(
                                            fontSize: 8,
                                            color:
                                                loan['status'] == 'On Time'
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavBar(
        currentIndex: 0,
      ), // Library from profile or home
      floatingActionButton: FloatingActionButton(
        onPressed: controller.scanQR,
        child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTab(String label, int index) {
    return Expanded(
      child: Obx(
        () => GestureDetector(
          onTap: () => controller.selectedTab.value = index,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color:
                  controller.selectedTab.value == index
                      ? (Theme.of(Get.context!).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : Colors.white)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    controller.selectedTab.value == index
                        ? AppColors.primary
                        : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 30),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

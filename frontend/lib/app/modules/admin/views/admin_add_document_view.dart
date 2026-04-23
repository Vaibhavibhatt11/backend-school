import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_admissions_controller.dart';

class AdminAddDocumentView extends StatelessWidget {
  final AdminAdmissionApplication item;
  
  const AdminAddDocumentView({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminAdmissionsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final typeController = TextEditingController(text: 'document');

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Add Document', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application: ${item.applicationNo.isEmpty ? item.fullName : item.applicationNo}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Document Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Document URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link_rounded),
                hintText: 'https://...',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final url = urlController.text.trim();
                  final type = typeController.text.trim();
                  
                  if (name.isEmpty || url.isEmpty) {
                    Get.snackbar('Error', 'Document name and URL are required.',
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }

                  await controller.submitDocument(
                    id: item.id,
                    name: name,
                    url: url,
                    type: type,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

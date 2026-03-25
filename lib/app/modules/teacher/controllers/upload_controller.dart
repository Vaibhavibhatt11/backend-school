import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:get/get.dart';

class UploadController extends GetxController {
  final selectedClass = 'Grade 10-A'.obs;
  final selectedSubject = 'Mathematics'.obs;
  final uploadProgress = 0.0.obs;
  final isUploading = false.obs;
  final uploadHistory = <UploadHistoryItem>[].obs;

  final classes = ['Grade 10-A', 'Grade 10-B', 'Grade 11-C', 'Grade 12-A'];
  final subjects = ['Mathematics', 'Physics', 'Chemistry', 'English'];

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  void _loadHistory() {
    uploadHistory.assignAll([
      UploadHistoryItem(
        id: '1',
        fileName: 'Algebra_Quiz_Oct.pdf',
        fileType: 'pdf',
        targetClass: 'Grade 10-A',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      UploadHistoryItem(
        id: '2',
        fileName: 'Geometry_Ref_Sheet.png',
        fileType: 'image',
        targetClass: 'Grade 10-B',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UploadHistoryItem(
        id: '3',
        fileName: 'Linear_Equations_Final.pdf',
        fileType: 'pdf',
        targetClass: 'Grade 9-C',
        uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }

  void pickFile() async {
    // Simulate file picking
    isUploading.value = true;
    uploadProgress.value = 0.0;
    // Simulate progress
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      uploadProgress.value = i / 10;
    }
    isUploading.value = false;
    // Add to history
    uploadHistory.insert(
      0,
      UploadHistoryItem(
        id: DateTime.now().toString(),
        fileName: 'Calculus_Homework_V2.pdf',
        fileType: 'pdf',
        targetClass: selectedClass.value,
        uploadedAt: DateTime.now(),
      ),
    );
  }
}

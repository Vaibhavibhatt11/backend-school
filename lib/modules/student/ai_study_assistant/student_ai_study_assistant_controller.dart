import 'package:get/get.dart';

class StudentAiStudyAssistantController extends GetxController {
  final RxString query = ''.obs;
  final RxBool loading = false.obs;

  void setQuery(String q) => query.value = q;
  void askExplain() => loading.value = true;
  void askSummarize() => loading.value = true;
  void askDoubts() => loading.value = true;
  void createQuiz() => loading.value = true;
  void examPrep() => loading.value = true;
}

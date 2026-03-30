import 'package:get/get.dart';
import 'models/exam_models.dart';

class StudentExamsController extends GetxController {
  final RxList<UpcomingExam> upcomingExams = <UpcomingExam>[].obs;
  final RxList<PastExam> pastExams = <PastExam>[].obs;

  @override
  void onInit() {
    super.onInit();
    upcomingExams.clear();
    pastExams.clear();
  }
}

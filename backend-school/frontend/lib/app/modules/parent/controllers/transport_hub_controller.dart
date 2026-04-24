import 'package:get/get.dart';

class TransportHubController extends GetxController {
  final selectedTab = 'tracking'.obs;
  final busPosition = 0.35.obs;
  final pickupAlertEnabled = true.obs;
  final nextPickupEta = '08:05 AM'.obs;

  final routeStops = <String>[
    'School Campus',
    'Green Park',
    'City Mall',
    'River View Society',
    'Sunrise Apartments',
  ].obs;

  final driver = <String, String>{
    'name': 'Ramesh Patel',
    'contact': '+91 98765 43210',
    'vehicle': 'GJ-01-AB-4321',
    'assistant': 'Suresh Kumar',
  }.obs;

  void changeTab(String tab) => selectedTab.value = tab;

  void updateTracking() {
    final next = busPosition.value + 0.08;
    busPosition.value = next > 1 ? 0.12 : next;
  }

  void togglePickupAlert(bool value) => pickupAlertEnabled.value = value;
}

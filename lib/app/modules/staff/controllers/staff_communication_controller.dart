import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffCommunicationController extends GetxController {
  StaffCommunicationController(this._staffService);

  final StaffService _staffService;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final chats = <Map<String, String>>[].obs;
  final announcements = <String>[].obs;
  final meetings = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCommunication();
  }

  Future<void> loadCommunication() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _staffService.getCommunication();
      final rawChats = data['chats'];
      if (rawChats is List) {
        chats.assignAll(
          rawChats.whereType<Map>().map((e) {
            return {
              'to': (e['to'] ?? '').toString(),
              'last': (e['last'] ?? '').toString(),
            };
          }).toList(),
        );
      } else {
        chats.clear();
      }

      final rawAnnouncements = data['announcements'];
      if (rawAnnouncements is List) {
        announcements.assignAll(rawAnnouncements.map((e) => e.toString()));
      } else {
        announcements.clear();
      }

      final rawMeetings = data['meetings'];
      if (rawMeetings is List) {
        meetings.assignAll(
          rawMeetings.whereType<Map>().map((e) {
            return {
              'title': (e['title'] ?? '').toString(),
              'time': (e['time'] ?? '').toString(),
            };
          }).toList(),
        );
      } else {
        meetings.clear();
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
      chats.clear();
      announcements.clear();
      meetings.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final toController = TextEditingController();
    final messageController = TextEditingController();
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Send Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: toController,
              decoration: const InputDecoration(labelText: 'To'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Send')),
        ],
      ),
    );
    if (result != true) return;
    try {
      await _staffService.sendMessage(
        to: toController.text.trim(),
        message: messageController.text.trim(),
      );
      await loadCommunication();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> addMeetingNote() async {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Save Meeting Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Save')),
        ],
      ),
    );
    if (result != true) return;
    try {
      await _staffService.saveMeetingNote(
        title: titleController.text.trim(),
        note: noteController.text.trim(),
      );
      await loadCommunication();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }
}


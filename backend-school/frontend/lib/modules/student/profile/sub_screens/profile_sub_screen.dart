import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../common/theme/app_color.dart';
import '../../../../common/fonts/common_textstyle.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../common/services/parent/parent_profile_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/session_storage_service.dart';
import '../../../../common/api/api_client.dart';
import '../../../../common/api/api_endpoints.dart';
import '../../../../common/services/parent/parent_api_utils.dart';

class ProfileSubScreen extends StatefulWidget {
  const ProfileSubScreen({super.key, required this.title});
  final String title;

  @override
  State<ProfileSubScreen> createState() => _ProfileSubScreenState();
}

class _ProfileSubScreenState extends State<ProfileSubScreen> {
  final ParentProfileService? _parentProfileService =
      Get.isRegistered<ParentProfileService>() ? Get.find<ParentProfileService>() : null;
  final ParentContextService? _parentContext =
      Get.isRegistered<ParentContextService>() ? Get.find<ParentContextService>() : null;
  final SessionStorageService _sessionStorage = Get.find<SessionStorageService>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic> _data = <String, dynamic>{};
  List<Map<String, dynamic>> _documents = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final loginResponse = await _sessionStorage.getLoginResponse();
      final role = (loginResponse?['data']?['user']?['role'] ?? '').toString().toUpperCase();

      Map<String, dynamic> payload;
      if (role == 'PARENT' && _parentProfileService != null) {
        payload = await _parentProfileService.getProfileHub(
          childId: _parentContext?.selectedChildId.value,
        );
      } else {
        final res = await _apiClient.get(ApiEndpoints.authMe);
        payload = extractApiData(res.data, context: 'auth me');
      }

      final rawDocs = payload['documents'];
      final docs = <Map<String, dynamic>>[];
      if (rawDocs is List) {
        for (final item in rawDocs.whereType<Map>()) {
          final m = Map<String, dynamic>.from(item);
          docs.add({
            ...m,
            'name': (m['name'] ?? 'Document').toString(),
            'url': (m['url'] ?? m['fileUrl'] ?? m['previewUrl'] ?? '').toString().trim(),
            'status': (m['status'] ?? 'AVAILABLE').toString(),
          });
        }
      }

      if (!mounted) return;
      setState(() {
        _data = payload;
        _documents = docs;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = dioOrApiErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _v(List<String> keys) {
    for (final k in keys) {
      final value = _data[k];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString().trim();
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.title.toLowerCase();
    return AppScaffold(
      title: widget.title,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.w(context, 16)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error, textAlign: TextAlign.center),
                        SizedBox(height: Responsive.h(context, 10)),
                        ElevatedButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.all(Responsive.w(context, 16)),
                    children: [
                      _header(context, widget.title),
                      SizedBox(height: Responsive.h(context, 12)),
                      if (section.contains('personal')) ..._buildPersonal(context),
                      if (section.contains('parent')) ..._buildParent(context),
                      if (section.contains('class') || section.contains('section')) ..._buildClassSection(context),
                      if (section.contains('id card')) ..._buildIdCard(context),
                      if (section.contains('academic')) ..._buildAcademic(context),
                      if (section.contains('medical')) ..._buildMedical(context),
                      if (section.contains('documents')) ..._buildDocuments(context),
                    ],
                  ),
                ),
    );
  }

  Widget _header(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primaryDark.withValues(alpha: 0.9)],
        ),
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
      ),
      child: Text(
        title,
        style: AppTextStyle.titleLarge(context).copyWith(
          color: AppColor.base,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  List<Widget> _buildPersonal(BuildContext context) => [
        _card(context, 'Student Details', [
          _kv('Full Name', _v(['studentName', 'fullName', 'name'])),
          _kv('Admission No.', _v(['admissionNo', 'admissionNumber'])),
          _kv('Date of Birth', _v(['dob', 'dateOfBirth'])),
          _kv('Gender', _v(['gender'])),
          _kv('Phone', _v(['phone', 'studentPhone'])),
          _kv('Email', _v(['email', 'studentEmail'])),
          _kv('Address', _v(['address', 'addressLine1'])),
        ]),
      ];

  List<Widget> _buildParent(BuildContext context) => [
        _card(context, 'Parent / Guardian', [
          _kv('Father Name', _v(['fatherName', 'fatherFullName'])),
          _kv('Father Phone', _v(['fatherPhone', 'fatherMobile'])),
          _kv('Father Email', _v(['fatherEmail'])),
          _kv('Mother Name', _v(['motherName', 'motherFullName'])),
          _kv('Mother Phone', _v(['motherPhone', 'motherMobile'])),
          _kv('Mother Email', _v(['motherEmail'])),
          _kv('Guardian Name', _v(['guardianName'])),
          _kv('Guardian Phone', _v(['guardianPhone', 'emergencyContact'])),
        ]),
      ];

  List<Widget> _buildClassSection(BuildContext context) => [
        _card(context, 'Class & Section', [
          _kv('Class', _v(['studentClass', 'className'])),
          _kv('Section', _v(['section', 'studentSection'])),
          _kv('Roll No.', _v(['rollNo', 'rollNumber'])),
          _kv('Academic Year', _v(['academicYear'])),
          _kv('Class Teacher', _v(['classTeacher', 'teacherName'])),
        ]),
      ];

  List<Widget> _buildIdCard(BuildContext context) => [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Responsive.w(context, 14)),
          decoration: BoxDecoration(
            color: AppColor.base,
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Student ID Card', style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: Responsive.h(context, 8)),
              _line('Name', _v(['studentName', 'fullName', 'name'])),
              _line('Student ID', _v(['studentId', 'id', 'admissionNo'])),
              _line('Class', _v(['studentClass', 'className'])),
              _line('Academic Year', _v(['academicYear'])),
            ],
          ),
        ),
      ];

  List<Widget> _buildAcademic(BuildContext context) => [
        _card(context, 'Academic Records', [
          _kv('Current Grade', _v(['currentTermGrade', 'grade'])),
          _kv('Current Percentage', '${_v(['currentTermPercentage'])}%'),
          _kv('Class Average', '${_v(['classAvg'])}%'),
          _kv('Attendance', '${_v(['attendance'])}%'),
        ]),
      ];

  List<Widget> _buildMedical(BuildContext context) => [
        _card(context, 'Medical Information', [
          _kv('Blood Group', _v(['bloodGroup'])),
          _kv('Allergies', _v(['allergies', 'allergy'])),
          _kv('Medical Conditions', _v(['medicalConditions', 'chronicCondition'])),
          _kv('Emergency Contact', _v(['emergencyContact', 'guardianPhone'])),
          _kv('Preferred Hospital', _v(['preferredHospital'])),
        ]),
      ];

  List<Widget> _buildDocuments(BuildContext context) => [
        Container(
          padding: EdgeInsets.all(Responsive.w(context, 14)),
          decoration: BoxDecoration(
            color: AppColor.base,
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Documents Storage', style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: Responsive.h(context, 10)),
              if (_documents.isEmpty)
                Text('No documents available yet.', style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary))
              else
                ..._documents.map((doc) {
                  final name = (doc['name'] ?? 'Document').toString();
                  final status = (doc['status'] ?? '').toString();
                  final url = (doc['url'] ?? '').toString();
                  return Container(
                    margin: EdgeInsets.only(bottom: Responsive.h(context, 8)),
                    decoration: BoxDecoration(
                      color: AppColor.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColor.border.withValues(alpha: 0.7)),
                    ),
                    child: ListTile(
                      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(status),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new_rounded),
                        onPressed: url.isEmpty ? null : () => _openUrl(url),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ];

  Widget _card(BuildContext context, String title, List<MapEntry<String, String>> rows) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 10)),
      padding: EdgeInsets.all(Responsive.w(context, 14)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: Responsive.h(context, 8)),
          ...rows.map((e) => _line(e.key, e.value)),
        ],
      ),
    );
  }

  MapEntry<String, String> _kv(String label, String value) => MapEntry(label, value);

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

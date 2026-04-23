import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_profile_service.dart';
import '../../../../common/services/parent/parent_api_utils.dart';

class PersonalInformationView extends StatefulWidget {
  const PersonalInformationView({super.key});

  @override
  State<PersonalInformationView> createState() => _PersonalInformationViewState();
}

class _PersonalInformationViewState extends State<PersonalInformationView> {
  final ParentProfileService _profileService = Get.find<ParentProfileService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic> _data = <String, dynamic>{};

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
      final data = await _profileService.getProfileHub(
        childId: _parentContext.selectedChildId.value,
      );
      if (!mounted) return;
      setState(() => _data = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = dioOrApiErrorMessage(e));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _value(List<String> keys) {
    for (final key in keys) {
      final v = _data[key];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(title: 'Personal Information', showBack: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _section(
                        isDark: isDark,
                        title: 'Student Details',
                        rows: [
                          _row('Student Name', _value(['studentName', 'fullName', 'name'])),
                          _row('Admission Number', _value(['admissionNo', 'admissionNumber'])),
                          _row('Student ID', _value(['studentId', 'id'])),
                          _row('Class & Section', _value(['studentClass', 'classSection', 'className'])),
                          _row('Academic Year', _value(['academicYear'])),
                          _row('Date of Birth', _value(['dob', 'dateOfBirth'])),
                          _row('Gender', _value(['gender'])),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _section(
                        isDark: isDark,
                        title: 'Health Information',
                        rows: [
                          _row('Blood Group', _value(['bloodGroup'])),
                          _row('Allergies', _value(['allergies', 'allergy'])),
                          _row('Medical Conditions', _value(['medicalConditions', 'chronicCondition'])),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _section(
                        isDark: isDark,
                        title: 'Address',
                        rows: [
                          _row('Address Line 1', _value(['addressLine1', 'address'])),
                          _row('Address Line 2', _value(['addressLine2'])),
                          _row('City', _value(['city'])),
                          _row('State', _value(['state'])),
                          _row('Country', _value(['country'])),
                          _row('Pincode', _value(['pincode', 'postalCode', 'zipCode'])),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _section(
                        isDark: isDark,
                        title: 'Parent / Guardian',
                        rows: [
                          _row('Father Name', _value(['fatherName', 'fatherFullName'])),
                          _row('Father Phone', _value(['fatherPhone', 'fatherMobile'])),
                          _row('Father Email', _value(['fatherEmail'])),
                          _row('Mother Name', _value(['motherName', 'motherFullName'])),
                          _row('Mother Phone', _value(['motherPhone', 'motherMobile'])),
                          _row('Mother Email', _value(['motherEmail'])),
                          _row('Guardian Name', _value(['guardianName'])),
                          _row('Guardian Phone', _value(['guardianPhone'])),
                          _row('Emergency Contact', _value(['emergencyContact'])),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _section({
    required bool isDark,
    required String title,
    required List<Widget> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

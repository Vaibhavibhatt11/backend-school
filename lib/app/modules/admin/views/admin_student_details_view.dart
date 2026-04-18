import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_students_controller.dart';

class AdminStudentDetailsView extends StatelessWidget {
  final AdminStudentRecord student;
  final Map<String, dynamic> rawData;

  const AdminStudentDetailsView({
    super.key,
    required this.student,
    required this.rawData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Extracted data from rawData or student object
    final admissionNo = rawData['admissionNo']?.toString() ?? student.admissionNo;
    final middleName = rawData['middleName']?.toString() ?? '';
    final className = rawData['className']?.toString() ?? student.className;
    final section = rawData['section']?.toString() ?? student.section;
    final status = rawData['status']?.toString() ?? student.status;
    final gender = rawData['gender']?.toString() ?? student.gender;
    final guardianPhone = rawData['guardianPhone']?.toString() ?? student.guardianPhone;
    final dob = rawData['dob']?.toString() ?? '';
    final createdAt = rawData['createdAt']?.toString() ?? '';
    final rollNo = rawData['rollNo']?.toString() ?? student.rollNo?.toString() ?? '';

    // Parent Details
    final fatherName = rawData['fatherName']?.toString() ?? '';
    final motherName = rawData['motherName']?.toString() ?? '';
    final fatherOccupation = rawData['fatherOccupation']?.toString() ?? '';
    final motherOccupation = rawData['motherOccupation']?.toString() ?? '';
    final fatherDob = rawData['fatherDob']?.toString() ?? '';
    final motherDob = rawData['motherDob']?.toString() ?? '';

    // Contact & Address
    final contact1 = rawData['contact1']?.toString() ?? '';
    final contact2 = rawData['contact2']?.toString() ?? '';
    final address = rawData['address']?.toString() ?? '';
    final permanentAddress = rawData['permanentAddress']?.toString() ?? '';
    final telephone = rawData['telephone']?.toString() ?? '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${student.firstName} ${middleName.isNotEmpty ? "$middleName " : ""}${student.lastName}'.trim(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Hero(
                      tag: 'student_avatar_${student.id}',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white24,
                          backgroundImage: student.profilePicUrl != null
                              ? NetworkImage(student.profilePicUrl!)
                              : null,
                          child: student.profilePicUrl == null
                              ? Text(
                                  student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    'Academic Status',
                    [
                      _buildInfoRow(Icons.school_rounded, 'Class', section.isEmpty ? className : '$className - $section'),
                      _buildInfoRow(Icons.badge_rounded, 'Admission No', admissionNo),
                      if (rollNo.isNotEmpty)
                        _buildInfoRow(Icons.format_list_numbered_rounded, 'Roll Number', rollNo),
                      _buildInfoRow(
                        Icons.circle,
                        'Status',
                        status,
                        valueColor: status == 'ACTIVE' ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Personal Details',
                    [
                      _buildInfoRow(Icons.person_rounded, 'First Name', student.firstName),
                      if (middleName.isNotEmpty)
                        _buildInfoRow(Icons.person_outline_rounded, 'Middle Name', middleName),
                      _buildInfoRow(Icons.person_rounded, 'Last Name', student.lastName),
                      if (gender.isNotEmpty)
                        _buildInfoRow(Icons.wc_rounded, 'Gender', gender),
                      if (dob.isNotEmpty)
                        _buildInfoRow(Icons.cake_rounded, 'Date of Birth', dob.length > 10 ? dob.substring(0, 10) : dob),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Parent Details',
                    [
                      if (fatherName.isNotEmpty)
                        _buildInfoRow(Icons.man_rounded, 'Father\'s Name', fatherName),
                      if (fatherOccupation.isNotEmpty)
                        _buildInfoRow(Icons.work_rounded, 'Father\'s Occupation', fatherOccupation),
                      if (fatherDob.isNotEmpty)
                        _buildInfoRow(Icons.cake_rounded, 'Father\'s DOB', fatherDob.length > 10 ? fatherDob.substring(0, 10) : fatherDob),
                      const Divider(height: 1, indent: 50),
                      if (motherName.isNotEmpty)
                        _buildInfoRow(Icons.woman_rounded, 'Mother\'s Name', motherName),
                      if (motherOccupation.isNotEmpty)
                        _buildInfoRow(Icons.work_rounded, 'Mother\'s Occupation', motherOccupation),
                      if (motherDob.isNotEmpty)
                        _buildInfoRow(Icons.cake_rounded, 'Mother\'s DOB', motherDob.length > 10 ? motherDob.substring(0, 10) : motherDob),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Contact Information',
                    [
                      if (contact1.isNotEmpty)
                        _buildInfoRow(Icons.phone_rounded, 'Contact No. 1', contact1),
                      if (contact2.isNotEmpty)
                        _buildInfoRow(Icons.phone_iphone_rounded, 'Contact No. 2', contact2),
                      if (telephone.isNotEmpty)
                        _buildInfoRow(Icons.call_rounded, 'Telephone', telephone),
                      if (guardianPhone.isNotEmpty && guardianPhone != contact1)
                        _buildInfoRow(Icons.contact_phone_rounded, 'Guardian Phone', guardianPhone),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Address Details',
                    [
                      if (address.isNotEmpty)
                        _buildInfoRow(Icons.home_rounded, 'Current Address', address),
                      if (permanentAddress.isNotEmpty)
                        _buildInfoRow(Icons.location_on_rounded, 'Permanent Address', permanentAddress),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'System Info',
                    [
                      if (createdAt.isNotEmpty)
                        _buildInfoRow(Icons.event_available_rounded, 'Enrolled Since', createdAt.length > 10 ? createdAt.substring(0, 10) : createdAt),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

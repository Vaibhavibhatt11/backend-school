import 'package:flutter/material.dart';
import '../../../../common/fonts/common_textstyle.dart';
import '../../../../common/theme/app_color.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../widgets/app_scaffold.dart';

class ProfileSubScreen extends StatelessWidget {
  const ProfileSubScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final data = _sectionData(title);
    return AppScaffold(
      title: title,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          return SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderCard(
                      icon: data.icon,
                      title: data.displayTitle,
                      subtitle: data.subtitle,
                    ),
                    SizedBox(height: Responsive.h(context, 16)),
                    Wrap(
                      spacing: Responsive.w(context, 12),
                      runSpacing: Responsive.h(context, 12),
                      children: data.infoCards.map((c) {
                        final cardWidth = isWide
                            ? (constraints.maxWidth > 900 ? 430.0 : (constraints.maxWidth - 56) / 2)
                            : constraints.maxWidth;
                        return SizedBox(
                          width: cardWidth,
                          child: _InfoCard(
                            title: c.title,
                            rows: c.rows,
                            accentColor: c.accentColor,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: Responsive.h(context, 20)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primary,
            AppColor.primaryDark.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 10)),
            decoration: BoxDecoration(
              color: AppColor.base.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
            ),
            child: Icon(icon, color: AppColor.base, size: Responsive.w(context, 24)),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.titleLarge(context).copyWith(
                    color: AppColor.base,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(
                  subtitle,
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: AppColor.base.withValues(alpha: 0.9),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.rows,
    required this.accentColor,
  });

  final String title;
  final List<_InfoRowData> rows;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 14)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: Responsive.h(context, 18),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: Responsive.w(context, 8)),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.titleSmall(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 10)),
          ...rows.map((r) => _InfoRow(label: r.label, value: r.value)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(context, 8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Responsive.w(context, 120),
            child: Text(
              label,
              style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColor.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionData {
  const _SectionData({
    required this.displayTitle,
    required this.subtitle,
    required this.icon,
    required this.infoCards,
  });

  final String displayTitle;
  final String subtitle;
  final IconData icon;
  final List<_InfoCardData> infoCards;
}

class _InfoCardData {
  const _InfoCardData({
    required this.title,
    required this.rows,
    required this.accentColor,
  });

  final String title;
  final List<_InfoRowData> rows;
  final Color accentColor;
}

class _InfoRowData {
  const _InfoRowData({required this.label, required this.value});

  final String label;
  final String value;
}

_SectionData _sectionData(String title) {
  final t = title.toLowerCase();
  if (t.contains('personal')) {
    return _SectionData(
      displayTitle: 'Personal Details',
      subtitle: 'Basic profile and contact information',
      icon: Icons.person_outline_rounded,
      infoCards: const [
        _InfoCardData(
          title: 'Student Profile',
          accentColor: AppColor.primary,
          rows: [
            _InfoRowData(label: 'Full Name', value: 'Aarav Patel'),
            _InfoRowData(label: 'Admission No.', value: 'ADM-2024-017'),
            _InfoRowData(label: 'Date of Birth', value: '14 Aug 2011'),
            _InfoRowData(label: 'Gender', value: 'Male'),
          ],
        ),
        _InfoCardData(
          title: 'Contact',
          accentColor: AppColor.info,
          rows: [
            _InfoRowData(label: 'Phone', value: '+91 98765 43210'),
            _InfoRowData(label: 'Email', value: 'aarav.patel@student.school.com'),
            _InfoRowData(label: 'Address', value: 'Bopal, Ahmedabad, Gujarat'),
          ],
        ),
      ],
    );
  }
  if (t.contains('parent')) {
    return _SectionData(
      displayTitle: 'Parents Details',
      subtitle: 'Guardian and emergency contact information',
      icon: Icons.family_restroom_rounded,
      infoCards: const [
        _InfoCardData(
          title: 'Father',
          accentColor: AppColor.primary,
          rows: [
            _InfoRowData(label: 'Name', value: 'Rakesh Patel'),
            _InfoRowData(label: 'Occupation', value: 'Business'),
            _InfoRowData(label: 'Phone', value: '+91 98111 22233'),
          ],
        ),
        _InfoCardData(
          title: 'Mother',
          accentColor: AppColor.success,
          rows: [
            _InfoRowData(label: 'Name', value: 'Neha Patel'),
            _InfoRowData(label: 'Occupation', value: 'Teacher'),
            _InfoRowData(label: 'Phone', value: '+91 98222 33445'),
          ],
        ),
      ],
    );
  }
  if (t.contains('class') || t.contains('section')) {
    return _SectionData(
      displayTitle: 'Class & Section',
      subtitle: 'Current academic placement',
      icon: Icons.class_rounded,
      infoCards: const [
        _InfoCardData(
          title: 'Class Details',
          accentColor: AppColor.primaryDark,
          rows: [
            _InfoRowData(label: 'Class', value: '9'),
            _InfoRowData(label: 'Section', value: 'A'),
            _InfoRowData(label: 'Roll No.', value: '23'),
            _InfoRowData(label: 'Class Teacher', value: 'Ms. Priya Shah'),
          ],
        ),
      ],
    );
  }
  if (t.contains('academic')) {
    return _SectionData(
      displayTitle: 'Academic Records',
      subtitle: 'Exam performance and attendance snapshot',
      icon: Icons.school_rounded,
      infoCards: const [
        _InfoCardData(
          title: 'Current Term',
          accentColor: AppColor.primary,
          rows: [
            _InfoRowData(label: 'Overall Grade', value: 'A'),
            _InfoRowData(label: 'Average', value: '87.4%'),
            _InfoRowData(label: 'Attendance', value: '92%'),
          ],
        ),
        _InfoCardData(
          title: 'Recent Results',
          accentColor: AppColor.info,
          rows: [
            _InfoRowData(label: 'Mathematics', value: '91 / 100'),
            _InfoRowData(label: 'Science', value: '88 / 100'),
            _InfoRowData(label: 'English', value: '84 / 100'),
            _InfoRowData(label: 'History', value: '86 / 100'),
          ],
        ),
      ],
    );
  }
  if (t.contains('medical')) {
    return _SectionData(
      displayTitle: 'Medical Information',
      subtitle: 'Health profile and emergency support details',
      icon: Icons.medical_information_rounded,
      infoCards: const [
        _InfoCardData(
          title: 'Health Summary',
          accentColor: AppColor.error,
          rows: [
            _InfoRowData(label: 'Blood Group', value: 'B+'),
            _InfoRowData(label: 'Allergies', value: 'Dust allergy'),
            _InfoRowData(label: 'Chronic Conditions', value: 'None'),
          ],
        ),
        _InfoCardData(
          title: 'Emergency',
          accentColor: AppColor.orange,
          rows: [
            _InfoRowData(label: 'Emergency Contact', value: '+91 98111 22233'),
            _InfoRowData(label: 'Preferred Hospital', value: 'City Care Hospital'),
            _InfoRowData(label: 'Doctor Note', value: 'Carry inhaler during sports'),
          ],
        ),
      ],
    );
  }
  return _SectionData(
    displayTitle: 'Documents Storage',
    subtitle: 'Uploaded school and personal documents',
    icon: Icons.folder_rounded,
    infoCards: const [
      _InfoCardData(
        title: 'Academic Documents',
        accentColor: AppColor.primary,
        rows: [
          _InfoRowData(label: 'Report Card (Term 1)', value: 'Uploaded'),
          _InfoRowData(label: 'Bonafide Certificate', value: 'Uploaded'),
          _InfoRowData(label: 'Transfer Certificate', value: 'Not uploaded'),
        ],
      ),
      _InfoCardData(
        title: 'Identity Documents',
        accentColor: AppColor.info,
        rows: [
          _InfoRowData(label: 'Birth Certificate', value: 'Uploaded'),
          _InfoRowData(label: 'Aadhar Card', value: 'Uploaded'),
          _InfoRowData(label: 'Passport Photo', value: 'Uploaded'),
        ],
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/utils/app_toast.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'student_communication_controller.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  const ScheduleMeetingScreen({super.key});

  @override
  State<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _facultyCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _dayCtrl = TextEditingController();

  DateTime? _selectedDate;
  String _dayLabel = '';

  @override
  void dispose() {
    _facultyCtrl.dispose();
    _subjectCtrl.dispose();
    _reasonCtrl.dispose();
    _timeCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      initialDate: _selectedDate ?? now,
    );
    if (picked == null) return;
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
      _dayLabel = days[_selectedDate!.weekday - 1];
      _dayCtrl.text = _dayLabel;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final minute = picked.minute.toString().padLeft(2, '0');
    setState(() {
      _timeCtrl.text = '$hour:$minute $period';
    });
  }

  String _dateLabel() {
    if (_selectedDate == null) return 'Select date';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${_selectedDate!.day} ${months[_selectedDate!.month - 1]} ${_selectedDate!.year}';
  }

  InputDecoration _decoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColor.cardBackground.withValues(alpha: 0.8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.border.withValues(alpha: 0.9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.border.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.primary, width: 1.4),
      ),
    );
  }

  void _submit() {
    final validForm = _formKey.currentState?.validate() ?? false;
    if (!validForm) return;
    if (_selectedDate == null) {
      AppToast.show('Please select a date.');
      return;
    }
    if (_dayLabel.isEmpty) {
      AppToast.show('Please select a valid day.');
      return;
    }
    if (_timeCtrl.text.trim().isEmpty) {
      AppToast.show('Please select time.');
      return;
    }

    final communicationController = Get.find<StudentCommunicationController>();
    communicationController.addScheduledMeeting(
      facultyName: _facultyCtrl.text,
      subject: _subjectCtrl.text,
      reason: _reasonCtrl.text,
      date: _selectedDate!,
      day: _dayLabel,
      time: _timeCtrl.text,
    );

    AppToast.show('Your meeting has been added.');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Schedule Meeting',
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 700;
            final horizontalPadding = isTablet ? 24.0 : 16.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(context, horizontalPadding),
                Responsive.h(context, 16),
                Responsive.w(context, horizontalPadding),
                Responsive.h(context, 24),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Container(
                    padding: EdgeInsets.all(Responsive.w(context, isTablet ? 22 : 16)),
                    decoration: BoxDecoration(
                      color: AppColor.base,
                      borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
                      border: Border.all(color: AppColor.border.withValues(alpha: 0.8)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(Responsive.w(context, 14)),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.primary.withValues(alpha: 0.14),
                                  AppColor.primaryDark.withValues(alpha: 0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
                              border: Border.all(
                                color: AppColor.primary.withValues(alpha: 0.24),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColor.base.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.groups_2_rounded,
                                    color: AppColor.primaryDark,
                                    size: Responsive.w(context, 22),
                                  ),
                                ),
                                SizedBox(width: Responsive.w(context, 12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Meeting request form',
                                        style: AppTextStyle.titleLarge(context)
                                            .copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: Responsive.h(context, 2)),
                                      Text(
                                        'Fill details to schedule a meeting with faculty.',
                                        style: AppTextStyle.bodySmall(context)
                                            .copyWith(color: AppColor.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Responsive.h(context, 16)),
                          Text(
                            'Faculty details',
                            style: AppTextStyle.titleSmall(context).copyWith(
                              color: AppColor.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: Responsive.h(context, 10)),
                          TextFormField(
                            controller: _facultyCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: _decoration(
                              label: 'Faculty name',
                              hint: 'e.g. Ms. Neha Shah',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Faculty name is required.';
                              if (v.trim().length < 2) return 'Enter a valid faculty name.';
                              return null;
                            },
                          ),
                          SizedBox(height: Responsive.h(context, 12)),
                          TextFormField(
                            controller: _subjectCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: _decoration(
                              label: 'Subject',
                              hint: 'e.g. Mathematics',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Subject is required.';
                              return null;
                            },
                          ),
                          SizedBox(height: Responsive.h(context, 16)),
                          Text(
                            'Schedule details',
                            style: AppTextStyle.titleSmall(context).copyWith(
                              color: AppColor.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: Responsive.h(context, 10)),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColor.cardBackground.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColor.border.withValues(alpha: 0.9)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded, color: AppColor.primary),
                                  SizedBox(width: Responsive.w(context, 10)),
                                  Expanded(
                                    child: Text(
                                      'Date: ${_dateLabel()}',
                                      style: AppTextStyle.bodyMedium(context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.h(context, 10)),
                          TextFormField(
                            controller: _dayCtrl,
                            enabled: false,
                            decoration: _decoration(
                              label: 'Day',
                              hint: 'Auto from selected date',
                            ),
                          ),
                          SizedBox(height: Responsive.h(context, 12)),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _timeCtrl,
                                  readOnly: true,
                                  onTap: _pickTime,
                                  decoration: _decoration(
                                    label: 'Time',
                                    hint: 'Select meeting time',
                                    suffixIcon: const Icon(Icons.access_time_rounded),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Time is required.';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.h(context, 12)),
                          TextFormField(
                            controller: _reasonCtrl,
                            textInputAction: TextInputAction.newline,
                            minLines: 3,
                            maxLines: 5,
                            decoration: _decoration(
                              label: 'Reason for meeting',
                              hint: 'Describe your reason clearly',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Reason is required.';
                              if (v.trim().length < 8) return 'Reason should be at least 8 characters.';
                              return null;
                            },
                          ),
                          SizedBox(height: Responsive.h(context, 18)),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.send_rounded),
                              label: const Text('Schedule meeting'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

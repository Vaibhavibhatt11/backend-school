import 'package:flutter/material.dart';

class StaffModuleItem {
  const StaffModuleItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.features,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<String> features;
}

const List<StaffModuleItem> kStaffModules = [
  StaffModuleItem(
    id: 'dashboard',
    title: 'Staff Dashboard',
    icon: Icons.dashboard_rounded,
    features: [
      "Today's schedule",
      'Assigned classes',
      'Pending tasks',
      'Student alerts',
      'Notifications',
      'Homework status',
      'Upcoming exams',
      'Meetings',
    ],
  ),
  StaffModuleItem(
    id: 'profile',
    title: 'Staff Profile',
    icon: Icons.badge_rounded,
    features: [
      'Personal details',
      'Qualification',
      'Experience',
      'Department',
      'Documents',
      'ID card',
      'Contact information',
    ],
  ),
  StaffModuleItem(
    id: 'attendance_leave',
    title: 'Attendance & Leave Management',
    icon: Icons.fact_check_rounded,
    features: [
      'Staff attendance',
      'Leave application',
      'Leave approval',
      'Attendance reports',
      'Late arrival tracking',
    ],
  ),
  StaffModuleItem(
    id: 'class_teaching',
    title: 'Class & Teaching Management',
    icon: Icons.class_rounded,
    features: [
      'Class list',
      'Student list',
      'Subject assignments',
      'Classroom schedule',
      'Class notes',
    ],
  ),
  StaffModuleItem(
    id: 'lesson_planning',
    title: 'Lesson Planning',
    icon: Icons.event_note_rounded,
    features: [
      'Create lesson plans',
      'Topic scheduling',
      'Lesson notes',
    ],
  ),
  StaffModuleItem(
    id: 'homework_assignment',
    title: 'Homework & Assignment Management',
    icon: Icons.assignment_rounded,
    features: [
      'Create assignments and homework',
      'Set deadlines',
      'Assignment and homework submissions',
      'Feedback system',
    ],
  ),
  StaffModuleItem(
    id: 'exam_assessment',
    title: 'Exam & Assessment Management',
    icon: Icons.quiz_rounded,
    features: [
      'Create exams',
      'Question paper upload',
      'Marks entry',
      'Grading system',
      'Result publishing',
    ],
  ),
  StaffModuleItem(
    id: 'performance',
    title: 'Student Performance Monitoring',
    icon: Icons.insights_rounded,
    features: [
      'Student marks tracking',
      'Attendance monitoring',
      'Academic progress reports',
      'Weak student identification',
    ],
  ),
  StaffModuleItem(
    id: 'communication_ai',
    title: 'Communication Center with AI',
    icon: Icons.support_agent_rounded,
    features: [
      'Message parents',
      'Message students',
      'Announcements',
      'Notifications',
      'Parent-teacher meeting scheduling',
      'Meeting notes',
    ],
  ),
  StaffModuleItem(
    id: 'study_material',
    title: 'Study Material Management',
    icon: Icons.upload_file_rounded,
    features: [
      'Upload notes',
      'Upload videos',
      'Upload PDFs',
      'Learning resources',
    ],
  ),
  StaffModuleItem(
    id: 'events',
    title: 'Event & Activity Management',
    icon: Icons.emoji_events_rounded,
    features: [
      'Plan school events',
      'Student competition management',
      'Event registration',
      'Event reports',
    ],
  ),
  StaffModuleItem(
    id: 'library',
    title: 'Library Management',
    icon: Icons.local_library_rounded,
    features: [
      'Book catalog',
      'Book issue',
      'Book return',
      'Fine calculation',
      'Library membership',
    ],
  ),
  StaffModuleItem(
    id: 'transport',
    title: 'Transport Management',
    icon: Icons.directions_bus_rounded,
    features: [
      'Bus routes',
      'Driver management',
      'Student transport allocation',
      'Route monitoring',
    ],
  ),
  StaffModuleItem(
    id: 'hostel',
    title: 'Hostel Management',
    icon: Icons.meeting_room_rounded,
    features: [
      'Room allocation',
      'Hostel attendance',
      'Visitor logs',
      'Hostel complaints',
    ],
  ),
  StaffModuleItem(
    id: 'inventory_lab',
    title: 'Inventory / Lab Management',
    icon: Icons.inventory_2_rounded,
    features: [
      'Lab equipment management',
      'Inventory tracking',
      'Purchase orders',
      'Maintenance tracking',
    ],
  ),
  StaffModuleItem(
    id: 'payroll_hr',
    title: 'Payroll & HR Management',
    icon: Icons.account_balance_wallet_rounded,
    features: [
      'Salary records',
      'Payroll processing',
      'Staff benefits',
      'Tax reports',
      'ITR tracking',
    ],
  ),
  StaffModuleItem(
    id: 'reports',
    title: 'Reports & Analytics',
    icon: Icons.bar_chart_rounded,
    features: [
      'Academic reports',
      'Attendance reports',
      'Staff productivity reports',
      'Student progress reports',
    ],
  ),
  StaffModuleItem(
    id: 'settings',
    title: 'Settings',
    icon: Icons.settings_rounded,
    features: [
      'Notification settings',
      'Account settings',
      'Privacy control',
      'Other settings',
    ],
  ),
];


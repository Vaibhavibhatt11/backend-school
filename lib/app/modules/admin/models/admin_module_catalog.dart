import 'package:flutter/material.dart';

class AdminModuleItem {
  const AdminModuleItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.features,
  });

  final String id;
  final String title;
  final IconData icon;
  final String description;
  final List<String> features;
}

const List<AdminModuleItem> kAdminModules = [
  AdminModuleItem(
    id: 'dashboard',
    title: 'Dashboard',
    icon: Icons.dashboard_rounded,
    description: 'School KPIs, alerts, and action center',
    features: [
      'Executive KPI cards',
      'Critical alerts',
      'Approvals queue',
      'Today activity snapshot',
    ],
  ),
  AdminModuleItem(
    id: 'admissions',
    title: 'Admissions',
    icon: Icons.how_to_reg_rounded,
    description: 'Application lifecycle from form to onboarding',
    features: [
      'Online admission form',
      'Application tracking',
      'Document upload',
      'Admission approval',
      'Waiting list management',
      'Registration number generation',
      'Admission fee payment',
      'Student onboarding',
    ],
  ),
  AdminModuleItem(
    id: 'students',
    title: 'Student Management',
    icon: Icons.school_rounded,
    description: 'Complete student profiles and operations',
    features: [
      'Student profile directory',
      'Academic profile',
      'Attendance history',
      'Guardian mapping',
      'Document records',
    ],
  ),
  AdminModuleItem(
    id: 'staff',
    title: 'Teacher & Staff Management',
    icon: Icons.groups_rounded,
    description: 'Employee master data and status',
    features: [
      'Teacher/staff directory',
      'Role and department mapping',
      'Joining and contract records',
      'Staff attendance summary',
    ],
  ),
  AdminModuleItem(
    id: 'academics',
    title: 'Academic Management',
    icon: Icons.menu_book_rounded,
    description: 'Classroom structure and curriculum control',
    features: [
      'Class management',
      'Section management',
      'Subject management',
      'Curriculum planning',
      'Syllabus tracking',
      'Lesson plan management',
      'Study material upload',
    ],
  ),
  AdminModuleItem(
    id: 'attendance',
    title: 'Attendance Management',
    icon: Icons.fact_check_rounded,
    description: 'Track attendance for students and staff',
    features: [
      'Student attendance',
      'Teacher attendance',
      'Bulk attendance',
      'Biometric and face integration',
      'Attendance reports',
    ],
  ),
  AdminModuleItem(
    id: 'fees',
    title: 'Fee Management',
    icon: Icons.payments_rounded,
    description: 'Fee operations and payment lifecycle',
    features: [
      'Fee structure setup',
      'Installment system',
      'Fee categories',
      'Online payment gateway',
      'Fee receipts',
      'Late fee calculation',
      'Fee reminders',
      'Fee reports',
    ],
  ),
  AdminModuleItem(
    id: 'exams',
    title: 'Examination System',
    icon: Icons.quiz_rounded,
    description: 'Exam planning, grading, and result release',
    features: [
      'Exam schedule',
      'Question paper upload',
      'Marks entry',
      'Grading system',
      'Report cards',
      'Exam analytics',
      'Result publishing',
    ],
  ),
  AdminModuleItem(
    id: 'timetable',
    title: 'Timetable Management',
    icon: Icons.schedule_rounded,
    description: 'Class/teacher/room scheduling',
    features: [
      'Class timetable',
      'Teacher timetable',
      'Room allocation',
      'Substitute teacher system',
    ],
  ),
  AdminModuleItem(
    id: 'library',
    title: 'Library Management',
    icon: Icons.local_library_rounded,
    description: 'Books, circulation, and fines',
    features: [
      'Book catalog',
      'Book categories',
      'Issue/return tracking',
      'Student library card',
      'Late fine management',
    ],
  ),
  AdminModuleItem(
    id: 'transport',
    title: 'Transport Management',
    icon: Icons.directions_bus_rounded,
    description: 'Transport routes, allocation, and fees',
    features: [
      'Bus routes',
      'Driver details',
      'Student bus allocation',
      'Transport fees',
    ],
  ),
  AdminModuleItem(
    id: 'hostel',
    title: 'Hostel Management',
    icon: Icons.meeting_room_rounded,
    description: 'Hostel residency, attendance, and fees',
    features: [
      'Room allocation',
      'Hostel attendance',
      'Visitor logs',
      'Hostel fee management',
    ],
  ),
  AdminModuleItem(
    id: 'inventory',
    title: 'Inventory & Assets',
    icon: Icons.inventory_2_rounded,
    description: 'Assets, purchases, and vendor records',
    features: [
      'Asset tracking',
      'Equipment inventory',
      'Purchase orders',
      'Vendor management',
    ],
  ),
  AdminModuleItem(
    id: 'communication',
    title: 'Communication Center',
    icon: Icons.campaign_rounded,
    description: 'Broadcast and direct communication channels',
    features: [
      'Staff chat',
      'SMS/WhatsApp broadcast',
      'Email notifications',
      'App notifications',
      'Parent communication',
      'Circular announcements',
    ],
  ),
  AdminModuleItem(
    id: 'events',
    title: 'Events & Activities',
    icon: Icons.event_rounded,
    description: 'Plan and publish school activities',
    features: [
      'Event calendar',
      'Event registration',
      'Competition management',
      'Photo gallery',
    ],
  ),
  AdminModuleItem(
    id: 'reports',
    title: 'Reports & Analytics',
    icon: Icons.bar_chart_rounded,
    description: 'Cross-module insights and analytics',
    features: [
      'Attendance reports',
      'Fee reports',
      'Academic reports',
      'Staff reports',
      'Transport reports',
      'All-in-one dashboards',
    ],
  ),
  AdminModuleItem(
    id: 'ai',
    title: 'AI Assistant',
    icon: Icons.smart_toy_rounded,
    description: 'Automation and predictive assistance',
    features: [
      'AI helper for operations',
      'AI student analysis',
      'AI teacher analytics',
      'AI academic prediction',
    ],
  ),
  AdminModuleItem(
    id: 'security',
    title: 'Security & Permissions',
    icon: Icons.verified_user_rounded,
    description: 'Access control and system security',
    features: [
      'Role-based access control',
      'User permissions',
      'Login tracking',
      'Two-factor authentication',
      'Device management',
    ],
  ),
  AdminModuleItem(
    id: 'settings',
    title: 'Settings',
    icon: Icons.settings_rounded,
    description: 'Global configurations for all modules',
    features: [
      'System settings',
      'Academic session setup',
      'Notification settings',
      'Branding and preferences',
    ],
  ),
];


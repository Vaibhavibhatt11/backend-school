import 'package:erp_frontend/app/core/theme/app_colors.dart';
import 'package:erp_frontend/app/modules/admin/controllers/admin_fee_snapshot_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminFeeSnapshotView extends GetView<AdminFeeSnapshotController> {
  const AdminFeeSnapshotView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Fee Management'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: _FeeHeaderCard(controller: controller),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorPadding: const EdgeInsets.all(6),
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  tabs: const [
                    Tab(text: 'Structure'),
                    Tab(text: 'Installments'),
                    Tab(text: 'Categories'),
                    Tab(text: 'Gateway'),
                    Tab(text: 'Receipts'),
                    Tab(text: 'Late Fee'),
                    Tab(text: 'Reminders'),
                    Tab(text: 'Reports'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  children: [
                    _StructureTab(controller: controller),
                    _InstallmentsTab(controller: controller),
                    _CategoriesTab(controller: controller),
                    _GatewayTab(controller: controller),
                    _ReceiptsTab(controller: controller),
                    _LateFeeTab(controller: controller),
                    _RemindersTab(controller: controller),
                    _ReportsTab(controller: controller),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _FeeHeaderCard extends StatelessWidget {
  const _FeeHeaderCard({required this.controller});
  final AdminFeeSnapshotController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fee Management Workspace',
                    style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due \$${controller.totalDues.value.toStringAsFixed(0)} • '
                    'Collected \$${controller.collected.value.toStringAsFixed(0)} • '
                    '${controller.overallPercent.value.toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StructureTab extends StatelessWidget {
  const _StructureTab({required this.controller});
  final AdminFeeSnapshotController controller;

  @override
  Widget build(BuildContext context) {
    return _CommonTabShell(
      title: 'Fee Structure Setup',
      actionLabel: 'Add Structure',
      onAction: () => _openStructureDialog(context, controller),
      child: Obx(() {
        if (controller.structures.isEmpty) return const _EmptyState(text: 'No fee structures configured.');
        return Column(
          children: controller.structures
              .map((item) => _DataTile(
                    title: item.name,
                    subtitle: '${item.className} • ${item.category}',
                    trailingText: '\$${item.amount.toStringAsFixed(2)}',
                    onEdit: () => _openStructureDialog(context, controller, existing: item),
                    onDelete: () => controller.deleteStructure(item.id),
                  ))
              .toList(),
        );
      }),
    );
  }
}

class _InstallmentsTab extends StatelessWidget {
  const _InstallmentsTab({required this.controller});
  final AdminFeeSnapshotController controller;

  @override
  Widget build(BuildContext context) {
    return _CommonTabShell(
      title: 'Installment System',
      actionLabel: 'Add Installment Plan',
      onAction: () => _openInstallmentDialog(context, controller),
      child: Obx(() {
        if (controller.installmentPlans.isEmpty) return const _EmptyState(text: 'No installment plans configured.');
        return Column(
          children: controller.installmentPlans
              .map((item) => _DataTile(
                    title: item.title,
                    subtitle: '${item.className} • ${item.installments} installments',
                    trailingText: '\$${item.totalAmount.toStringAsFixed(2)}',
                    onEdit: () => _openInstallmentDialog(context, controller, existing: item),
                    onDelete: () => controller.deleteInstallmentPlan(item.id),
                  ))
              .toList(),
        );
      }),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.controller});
  final AdminFeeSnapshotController controller;

  @override
  Widget build(BuildContext context) {
    return _CommonTabShell(
      title: 'Fee Categories',
      actionLabel: 'Add Category',
      onAction: () => _openCategoryDialog(context, controller),
      child: Obx(() {
        if (controller.categoryConfigs.isEmpty) return const _EmptyState(text: 'No fee categories configured.');
        return Column(
          children: controller.categoryConfigs
              .map((item) => _DataTile(
                    title: item.name,
                    subtitle: item.description,
                    onEdit: () => _openCategoryDialog(context, controller, existing: item),
                    onDelete: () => controller.deleteCategoryConfig(item.id),
                  ))
              .toList(),
        );
      }),
    );
  }
}

class _GatewayTab extends StatelessWidget {
  const _GatewayTab({required this.controller});
  final AdminFeeSnapshotController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionTitle(title: 'Online Payment Gateway'),
        const SizedBox(height: 10),
        _ThemedBox(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Provider: ${controller.gatewayProvider.value.isEmpty ? 'Not configured' : controller.gatewayProvider.value}',
                  style: TextStyle(color: isDark ? AppColors.textDark : AppColors.textLight),
                ),
                const SizedBox(height: 6),
                Text(
                  'Merchant ID: ${controller.gatewayMerchantId.value.isEmpty ? 'Not configured' : controller.gatewayMerchantId.value}',
                  style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Gateway Active'),
                    const Spacer(),
                    Switch(
                      value: controller.gatewayActive.value,
                      onChanged: (v) => controller.saveGatewayConfig(
                        provider: controller.gatewayProvider.value,
                        merchantId: controller.gatewayMerchantId.value,
                        active: v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => _openGatewayDialog(context, controller),
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Configure Gateway'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReceiptsTab extends StatelessWidget {
  const _ReceiptsTab({required this.controller});
  final AdminFeeSnapshotController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionTitle(title: 'Fee Receipts'),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.receipts.isEmpty) return const _EmptyState(text: 'No receipts found for current range.');
          return Column(
            children: controller.receipts
                .map((item) => _DataTile(
                      title: item.receiptNo,
                      subtitle: '${item.studentName} • ${item.mode}',
                      trailingText: '\$${item.amount.toStringAsFixed(2)}',
                      infoText: item.date,
                    ))
                .toList(),
          );
        }),
      ],
    );
  }
}

class _LateFeeTab extends StatelessWidget {
  const _LateFeeTab({required this.controller});
  final AdminFeeSnapshotController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionTitle(title: 'Late Fee Calculation'),
        const SizedBox(height: 10),
        _ThemedBox(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${controller.lateFeeType.value}'),
                const SizedBox(height: 4),
                Text('Value: ${controller.lateFeeValue.value}'),
                const SizedBox(height: 4),
                Text('Grace days: ${controller.lateFeeGraceDays.value}'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _openLateFeeDialog(context, controller),
                  icon: const Icon(Icons.calculate_rounded),
                  label: const Text('Configure Late Fee Rules'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RemindersTab extends StatelessWidget {
  const _RemindersTab({required this.controller});
  final AdminFeeSnapshotController controller;

  @override
  Widget build(BuildContext context) {
    return _CommonTabShell(
      title: 'Fee Reminders',
      actionLabel: 'Send Reminder',
      onAction: () => _openReminderDialog(context, controller),
      child: Obx(() {
        if (controller.reminderLogs.isEmpty) return const _EmptyState(text: 'No reminder logs found.');
        return Column(
          children: controller.reminderLogs
              .map((item) => _DataTile(title: item.title, subtitle: item.status, infoText: item.createdAt))
              .toList(),
        );
      }),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab({required this.controller});
  final AdminFeeSnapshotController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionTitle(title: 'Fee Reports'),
        const SizedBox(height: 10),
        _ThemedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Open detailed fee reports for outstanding balances, collections, exports, and operational finance analysis.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.openFeeReports,
                icon: const Icon(Icons.bar_chart_rounded),
                label: const Text('Open Fee Reports'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommonTabShell extends StatelessWidget {
  const _CommonTabShell({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.child,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionTitle(title: title),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add_rounded),
            label: Text(actionLabel),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ThemedBox extends StatelessWidget {
  const _ThemedBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16,
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
    );
  }
}

class _DataTile extends StatelessWidget {
  const _DataTile({
    required this.title,
    required this.subtitle,
    this.trailingText,
    this.infoText,
    this.onEdit,
    this.onDelete,
  });

  final String title;
  final String subtitle;
  final String? trailingText;
  final String? infoText;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text([subtitle, if (infoText != null && infoText!.isNotEmpty) infoText!].join('\n')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null) Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(trailingText!, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            if (onEdit != null) IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_rounded)),
            if (onDelete != null) IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      ),
    );
  }
}

Future<void> _openStructureDialog(
  BuildContext context,
  AdminFeeSnapshotController controller, {
  FeeStructureItem? existing,
}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final className = TextEditingController(text: existing?.className ?? '');
  final amount = TextEditingController(text: existing == null ? '' : existing.amount.toString());
  final category = TextEditingController(text: existing?.category ?? '');
  final ok = await Get.dialog<bool>(
    AlertDialog(
      title: Text(existing == null ? 'Add Fee Structure' : 'Edit Fee Structure'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Structure name')),
            TextField(controller: className, decoration: const InputDecoration(labelText: 'Class')),
            TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')),
            TextField(controller: amount, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Get.back(result: true), child: const Text('Save')),
      ],
    ),
  );
  if (ok != true) return;
  await controller.saveStructure(
    FeeStructureItem(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.text.trim(),
      className: className.text.trim(),
      amount: double.tryParse(amount.text.trim()) ?? 0,
      category: category.text.trim(),
    ),
  );
}

Future<void> _openInstallmentDialog(
  BuildContext context,
  AdminFeeSnapshotController controller, {
  InstallmentPlan? existing,
}) async {
  final title = TextEditingController(text: existing?.title ?? '');
  final className = TextEditingController(text: existing?.className ?? '');
  final total = TextEditingController(text: existing == null ? '' : existing.totalAmount.toString());
  final count = TextEditingController(text: existing == null ? '3' : existing.installments.toString());
  final ok = await Get.dialog<bool>(
    AlertDialog(
      title: Text(existing == null ? 'Add Installment Plan' : 'Edit Installment Plan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Plan title')),
            TextField(controller: className, decoration: const InputDecoration(labelText: 'Class')),
            TextField(controller: total, decoration: const InputDecoration(labelText: 'Total amount'), keyboardType: TextInputType.number),
            TextField(controller: count, decoration: const InputDecoration(labelText: 'Installments count'), keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Get.back(result: true), child: const Text('Save')),
      ],
    ),
  );
  if (ok != true) return;
  await controller.saveInstallmentPlan(
    InstallmentPlan(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.text.trim(),
      className: className.text.trim(),
      totalAmount: double.tryParse(total.text.trim()) ?? 0,
      installments: int.tryParse(count.text.trim()) ?? 1,
    ),
  );
}

Future<void> _openCategoryDialog(
  BuildContext context,
  AdminFeeSnapshotController controller, {
  FeeCategoryConfig? existing,
}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final desc = TextEditingController(text: existing?.description ?? '');
  final ok = await Get.dialog<bool>(
    AlertDialog(
      title: Text(existing == null ? 'Add Fee Category' : 'Edit Fee Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Category name')),
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Get.back(result: true), child: const Text('Save')),
      ],
    ),
  );
  if (ok != true) return;
  await controller.saveCategoryConfig(
    FeeCategoryConfig(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.text.trim(),
      description: desc.text.trim(),
    ),
  );
}

Future<void> _openGatewayDialog(BuildContext context, AdminFeeSnapshotController controller) async {
  final provider = TextEditingController(text: controller.gatewayProvider.value);
  final merchant = TextEditingController(text: controller.gatewayMerchantId.value);
  bool active = controller.gatewayActive.value;
  final ok = await Get.dialog<bool>(
    StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Configure Payment Gateway'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: provider, decoration: const InputDecoration(labelText: 'Provider')),
                TextField(controller: merchant, decoration: const InputDecoration(labelText: 'Merchant ID')),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: active,
                  onChanged: (value) => setState(() => active = value),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Get.back(result: true), child: const Text('Save')),
          ],
        );
      },
    ),
  );
  if (ok != true) return;
  await controller.saveGatewayConfig(
    provider: provider.text.trim(),
    merchantId: merchant.text.trim(),
    active: active,
  );
}

Future<void> _openLateFeeDialog(BuildContext context, AdminFeeSnapshotController controller) async {
  String type = controller.lateFeeType.value;
  final value = TextEditingController(text: controller.lateFeeValue.value.toString());
  final grace = TextEditingController(text: controller.lateFeeGraceDays.value.toString());
  final ok = await Get.dialog<bool>(
    StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Configure Late Fee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Calculation type'),
                  items: const [
                    DropdownMenuItem(value: 'percent', child: Text('Percent')),
                    DropdownMenuItem(value: 'fixed', child: Text('Fixed amount')),
                  ],
                  onChanged: (v) => setState(() => type = v ?? 'percent'),
                ),
                TextField(controller: value, decoration: const InputDecoration(labelText: 'Value'), keyboardType: TextInputType.number),
                TextField(controller: grace, decoration: const InputDecoration(labelText: 'Grace days'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Get.back(result: true), child: const Text('Save')),
          ],
        );
      },
    ),
  );
  if (ok != true) return;
  await controller.saveLateFeeConfig(
    type: type,
    value: double.tryParse(value.text.trim()) ?? 0,
    graceDays: int.tryParse(grace.text.trim()) ?? 0,
  );
}

Future<void> _openReminderDialog(BuildContext context, AdminFeeSnapshotController controller) async {
  final title = TextEditingController(text: 'Fee Payment Reminder');
  final content = TextEditingController(text: 'Please clear your pending fees to avoid late charges.');
  final ok = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Send Fee Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: content, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Send'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  await controller.sendFeeReminder(title: title.text.trim(), content: content.text.trim());
}

import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─── Models (mirrored from AdminResourcesController) ─────────────────────────

class InventoryItemRecord {
  const InventoryItemRecord({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.qty,
    required this.unit,
    required this.lowStockThreshold,
    required this.isActive,
  });
  final String id;
  final String sku;
  final String name;
  final String category;
  final int qty;
  final String unit;
  final int lowStockThreshold;
  final bool isActive;
  bool get isLowStock => qty <= lowStockThreshold;

  factory InventoryItemRecord.fromJson(Map<String, dynamic> json) {
    return InventoryItemRecord(
      id: json['id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      unit: json['unit']?.toString() ?? 'pcs',
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] != false,
    );
  }
}

class InventoryTransactionRecord {
  const InventoryTransactionRecord({
    required this.id,
    required this.itemName,
    required this.type,
    required this.qty,
    required this.note,
    required this.createdAt,
  });
  final String id;
  final String itemName;
  final String type;
  final int qty;
  final String note;
  final DateTime? createdAt;

  factory InventoryTransactionRecord.fromJson(Map<String, dynamic> json) {
    final item =
        json['item'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return InventoryTransactionRecord(
      id: json['id']?.toString() ?? '',
      itemName: item['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      note: json['note']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }
}

class AssetRecord {
  const AssetRecord({
    required this.id,
    required this.assetCode,
    required this.name,
    required this.category,
    required this.assignedTo,
    required this.status,
    required this.purchaseDate,
  });
  final String id;
  final String assetCode;
  final String name;
  final String category;
  final String assignedTo;
  final String status;
  final String purchaseDate;

  Map<String, dynamic> toJson() => {
    'id': id,
    'assetCode': assetCode,
    'name': name,
    'category': category,
    'assignedTo': assignedTo,
    'status': status,
    'purchaseDate': purchaseDate,
  };

  factory AssetRecord.fromJson(Map<String, dynamic> json) {
    return AssetRecord(
      id: json['id']?.toString() ?? '',
      assetCode: json['assetCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      assignedTo: json['assignedTo']?.toString() ?? '',
      status: json['status']?.toString() ?? 'AVAILABLE',
      purchaseDate: json['purchaseDate']?.toString() ?? '',
    );
  }
}

class VendorRecord {
  const VendorRecord({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.isActive,
  });
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'contactPerson': contactPerson,
    'phone': phone,
    'email': email,
    'address': address,
    'isActive': isActive,
  };

  factory VendorRecord.fromJson(Map<String, dynamic> json) {
    return VendorRecord(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contactPerson: json['contactPerson']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      isActive: json['isActive'] != false,
    );
  }
}

class PurchaseOrderRecord {
  const PurchaseOrderRecord({
    required this.id,
    required this.poNumber,
    required this.vendorId,
    required this.vendorName,
    required this.itemSummary,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.expectedDate,
  });
  final String id;
  final String poNumber;
  final String vendorId;
  final String vendorName;
  final String itemSummary;
  final double totalAmount;
  final String status;
  final String orderDate;
  final String expectedDate;

  Map<String, dynamic> toJson() => {
    'id': id,
    'poNumber': poNumber,
    'vendorId': vendorId,
    'vendorName': vendorName,
    'itemSummary': itemSummary,
    'totalAmount': totalAmount,
    'status': status,
    'orderDate': orderDate,
    'expectedDate': expectedDate,
  };

  factory PurchaseOrderRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderRecord(
      id: json['id']?.toString() ?? '',
      poNumber: json['poNumber']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      itemSummary: json['itemSummary']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'DRAFT',
      orderDate: json['orderDate']?.toString() ?? '',
      expectedDate: json['expectedDate']?.toString() ?? '',
    );
  }
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}

// ─── Controller ─────────────────────────────────────────────────────────────

class StaffInventoryController extends GetxController {
  StaffInventoryController(this._adminService);

  // Uses AdminService so it reads/writes the same backend data as Admin portal
  final AdminService _adminService;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final inventoryItems = <InventoryItemRecord>[].obs;
  final inventoryTransactions = <InventoryTransactionRecord>[].obs;
  final assets = <AssetRecord>[].obs;
  final vendors = <VendorRecord>[].obs;
  final purchaseOrders = <PurchaseOrderRecord>[].obs;

  // KPIs
  final totalAssets = 0.obs;
  final lowStockCount = 0.obs;
  final pendingPOCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> refreshData() => loadAllData(force: true);

  Future<void> loadAllData({bool force = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([
        _loadAssets(),
        _loadInventoryItems(),
        _loadInventoryTransactions(),
        _loadInventorySettings(),
      ]);
      _computeKPIs();
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void _computeKPIs() {
    totalAssets.value = assets.length;
    lowStockCount.value = inventoryItems.where((i) => i.isLowStock).length;
    pendingPOCount.value = purchaseOrders
        .where((p) => p.status == 'DRAFT' || p.status == 'APPROVED')
        .length;
  }

  Future<void> _loadAssets() async {
    try {
      final data = await _adminService.getSchoolSettings();
      final raw = data['inventoryManagement'];
      if (raw is! Map) {
        // inventoryManagement not set yet — start with empty lists
        assets.clear();
        vendors.clear();
        purchaseOrders.clear();
        return;
      }
      final map = Map<String, dynamic>.from(raw);
      assets.assignAll(
        (map['assets'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((e) => AssetRecord.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );
      vendors.assignAll(
        (map['vendors'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((e) => VendorRecord.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );
      purchaseOrders.assignAll(
        (map['purchaseOrders'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((e) => PurchaseOrderRecord.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );
    } catch (_) {
      assets.clear();
      vendors.clear();
      purchaseOrders.clear();
    }
  }

  Future<void> _loadInventoryItems() async {
    try {
      final data = await _adminService.getInventoryItems(page: 1, limit: 100);
      final rawItems = data['items'];
      if (rawItems is! List) {
        inventoryItems.clear();
        return;
      }
      inventoryItems.assignAll(
        rawItems
            .whereType<Map>()
            .map((e) => InventoryItemRecord.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );
    } catch (_) {
      inventoryItems.clear();
    }
  }

  Future<void> _loadInventoryTransactions() async {
    try {
      final data = await _adminService.getInventoryTransactions(
        page: 1,
        limit: 100,
      );
      final rawItems = data['items'];
      if (rawItems is! List) {
        inventoryTransactions.clear();
        return;
      }
      inventoryTransactions.assignAll(
        rawItems
            .whereType<Map>()
            .map(
              (e) => InventoryTransactionRecord.fromJson(
                e.cast<String, dynamic>(),
              ),
            )
            .toList(),
      );
    } catch (_) {
      inventoryTransactions.clear();
    }
  }

  Future<void> _loadInventorySettings() async {
    // Already loaded with assets above
  }

  // ── Asset CRUD ──────────────────────────────────────────────────────────────
  Future<void> openAssetDialog({AssetRecord? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final codeCtrl = TextEditingController(text: existing?.assetCode ?? '');
    final categoryCtrl = TextEditingController(text: existing?.category ?? '');
    final assignedCtrl = TextEditingController(
      text: existing?.assignedTo ?? '',
    );
    final dateCtrl = TextEditingController(text: existing?.purchaseDate ?? '');
    String status = existing?.status ?? 'AVAILABLE';

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(
            existing == null ? 'Add Lab Equipment' : 'Edit Equipment',
          ),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Equipment name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(labelText: 'Asset code'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: categoryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Category (e.g. Lab, IT)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: assignedCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Assigned to (room/dept)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dateCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Purchase date (YYYY-MM-DD)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['AVAILABLE', 'IN_USE', 'MAINTENANCE', 'RETIRED']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => status = v ?? 'AVAILABLE'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || nameCtrl.text.trim().isEmpty) return;
    assets.assignAll([
      ...assets.where((e) => e.id != existing?.id),
      AssetRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        assetCode: codeCtrl.text.trim(),
        name: nameCtrl.text.trim(),
        category: categoryCtrl.text.trim(),
        assignedTo: assignedCtrl.text.trim(),
        status: status,
        purchaseDate: dateCtrl.text.trim(),
      ),
    ]);
    await _saveInventoryManagement();
    _computeKPIs();
    AppToast.show('Equipment saved.');
  }

  Future<void> deleteAsset(AssetRecord item) async {
    if (!await _confirm('Delete ${item.name}?')) return;
    assets.removeWhere((e) => e.id == item.id);
    await _saveInventoryManagement();
    _computeKPIs();
    AppToast.show('Equipment deleted.');
  }

  // ── Inventory Item CRUD ────────────────────────────────────────────────────
  Future<void> openInventoryItemDialog({InventoryItemRecord? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final skuCtrl = TextEditingController(text: existing?.sku ?? '');
    final categoryCtrl = TextEditingController(text: existing?.category ?? '');
    final qtyCtrl = TextEditingController(
      text: existing?.qty.toString() ?? '0',
    );
    final unitCtrl = TextEditingController(text: existing?.unit ?? 'pcs');
    final thresholdCtrl = TextEditingController(
      text: existing?.lowStockThreshold.toString() ?? '5',
    );

    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(existing == null ? 'Add Inventory Item' : 'Edit Item'),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Item name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: skuCtrl,
                  decoration: const InputDecoration(labelText: 'SKU'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: unitCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Unit (pcs, kg, litre...)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: thresholdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Low stock threshold',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true || nameCtrl.text.trim().isEmpty) return;
    final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
    final threshold = int.tryParse(thresholdCtrl.text.trim()) ?? 5;
    try {
      final payload = {
        'name': nameCtrl.text.trim(),
        'sku': skuCtrl.text.trim(),
        'category': categoryCtrl.text.trim(),
        'qty': qty,
        'unit': unitCtrl.text.trim().isEmpty ? 'pcs' : unitCtrl.text.trim(),
        'lowStockThreshold': threshold,
        'isActive': true,
      };
      if (existing == null) {
        await _adminService.createInventoryItem(payload);
        AppToast.show('Item created.');
      } else {
        await _adminService.updateInventoryItem(
          id: existing.id,
          payload: payload,
        );
        AppToast.show('Item updated.');
      }
      await _loadInventoryItems();
      _computeKPIs();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteInventoryItem(InventoryItemRecord item) async {
    if (!await _confirm('Delete ${item.name}?')) return;
    try {
      await _adminService.deleteInventoryItem(item.id);
      AppToast.show('Item deleted.');
      await _loadInventoryItems();
      _computeKPIs();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> createStockMove() async {
    if (inventoryItems.isEmpty) {
      AppToast.show('Add items first.');
      return;
    }
    String itemId = inventoryItems.first.id;
    String type = 'IN';
    final qtyCtrl = TextEditingController(text: '1');
    final noteCtrl = TextEditingController();

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Stock Move'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: itemId,
                    decoration: const InputDecoration(labelText: 'Item'),
                    items: inventoryItems
                        .map(
                          (i) => DropdownMenuItem(
                            value: i.id,
                            child: Text(i.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => itemId = v ?? ''),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: ['IN', 'OUT']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => type = v ?? 'IN'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(labelText: 'Note'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final qty = int.tryParse(qtyCtrl.text.trim());
    if (qty == null || qty <= 0) {
      AppToast.show('Valid quantity required.');
      return;
    }
    try {
      await _adminService.createInventoryTransaction({
        'itemId': itemId,
        'type': type,
        'qty': qty,
        'note': noteCtrl.text.trim(),
      });
      AppToast.show('Stock move recorded.');
      await _loadInventoryItems();
      await _loadInventoryTransactions();
      _computeKPIs();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  // ── Purchase Order CRUD ────────────────────────────────────────────────────
  Future<void> openPurchaseOrderDialog({PurchaseOrderRecord? existing}) async {
    final poCtrl = TextEditingController(
      text: existing?.poNumber ?? 'PO-${DateTime.now().millisecondsSinceEpoch}',
    );
    final vendorCtrl = TextEditingController(text: existing?.vendorName ?? '');
    final itemsCtrl = TextEditingController(text: existing?.itemSummary ?? '');
    final amountCtrl = TextEditingController(
      text: existing?.totalAmount.toStringAsFixed(2) ?? '0.00',
    );
    final orderDateCtrl = TextEditingController(
      text:
          existing?.orderDate ??
          DateTime.now().toIso8601String().split('T').first,
    );
    final expectedCtrl = TextEditingController(
      text: existing?.expectedDate ?? '',
    );

    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(existing == null ? 'Create Purchase Order' : 'Edit PO'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: poCtrl,
                  decoration: const InputDecoration(labelText: 'PO Number'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: vendorCtrl,
                  decoration: const InputDecoration(labelText: 'Vendor name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: itemsCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Items summary'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Total amount'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: orderDateCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Order date (YYYY-MM-DD)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: expectedCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Expected date (YYYY-MM-DD)',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true || vendorCtrl.text.trim().isEmpty) return;
    purchaseOrders.assignAll([
      ...purchaseOrders.where((e) => e.id != existing?.id),
      PurchaseOrderRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        poNumber: poCtrl.text.trim(),
        vendorId: existing?.vendorId ?? '',
        vendorName: vendorCtrl.text.trim(),
        itemSummary: itemsCtrl.text.trim(),
        totalAmount: double.tryParse(amountCtrl.text.trim()) ?? 0,
        status: existing?.status ?? 'DRAFT',
        orderDate: orderDateCtrl.text.trim(),
        expectedDate: expectedCtrl.text.trim(),
      ),
    ]);
    await _saveInventoryManagement();
    _computeKPIs();
    AppToast.show('Purchase order saved.');
  }

  Future<void> updatePOStatus(
    PurchaseOrderRecord item,
    String newStatus,
  ) async {
    purchaseOrders.assignAll(
      purchaseOrders
          .map(
            (e) => e.id == item.id
                ? PurchaseOrderRecord(
                    id: e.id,
                    poNumber: e.poNumber,
                    vendorId: e.vendorId,
                    vendorName: e.vendorName,
                    itemSummary: e.itemSummary,
                    totalAmount: e.totalAmount,
                    status: newStatus,
                    orderDate: e.orderDate,
                    expectedDate: e.expectedDate,
                  )
                : e,
          )
          .toList(),
    );
    await _saveInventoryManagement();
    _computeKPIs();
    AppToast.show('PO status updated to $newStatus.');
  }

  Future<void> deletePurchaseOrder(PurchaseOrderRecord item) async {
    if (!await _confirm('Delete PO ${item.poNumber}?')) return;
    purchaseOrders.removeWhere((e) => e.id == item.id);
    await _saveInventoryManagement();
    _computeKPIs();
    AppToast.show('Purchase order deleted.');
  }

  Future<void> _saveInventoryManagement() async {
    try {
      await _adminService.patchSchoolSettings({
        'inventoryManagement': {
          'assets': assets.map((e) => e.toJson()).toList(),
          'vendors': vendors.map((e) => e.toJson()).toList(),
          'purchaseOrders': purchaseOrders.map((e) => e.toJson()).toList(),
        },
      });
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<bool> _confirm(String msg) async {
    final res = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return res == true;
  }
}

import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminLibraryBookRecord {
  const AdminLibraryBookRecord({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.totalCopies,
    required this.availableCopies,
    required this.isActive,
  });

  final String id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final int totalCopies;
  final int availableCopies;
  final bool isActive;

  factory AdminLibraryBookRecord.fromJson(Map<String, dynamic> json) {
    return AdminLibraryBookRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      isbn: json['isbn']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      totalCopies: (json['totalCopies'] as num?)?.toInt() ?? 0,
      availableCopies: (json['availableCopies'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] != false,
    );
  }
}

class AdminLibraryBorrowRecord {
  const AdminLibraryBorrowRecord({
    required this.id,
    required this.bookTitle,
    required this.borrowerType,
    required this.borrowerRefId,
    required this.status,
    required this.issuedAt,
    required this.dueDate,
    required this.returnedAt,
  });

  final String id;
  final String bookTitle;
  final String borrowerType;
  final String borrowerRefId;
  final String status;
  final DateTime? issuedAt;
  final DateTime? dueDate;
  final DateTime? returnedAt;

  factory AdminLibraryBorrowRecord.fromJson(Map<String, dynamic> json) {
    final book =
        json['book'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return AdminLibraryBorrowRecord(
      id: json['id']?.toString() ?? '',
      bookTitle: book['title']?.toString() ?? '',
      borrowerType: json['borrowerType']?.toString() ?? '',
      borrowerRefId: json['borrowerRefId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      issuedAt: _readDate(json['issuedAt']),
      dueDate: _readDate(json['dueDate']),
      returnedAt: _readDate(json['returnedAt']),
    );
  }
}

class AdminInventoryItemRecord {
  const AdminInventoryItemRecord({
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

  factory AdminInventoryItemRecord.fromJson(Map<String, dynamic> json) {
    return AdminInventoryItemRecord(
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

class AdminInventoryTransactionRecord {
  const AdminInventoryTransactionRecord({
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

  factory AdminInventoryTransactionRecord.fromJson(Map<String, dynamic> json) {
    final item =
        json['item'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return AdminInventoryTransactionRecord(
      id: json['id']?.toString() ?? '',
      itemName: item['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      note: json['note']?.toString() ?? '',
      createdAt: _readDate(json['createdAt']),
    );
  }
}

class AdminResourcesController extends GetxController {
  AdminResourcesController(this._adminService);

  final AdminService _adminService;

  final currentTab = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final libraryBooks = <AdminLibraryBookRecord>[].obs;
  final libraryBorrows = <AdminLibraryBorrowRecord>[].obs;
  final inventoryItems = <AdminInventoryItemRecord>[].obs;
  final inventoryTransactions = <AdminInventoryTransactionRecord>[].obs;
  final studentOptions = <Map<String, String>>[].obs;
  final staffOptions = <Map<String, String>>[].obs;

  bool _libraryLoaded = false;
  bool _inventoryLoaded = false;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    currentTab.value = _resourceTab((args['initialTab'] as num?)?.toInt() ?? 0);
    loadCurrentTab(force: true);
  }

  Future<void> changeTab(int index) async {
    currentTab.value = _resourceTab(index);
    await loadCurrentTab();
  }

  Future<void> refreshCurrentTab() async {
    await loadCurrentTab(force: true);
  }

  Future<void> loadCurrentTab({bool force = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (currentTab.value == 0) {
        if (force || !_libraryLoaded) {
          await Future.wait([
            loadLibraryBooks(),
            loadLibraryBorrows(),
            loadBorrowerOptions(),
          ]);
          _libraryLoaded = true;
        }
      } else {
        if (force || !_inventoryLoaded) {
          await Future.wait([
            loadInventoryItems(),
            loadInventoryTransactions(),
          ]);
          _inventoryLoaded = true;
        }
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLibraryBooks() async {
    final data = await _adminService.getLibraryBooks(page: 1, limit: 50);
    final rawItems = data['items'];
    if (rawItems is! List) {
      libraryBooks.clear();
      return;
    }
    libraryBooks.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) =>
                AdminLibraryBookRecord.fromJson(item.cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  Future<void> loadLibraryBorrows() async {
    final data = await _adminService.getLibraryBorrows(page: 1, limit: 50);
    final rawItems = data['items'];
    if (rawItems is! List) {
      libraryBorrows.clear();
      return;
    }
    libraryBorrows.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) =>
                AdminLibraryBorrowRecord.fromJson(item.cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  Future<void> loadInventoryItems() async {
    final data = await _adminService.getInventoryItems(page: 1, limit: 50);
    final rawItems = data['items'];
    if (rawItems is! List) {
      inventoryItems.clear();
      return;
    }
    inventoryItems.assignAll(
      rawItems
          .whereType<Map>()
          .map(
            (item) =>
                AdminInventoryItemRecord.fromJson(item.cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  Future<void> loadInventoryTransactions() async {
    final data = await _adminService.getInventoryTransactions(
      page: 1,
      limit: 50,
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
            (item) => AdminInventoryTransactionRecord.fromJson(
              item.cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  Future<void> loadBorrowerOptions() async {
    try {
      final results = await Future.wait([
        _adminService.getStudents(page: 1, limit: 100, status: 'ACTIVE'),
        _adminService.getStaff(page: 1, limit: 100, isActive: true),
      ]);
      final rawStudents = results[0]['items'];
      final rawStaff = results[1]['items'];
      if (rawStudents is List) {
        studentOptions.assignAll(
          rawStudents
              .whereType<Map>()
              .map((item) {
                final json = item.cast<String, dynamic>();
                return <String, String>{
                  'id': json['id']?.toString() ?? '',
                  'label':
                      '${json['firstName']?.toString() ?? ''} ${json['lastName']?.toString() ?? ''} (${json['admissionNo']?.toString() ?? ''})'
                          .trim(),
                };
              })
              .where((item) => item['id']!.isNotEmpty)
              .toList(),
        );
      }
      if (rawStaff is List) {
        staffOptions.assignAll(
          rawStaff
              .whereType<Map>()
              .map((item) {
                final json = item.cast<String, dynamic>();
                return <String, String>{
                  'id': json['id']?.toString() ?? '',
                  'label':
                      '${json['fullName']?.toString() ?? ''} (${json['employeeCode']?.toString() ?? ''})'
                          .trim(),
                };
              })
              .where((item) => item['id']!.isNotEmpty)
              .toList(),
        );
      }
    } catch (_) {
      studentOptions.clear();
      staffOptions.clear();
    }
  }

  Future<void> openBookDialog({AdminLibraryBookRecord? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final authorController = TextEditingController(
      text: existing?.author ?? '',
    );
    final isbnController = TextEditingController(text: existing?.isbn ?? '');
    final categoryController = TextEditingController(
      text: existing?.category ?? '',
    );
    final totalCopiesController = TextEditingController(
      text: existing?.totalCopies.toString() ?? '1',
    );
    final availableCopiesController = TextEditingController(
      text: existing?.availableCopies.toString() ?? '1',
    );
    bool isActive = existing?.isActive ?? true;

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Book' : 'Edit Book'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: authorController,
                      decoration: const InputDecoration(labelText: 'Author'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: isbnController,
                      decoration: const InputDecoration(labelText: 'ISBN'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: totalCopiesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total copies',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: availableCopiesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Available copies',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                      title: const Text('Active'),
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
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return;

    final totalCopies = int.tryParse(totalCopiesController.text.trim());
    final availableCopies = int.tryParse(availableCopiesController.text.trim());
    if (titleController.text.trim().isEmpty ||
        totalCopies == null ||
        availableCopies == null) {
      AppToast.show('Title and copy counts are required.');
      return;
    }

    try {
      final payload = <String, dynamic>{
        'title': titleController.text.trim(),
        'author': authorController.text.trim().isEmpty
            ? null
            : authorController.text.trim(),
        'isbn': isbnController.text.trim().isEmpty
            ? null
            : isbnController.text.trim(),
        'category': categoryController.text.trim().isEmpty
            ? null
            : categoryController.text.trim(),
        'totalCopies': totalCopies,
        'availableCopies': availableCopies,
        'isActive': isActive,
      };
      if (existing == null) {
        await _adminService.createLibraryBook(payload);
        AppToast.show('Library book created.');
      } else {
        await _adminService.updateLibraryBook(
          id: existing.id,
          payload: payload,
        );
        AppToast.show('Library book updated.');
      }
      await loadLibraryBooks();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteBook(AdminLibraryBookRecord item) async {
    if (!await _confirm('Delete ${item.title}?')) return;
    try {
      await _adminService.deleteLibraryBook(item.id);
      AppToast.show('Library book deleted.');
      await loadLibraryBooks();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> issueBook() async {
    if (libraryBooks.isEmpty) {
      AppToast.show('Add books first.');
      return;
    }
    String bookId = libraryBooks.first.id;
    String borrowerType = 'STUDENT';
    String borrowerRefId = studentOptions.isNotEmpty
        ? studentOptions.first['id']!
        : '';
    final dueDateController = TextEditingController();

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          final borrowerItems = borrowerType == 'STAFF'
              ? staffOptions
              : studentOptions;
          if (borrowerRefId.isEmpty && borrowerItems.isNotEmpty) {
            borrowerRefId = borrowerItems.first['id']!;
          }
          return AlertDialog(
            title: const Text('Issue Book'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: bookId,
                      decoration: const InputDecoration(labelText: 'Book'),
                      items: libraryBooks
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => bookId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: borrowerType,
                      decoration: const InputDecoration(
                        labelText: 'Borrower type',
                      ),
                      items: const ['STUDENT', 'STAFF']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          borrowerType = value ?? 'STUDENT';
                          final items = borrowerType == 'STAFF'
                              ? staffOptions
                              : studentOptions;
                          borrowerRefId = items.isNotEmpty
                              ? items.first['id']!
                              : '';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: borrowerRefId.isEmpty ? null : borrowerRefId,
                      decoration: const InputDecoration(labelText: 'Borrower'),
                      items: borrowerItems
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['id'],
                              child: Text(item['label'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => borrowerRefId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dueDateController,
                      decoration: const InputDecoration(
                        labelText: 'Due date',
                        helperText: 'YYYY-MM-DD',
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
                child: const Text('Issue'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return;
    final dueDate = _readInputDate(dueDateController.text);
    if (borrowerRefId.isEmpty || dueDate == null) {
      AppToast.show('Borrower and valid due date are required.');
      return;
    }
    try {
      await _adminService.createLibraryBorrow({
        'bookId': bookId,
        'borrowerType': borrowerType,
        'borrowerRefId': borrowerRefId,
        'dueDate': dueDate.toIso8601String(),
      });
      AppToast.show('Book issued.');
      await Future.wait([loadLibraryBooks(), loadLibraryBorrows()]);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> returnBorrow(AdminLibraryBorrowRecord item) async {
    try {
      await _adminService.returnLibraryBorrow(item.id);
      AppToast.show('Book returned.');
      await Future.wait([loadLibraryBooks(), loadLibraryBorrows()]);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> openInventoryItemDialog({
    AdminInventoryItemRecord? existing,
  }) async {
    final skuController = TextEditingController(text: existing?.sku ?? '');
    final nameController = TextEditingController(text: existing?.name ?? '');
    final categoryController = TextEditingController(
      text: existing?.category ?? '',
    );
    final qtyController = TextEditingController(
      text: existing?.qty.toString() ?? '0',
    );
    final unitController = TextEditingController(text: existing?.unit ?? 'pcs');
    final thresholdController = TextEditingController(
      text: existing?.lowStockThreshold.toString() ?? '0',
    );
    bool isActive = existing?.isActive ?? true;

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Inventory Item' : 'Edit Item'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: skuController,
                      decoration: const InputDecoration(labelText: 'SKU'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: unitController,
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: thresholdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Low stock threshold',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                      title: const Text('Active'),
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
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return;

    final qty = int.tryParse(qtyController.text.trim());
    final threshold = int.tryParse(thresholdController.text.trim());
    if (skuController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        qty == null ||
        threshold == null) {
      AppToast.show('SKU, name, quantity, and threshold are required.');
      return;
    }

    try {
      final payload = <String, dynamic>{
        'sku': skuController.text.trim(),
        'name': nameController.text.trim(),
        'category': categoryController.text.trim().isEmpty
            ? null
            : categoryController.text.trim(),
        'qty': qty,
        'unit': unitController.text.trim().isEmpty
            ? 'pcs'
            : unitController.text.trim(),
        'lowStockThreshold': threshold,
        'isActive': isActive,
      };
      if (existing == null) {
        await _adminService.createInventoryItem(payload);
        AppToast.show('Inventory item created.');
      } else {
        await _adminService.updateInventoryItem(
          id: existing.id,
          payload: payload,
        );
        AppToast.show('Inventory item updated.');
      }
      await loadInventoryItems();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> deleteInventoryItem(AdminInventoryItemRecord item) async {
    if (!await _confirm('Delete ${item.name}?')) return;
    try {
      await _adminService.deleteInventoryItem(item.id);
      AppToast.show('Inventory item deleted.');
      await loadInventoryItems();
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<void> createInventoryTransaction() async {
    if (inventoryItems.isEmpty) {
      AppToast.show('Add inventory items first.');
      return;
    }
    String itemId = inventoryItems.first.id;
    String type = 'IN';
    final qtyController = TextEditingController();
    final noteController = TextEditingController();

    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Stock Transaction'),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: itemId,
                      decoration: const InputDecoration(labelText: 'Item'),
                      items: inventoryItems
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text('${item.name} | ${item.sku}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => itemId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const ['IN', 'OUT']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => type = value ?? 'IN'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteController,
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
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return;

    final qty = int.tryParse(qtyController.text.trim());
    if (qty == null || qty <= 0) {
      AppToast.show('Enter a valid quantity.');
      return;
    }
    try {
      await _adminService.createInventoryTransaction({
        'itemId': itemId,
        'type': type,
        'qty': qty,
        'note': noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
      });
      AppToast.show('Inventory transaction created.');
      await Future.wait([loadInventoryItems(), loadInventoryTransactions()]);
    } catch (e) {
      AppToast.show(dioOrApiErrorMessage(e));
    }
  }

  Future<bool> _confirm(String message) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
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
    return confirmed == true;
  }

  int _resourceTab(int value) {
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }
}

DateTime? _readDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

DateTime? _readInputDate(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

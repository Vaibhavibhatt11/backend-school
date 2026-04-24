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

class AdminLibraryCategoryRecord {
  const AdminLibraryCategoryRecord({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory AdminLibraryCategoryRecord.fromJson(Map<String, dynamic> json) {
    return AdminLibraryCategoryRecord(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class AdminStudentLibraryCardRecord {
  const AdminStudentLibraryCardRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.cardNo,
    required this.issuedOn,
    required this.isActive,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String cardNo;
  final String issuedOn;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'cardNo': cardNo,
    'issuedOn': issuedOn,
    'isActive': isActive,
  };

  factory AdminStudentLibraryCardRecord.fromJson(Map<String, dynamic> json) {
    return AdminStudentLibraryCardRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      studentName: json['studentName']?.toString() ?? '',
      cardNo: json['cardNo']?.toString() ?? '',
      issuedOn: json['issuedOn']?.toString() ?? '',
      isActive: json['isActive'] != false,
    );
  }
}

class AdminLateFineRule {
  const AdminLateFineRule({
    required this.type,
    required this.amount,
    required this.graceDays,
  });

  final String type;
  final double amount;
  final int graceDays;

  Map<String, dynamic> toJson() => {
    'type': type,
    'amount': amount,
    'graceDays': graceDays,
  };

  factory AdminLateFineRule.fromJson(Map<String, dynamic> json) {
    return AdminLateFineRule(
      type: json['type']?.toString() ?? 'per_day',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      graceDays: (json['graceDays'] as num?)?.toInt() ?? 0,
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

class AdminAssetRecord {
  const AdminAssetRecord({
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

  factory AdminAssetRecord.fromJson(Map<String, dynamic> json) {
    return AdminAssetRecord(
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

class AdminVendorRecord {
  const AdminVendorRecord({
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

  factory AdminVendorRecord.fromJson(Map<String, dynamic> json) {
    return AdminVendorRecord(
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

class AdminPurchaseOrderRecord {
  const AdminPurchaseOrderRecord({
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

  factory AdminPurchaseOrderRecord.fromJson(Map<String, dynamic> json) {
    return AdminPurchaseOrderRecord(
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

class AdminResourcesController extends GetxController {
  AdminResourcesController(this._adminService);

  final AdminService _adminService;

  final currentTab = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final libraryBooks = <AdminLibraryBookRecord>[].obs;
  final libraryBorrows = <AdminLibraryBorrowRecord>[].obs;
  final libraryCategories = <AdminLibraryCategoryRecord>[].obs;
  final libraryCards = <AdminStudentLibraryCardRecord>[].obs;
  final lateFineRule = const AdminLateFineRule(
    type: 'per_day',
    amount: 10,
    graceDays: 3,
  ).obs;
  final inventoryItems = <AdminInventoryItemRecord>[].obs;
  final inventoryTransactions = <AdminInventoryTransactionRecord>[].obs;
  final assets = <AdminAssetRecord>[].obs;
  final vendors = <AdminVendorRecord>[].obs;
  final purchaseOrders = <AdminPurchaseOrderRecord>[].obs;
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
            loadLibraryManagementSettings(),
          ]);
          _libraryLoaded = true;
        }
      } else {
        if (force || !_inventoryLoaded) {
          await Future.wait([
            loadInventoryItems(),
            loadInventoryTransactions(),
            loadInventoryManagementSettings(),
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
                      initialValue: bookId,
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
                      initialValue: borrowerType,
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
                      initialValue: borrowerRefId.isEmpty
                          ? null
                          : borrowerRefId,
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

  Future<void> loadLibraryManagementSettings() async {
    final settings = await _adminService.getSchoolSettings();
    final lib = settings['libraryManagement'];
    if (lib is! Map) return;
    final map = Map<String, dynamic>.from(lib);
    libraryCategories.assignAll(
      (map['categories'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (e) => AdminLibraryCategoryRecord.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
    libraryCards.assignAll(
      (map['studentCards'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (e) => AdminStudentLibraryCardRecord.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
    final fine = map['lateFineRule'];
    if (fine is Map) {
      lateFineRule.value = AdminLateFineRule.fromJson(
        Map<String, dynamic>.from(fine),
      );
    }
  }

  Future<void> openLibraryCategoryDialog({
    AdminLibraryCategoryRecord? existing,
  }) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(existing == null ? 'Add Category' : 'Edit Category'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Category name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
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
    if (ok != true) return;
    if (nameCtrl.text.trim().isEmpty) {
      AppToast.show('Category name is required.');
      return;
    }
    final next = [
      ...libraryCategories.where((e) => e.id != existing?.id),
      AdminLibraryCategoryRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
      ),
    ];
    await _saveLibraryManagementSettings(
      categories: next.map((e) => e.toJson()).toList(),
    );
    libraryCategories.assignAll(next);
    AppToast.show('Library category saved.');
  }

  Future<void> deleteLibraryCategory(AdminLibraryCategoryRecord item) async {
    if (!await _confirm('Delete ${item.name}?')) return;
    final next = libraryCategories.where((e) => e.id != item.id).toList();
    await _saveLibraryManagementSettings(
      categories: next.map((e) => e.toJson()).toList(),
    );
    libraryCategories.assignAll(next);
    AppToast.show('Library category deleted.');
  }

  Future<void> openLibraryCardDialog({
    AdminStudentLibraryCardRecord? existing,
  }) async {
    String studentId =
        existing?.studentId ??
        (studentOptions.isNotEmpty ? studentOptions.first['id']! : '');
    final cardNoCtrl = TextEditingController(
      text: existing?.cardNo ?? 'LIB-${DateTime.now().millisecondsSinceEpoch}',
    );
    final issuedOnCtrl = TextEditingController(
      text:
          existing?.issuedOn ??
          DateTime.now().toIso8601String().substring(0, 10),
    );
    bool isActive = existing?.isActive ?? true;
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              existing == null ? 'Issue Library Card' : 'Edit Library Card',
            ),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: studentId.isEmpty ? null : studentId,
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: studentOptions
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['id'],
                              child: Text(item['label'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => studentId = value ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cardNoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Card number',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: issuedOnCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Issued on (YYYY-MM-DD)',
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
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return;
    if (studentId.isEmpty || cardNoCtrl.text.trim().isEmpty) {
      AppToast.show('Student and card number are required.');
      return;
    }
    final studentLabel =
        studentOptions.firstWhereOrNull(
          (e) => e['id'] == studentId,
        )?['label'] ??
        'Student';
    final next = [
      ...libraryCards.where((e) => e.id != existing?.id),
      AdminStudentLibraryCardRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        studentName: studentLabel,
        cardNo: cardNoCtrl.text.trim(),
        issuedOn: issuedOnCtrl.text.trim(),
        isActive: isActive,
      ),
    ];
    await _saveLibraryManagementSettings(
      cards: next.map((e) => e.toJson()).toList(),
    );
    libraryCards.assignAll(next);
    AppToast.show('Library card saved.');
  }

  Future<void> deleteLibraryCard(AdminStudentLibraryCardRecord item) async {
    if (!await _confirm('Delete card ${item.cardNo}?')) return;
    final next = libraryCards.where((e) => e.id != item.id).toList();
    await _saveLibraryManagementSettings(
      cards: next.map((e) => e.toJson()).toList(),
    );
    libraryCards.assignAll(next);
    AppToast.show('Library card deleted.');
  }

  Future<void> openLateFineRuleDialog() async {
    final current = lateFineRule.value;
    String type = current.type;
    final amountCtrl = TextEditingController(
      text: current.amount.toStringAsFixed(2),
    );
    final graceCtrl = TextEditingController(text: current.graceDays.toString());
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Late Fine Management'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Fine type'),
                    items: const [
                      DropdownMenuItem(
                        value: 'per_day',
                        child: Text('Per day fine'),
                      ),
                      DropdownMenuItem(
                        value: 'fixed',
                        child: Text('Fixed fine'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => type = value ?? 'per_day'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Fine amount'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: graceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Grace days'),
                  ),
                ],
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
    final amount = double.tryParse(amountCtrl.text.trim());
    final grace = int.tryParse(graceCtrl.text.trim());
    if (amount == null || amount < 0 || grace == null || grace < 0) {
      AppToast.show('Enter valid late fine values.');
      return;
    }
    final next = AdminLateFineRule(
      type: type,
      amount: amount,
      graceDays: grace,
    );
    await _saveLibraryManagementSettings(lateFineRuleData: next.toJson());
    lateFineRule.value = next;
    AppToast.show('Late fine rule saved.');
  }

  Future<void> _saveLibraryManagementSettings({
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? cards,
    Map<String, dynamic>? lateFineRuleData,
  }) async {
    final settings = await _adminService.getSchoolSettings();
    final existing = settings['libraryManagement'];
    final map = existing is Map<String, dynamic>
        ? Map<String, dynamic>.from(existing)
        : <String, dynamic>{};
    if (categories != null) map['categories'] = categories;
    if (cards != null) map['studentCards'] = cards;
    if (lateFineRuleData != null) map['lateFineRule'] = lateFineRuleData;
    await _adminService.patchSchoolSettings({'libraryManagement': map});
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
                      initialValue: itemId,
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
                      initialValue: type,
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

  Future<void> loadInventoryManagementSettings() async {
    final settings = await _adminService.getSchoolSettings();
    final raw = settings['inventoryManagement'];
    if (raw is! Map) {
      assets.clear();
      vendors.clear();
      purchaseOrders.clear();
      return;
    }
    final map = Map<String, dynamic>.from(raw);
    assets.assignAll(
      (map['assets'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => AdminAssetRecord.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
    vendors.assignAll(
      (map['vendors'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => AdminVendorRecord.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
    purchaseOrders.assignAll(
      (map['purchaseOrders'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (e) => AdminPurchaseOrderRecord.fromJson(e.cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  Future<void> openAssetDialog({AdminAssetRecord? existing}) async {
    final code = TextEditingController(text: existing?.assetCode ?? '');
    final name = TextEditingController(text: existing?.name ?? '');
    final category = TextEditingController(text: existing?.category ?? '');
    final assigned = TextEditingController(text: existing?.assignedTo ?? '');
    final date = TextEditingController(
      text: existing?.purchaseDate.isNotEmpty == true
          ? existing!.purchaseDate
          : DateTime.now().toIso8601String().substring(0, 10),
    );
    String status = existing?.status ?? 'AVAILABLE';
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Asset' : 'Edit Asset'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: code,
                    decoration: const InputDecoration(labelText: 'Asset code'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Asset name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: assigned,
                    decoration: const InputDecoration(labelText: 'Assigned to'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items:
                        const [
                              'AVAILABLE',
                              'ASSIGNED',
                              'MAINTENANCE',
                              'RETIRED',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => status = value ?? 'AVAILABLE'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: date,
                    decoration: const InputDecoration(
                      labelText: 'Purchase date (YYYY-MM-DD)',
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
      ),
    );
    if (ok != true || code.text.trim().isEmpty || name.text.trim().isEmpty) {
      if (ok == true) AppToast.show('Asset code and name are required.');
      return;
    }
    final next = [
      ...assets.where((e) => e.id != existing?.id),
      AdminAssetRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        assetCode: code.text.trim(),
        name: name.text.trim(),
        category: category.text.trim(),
        assignedTo: assigned.text.trim(),
        status: status,
        purchaseDate: date.text.trim(),
      ),
    ];
    assets.assignAll(next);
    await _saveInventoryManagementSettings();
    AppToast.show('Asset saved.');
  }

  Future<void> deleteAsset(AdminAssetRecord item) async {
    if (!await _confirm('Delete asset ${item.name}?')) return;
    assets.removeWhere((e) => e.id == item.id);
    await _saveInventoryManagementSettings();
    AppToast.show('Asset deleted.');
  }

  Future<void> openVendorDialog({AdminVendorRecord? existing}) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final contact = TextEditingController(text: existing?.contactPerson ?? '');
    final phone = TextEditingController(text: existing?.phone ?? '');
    final email = TextEditingController(text: existing?.email ?? '');
    final address = TextEditingController(text: existing?.address ?? '');
    bool isActive = existing?.isActive ?? true;
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Vendor' : 'Edit Vendor'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Vendor name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contact,
                    decoration: const InputDecoration(
                      labelText: 'Contact person',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: address,
                    decoration: const InputDecoration(labelText: 'Address'),
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || name.text.trim().isEmpty) {
      if (ok == true) AppToast.show('Vendor name is required.');
      return;
    }
    final next = [
      ...vendors.where((e) => e.id != existing?.id),
      AdminVendorRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.text.trim(),
        contactPerson: contact.text.trim(),
        phone: phone.text.trim(),
        email: email.text.trim(),
        address: address.text.trim(),
        isActive: isActive,
      ),
    ];
    vendors.assignAll(next);
    await _saveInventoryManagementSettings();
    AppToast.show('Vendor saved.');
  }

  Future<void> deleteVendor(AdminVendorRecord item) async {
    if (!await _confirm('Delete vendor ${item.name}?')) return;
    vendors.removeWhere((e) => e.id == item.id);
    await _saveInventoryManagementSettings();
    AppToast.show('Vendor deleted.');
  }

  Future<void> openPurchaseOrderDialog({
    AdminPurchaseOrderRecord? existing,
  }) async {
    if (vendors.isEmpty) {
      AppToast.show('Add vendors first.');
      return;
    }
    String vendorId = existing?.vendorId.isNotEmpty == true
        ? existing!.vendorId
        : vendors.first.id;
    final itemSummary = TextEditingController(
      text: existing?.itemSummary ?? '',
    );
    final amount = TextEditingController(
      text: existing?.totalAmount.toStringAsFixed(2) ?? '',
    );
    final expected = TextEditingController(
      text: existing?.expectedDate.isNotEmpty == true
          ? existing!.expectedDate
          : DateTime.now()
                .add(const Duration(days: 7))
                .toIso8601String()
                .substring(0, 10),
    );
    String status = existing?.status ?? 'DRAFT';
    final ok = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            existing == null ? 'Create Purchase Order' : 'Edit Purchase Order',
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: vendorId,
                    decoration: const InputDecoration(labelText: 'Vendor'),
                    items: vendors
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(e.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => vendorId = value ?? ''),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: itemSummary,
                    decoration: const InputDecoration(
                      labelText: 'Item summary',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total amount',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: expected,
                    decoration: const InputDecoration(
                      labelText: 'Expected date (YYYY-MM-DD)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items:
                        const [
                              'DRAFT',
                              'APPROVED',
                              'ORDERED',
                              'RECEIVED',
                              'CANCELLED',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => status = value ?? 'DRAFT'),
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
    final total = double.tryParse(amount.text.trim());
    if (ok != true || vendorId.isEmpty || total == null) {
      if (ok == true) AppToast.show('Vendor and valid amount are required.');
      return;
    }
    final vendorName =
        vendors.firstWhereOrNull((e) => e.id == vendorId)?.name ?? 'Vendor';
    final next = [
      ...purchaseOrders.where((e) => e.id != existing?.id),
      AdminPurchaseOrderRecord(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        poNumber:
            existing?.poNumber ??
            'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
        vendorId: vendorId,
        vendorName: vendorName,
        itemSummary: itemSummary.text.trim(),
        totalAmount: total,
        status: status,
        orderDate: existing?.orderDate.isNotEmpty == true
            ? existing!.orderDate
            : DateTime.now().toIso8601String().substring(0, 10),
        expectedDate: expected.text.trim(),
      ),
    ];
    purchaseOrders.assignAll(next);
    await _saveInventoryManagementSettings();
    AppToast.show('Purchase order saved.');
  }

  Future<void> updatePurchaseOrderStatus(
    AdminPurchaseOrderRecord item,
    String status,
  ) async {
    purchaseOrders.assignAll(
      purchaseOrders
          .map(
            (e) => e.id == item.id
                ? AdminPurchaseOrderRecord(
                    id: e.id,
                    poNumber: e.poNumber,
                    vendorId: e.vendorId,
                    vendorName: e.vendorName,
                    itemSummary: e.itemSummary,
                    totalAmount: e.totalAmount,
                    status: status,
                    orderDate: e.orderDate,
                    expectedDate: e.expectedDate,
                  )
                : e,
          )
          .toList(),
    );
    await _saveInventoryManagementSettings();
    AppToast.show('Purchase order status updated.');
  }

  Future<void> _saveInventoryManagementSettings() async {
    await _adminService.patchSchoolSettings({
      'inventoryManagement': {
        'assets': assets.map((e) => e.toJson()).toList(),
        'vendors': vendors.map((e) => e.toJson()).toList(),
        'purchaseOrders': purchaseOrders.map((e) => e.toJson()).toList(),
      },
    });
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

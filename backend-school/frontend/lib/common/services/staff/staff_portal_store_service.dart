import '../admin/admin_service.dart';
import 'staff_service.dart';

class StaffPortalStoreService {
  StaffPortalStoreService(this._adminService, this._staffService);

  final AdminService _adminService;
  final StaffService _staffService;

  String? _cachedStaffKey;

  Future<Map<String, dynamic>> readModule(String moduleKey) async {
    final portal = await _readPortal();
    final byStaff = _asMap(portal['byStaff']);
    final staffModules = _asMap(byStaff[await _staffKey()]);
    return _asMap(staffModules[moduleKey]);
  }

  Future<Map<String, dynamic>> patchModule(
    String moduleKey,
    Map<String, dynamic> patch,
  ) async {
    final portal = await _readPortal();
    final byStaff = _asMap(portal['byStaff']);
    final staffKey = await _staffKey();
    final staffModules = _asMap(byStaff[staffKey]);
    final current = _asMap(staffModules[moduleKey]);
    staffModules[moduleKey] = {...current, ...patch};
    byStaff[staffKey] = staffModules;
    portal['byStaff'] = byStaff;
    await _adminService.patchSchoolSettings({'staffPortal': portal});
    return _asMap(staffModules[moduleKey]);
  }

  Future<List<Map<String, dynamic>>> readCollection(
    String moduleKey,
    String collectionKey,
  ) async {
    final module = await readModule(moduleKey);
    return _asListOfMaps(module[collectionKey]);
  }

  Future<List<Map<String, dynamic>>> saveCollection(
    String moduleKey,
    String collectionKey,
    List<Map<String, dynamic>> items,
  ) async {
    final nextItems = items
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    await patchModule(moduleKey, {collectionKey: nextItems});
    return nextItems;
  }

  Future<List<Map<String, dynamic>>> upsertCollectionItem({
    required String moduleKey,
    required String collectionKey,
    String? id,
    required Map<String, dynamic> payload,
  }) async {
    final items = await readCollection(moduleKey, collectionKey);
    final itemId = _resolveItemId(id, payload);
    final nextItem = {
      ...payload,
      'id': itemId,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    final next = <Map<String, dynamic>>[
      ...items.where((item) => item['id']?.toString() != itemId),
      nextItem,
    ];
    await saveCollection(moduleKey, collectionKey, next);
    return next;
  }

  Future<List<Map<String, dynamic>>> deleteCollectionItem({
    required String moduleKey,
    required String collectionKey,
    required String id,
  }) async {
    final items = await readCollection(moduleKey, collectionKey);
    final next = items
        .where((item) => item['id']?.toString() != id)
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    await saveCollection(moduleKey, collectionKey, next);
    return next;
  }

  Future<Map<String, dynamic>> _readPortal() async {
    final settings = await _adminService.getSchoolSettings();
    return _asMap(settings['staffPortal']);
  }

  Future<String> _staffKey() async {
    final cached = _cachedStaffKey;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    try {
      final profile = await _staffService.getProfile();
      final candidates = [
        profile['staffId'],
        profile['id'],
        profile['employeeCode'],
        profile['email'],
        profile['contact'],
        profile['name'],
      ];
      for (final value in candidates) {
        final normalized = _normalizeKey(value);
        if (normalized.isNotEmpty) {
          _cachedStaffKey = normalized;
          return normalized;
        }
      }
    } catch (_) {
      // Fall back to a shared staff namespace when the live profile
      // endpoint is temporarily unavailable.
    }
    _cachedStaffKey = 'default';
    return _cachedStaffKey!;
  }

  String _resolveItemId(String? id, Map<String, dynamic> payload) {
    final fromId = (id ?? payload['id'])?.toString().trim() ?? '';
    if (fromId.isNotEmpty) {
      return fromId;
    }
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _normalizeKey(dynamic value) {
    final raw = value?.toString().trim().toLowerCase() ?? '';
    if (raw.isEmpty) {
      return '';
    }
    final normalized = raw.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return normalized.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asListOfMaps(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }
    return value
        .whereType<Map>()
        .map((item) => item.map((key, data) => MapEntry(key.toString(), data)))
        .toList(growable: false);
  }
}

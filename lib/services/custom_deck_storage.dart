import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/custom_deck_record.dart';

/// CRUD storage for user-created decks, persisted locally 
/// 
/// Same shape as StorageService
/// keep an in-memory cache as the source, and only touch disk again on writes.
class CustomDeckStorage {
  CustomDeckStorage._(this._prefs, Map<String, CustomDeckRecord> initial) : _cache = initial;

  static const _kKey = 'custom_decks_v1';
  final SharedPreferences _prefs;
  final Map<String, CustomDeckRecord> _cache; // key by CustomDeckRecord.id

  static Future<CustomDeckStorage> create() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_kKey);
    Map<String, CustomDeckRecord> initial = {};
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      for (final entry in decoded) {
        final record = CustomDeckRecord.fromJson(entry as Map<String, dynamic>);
        initial[record.id] = record;
      }
    }

    return CustomDeckStorage._(prefs, initial);
  }

  /// All custom decks
  List<CustomDeckRecord> get all => _cache.values.toList(growable: false);

  CustomDeckRecord? byId(String id) => _cache[id];

  /// Creates or overwrites a deck (matched by [record.id]).
  Future<void> save(CustomDeckRecord record) async {
    _cache[record.id] = record;
    await _persist();
  }

  Future<void> delete(String id) async {
    _cache.remove(id);
    await _persist();
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(_cache.values.map((r) => r.toJson()).toList());
    await _prefs.setString(_kKey, encoded);
  }

  /// generates a new unique id for a new custom deck.
  static String newId() => 'custom_${DateTime.now().microsecondsSinceEpoch}';
}

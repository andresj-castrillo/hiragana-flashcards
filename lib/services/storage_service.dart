import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Per card progress persisted locally (no backend/account needed).
///
/// Stored as `kanaId -> {correct, incorrect}` map under one SharedPreferences key.
class CardStats {
  const CardStats({
    this.correctCount = 0, 
    this.incorrectCount = 0,
    this.recentAttempts = const [],
    });
  
  /// how many attempts to remember per card 
  /// used for recall trend of that recent attempts 
  /// not use only lifetime average 
  static const int maxRecentAttempts = 10;

  final int correctCount;
  final int incorrectCount;
  
  // oldest to newest list of recent pass fail result of that kana, max -> maxRecentAttempts
  final List<bool> recentAttempts;

  int get totalAttempts => correctCount + incorrectCount;
 
  double get accuracy => totalAttempts == 0 ? 0 : correctCount / totalAttempts;
 
  CardStats withResult(bool wasCorrect) {
    final updatedRecent = [...recentAttempts, wasCorrect];
    if (updatedRecent.length > maxRecentAttempts) {
      updatedRecent.removeAt(0);
    }
    return CardStats(
      correctCount: correctCount + (wasCorrect ? 1 : 0),
      incorrectCount: incorrectCount + (wasCorrect ? 0 : 1),
      recentAttempts: updatedRecent,
    );
  }

  Map<String, dynamic> toJson() => {
        'c': correctCount,
        'i': incorrectCount,
        'r': recentAttempts,
      };

  factory CardStats.fromJson(Map<String, dynamic> json) => CardStats(
        correctCount: json['c'] as int? ?? 0,
        incorrectCount: json['i'] as int? ?? 0,
        // Absent for progress saved before this field existed defaults to empty
        recentAttempts: (json['r'] as List<dynamic>?)?.cast<bool>() ?? const [],
      );
}
 
class StorageService {
  StorageService._(this._prefs, Map<String, CardStats> initialProgress)
      : _cache = initialProgress;
 
  static const _kProgressKey = 'kana_progress_v1';
  final SharedPreferences _prefs;
 
  // In-memory cache, kept in sync with disk.
  final Map<String, CardStats> _cache;
 
  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
 
    // Read and parse the JSON blob ONCE when the service is created.
    final raw = prefs.getString(_kProgressKey);
    Map<String, CardStats> initialMap = {};
 
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      initialMap = decoded.map(
        (id, value) => MapEntry(id, CardStats.fromJson(value as Map<String, dynamic>)),
      );
    }
 
    return StorageService._(prefs, initialMap);
  }
 
  // Instant lookup straight from memory 
  CardStats statsFor(String kanaId) => _cache[kanaId] ?? const CardStats();
 
  Future<void> recordAttempt(String kanaId, {required bool wasCorrect}) async {
    final current = _cache[kanaId] ?? const CardStats();
    _cache[kanaId] = current.withResult(wasCorrect);
 
    // Persist the change to disk.
    await _persist();
  }
 
  Future<void> _persist() async {
    final encoded = jsonEncode(_cache.map((id, s) => MapEntry(id, s.toJson())));
    await _prefs.setString(_kProgressKey, encoded);
  }
 
  Future<void> resetProgress() async {
    _cache.clear();
    await _prefs.remove(_kProgressKey);
  }
}

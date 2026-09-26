import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Per card progress persisted locally (no backend/account needed).
///
/// Stored as `kanaId -> {correct, incorrect}` map under one SharedPreferences key.
class CardStats {
  const CardStats({this.correctCount = 0, this.incorrectCount = 0});

  final int correctCount;
  final int incorrectCount;

  int get totalAttempts => correctCount + incorrectCount;

  double get accuracy => totalAttempts == 0 ? 0 : correctCount / totalAttempts;

  CardStats withResult(bool wasCorrect) => CardStats(
        correctCount: correctCount + (wasCorrect ? 1 : 0),
        incorrectCount: incorrectCount + (wasCorrect ? 0 : 1),
      );

  Map<String, dynamic> toJson() => {'c': correctCount, 'i': incorrectCount};

  factory CardStats.fromJson(Map<String, dynamic> json) => CardStats(
        correctCount: json['c'] as int? ?? 0,
        incorrectCount: json['i'] as int? ?? 0,
      );
}

class StorageService {
  StorageService._(this._prefs);

  static const _kProgressKey = 'kana_progress_v1';

  final SharedPreferences _prefs;

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  Map<String, CardStats> _readAll() {
    final raw = _prefs.getString(_kProgressKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (id, value) => MapEntry(id, CardStats.fromJson(value as Map<String, dynamic>)),
    );
  }

  Future<void> _writeAll(Map<String, CardStats> stats) async {
    final encoded = jsonEncode(stats.map((id, s) => MapEntry(id, s.toJson())));
    await _prefs.setString(_kProgressKey, encoded);
  }

  CardStats statsFor(String kanaId) => _readAll()[kanaId] ?? const CardStats();

  Future<void> recordAttempt(String kanaId, {required bool wasCorrect}) async {
    final all = _readAll();
    final current = all[kanaId] ?? const CardStats();
    all[kanaId] = current.withResult(wasCorrect);
    await _writeAll(all);
  }

  Future<void> resetProgress() async => _prefs.remove(_kProgressKey);
}

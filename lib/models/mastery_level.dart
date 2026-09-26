/// How well a card seems to be known from its practice stats.
///
/// plain classification 
/// in the screens decide how to render 
enum MasteryLevel {

  /// Never attempted.
  notStudied,

  /// Attempted, but accuracy is low — needs focused review.
  needsWork,

  /// Reasonable accuracy, but not enough attempts (or not high enough accuracy) yet to call it mastered.
  learning,

  /// Consistently correct across enough attempts to trust the number.
  mastered,
}

/// Turns raw stats into a [MasteryLevel] using thresholds.
abstract final class MasteryEvaluator {

  /// below this accuracy, a studied card is flagged as needing work, regardless of how many times its been attempted.
  static const double needsWorkMaxAccuracy = 0.5;

  /// minimum accuracy to be considered mastered
  static const double masteredMinAccuracy = 0.85;

  /// minimum number of attempts before "mastered" can apply
  static const int masteredMinAttempts = 5;

  static MasteryLevel evaluate({required int totalAttempts, required double accuracy}) {
    if (totalAttempts == 0) return MasteryLevel.notStudied;
    
    if (accuracy < needsWorkMaxAccuracy) return MasteryLevel.needsWork;

    if (accuracy >= masteredMinAccuracy && totalAttempts >= masteredMinAttempts) {
      return MasteryLevel.mastered;
    }
    
    return MasteryLevel.learning;
  }
}

extension MasteryLevelLabel on MasteryLevel {
  String get label {
    switch (this) {
      case MasteryLevel.notStudied:
        return 'Not studied';
      case MasteryLevel.needsWork:
        return 'Needs work';
      case MasteryLevel.learning:
        return 'Learning';
      case MasteryLevel.mastered:
        return 'Mastered';
    }
  }
}

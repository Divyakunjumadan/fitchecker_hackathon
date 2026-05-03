enum FitStatus {
  perfectFit,
  slightAdjustments,
  notRecommended,
}

class FitAdjustment {
  final String area; // e.g., "bust", "waist", "hip"
  final double difference; // in cm
  final String direction; // "tight" or "loose"
  final String suggestion;

  FitAdjustment({
    required this.area,
    required this.difference,
    required this.direction,
    required this.suggestion,
  });
}

class FitResult {
  final FitStatus status;
  final String statusText;
  final List<FitAdjustment> adjustments;
  final String summary;
  final String? aiAnalysis; // AI-generated styling advice

  FitResult({
    required this.status,
    required this.statusText,
    required this.adjustments,
    required this.summary,
    this.aiAnalysis,
  });

  String get statusEmoji {
    switch (status) {
      case FitStatus.perfectFit:
        return '✅';
      case FitStatus.slightAdjustments:
        return '⚠️';
      case FitStatus.notRecommended:
        return '❌';
    }
  }

  FitResult copyWith({String? aiAnalysis}) {
    return FitResult(
      status: status,
      statusText: statusText,
      adjustments: adjustments,
      summary: summary,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
    );
  }
}

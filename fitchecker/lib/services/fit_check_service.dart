import '../models/measurement.dart';
import '../models/fit_result.dart';

class FitCheckService {
  // ─── MOCK SIZE CHARTS (in cm) ────────────────────────────
  // Each brand has sizes mapped to measurements for each gender.

  static final Map<String, Map<String, Map<String, double>>> _femaleSizeCharts = {
    'Zudio': {
      'XS': {'bust': 78, 'waist': 60, 'hip': 84},
      'S':  {'bust': 82, 'waist': 64, 'hip': 88},
      'M':  {'bust': 88, 'waist': 70, 'hip': 94},
      'L':  {'bust': 94, 'waist': 76, 'hip': 100},
      'XL': {'bust': 100, 'waist': 82, 'hip': 106},
      'XXL':{'bust': 106, 'waist': 88, 'hip': 112},
    },
    'H&M': {
      'XS': {'bust': 80, 'waist': 62, 'hip': 86},
      'S':  {'bust': 84, 'waist': 66, 'hip': 90},
      'M':  {'bust': 90, 'waist': 72, 'hip': 96},
      'L':  {'bust': 96, 'waist': 78, 'hip': 102},
      'XL': {'bust': 102, 'waist': 84, 'hip': 108},
      'XXL':{'bust': 108, 'waist': 90, 'hip': 114},
    },
    'Zara': {
      'XS': {'bust': 79, 'waist': 61, 'hip': 85},
      'S':  {'bust': 83, 'waist': 65, 'hip': 89},
      'M':  {'bust': 89, 'waist': 71, 'hip': 95},
      'L':  {'bust': 95, 'waist': 77, 'hip': 101},
      'XL': {'bust': 101, 'waist': 83, 'hip': 107},
      'XXL':{'bust': 107, 'waist': 89, 'hip': 113},
    },
  };

  static final Map<String, Map<String, Map<String, double>>> _maleSizeCharts = {
    'Zudio': {
      'XS': {'chest': 86, 'waist': 72, 'shoulder': 42},
      'S':  {'chest': 90, 'waist': 76, 'shoulder': 44},
      'M':  {'chest': 96, 'waist': 82, 'shoulder': 46},
      'L':  {'chest': 102, 'waist': 88, 'shoulder': 48},
      'XL': {'chest': 108, 'waist': 94, 'shoulder': 50},
      'XXL':{'chest': 114, 'waist': 100, 'shoulder': 52},
    },
    'H&M': {
      'XS': {'chest': 88, 'waist': 74, 'shoulder': 43},
      'S':  {'chest': 92, 'waist': 78, 'shoulder': 45},
      'M':  {'chest': 98, 'waist': 84, 'shoulder': 47},
      'L':  {'chest': 104, 'waist': 90, 'shoulder': 49},
      'XL': {'chest': 110, 'waist': 96, 'shoulder': 51},
      'XXL':{'chest': 116, 'waist': 102, 'shoulder': 53},
    },
    'Zara': {
      'XS': {'chest': 87, 'waist': 73, 'shoulder': 42.5},
      'S':  {'chest': 91, 'waist': 77, 'shoulder': 44.5},
      'M':  {'chest': 97, 'waist': 83, 'shoulder': 46.5},
      'L':  {'chest': 103, 'waist': 89, 'shoulder': 48.5},
      'XL': {'chest': 109, 'waist': 95, 'shoulder': 50.5},
      'XXL':{'chest': 115, 'waist': 101, 'shoulder': 52.5},
    },
  };

  /// Main fit check function
  /// Compares user measurements against clothing size for a given brand
  FitResult checkFit({
    required Measurement userMeasurements,
    required String brand,
    required String size,
  }) {
    final gender = userMeasurements.gender.toLowerCase();
    final List<FitAdjustment> adjustments = [];

    Map<String, double>? sizeChart;

    if (gender == 'female') {
      sizeChart = _femaleSizeCharts[brand]?[size];
    } else {
      sizeChart = _maleSizeCharts[brand]?[size];
    }

    if (sizeChart == null) {
      return FitResult(
        status: FitStatus.notRecommended,
        statusText: 'Not Recommended',
        adjustments: [],
        summary: 'Size chart not available for $brand in size $size.',
      );
    }

    // Compare each measurement
    if (gender == 'female') {
      _compareMeasurement(
        adjustments: adjustments,
        area: 'Bust',
        userValue: userMeasurements.bust,
        chartValue: sizeChart['bust'],
      );
      _compareMeasurement(
        adjustments: adjustments,
        area: 'Waist',
        userValue: userMeasurements.waist,
        chartValue: sizeChart['waist'],
      );
      _compareMeasurement(
        adjustments: adjustments,
        area: 'Hip',
        userValue: userMeasurements.hip,
        chartValue: sizeChart['hip'],
      );
    } else {
      _compareMeasurement(
        adjustments: adjustments,
        area: 'Chest',
        userValue: userMeasurements.chest,
        chartValue: sizeChart['chest'],
      );
      _compareMeasurement(
        adjustments: adjustments,
        area: 'Waist',
        userValue: userMeasurements.waist,
        chartValue: sizeChart['waist'],
      );
      _compareMeasurement(
        adjustments: adjustments,
        area: 'Shoulder',
        userValue: userMeasurements.shoulder,
        chartValue: sizeChart['shoulder'],
      );
    }

    // Determine overall fit status
    final FitStatus status;
    final String statusText;
    final String summary;

    if (adjustments.isEmpty) {
      status = FitStatus.perfectFit;
      statusText = 'Perfect Fit ✨';
      summary = 'This size fits you perfectly! No adjustments needed.';
    } else {
      final maxDiff = adjustments
          .map((a) => a.difference)
          .reduce((a, b) => a > b ? a : b);

      if (maxDiff <= 4.0) {
        status = FitStatus.slightAdjustments;
        statusText = 'Slight Adjustments Needed';
        summary = _buildAdjustmentSummary(adjustments);
      } else {
        status = FitStatus.notRecommended;
        statusText = 'Not Recommended';
        summary = 'This size has significant fit differences. Consider trying a different size.';
      }
    }

    return FitResult(
      status: status,
      statusText: statusText,
      adjustments: adjustments,
      summary: summary,
    );
  }

  void _compareMeasurement({
    required List<FitAdjustment> adjustments,
    required String area,
    required double? userValue,
    required double? chartValue,
  }) {
    if (userValue == null || chartValue == null) return;

    final diff = userValue - chartValue;
    final absDiff = diff.abs();

    // Within 2cm tolerance → perfect fit for this area
    if (absDiff <= 2.0) return;

    if (diff > 0) {
      // User is bigger → clothing will be tight
      adjustments.add(FitAdjustment(
        area: area,
        difference: absDiff,
        direction: 'tight',
        suggestion: '$area may feel tight by ${absDiff.toStringAsFixed(1)} cm. Consider sizing up.',
      ));
    } else {
      // User is smaller → clothing will be loose
      adjustments.add(FitAdjustment(
        area: area,
        difference: absDiff,
        direction: 'loose',
        suggestion: '$area may be loose by ${absDiff.toStringAsFixed(1)} cm. Consider sizing down or tailoring.',
      ));
    }
  }

  String _buildAdjustmentSummary(List<FitAdjustment> adjustments) {
    final parts = adjustments.map((a) {
      if (a.direction == 'tight') {
        return '${a.area}: ${a.difference.toStringAsFixed(1)} cm tight';
      } else {
        return '${a.area}: ${a.difference.toStringAsFixed(1)} cm loose';
      }
    });
    return 'Minor adjustments recommended:\n${parts.join('\n')}';
  }

  /// Get available brands
  List<String> get availableBrands => ['Zudio', 'H&M', 'Zara'];

  /// Get available sizes for a brand
  List<String> getAvailableSizes(String brand) {
    return ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  }
}

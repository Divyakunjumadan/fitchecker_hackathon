class Measurement {
  final String? id;
  final String profileId;
  final String gender;
  // Female measurements
  final double? bust;
  final double? waist;
  final double? hip;
  // Male measurements
  final double? chest;
  final double? shoulder;
  // waist is shared between both genders

  Measurement({
    this.id,
    required this.profileId,
    required this.gender,
    this.bust,
    this.waist,
    this.hip,
    this.chest,
    this.shoulder,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'] as String?,
      profileId: json['profile_id'] as String,
      gender: json['gender'] as String,
      bust: (json['bust'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hip: (json['hip'] as num?)?.toDouble(),
      chest: (json['chest'] as num?)?.toDouble(),
      shoulder: (json['shoulder'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'profile_id': profileId,
      'gender': gender,
      'bust': bust,
      'waist': waist,
      'hip': hip,
      'chest': chest,
      'shoulder': shoulder,
    };
  }

  Measurement copyWith({
    String? id,
    String? profileId,
    String? gender,
    double? bust,
    double? waist,
    double? hip,
    double? chest,
    double? shoulder,
  }) {
    return Measurement(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      gender: gender ?? this.gender,
      bust: bust ?? this.bust,
      waist: waist ?? this.waist,
      hip: hip ?? this.hip,
      chest: chest ?? this.chest,
      shoulder: shoulder ?? this.shoulder,
    );
  }
}

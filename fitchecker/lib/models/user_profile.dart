class UserProfile {
  final String? id;
  final String userId;
  final String name;
  final String gender;
  final double height; // in cm
  final double weight; // in kg
  final String? profileImageUrl;
  final DateTime? createdAt;

  UserProfile({
    this.id,
    required this.userId,
    required this.name,
    required this.gender,
    required this.height,
    required this.weight,
    this.profileImageUrl,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'gender': gender,
      'height': height,
      'weight': weight,
      'profile_image_url': profileImageUrl,
    };
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? gender,
    double? height,
    double? weight,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

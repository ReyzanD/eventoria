import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.avatarUrl,
    required super.role,
    required super.createdAt,
    super.isVerified = false,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] as String?)?.toLowerCase().trim();

    UserRole parsedRole;
    switch (roleStr) {
      case 'admin':
        parsedRole = UserRole.admin;
        break;
      case 'organizer':
        parsedRole = UserRole.organizer;
        break;
      case 'attendee':
      default:
        parsedRole = UserRole.attendee;
    }

    return ProfileModel(
      id: json['id'] as String,
      fullName: (json['full_name'] as String?) ?? 'Venu User',
      email: (json['email'] as String?) ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: parsedRole,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
      'is_verified': isVerified,
    };
  }
}

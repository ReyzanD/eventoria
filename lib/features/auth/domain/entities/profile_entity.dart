enum UserRole { attendee, organizer }

class ProfileEntity {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final UserRole role;
  final DateTime createdAt;

  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });
}

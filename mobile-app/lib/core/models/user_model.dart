import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String tcId;
  final String firstName;
  final String lastName;
  final String? phone;
  final bool isEmailVerified;
  final bool isMFASetup;
  final bool isActive;
  final String role;
  final String subscription;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? preferences;
  final List<String>? permissions;

  const User({
    required this.id,
    required this.email,
    required this.tcId,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.isEmailVerified,
    required this.isMFASetup,
    required this.isActive,
    required this.role,
    required this.subscription,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.preferences,
    this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? tcId,
    String? firstName,
    String? lastName,
    String? phone,
    bool? isEmailVerified,
    bool? isMFASetup,
    bool? isActive,
    String? role,
    String? subscription,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
    List<String>? permissions,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      tcId: tcId ?? this.tcId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isMFASetup: isMFASetup ?? this.isMFASetup,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      subscription: subscription ?? this.subscription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
      permissions: permissions ?? this.permissions,
    );
  }

  String get fullName => '$firstName $lastName';
  String get displayName => firstName.isNotEmpty ? firstName : email;
  bool get isPremium => subscription == 'premium';
  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';

  bool hasPermission(String permission) {
    return permissions?.contains(permission) ?? false;
  }

  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((permission) => hasPermission(permission));
  }

  bool hasAllPermissions(List<String> permissions) {
    return permissions.every((permission) => hasPermission(permission));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $fullName, role: $role)';
  }
}

@JsonSerializable()
class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatar;
  final Map<String, dynamic>? preferences;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatar,
    this.preferences,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  String get fullName => '$firstName $lastName';
  String get displayName => firstName.isNotEmpty ? firstName : 'User';

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
    Map<String, dynamic>? preferences,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      preferences: preferences ?? this.preferences,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class UserSession {
  final String id;
  final String userId;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String ipAddress;
  final String userAgent;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;

  const UserSession({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.ipAddress,
    required this.userAgent,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) => _$UserSessionFromJson(json);
  Map<String, dynamic> toJson() => _$UserSessionToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());
  bool get isExpiringSoon => timeUntilExpiry.inHours < 1;

  UserSession copyWith({
    String? id,
    String? userId,
    String? deviceId,
    String? deviceName,
    String? deviceType,
    String? ipAddress,
    String? userAgent,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return UserSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

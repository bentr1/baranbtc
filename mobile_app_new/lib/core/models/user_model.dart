import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final bool isEmailVerified;
  final bool isMFASetup;
  final bool isActive;
  final List<String> roles;
  final List<String> permissions;
  final UserProfile? profile;
  final UserSession? session;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    this.isEmailVerified = false,
    this.isMFASetup = false,
    this.isActive = true,
    this.roles = const [],
    this.permissions = const [],
    this.profile,
    this.session,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
    bool? isEmailVerified,
    bool? isMFASetup,
    bool? isActive,
    List<String>? roles,
    List<String>? permissions,
    UserProfile? profile,
    UserSession? session,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isMFASetup: isMFASetup ?? this.isMFASetup,
      isActive: isActive ?? this.isActive,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      profile: profile ?? this.profile,
      session: session ?? this.session,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class UserProfile {
  final String? bio;
  final String? location;
  final String? website;
  final String? timezone;
  final String? language;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? settings;

  const UserProfile({
    this.bio,
    this.location,
    this.website,
    this.timezone,
    this.language,
    this.preferences,
    this.settings,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? bio,
    String? location,
    String? website,
    String? timezone,
    String? language,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? settings,
  }) {
    return UserProfile(
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      preferences: preferences ?? this.preferences,
      settings: settings ?? this.settings,
    );
  }
}

@JsonSerializable()
class UserSession {
  final String id;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String? ipAddress;
  final String? userAgent;
  final String? location;
  final bool isActive;
  final DateTime lastActivity;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const UserSession({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.ipAddress,
    this.userAgent,
    this.location,
    this.isActive = true,
    required this.lastActivity,
    required this.createdAt,
    this.expiresAt,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) => _$UserSessionFromJson(json);
  Map<String, dynamic> toJson() => _$UserSessionToJson(this);

  UserSession copyWith({
    String? id,
    String? deviceId,
    String? deviceName,
    String? deviceType,
    String? ipAddress,
    String? userAgent,
    String? location,
    bool? isActive,
    DateTime? lastActivity,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return UserSession(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      lastActivity: lastActivity ?? this.lastActivity,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
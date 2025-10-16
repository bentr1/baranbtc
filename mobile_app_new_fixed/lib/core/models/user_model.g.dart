// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isMFASetup: json['isMFASetup'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      profile: json['profile'] == null
          ? null
          : UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      session: json['session'] == null
          ? null
          : UserSession.fromJson(json['session'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'isEmailVerified': instance.isEmailVerified,
      'isMFASetup': instance.isMFASetup,
      'isActive': instance.isActive,
      'roles': instance.roles,
      'permissions': instance.permissions,
      'profile': instance.profile,
      'session': instance.session,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      timezone: json['timezone'] as String?,
      language: json['language'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      settings: json['settings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'bio': instance.bio,
      'location': instance.location,
      'website': instance.website,
      'timezone': instance.timezone,
      'language': instance.language,
      'preferences': instance.preferences,
      'settings': instance.settings,
    };

UserSession _$UserSessionFromJson(Map<String, dynamic> json) => UserSession(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      deviceType: json['deviceType'] as String,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      location: json['location'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$UserSessionToJson(UserSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'deviceType': instance.deviceType,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'location': instance.location,
      'isActive': instance.isActive,
      'lastActivity': instance.lastActivity.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

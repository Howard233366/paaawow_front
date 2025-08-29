// User related data models

class UserProfile {
  final String id;
  final String email;
  final String username;
  final String? avatar;
  final UserProfileData profile;
  final UserSettings settings;

  const UserProfile({
    required this.id,
    required this.email,
    required this.username,
    this.avatar,
    required this.profile,
    required this.settings,
  });

  // Getter for backward compatibility
  UserProfileData get userData => profile;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'],
      profile: UserProfileData.fromJson(json['profile'] ?? {}),
      settings: UserSettings.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar': avatar,
      'profile': profile.toJson(),
      'settings': settings.toJson(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? username,
    String? avatar,
    UserProfileData? profile,
    UserSettings? settings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
    );
  }
}

class UserProfileData {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? address;
  final String? gender;
  final String? birthday;
  final String? personalSignature;
  // Additional fields for backward compatibility
  final String? userId;
  final String? username;
  final String? email;
  final String? location;
  final String? avatarUrl;
  final int? createdAt;
  final int? updatedAt;

  const UserProfileData({
    required this.firstName,
    this.lastName = '',
    this.phone,
    this.address,
    this.gender,
    this.birthday,
    this.personalSignature,
    // Additional fields
    this.userId,
    this.username,
    this.email,
    this.location,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      address: json['address'],
      gender: json['gender'],
      birthday: json['birthday'],
      personalSignature: json['personalSignature'],
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      location: json['location'],
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'address': address,
      'gender': gender,
      'birthday': birthday,
      'personalSignature': personalSignature,
      'userId': userId,
      'username': username,
      'email': email,
      'location': location,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserProfileData copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? gender,
    String? birthday,
    String? personalSignature,
    String? userId,
    String? username,
    String? email,
    String? location,
    String? avatarUrl,
    int? createdAt,
    int? updatedAt,
  }) {
    return UserProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      personalSignature: personalSignature ?? this.personalSignature,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserSettings {
  final String language;
  final bool notifications;
  final bool dataSharing;
  // Additional fields for backward compatibility
  final bool? notificationsEnabled;
  final bool? soundEnabled;
  final bool? vibrationEnabled;
  final String? theme;

  const UserSettings({
    this.language = 'zh-CN',
    this.notifications = true,
    this.dataSharing = false,
    this.notificationsEnabled,
    this.soundEnabled,
    this.vibrationEnabled,
    this.theme,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      language: json['language'] ?? 'zh-CN',
      notifications: json['notifications'] ?? true,
      dataSharing: json['dataSharing'] ?? false,
      notificationsEnabled: json['notificationsEnabled'],
      soundEnabled: json['soundEnabled'],
      vibrationEnabled: json['vibrationEnabled'],
      theme: json['theme'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'notifications': notifications,
      'dataSharing': dataSharing,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'theme': theme,
    };
  }

  UserSettings copyWith({
    String? language,
    bool? notifications,
    bool? dataSharing,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? theme,
  }) {
    return UserSettings(
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      dataSharing: dataSharing ?? this.dataSharing,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      theme: theme ?? this.theme,
    );
  }
}

class UpdateProfileRequest {
  final UserProfileData? profile;
  final UserSettings? settings;

  const UpdateProfileRequest({
    this.profile,
    this.settings,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequest(
      profile: json['profile'] != null 
          ? UserProfileData.fromJson(json['profile'])
          : null,
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (profile != null) 'profile': profile!.toJson(),
      if (settings != null) 'settings': settings!.toJson(),
    };
  }
}
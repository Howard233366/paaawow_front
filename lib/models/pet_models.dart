// Pet related data models

enum PetType {
  dog,
  cat;

  String get displayName {
    switch (this) {
      case PetType.dog:
        return 'Dog';
      case PetType.cat:
        return 'Cat';
    }
  }
}

enum PetGender {
  male,
  female,
  unknown;

  String get displayName {
    switch (this) {
      case PetGender.male:
        return 'Male';
      case PetGender.female:
        return 'Female';
      case PetGender.unknown:
        return 'Unknown';
    }
  }
}

enum ActivityStatus {
  sleeping,
  resting,
  active,
  running,
  playing;

  String get displayName {
    switch (this) {
      case ActivityStatus.sleeping:
        return 'Sleeping';
      case ActivityStatus.resting:
        return 'Resting';
      case ActivityStatus.active:
        return 'Active';
      case ActivityStatus.running:
        return 'Running';
      case ActivityStatus.playing:
        return 'Playing';
    }
  }
}

class PetInfo {
  final String id;
  final PetType type;
  final String name;
  final String breed;
  final PetGender gender;
  final String birthday;
  final String? sterilizationDate;
  final String profile;
  final String color;
  final double weight;
  // Cat specific properties
  final String? ribCage;
  final String? lim;
  // Dog specific properties
  final String? height;

  const PetInfo({
    required this.id,
    required this.type,
    required this.name,
    required this.breed,
    required this.gender,
    required this.birthday,
    this.sterilizationDate,
    required this.profile,
    required this.color,
    required this.weight,
    this.ribCage,
    this.lim,
    this.height,
  });

  factory PetInfo.fromJson(Map<String, dynamic> json) {
    return PetInfo(
      id: json['id'] ?? '',
      type: PetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PetType.dog,
      ),
      name: json['name'] ?? '',
      breed: json['breed'] ?? '',
      gender: PetGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => PetGender.unknown,
      ),
      birthday: json['birthday'] ?? '',
      sterilizationDate: json['sterilizationDate'],
      profile: json['profile'] ?? '',
      color: json['color'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      ribCage: json['ribCage'],
      lim: json['lim'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'breed': breed,
      'gender': gender.name,
      'birthday': birthday,
      'sterilizationDate': sterilizationDate,
      'profile': profile,
      'color': color,
      'weight': weight,
      'ribCage': ribCage,
      'lim': lim,
      'height': height,
    };
  }

  PetInfo copyWith({
    String? id,
    PetType? type,
    String? name,
    String? breed,
    PetGender? gender,
    String? birthday,
    String? sterilizationDate,
    String? profile,
    String? color,
    double? weight,
    String? ribCage,
    String? lim,
    String? height,
  }) {
    return PetInfo(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      sterilizationDate: sterilizationDate ?? this.sterilizationDate,
      profile: profile ?? this.profile,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      ribCage: ribCage ?? this.ribCage,
      lim: lim ?? this.lim,
      height: height ?? this.height,
    );
  }
}

class PetAnimation {
  final String fileName;
  final int durationSeconds;
  final bool hasGif;

  const PetAnimation({
    required this.fileName,
    required this.durationSeconds,
    this.hasGif = true,
  });

  String getPreferredFileName() {
    if (hasGif) {
      return fileName.replaceAll('.webp', '.gif');
    }
    return fileName;
  }

  factory PetAnimation.fromJson(Map<String, dynamic> json) {
    return PetAnimation(
      fileName: json['fileName'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 0,
      hasGif: json['hasGif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'durationSeconds': durationSeconds,
      'hasGif': hasGif,
    };
  }
}

class PetProfile {
  final String id;
  final String petType;
  final String petName;
  final String? breed;
  final int? age;
  final List<String> characteristics;
  final List<PetAnimation> animations;
  final String? collarId;
  final bool isSelected;
  final ActivityStatus activityStatus;

  const PetProfile({
    required this.id,
    required this.petType,
    required this.petName,
    this.breed,
    this.age,
    this.characteristics = const [],
    this.animations = const [],
    this.collarId,
    this.isSelected = false,
    this.activityStatus = ActivityStatus.resting,
  });

  factory PetProfile.fromJson(Map<String, dynamic> json) {
    return PetProfile(
      id: json['id'] ?? '',
      petType: json['petType'] ?? '',
      petName: json['petName'] ?? '',
      breed: json['breed'],
      age: json['age'],
      characteristics: List<String>.from(json['characteristics'] ?? []),
      animations: (json['animations'] as List<dynamic>?)
              ?.map((e) => PetAnimation.fromJson(e))
              .toList() ??
          [],
      collarId: json['collarId'],
      isSelected: json['isSelected'] ?? false,
      activityStatus: ActivityStatus.values.firstWhere(
        (e) => e.name == json['activityStatus'],
        orElse: () => ActivityStatus.resting,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petType': petType,
      'petName': petName,
      'breed': breed,
      'age': age,
      'characteristics': characteristics,
      'animations': animations.map((e) => e.toJson()).toList(),
      'collarId': collarId,
      'isSelected': isSelected,
      'activityStatus': activityStatus.name,
    };
  }

  PetProfile copyWith({
    String? id,
    String? petType,
    String? petName,
    String? breed,
    int? age,
    List<String>? characteristics,
    List<PetAnimation>? animations,
    String? collarId,
    bool? isSelected,
    ActivityStatus? activityStatus,
  }) {
    return PetProfile(
      id: id ?? this.id,
      petType: petType ?? this.petType,
      petName: petName ?? this.petName,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      characteristics: characteristics ?? this.characteristics,
      animations: animations ?? this.animations,
      collarId: collarId ?? this.collarId,
      isSelected: isSelected ?? this.isSelected,
      activityStatus: activityStatus ?? this.activityStatus,
    );
  }
}
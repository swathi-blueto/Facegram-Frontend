class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String? username;
  final String email;
  final String? phone; 
  final String? gender;
  final String? dateOfBirth; 
  final String? profilePic;
  final String? coverPhoto;
  final String? city; 
  final String? country; 
  final String? hometown; 
  final String? bio; 
  final String? website;
  final String? work;
  final String? education; 
  final String? relationshipStatus; 
  final String createdAt;
  final String role;
  final bool? isBlocked;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.username,
    required this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.profilePic,
    this.coverPhoto,
    this.city,
    this.country,
    this.hometown,
    this.bio,
    this.website,
    this.work,
    this.education,
    this.relationshipStatus,
    required this.createdAt,
    required this.role,
    this.isBlocked,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      username: json['username'] as String?,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      profilePic: json['profile_pic'] as String?,
      coverPhoto: json['cover_photo'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      hometown: json['hometown'] as String?,
      bio: json['bio'] as String?,
      work: json['work'] as String?,
      education: json['education'] as String?,
      relationshipStatus: json['relationship_status'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      isBlocked: json['is_blocked'] as bool?,
    );
  }
}

class PotentialFriend {
  final String id;
  final String firstName;
  final String profilePic;
  final String status;

  PotentialFriend({
    required this.id,
    required this.firstName,
    required this.profilePic,
    required this.status,
  });

  factory PotentialFriend.fromJson(Map<String, dynamic> json) {
    return PotentialFriend(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? 'Unknown',
      profilePic: json['profile_pic'] ?? '',
      status: json['status'] ?? 'none',
    );
  }

  PotentialFriend copyWith({
    String? id,
    String? firstName,
    String? profilePic,
    String? status,
  }) {
    return PotentialFriend(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      profilePic: profilePic ?? this.profilePic,
      status: status ?? this.status,
    );
  }
}
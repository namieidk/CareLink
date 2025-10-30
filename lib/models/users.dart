class User {
  final String id; // Primary key (UUID or auto-increment)
  final String role; // 'patient', 'doctor', 'caregiver'
  
  // Common fields
  final String password; // Hashed password
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  
  // Optional fields (not all roles use all fields)
  final String? email; // Patient & Caregiver use this
  final String? phone; // Patient uses this
  final String? doctorId; // Doctor uses this (e.g., DR12345)
  final String? username; // Doctor & Caregiver use this
  
  final String? profilePicture;
  final String? fullName;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.role,
    required this.password,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.email,
    this.phone,
    this.doctorId,
    this.username,
    this.profilePicture,
    this.fullName,
    this.lastLogin,
  });

  // Factory constructor from JSON/Map (for database retrieval)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      role: json['role'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      isActive: json['is_active'] as bool? ?? true,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      doctorId: json['doctor_id'] as String?,
      username: json['username'] as String?,
      profilePicture: json['profile_picture'] as String?,
      fullName: json['full_name'] as String?,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'] as String) 
          : null,
    );
  }

  // Convert to JSON/Map (for database insertion)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'password': password,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'email': email,
      'phone': phone,
      'doctor_id': doctorId,
      'username': username,
      'profile_picture': profilePicture,
      'full_name': fullName,
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  // Copy with method for updates
  User copyWith({
    String? id,
    String? role,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? email,
    String? phone,
    String? doctorId,
    String? username,
    String? profilePicture,
    String? fullName,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      doctorId: doctorId ?? this.doctorId,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
      fullName: fullName ?? this.fullName,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Validation methods
  bool isPatient() => role == 'patient';
  bool isDoctor() => role == 'doctor';
  bool isCaregiver() => role == 'caregiver';

  // Get display name based on role
  String getDisplayName() {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (username != null && username!.isNotEmpty) return username!;
    if (email != null && email!.isNotEmpty) return email!;
    if (doctorId != null && doctorId!.isNotEmpty) return doctorId!;
    return 'User $id';
  }

  // Get login identifier based on role
  String? getLoginIdentifier() {
    switch (role) {
      case 'patient':
        return email;
      case 'doctor':
        return doctorId ?? username;
      case 'caregiver':
        return username;
      default:
        return null;
    }
  }

  @override
  String toString() {
    return 'User(id: $id, role: $role, email: $email, username: $username, doctorId: $doctorId)';
  }
}

// ──────────────────────────────────────────────────────────────
// User Role Enum (Optional - for type safety)
// ──────────────────────────────────────────────────────────────
enum UserRole {
  patient,
  doctor,
  caregiver;

  String get value => name;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.value == role.toLowerCase(),
      orElse: () => UserRole.patient,
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Factory constructors for each role (Helper methods)
// ──────────────────────────────────────────────────────────────
extension UserFactories on User {
  // Create a Patient user
  static User createPatient({
    required String id,
    required String email,
    required String phone,
    required String password,
    String? fullName,
  }) {
    return User(
      id: id,
      role: 'patient',
      email: email,
      phone: phone,
      password: password,
      createdAt: DateTime.now(),
      fullName: fullName,
    );
  }

  // Create a Doctor user
  static User createDoctor({
    required String id,
    required String doctorId,
    required String username,
    required String password,
    String? fullName,
  }) {
    return User(
      id: id,
      role: 'doctor',
      doctorId: doctorId,
      username: username,
      password: password,
      createdAt: DateTime.now(),
      fullName: fullName,
    );
  }

  // Create a Caregiver user
  static User createCaregiver({
    required String id,
    required String email,
    required String username,
    required String password,
    String? fullName,
  }) {
    return User(
      id: id,
      role: 'caregiver',
      email: email,
      username: username,
      password: password,
      createdAt: DateTime.now(),
      fullName: fullName,
    );
  }
}

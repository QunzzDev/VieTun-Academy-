import 'package:equatable/equatable.dart';

/// User roles in the system
enum UserRole {
  adminSystem,
  adminSchool,
  teacher,
  student,
  parent,
}

/// User status
enum UserStatus {
  active,
  inactive,
  pending,
}

/// User model representing authenticated user
class User extends Equatable {
  final String id;
  final String username;
  final UserRole role;
  final UserStatus status;
  final String? schoolId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const User({
    required this.id,
    required this.username,
    required this.role,
    required this.status,
    this.schoolId,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      role: _parseRole(json['role'] as String),
      status: _parseStatus(json['status'] as String),
      schoolId: json['school_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role.name.toUpperCase(),
      'status': status.name.toUpperCase(),
      'school_id': schoolId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  static UserRole _parseRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN_SYSTEM':
        return UserRole.adminSystem;
      case 'ADMIN_SCHOOL':
        return UserRole.adminSchool;
      case 'TEACHER':
        return UserRole.teacher;
      case 'STUDENT':
        return UserRole.student;
      case 'PARENT':
        return UserRole.parent;
      default:
        return UserRole.student;
    }
  }
  
  static UserStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return UserStatus.active;
      case 'INACTIVE':
        return UserStatus.inactive;
      case 'PENDING':
        return UserStatus.pending;
      default:
        return UserStatus.pending;
    }
  }
  
  @override
  List<Object?> get props => [id, username, role, status, schoolId, createdAt, updatedAt];
}

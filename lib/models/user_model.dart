import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  manager,
  teamLeader,
  salesAgent;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.teamLeader:
        return 'Team Leader';
      case UserRole.salesAgent:
        return 'Sales Agent';
    }
  }
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? teamId;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.teamId,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.name,
      'teamId': teamId,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.salesAgent,
      ),
      teamId: map['teamId'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: map['lastLogin'] != null 
          ? (map['lastLogin'] as Timestamp).toDate()
          : null,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    String? teamId,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, role: ${role.name})';
  }

  bool hasPermission(UserRole requiredRole) {
    final roleIndex = UserRole.values.indexOf(role);
    final requiredRoleIndex = UserRole.values.indexOf(requiredRole);
    return roleIndex <= requiredRoleIndex;
  }
}

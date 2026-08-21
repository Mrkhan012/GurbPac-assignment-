import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? orgId;
  final String? role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.orgId,
    this.role,
  });

  bool get isAdmin => role == 'org_admin';

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? orgId,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      orgId: orgId ?? this.orgId,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, orgId, role];
}

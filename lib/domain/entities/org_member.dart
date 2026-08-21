import 'package:equatable/equatable.dart';

class OrgMember extends Equatable {
  final String orgId;
  final String userId;
  final String role;

  const OrgMember({
    required this.orgId,
    required this.userId,
    required this.role,
  });

  bool get isAdmin => role == 'org_admin';

  @override
  List<Object?> get props => [orgId, userId, role];
}

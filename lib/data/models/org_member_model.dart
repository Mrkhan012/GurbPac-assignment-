import '../../domain/entities/org_member.dart';

class OrgMemberModel extends OrgMember {
  const OrgMemberModel({
    required super.orgId,
    required super.userId,
    required super.role,
  });

  factory OrgMemberModel.fromJson(Map<String, dynamic> json) {
    return OrgMemberModel(
      orgId: json['org_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'org_id': orgId,
      'user_id': userId,
      'role': role,
    };
  }
}

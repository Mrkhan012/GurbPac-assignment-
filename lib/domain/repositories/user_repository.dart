import '../entities/organization.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getOrgMembers(String orgId);
  Future<User> getUserById(String userId);
  Future<List<Organization>> getOrganizations();
}

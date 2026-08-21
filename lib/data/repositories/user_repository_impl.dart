import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/organization.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/mock_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final MockDataSource _dataSource;

  UserRepositoryImpl({required MockDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<List<User>> getOrgMembers(String orgId) async {
    try {
      return await _dataSource.getOrgMembers(orgId);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<User> getUserById(String userId) async {
    try {
      return await _dataSource.getUserById(userId);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<Organization>> getOrganizations() async {
    try {
      return await _dataSource.getOrganizations();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

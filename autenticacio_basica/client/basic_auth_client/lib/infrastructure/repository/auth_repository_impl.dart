import 'package:basic_auth_client/domain/repository/auth_repository.dart';
import 'package:basic_auth_client/infrastructure/data_source/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<bool> login(String username, String password) {
    return remoteDataSource.login(username, password);
  }
}

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';

abstract class UserLocalDataSource extends Equatable {
  Future<UserModel> storeOfflineUser(UserModel user);
  Future<UserModel> fetchOfflineUser();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final Box userBox;

  const UserLocalDataSourceImpl({required this.userBox});
  @override
  Future<UserModel> fetchOfflineUser() async {
    return await userBox.get("USER") as UserModel;
  }

  @override
  Future<UserModel> storeOfflineUser(UserModel user) async {
    await userBox.put("USER", user);
    return await fetchOfflineUser();
  }

  @override
  List<Object?> get props => [userBox];

  @override
  bool? get stringify => true;
}

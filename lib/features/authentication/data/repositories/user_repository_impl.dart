import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/errors/errors.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/core/network_info/network_info.dart';
import 'package:portfolio_plus/features/authentication/data/data_sources/user_local_data_source.dart';
import 'package:portfolio_plus/features/authentication/data/data_sources/user_remote_data_source.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/user_repository.dart';

typedef OnlineInteractionFunc1 = Future<UserModel> Function();
typedef OnlineInteractionFunc2 = Future<List<UserModel>> Function();

class UserRepositoryImpl implements UserRepository {
  final NetworkInfo networkInfo;
  final UserLocalDataSource localDataSource;
  final UserRemoteDataSource remoteDataSource;

  const UserRepositoryImpl(
      {required this.networkInfo,
      required this.localDataSource,
      required this.remoteDataSource});

  @override
  Future<Either<AppFailure, UserModel>> changeUserData(
      UserModel userModel) async {
    return await _mapOnlineInteraction1(
        () => remoteDataSource.changeUserData(userModel));
  }

  @override
  Future<Either<AppFailure, UserModel>> fetchOnlineUser(String userId) async {
    return await _mapOnlineInteraction1(
        () => remoteDataSource.fetchOnlineUser(userId));
  }

  @override
  Future<Either<AppFailure, String>> storeProfilePhoto(
      String userId, File file) async {
    if (await networkInfo.isConnected()) {
      try {
        return Right(await remoteDataSource.storeProfilePicture(userId, file));
      } on OnlineException catch (e) {
        return Left(OnlineFailure(failureMessage: e.message));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }

  @override
  Future<Either<AppFailure, UserModel>> fetchOfflineUser() async {
    try {
      UserModel user = await localDataSource.fetchOfflineUser();
      return Right(user);
    } catch (e) {
      if (e.toString() ==
          "type 'Null' is not a subtype of type 'UserModel' in type cast") {
        return Left(OfflineFailure(failureMessage: EMPTY_CACHE_MESSAGE));
      } else {
        return Left(OfflineFailure(failureMessage: e.toString()));
      }
    }
  }

  @override
  Future<Either<AppFailure, UserModel>> storeOfflineUser(
      UserModel userModel) async {
    try {
      final user = await localDataSource.storeOfflineUser(userModel);
      return Right(user);
    } catch (e) {
      return Left(OfflineFailure(failureMessage: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, UserModel>> storeOnlineUser(
      UserModel userModel) async {
    if (await networkInfo.isConnected()) {
      try {
        final user = await remoteDataSource.storeOnlineUser(userModel);
        return Right(user);
      } catch (e) {
        return Left(OnlineFailure(
            failureMessage: "CAN'T STORE DATA IN ONLINE DATABASE!"));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }

  @override
  Future<Either<AppFailure, UserModel>> followUser(String id) async {
    return await _mapOnlineInteraction1(() => remoteDataSource.followUser(id));
  }

  @override
  Future<Either<AppFailure, UserModel>> unFollowUser(String id) async {
    return await _mapOnlineInteraction1(
        () => remoteDataSource.unfollowUser(id));
  }

  @override
  Future<Either<AppFailure, bool>> checkUserAccountName(
      String accountName) async {
    if (await networkInfo.isConnected()) {
      try {
        final bool status =
            await remoteDataSource.checkAccountName(accountName);
        return Right(status);
      } on OnlineException catch (exception) {
        return Left(OnlineFailure(failureMessage: exception.message));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }

  @override
  Future<Either<AppFailure, List<UserModel>>> getSearchedUsers(
      String name) async {
    return await _mapOnlineInteraction2(
        () => remoteDataSource.getSearchedUsers(name));
  }

  @override
  Future<Either<AppFailure, List<UserModel>>> getUsersByIds(
      List<String> ids) async {
    return await _mapOnlineInteraction2(
        () => remoteDataSource.getUsersByIds(ids));
  }

  @override
  List<Object?> get props => [localDataSource, remoteDataSource];

  @override
  bool? get stringify => true;

  Future<Either<AppFailure, UserModel>> _mapOnlineInteraction1(
      OnlineInteractionFunc1 func) async {
    if (await networkInfo.isConnected()) {
      try {
        final UserModel user = await func();
        return Right(user);
      } on OnlineException catch (exception) {
        return Left(OnlineFailure(failureMessage: exception.message));
      } catch (e) {
        return Left(OnlineFailure(failureMessage: e.toString()));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }

  Future<Either<AppFailure, List<UserModel>>> _mapOnlineInteraction2(
      OnlineInteractionFunc2 func) async {
    if (await networkInfo.isConnected()) {
      try {
        final List<UserModel> users = await func();
        return Right(users);
      } on OnlineException catch (exception) {
        return Left(OnlineFailure(failureMessage: exception.message));
      } catch (e) {
        return Left(OnlineFailure(failureMessage: e.toString()));
      }
    } else {
      return Left(OnlineFailure(failureMessage: NO_INTERNET_MESSAGE));
    }
  }
}

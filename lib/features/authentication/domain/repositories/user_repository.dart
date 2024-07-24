import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';

abstract class UserRepository extends Equatable {
  Future<Either<AppFailure, UserModel>> storeOfflineUser(UserModel user);
  Future<Either<AppFailure, UserModel>> storeOnlineUser(UserModel user);
  Future<Either<AppFailure, String>> storeProfilePhoto(
      String userId, File file);
  Future<Either<AppFailure, bool>> checkUserAccountName(String accountName);
  Future<Either<AppFailure, UserModel>> fetchOfflineUser();
  Future<Either<AppFailure, UserModel>> fetchOnlineUser(String userId);
  Future<Either<AppFailure, UserModel>> changeUserData(UserModel user);
}

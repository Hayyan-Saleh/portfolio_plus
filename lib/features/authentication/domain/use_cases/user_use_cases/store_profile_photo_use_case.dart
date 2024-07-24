import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/user_repository.dart';

class StoreProfilePhotoUseCase extends Equatable {
  final UserRepository userRepository;

  const StoreProfilePhotoUseCase({required this.userRepository});
  Future<Either<AppFailure, String>> call(String userId, File file) async {
    return await userRepository.storeProfilePhoto(userId, file);
  }

  @override
  List<Object?> get props => [userRepository];
}

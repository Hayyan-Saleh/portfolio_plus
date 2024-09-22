import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/domain/repositories/chat_box_repository.dart';

class ListenToUserUseCase extends Equatable {
  final ChatBoxRepository chatBoxRepository;

  const ListenToUserUseCase({required this.chatBoxRepository});

  Future<Either<AppFailure, Unit>> call(
      String userId, StreamController<UserModel> controller) async {
    return await chatBoxRepository.listenToUser(userId, controller);
  }

  @override
  List<Object?> get props => [chatBoxRepository];
}

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';
import 'package:portfolio_plus/features/chat/domain/repositories/chat_box_repository.dart';

class AddMessageUseCase extends Equatable {
  final ChatBoxRepository chatBoxRepository;

  const AddMessageUseCase({required this.chatBoxRepository});

  Future<Either<AppFailure, Unit>> call(
      UserModel originalUser,
      UserModel otherUser,
      String chatBoxId,
      MessageEntity message,
      File? file) async {
    return await chatBoxRepository.addMessage(
        originalUser, otherUser, chatBoxId, message, file);
  }

  @override
  List<Object?> get props => [chatBoxRepository];
}

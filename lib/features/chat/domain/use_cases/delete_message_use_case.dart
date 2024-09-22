import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';
import 'package:portfolio_plus/features/chat/domain/repositories/chat_box_repository.dart';

class DeleteMessageUseCase extends Equatable {
  final ChatBoxRepository chatBoxRepository;

  const DeleteMessageUseCase({required this.chatBoxRepository});

  Future<Either<AppFailure, Unit>> call(
      String chatBoxId, MessageEntity message) async {
    return await chatBoxRepository.deleteMessage(chatBoxId, message);
  }

  @override
  List<Object?> get props => [chatBoxRepository];
}

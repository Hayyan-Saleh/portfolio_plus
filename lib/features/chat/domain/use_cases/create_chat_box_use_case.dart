import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/chat/domain/entities/chat_entity.dart';
import 'package:portfolio_plus/features/chat/domain/repositories/chat_box_repository.dart';

class CreateChatBoxUseCase extends Equatable {
  final ChatBoxRepository chatBoxRepository;

  const CreateChatBoxUseCase({required this.chatBoxRepository});
  Future<Either<AppFailure, ChatBox>> call(List<String> usersIds) async {
    return await chatBoxRepository.createChatBox(usersIds);
  }

  @override
  List<Object?> get props => [chatBoxRepository];
}

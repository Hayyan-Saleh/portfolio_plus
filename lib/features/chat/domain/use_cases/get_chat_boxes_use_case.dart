import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/chat/domain/entities/chat_entity.dart';
import 'package:portfolio_plus/features/chat/domain/repositories/chat_box_repository.dart';

class GetChatBoxesUseCase extends Equatable {
  final ChatBoxRepository chatBoxRepository;

  const GetChatBoxesUseCase({required this.chatBoxRepository});
  Future<Either<AppFailure, List<ChatBox>>> call(
      List<String> chatBoxesIds) async {
    return await chatBoxRepository.getChatBoxes(chatBoxesIds);
  }

  @override
  List<Object> get props => [chatBoxRepository];
}

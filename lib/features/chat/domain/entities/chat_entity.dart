import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';

class ChatBox extends Equatable {
  final String id;
  final List<String> usersIds;
  final List<MessageEntity> messages;
  final MessageEntity? lastMessage;

  const ChatBox(
      {required this.id,
      required this.usersIds,
      required this.messages,
      required this.lastMessage});

  @override
  List<Object?> get props => [id, usersIds, messages, lastMessage];
}

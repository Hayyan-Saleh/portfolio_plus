import 'package:portfolio_plus/features/chat/data/models/message_model.dart';
import 'package:portfolio_plus/features/chat/domain/entities/chat_entity.dart';

class ChatBoxModel extends ChatBox {
  const ChatBoxModel(
      {required super.id,
      required super.usersIds,
      required super.messages,
      required super.lastMessage});
  factory ChatBoxModel.fromJson(Map<String, dynamic> chatBoxMap) {
    //* decode userIds
    final List<String> usersIds =
        (chatBoxMap['usersIds'] as List<dynamic>).cast<String>().toList();

    //* decode the messages list
    final List<MessageModel> messages = (chatBoxMap['messages'] as List)
        .map<MessageModel>((messageMap) => MessageModel.fromJson(messageMap))
        .toList()
      ..sort((firstMessage, secondMessage) =>
          firstMessage.date.compareTo(secondMessage.date));

    //* decode last message
    final MessageModel? lastMessage = chatBoxMap['lastMessage'] != null
        ? MessageModel.fromJson(chatBoxMap['lastMessage'])
        : null;

    return ChatBoxModel(
        id: chatBoxMap['id'],
        usersIds: usersIds,
        messages: messages,
        lastMessage: lastMessage);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usersIds': usersIds,
      'messages': messages.map((message) => (message as MessageModel).toJson()),
      'lastMessage':
          lastMessage != null ? (lastMessage as MessageModel).toJson() : null
    };
  }

  void sortMessagesByDate() {
    messages.sort((firstMessage, secondMessage) =>
        firstMessage.date.compareTo(secondMessage.date));
  }
}

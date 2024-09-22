part of 'chat_box_bloc.dart';

sealed class ChatBoxEvent extends Equatable {
  const ChatBoxEvent();

  @override
  List<Object> get props => [];
}

class AddMessageEvent extends ChatBoxEvent {
  final UserModel originalUser;
  final UserModel otherUser;
  final MessageEntity message;
  final String chatBoxId;
  final File? file;
  const AddMessageEvent(
      {required this.otherUser,
      required this.originalUser,
      required this.chatBoxId,
      required this.message,
      required this.file});

  @override
  List<Object> get props {
    if (file != null) {
      return [originalUser, otherUser, chatBoxId, message, file!];
    } else {
      return [originalUser, otherUser, chatBoxId, message];
    }
  }
}

class DeleteMessageEvent extends ChatBoxEvent {
  final MessageEntity message;
  final String chatBoxId;
  const DeleteMessageEvent({required this.chatBoxId, required this.message});

  @override
  List<Object> get props => [chatBoxId, message];
}

class ModifyMessageEvent extends ChatBoxEvent {
  final MessageEntity oldMessage, newMessage;
  final String chatBoxId;
  const ModifyMessageEvent(
      {required this.chatBoxId,
      required this.oldMessage,
      required this.newMessage});

  @override
  List<Object> get props => [chatBoxId, oldMessage, newMessage];
}

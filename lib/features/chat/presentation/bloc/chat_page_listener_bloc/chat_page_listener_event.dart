part of 'chat_page_listener_bloc.dart';

sealed class ChatPageListenerEvent extends Equatable {
  const ChatPageListenerEvent();

  @override
  List<Object> get props => [];
}

class ListenToUserWithChatBoxEvent extends ChatPageListenerEvent {
  final UserModel otherUser;
  final ChatBox chatBox;

  const ListenToUserWithChatBoxEvent(
      {required this.otherUser, required this.chatBox});
  @override
  List<Object> get props => [otherUser, chatBox];
}

class ChangeUserStateChatPageEvent extends ChatPageListenerEvent {
  final UserModel otherUser;

  const ChangeUserStateChatPageEvent({
    required this.otherUser,
  });
  @override
  List<Object> get props => [
        otherUser,
      ];
}

class ChangeChatBoxChatPageEvent extends ChatPageListenerEvent {
  final ChatBox chatBox;

  const ChangeChatBoxChatPageEvent({required this.chatBox});
  @override
  List<Object> get props => [chatBox];
}

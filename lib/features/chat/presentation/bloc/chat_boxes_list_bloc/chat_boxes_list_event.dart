part of 'chat_boxes_list_bloc.dart';

sealed class ChatBoxesListEvent extends Equatable {
  const ChatBoxesListEvent();

  @override
  List<Object> get props => [];
}

class CreateChatBoxEvent extends ChatBoxesListEvent {
  final List<String> usersIds;

  const CreateChatBoxEvent({required this.usersIds});
  @override
  List<Object> get props => [usersIds];
}

class GetChatBoxesEvent extends ChatBoxesListEvent {
  final List<String> chatBoxesIds;

  const GetChatBoxesEvent({required this.chatBoxesIds});
  @override
  List<Object> get props => [chatBoxesIds];
}

class ListenToUsersAndChatBoxesEvent extends ChatBoxesListEvent {
  final List<String> chatBoxesIds;
  final List<String> usersIds;

  const ListenToUsersAndChatBoxesEvent(
      {required this.chatBoxesIds, required this.usersIds});
  @override
  List<Object> get props => [chatBoxesIds, usersIds];
}

class ChangedChatBoxEvent extends ChatBoxesListEvent {
  final ChatBox changedChatBox;

  const ChangedChatBoxEvent({required this.changedChatBox});
  @override
  List<Object> get props => [changedChatBox];
}

class ChangedUserEvent extends ChatBoxesListEvent {
  final UserModel changedUser;

  const ChangedUserEvent({required this.changedUser});
  @override
  List<Object> get props => [changedUser];
}

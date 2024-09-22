part of 'chat_page_listener_bloc.dart';

sealed class ChatPageListenerState extends Equatable {
  const ChatPageListenerState();

  @override
  List<Object> get props => [];
}

final class ChatPageBlocInitial extends ChatPageListenerState {}

final class LoadingListeningState extends ChatPageListenerState {}

class ChangedUserChatPageState extends ChatPageListenerState {
  final UserModel changedUser;

  const ChangedUserChatPageState({required this.changedUser});
  @override
  List<Object> get props => [changedUser];
}

class ChangedChatBoxChatPageState extends ChatPageListenerState {
  final ChatBox changedChatBox;

  const ChangedChatBoxChatPageState({required this.changedChatBox});
  @override
  List<Object> get props => [changedChatBox];
}

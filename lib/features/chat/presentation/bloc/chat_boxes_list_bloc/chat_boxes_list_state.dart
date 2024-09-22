part of 'chat_boxes_list_bloc.dart';

sealed class ChatBoxesListState extends Equatable {
  const ChatBoxesListState();

  @override
  List<Object> get props => [];
}

final class ChatBoxesListInitial extends ChatBoxesListState {}

final class LoadingCreateChatBoxState extends ChatBoxesListState {}

final class LoadingGetChatBoxesState extends ChatBoxesListState {}

class CreatedChatBoxState extends ChatBoxesListState {
  final ChatBox createdChatBox;

  const CreatedChatBoxState({required this.createdChatBox});
  @override
  List<Object> get props => [createdChatBox];
}

class LoadedUCBModelsState extends ChatBoxesListState {
  final UserChatBoxModel ucbModel;
  const LoadedUCBModelsState({required this.ucbModel});
  @override
  List<Object> get props => [ucbModel];
}

class ChangedChatBoxState extends ChatBoxesListState {
  final ChatBox changedChatBox;
  const ChangedChatBoxState({required this.changedChatBox});
  @override
  List<Object> get props => [changedChatBox];
}

class ChangedUserState extends ChatBoxesListState {
  final UserModel changedUser;
  const ChangedUserState({required this.changedUser});
  @override
  List<Object> get props => [changedUser];
}

class FailedChatBoxesListState extends ChatBoxesListState {
  final AppFailure failure;

  const FailedChatBoxesListState({required this.failure});
  @override
  List<Object> get props => [failure];
}

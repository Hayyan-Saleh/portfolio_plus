part of 'chat_box_bloc.dart';

sealed class ChatBoxState extends Equatable {
  const ChatBoxState();

  @override
  List<Object> get props => [];
}

final class ChatBoxInitial extends ChatBoxState {}

final class LoadingMessageState extends ChatBoxState {}

final class DoneMessageState extends ChatBoxState {}

final class FailedMessageState extends ChatBoxState {
  final AppFailure failure;

  const FailedMessageState({required this.failure});
  @override
  List<Object> get props => [failure];
}

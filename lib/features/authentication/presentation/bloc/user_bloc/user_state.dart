part of 'user_bloc.dart';

sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

final class UserInitial extends UserState {}

class LoadingUserState extends UserState {}

class LaodedOfflineUserState extends UserState {
  final UserModel user;

  const LaodedOfflineUserState({required this.user});
  @override
  List<Object> get props => [user];
}

class LaodedOnlineUserState extends UserState {
  final UserModel user;

  const LaodedOnlineUserState({required this.user});
  @override
  List<Object> get props => [user];
}

class ChangedUserDataState extends UserState {
  final UserModel user;

  const ChangedUserDataState({required this.user});
  @override
  List<Object> get props => [user];
}

class StoredOfflineUserState extends UserState {
  final UserModel user;

  const StoredOfflineUserState({required this.user});
  @override
  List<Object> get props => [user];
}

class StoredOnlineUserState extends UserState {
  final UserModel user;

  const StoredOnlineUserState({required this.user});
  @override
  List<Object> get props => [user];
}

class FailedUserState extends UserState {
  final AppFailure failure;

  const FailedUserState({required this.failure});
  @override
  List<Object> get props => [failure];
}

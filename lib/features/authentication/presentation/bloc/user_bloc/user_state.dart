part of 'user_bloc.dart';

sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

final class UserInitial extends UserState {}

class LoadingUserState extends UserState {}

class LoadingFollowingUserState extends UserState {}

class LaodedOfflineUserState extends UserState {
  final UserModel user;

  const LaodedOfflineUserState({required this.user});
  @override
  List<Object> get props => [user];
}

class LaodedOriginalOnlineUserState extends UserState {
  final UserModel user;

  const LaodedOriginalOnlineUserState({required this.user});
  @override
  List<Object> get props => [user];
}

class LaodedOtherOnlineUserState extends UserState {
  final UserModel user;

  const LaodedOtherOnlineUserState({required this.user});
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

class FollowedUserState extends UserState {
  final UserModel followedUser;

  const FollowedUserState({required this.followedUser});
  @override
  List<Object> get props => [followedUser];
}

class UnFollowedUserState extends UserState {
  final UserModel unfollowedUser;

  const UnFollowedUserState({required this.unfollowedUser});
  @override
  List<Object> get props => [unfollowedUser];
}

class LoadingFetchingOnlineUsersEvent extends UserState {}

class LoadedFollowingUserState extends UserState {
  final List<UserModel> users;

  const LoadedFollowingUserState({required this.users});
  @override
  List<Object> get props => [users];
}

class LoadedFollowersUserState extends UserState {
  final List<UserModel> users;

  const LoadedFollowersUserState({required this.users});
  @override
  List<Object> get props => [users];
}

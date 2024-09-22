part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetOfflineUserEvent extends UserEvent {}

class GetOtherOnlineUserEvent extends UserEvent {
  final String id;

  const GetOtherOnlineUserEvent({required this.id});
  @override
  List<Object> get props => [id];
}

class GetOriginalOnlineUserEvent extends UserEvent {
  final String id;

  const GetOriginalOnlineUserEvent({required this.id});
  @override
  List<Object> get props => [id];
}

class StoreOfflineUserEvent extends UserEvent {
  final UserModel user;

  const StoreOfflineUserEvent({required this.user});
  @override
  List<Object> get props => [user];
}

class StoreOnlineUserEvent extends UserEvent {
  final UserModel user;

  const StoreOnlineUserEvent({required this.user});
  @override
  List<Object> get props => [user];
}

class ChangeUserDataEvent extends UserEvent {
  final UserModel user;

  const ChangeUserDataEvent({required this.user});
  @override
  List<Object> get props => [user];
}

class FollowUserEvent extends UserEvent {
  final String id;

  const FollowUserEvent({required this.id});
  @override
  List<Object> get props => [id];
}

class UnfollowUserEvent extends UserEvent {
  final String id;

  const UnfollowUserEvent({required this.id});
  @override
  List<Object> get props => [id];
}

class FetchFollowingUserEvent extends UserEvent {
  final List<String> ids;

  const FetchFollowingUserEvent({required this.ids});
  @override
  List<Object> get props => [ids];
}

class FetchFollowersUserEvent extends UserEvent {
  final List<String> ids;

  const FetchFollowersUserEvent({required this.ids});
  @override
  List<Object> get props => [ids];
}

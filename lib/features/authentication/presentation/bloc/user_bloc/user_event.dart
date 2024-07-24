part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetOfflineUserEvent extends UserEvent {}

class GetOnlineUserEvent extends UserEvent {
  final String id;

  const GetOnlineUserEvent({required this.id});
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

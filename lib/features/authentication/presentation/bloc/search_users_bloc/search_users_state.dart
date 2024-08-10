part of 'search_users_bloc.dart';

sealed class SearchUsersState extends Equatable {
  const SearchUsersState();

  @override
  List<Object> get props => [];
}

final class SearchUsersInitial extends SearchUsersState {}

class SearchingUsersState extends SearchUsersState {}

class SearchedUsersState extends SearchUsersState {
  final List<UserModel> users;

  const SearchedUsersState({required this.users});
  @override
  List<Object> get props => [users];
}

class FailedSearchUsersState extends SearchUsersState {
  final String message;

  const FailedSearchUsersState({required this.message});
  @override
  List<Object> get props => [message];
}

part of 'search_users_bloc.dart';

sealed class SearchUsersEvent extends Equatable {
  const SearchUsersEvent();

  @override
  List<Object> get props => [];
}

class GetSearchedUsersEvent extends SearchUsersEvent {
  final String name;

  const GetSearchedUsersEvent({required this.name});

  @override
  List<Object> get props => [name];
}

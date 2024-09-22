part of 'post_search_bloc.dart';

sealed class PostSearchState extends Equatable {
  const PostSearchState();

  @override
  List<Object> get props => [];
}

final class PostSearchInitial extends PostSearchState {}

class SearchingPostsState extends PostSearchState {}

class SearchedPostsState extends PostSearchState {
  final List<Post> posts;
  final List<UserModel> users;

  const SearchedPostsState({required this.posts, required this.users});
  @override
  List<Object> get props => [posts, users];
}

class FailedSearchPostsState extends PostSearchState {
  final String message;

  const FailedSearchPostsState({required this.message});
  @override
  List<Object> get props => [message];
}

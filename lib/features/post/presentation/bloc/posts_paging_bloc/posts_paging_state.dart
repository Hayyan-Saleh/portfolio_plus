part of 'posts_paging_bloc.dart';

sealed class PostsPagingState extends Equatable {
  const PostsPagingState();

  @override
  List<Object> get props => [];
}

final class PostPagingInitial extends PostsPagingState {}

class LoadingFetchingState extends PostsPagingState {}

class LoadedPostsPagingState extends PostsPagingState {
  final List<Post> posts;
  final List<UserModel> users;

  const LoadedPostsPagingState({required this.posts, required this.users});
  @override
  List<Object> get props => [posts, users];
}

class ChangedPostsPagingState extends PostsPagingState {
  final Post changedPost;

  const ChangedPostsPagingState({required this.changedPost});
  @override
  List<Object> get props => [changedPost];
}

class FailedPostsPagingState extends PostsPagingState {
  final AppFailure failure;

  const FailedPostsPagingState({required this.failure});
  @override
  List<Object> get props => [failure];
}

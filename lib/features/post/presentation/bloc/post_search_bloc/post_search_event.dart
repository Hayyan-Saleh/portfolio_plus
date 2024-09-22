part of 'post_search_bloc.dart';

sealed class PostSearchEvent extends Equatable {
  const PostSearchEvent();

  @override
  List<Object> get props => [];
}

class GetSearchedPostsEvent extends PostSearchEvent {
  final String query;

  const GetSearchedPostsEvent({required this.query});

  @override
  List<Object> get props => [query];
}

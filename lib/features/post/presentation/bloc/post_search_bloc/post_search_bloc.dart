import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/fetch_online_user_use_case.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/get_searched_posts_use_case.dart';

part 'post_search_event.dart';
part 'post_search_state.dart';

class PostSearchBloc extends Bloc<PostSearchEvent, PostSearchState> {
  final GetSearchedPostsUseCase getSearchedPosts;
  final FetchOnlineUserUseCase fetchOnlineUser;

  PostSearchBloc(
      {required this.getSearchedPosts, required this.fetchOnlineUser})
      : super(PostSearchInitial()) {
    on<PostSearchEvent>((event, emit) async {
      if (event is GetSearchedPostsEvent) {
        emit(SearchingPostsState());
        final List<Post> fetchedPosts = [];
        final List<UserModel> fetchedUsers = [];
        final either = await getSearchedPosts(event.query);
        either.fold(
            (failure) =>
                emit(FailedSearchPostsState(message: failure.failureMessage)),
            (posts) => fetchedPosts.addAll(posts));
        for (Post post in fetchedPosts) {
          final either = await fetchOnlineUser(post.userId);
          either.fold(
              (failure) =>
                  emit(FailedSearchPostsState(message: failure.failureMessage)),
              (user) => fetchedUsers.add(user));
        }
        emit(SearchedPostsState(posts: fetchedPosts, users: fetchedUsers));
      }
    }, transformer: restartable());
  }
}

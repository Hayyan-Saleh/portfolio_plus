import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/fetch_online_user_use_case.dart';
import 'package:portfolio_plus/features/post/data/models/post_model.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/get_other_users_posts_use_case.dart';
import 'package:portfolio_plus/features/post/domain/use_cases/post_use_cases/listen_to_posts_use_case.dart';

part 'posts_paging_event.dart';
part 'posts_paging_state.dart';

class PostsPagingBloc extends Bloc<PostsPagingEvent, PostsPagingState> {
  StreamController<PostModel> controller = StreamController<PostModel>();
  final GetOtherUsersPostsUseCase getOtherUsersPosts;
  final ListenToPostsUseCase listenToPosts;
  final FetchOnlineUserUseCase fetchOnlineUser;
  PostsPagingBloc(
      {required this.listenToPosts,
      required this.fetchOnlineUser,
      required this.getOtherUsersPosts})
      : super(PostPagingInitial()) {
    on<PostsPagingEvent>((event, emit) async {
      if (event is StartPostsPaging) {
        emit(LoadingFetchingState());
        final List<Post> fetchedPosts = [];
        final either = await getOtherUsersPosts(
            event.originalUser, event.limit, event.discover);
        either.fold((failure) => emit(FailedPostsPagingState(failure: failure)),
            (posts) => fetchedPosts.addAll(posts));

        final List<UserModel> fetchedUsers = [];
        for (Post post in fetchedPosts) {
          final either = await fetchOnlineUser(post.userId);
          either.fold(
              (failure) => emit(FailedPostsPagingState(failure: failure)),
              (user) => fetchedUsers.add(user));
        }
        emit(LoadedPostsPagingState(posts: fetchedPosts, users: fetchedUsers));
      } else if (event is ListenToPostsPagingEvent) {
        final either =
            await listenToPosts(controller, event.user, event.discover);
        either.fold((failure) => emit(FailedPostsPagingState(failure: failure)),
            (_) {
          controller.stream.listen((PostModel changedPost) {
            add(ChangePostPagingEvent(changedPost: changedPost));
          });
        });
      } else if (event is ChangePostPagingEvent) {
        emit(ChangedPostsPagingState(changedPost: event.changedPost));
      }
    }, transformer: droppable());
  }

  @override
  Future<void> close() {
    controller.close();
    return super.close();
  }
}

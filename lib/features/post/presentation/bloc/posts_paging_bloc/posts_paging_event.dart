part of 'posts_paging_bloc.dart';

sealed class PostsPagingEvent extends Equatable {
  const PostsPagingEvent();

  @override
  List<Object> get props => [];
}

class StartPostsPaging extends PostsPagingEvent {
  final UserModel originalUser;
  final int limit;
  final bool? discover;

  const StartPostsPaging(
      {required this.originalUser,
      required this.limit,
      required this.discover});
  @override
  List<Object> get props {
    if (discover != null) {
      return [originalUser, limit, discover!];
    } else {
      return [originalUser, limit];
    }
  }
}

class ChangePostPagingEvent extends PostsPagingEvent {
  final Post changedPost;

  const ChangePostPagingEvent({required this.changedPost});
  @override
  List<Object> get props => [changedPost];
}

class ListenToPostsPagingEvent extends PostsPagingEvent {
  final UserModel user;
  final bool? discover;

  const ListenToPostsPagingEvent({required this.user, required this.discover});

  @override
  List<Object> get props {
    if (discover != null) {
      return [user, discover!];
    } else {
      return [user];
    }
  }
}

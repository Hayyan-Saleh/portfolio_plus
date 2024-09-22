import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/change_user_data_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/fetch_offline_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/fetch_online_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/follow_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/get_users_by_ids_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/store_offline_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/store_online_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/unfollow_user_use_case.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ChangeUserDataUseCase changeUserData;
  final FetchOfflineUserUseCase fetchOfflineUser;
  final FetchOnlineUserUseCase fetchOnlineUser;
  final StoreOfflineUserUseCase storeOfflineUser;
  final StoreOnlineUserUseCase storeOnlineUser;
  final FollowUserUseCase followUser;
  final UnFollowUserUseCase unFollowUser;
  final GetUsersByIdsUseCase getUsersByIds;
  UserBloc({
    required this.changeUserData,
    required this.fetchOfflineUser,
    required this.fetchOnlineUser,
    required this.storeOfflineUser,
    required this.storeOnlineUser,
    required this.followUser,
    required this.unFollowUser,
    required this.getUsersByIds,
  }) : super(UserInitial()) {
    on<UserEvent>((event, emit) async {
      if (event is GetOfflineUserEvent) {
        emit(LoadingUserState());
        final either = await fetchOfflineUser();
        either.fold(
          (failure) {
            emit(FailedUserState(failure: failure));
          },
          (user) {
            emit(LaodedOfflineUserState(user: user));
          },
        );
      } else if (event is GetOriginalOnlineUserEvent) {
        emit(LoadingUserState());
        final either = await fetchOnlineUser(event.id);
        either.fold(
          (failure) {
            emit(FailedUserState(failure: failure));
          },
          (user) {
            emit(LaodedOriginalOnlineUserState(user: user));
          },
        );
      } else if (event is GetOtherOnlineUserEvent) {
        emit(LoadingUserState());
        final either = await fetchOnlineUser(event.id);
        either.fold(
          (failure) {
            emit(FailedUserState(failure: failure));
          },
          (user) {
            emit(LaodedOtherOnlineUserState(user: user));
          },
        );
      } else if (event is StoreOfflineUserEvent) {
        emit(LoadingUserState());
        final either = await storeOfflineUser(event.user);
        either.fold(
          (failure) {
            emit(FailedUserState(failure: failure));
          },
          (user) {
            emit(StoredOfflineUserState(user: user));
          },
        );
      } else if (event is StoreOnlineUserEvent) {
        emit(LoadingUserState());
        final either = await storeOnlineUser(event.user);
        either.fold(
          (failure) {
            emit(FailedUserState(failure: failure));
          },
          (user) {
            emit(StoredOnlineUserState(user: user));
          },
        );
      } else if (event is ChangeUserDataEvent) {
        emit(LoadingUserState());
        final either = await changeUserData(event.user);
        either.fold(
          (failure) {
            emit(FailedUserState(failure: failure));
          },
          (user) {
            emit(ChangedUserDataState(user: user));
          },
        );
      } else if (event is FollowUserEvent) {
        emit(LoadingFollowingUserState());
        final either = await followUser(event.id);
        either.fold(
          (failure) {
            emit(FailedUserState(failure: failure));
          },
          (followedUser) {
            emit(FollowedUserState(followedUser: followedUser));
          },
        );
      } else if (event is UnfollowUserEvent) {
        emit(LoadingFollowingUserState());
        final either = await unFollowUser(event.id);
        either.fold(
          (failure) {
            emit(FailedUserState(failure: failure));
          },
          (unfollowedUser) {
            emit(UnFollowedUserState(unfollowedUser: unfollowedUser));
          },
        );
      } else if (event is FetchFollowingUserEvent) {
        emit(LoadingFetchingOnlineUsersEvent());
        final either = await getUsersByIds(event.ids);
        either.fold((failure) => emit(FailedUserState(failure: failure)),
            (users) => emit(LoadedFollowingUserState(users: users)));
      } else if (event is FetchFollowersUserEvent) {
        emit(LoadingFetchingOnlineUsersEvent());
        final either = await getUsersByIds(event.ids);
        either.fold((failure) => emit(FailedUserState(failure: failure)),
            (users) => emit(LoadedFollowersUserState(users: users)));
      }
    });
  }
}

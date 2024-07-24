import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/change_user_data_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/fetch_offline_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/fetch_online_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/store_offline_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/store_online_user_use_case.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ChangeUserDataUseCase changeUserData;
  final FetchOfflineUserUseCase fetchOfflineUser;
  final FetchOnlineUserUseCase fetchOnlineUser;
  final StoreOfflineUserUseCase storeOfflineUser;
  final StoreOnlineUserUseCase storeOnlineUser;
  UserBloc(
      {required this.changeUserData,
      required this.fetchOfflineUser,
      required this.fetchOnlineUser,
      required this.storeOfflineUser,
      required this.storeOnlineUser})
      : super(UserInitial()) {
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
      } else if (event is GetOnlineUserEvent) {
        emit(LoadingUserState());
        final either = await fetchOnlineUser(event.id);
        either.fold(
          (failure) {
            emit(FailedUserState(failure: failure));
          },
          (user) {
            emit(LaodedOnlineUserState(user: user));
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
      }
    });
  }
}

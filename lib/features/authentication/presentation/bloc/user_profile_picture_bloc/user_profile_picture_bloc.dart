import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/store_profile_photo_use_case.dart';

part 'user_profile_picture_event.dart';
part 'user_profile_picture_state.dart';

class UserProfilePictureBloc
    extends Bloc<UserProfilePictureEvent, UserProfilePictureState> {
  final StoreProfilePhotoUseCase storeProfilePhoto;
  UserProfilePictureBloc({required this.storeProfilePhoto})
      : super(UserProfilePictureInitial()) {
    on<UserProfilePictureEvent>((event, emit) async {
      if (event is StoreUserProfilePhotoEvent) {
        emit(LoadingUserProfilePhotoState());
        final either = await storeProfilePhoto(event.userId, event.file);
        either.fold(
          (failure) {
            emit(FailedLoadingPictureState(
                errorMessage: failure.failureMessage));
          },
          (photoURL) {
            emit(LoadedUserProfilePhotoState(downloadLink: photoURL));
          },
        );
      }
    });
  }
}

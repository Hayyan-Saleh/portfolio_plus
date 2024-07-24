part of 'user_profile_picture_bloc.dart';

sealed class UserProfilePictureState extends Equatable {
  const UserProfilePictureState();

  @override
  List<Object> get props => [];
}

final class UserProfilePictureInitial extends UserProfilePictureState {}

class LoadingUserProfilePhotoState extends UserProfilePictureState {}

class LoadedUserProfilePhotoState extends UserProfilePictureState {
  final String downloadLink;

  const LoadedUserProfilePhotoState({required this.downloadLink});

  @override
  List<Object> get props => [downloadLink];
}

class FailedLoadingPictureState extends UserProfilePictureState {
  final String errorMessage;

  const FailedLoadingPictureState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

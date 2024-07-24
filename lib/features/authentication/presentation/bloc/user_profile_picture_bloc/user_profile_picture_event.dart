part of 'user_profile_picture_bloc.dart';

sealed class UserProfilePictureEvent extends Equatable {
  const UserProfilePictureEvent();

  @override
  List<Object> get props => [];
}

class StoreUserProfilePhotoEvent extends UserProfilePictureEvent {
  final String userId;
  final File file;

  const StoreUserProfilePhotoEvent({required this.userId, required this.file});

  @override
  List<Object> get props => [userId, file];
}

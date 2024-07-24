part of 'user_account_name_bloc.dart';

sealed class UserAccountNameState extends Equatable {
  const UserAccountNameState();

  @override
  List<Object> get props => [];
}

final class UserAccountNameInitial extends UserAccountNameState {}

final class UserAccountNameLoadingState extends UserAccountNameState {}

final class UserAccountNameCheckedState extends UserAccountNameState {
  final bool isVerified;
  final String? message;

  const UserAccountNameCheckedState(
      {required this.isVerified, required this.message});
  @override
  List<Object> get props => [isVerified, message ?? ""];
}

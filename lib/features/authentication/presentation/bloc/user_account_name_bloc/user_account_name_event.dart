part of 'user_account_name_bloc.dart';

sealed class UserAccountNameEvent extends Equatable {
  const UserAccountNameEvent();

  @override
  List<Object> get props => [];
}

class CheckUserAccountNameEvent extends UserAccountNameEvent {
  final String accountName;
  const CheckUserAccountNameEvent({required this.accountName});
  @override
  List<Object> get props => [accountName];
}

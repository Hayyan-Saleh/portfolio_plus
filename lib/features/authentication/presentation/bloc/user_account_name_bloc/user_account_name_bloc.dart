import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/check_user_account_name_use_case.dart';

part 'user_account_name_event.dart';
part 'user_account_name_state.dart';

class UserAccountNameBloc
    extends Bloc<UserAccountNameEvent, UserAccountNameState> {
  final CheckUserAccountNameUseCase checkUserAccountName;
  UserAccountNameBloc({required this.checkUserAccountName})
      : super(UserAccountNameInitial()) {
    on<UserAccountNameEvent>((event, emit) async {
      if (event is CheckUserAccountNameEvent) {
        emit(UserAccountNameLoadingState());
        final either = await checkUserAccountName(event.accountName);
        either.fold(
            (failed) => emit(UserAccountNameCheckedState(
                isVerified: false, message: failed.failureMessage)),
            (isVerified) => emit(UserAccountNameCheckedState(
                isVerified: isVerified,
                message: isVerified ? null : "Please choose another name")));
      }
    }, transformer: restartable());
  }
}

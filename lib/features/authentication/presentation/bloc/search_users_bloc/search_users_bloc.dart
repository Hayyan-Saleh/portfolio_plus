import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/get_searched_users_use_case.dart';

part 'search_users_event.dart';
part 'search_users_state.dart';

class SearchUsersBloc extends Bloc<SearchUsersEvent, SearchUsersState> {
  final GetSearchedUsersUseCase getSearchedUsers;
  SearchUsersBloc({required this.getSearchedUsers})
      : super(SearchUsersInitial()) {
    on<SearchUsersEvent>((event, emit) async {
      if (event is GetSearchedUsersEvent) {
        emit(SearchingUsersState());
        final either = await getSearchedUsers(event.name);
        either.fold(
            (failure) =>
                emit(FailedSearchUsersState(message: failure.failureMessage)),
            (users) => emit(SearchedUsersState(users: users)));
      }
    }, transformer: restartable());
  }
}

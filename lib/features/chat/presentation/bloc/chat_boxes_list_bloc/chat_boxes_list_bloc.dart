import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/core/errors/failures.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/fetch_online_user_use_case.dart';
import 'package:portfolio_plus/features/chat/data/models/chat_box_model.dart';
import 'package:portfolio_plus/features/chat/domain/entities/chat_box_list_tile_model.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/create_chat_box_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/get_chat_boxes_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/listen_to_chat_box_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/listen_to_user_use_case.dart';

import '../../../domain/entities/chat_entity.dart';

part 'chat_boxes_list_event.dart';
part 'chat_boxes_list_state.dart';

class ChatBoxesListBloc extends Bloc<ChatBoxesListEvent, ChatBoxesListState> {
  final CreateChatBoxUseCase createChatBox;
  final GetChatBoxesUseCase getChatBoxes;
  final FetchOnlineUserUseCase fetchUser;
  final ListenToChatBoxUseCase listenToChatBox;
  final ListenToUserUseCase listenToUser;
  late final List<StreamController<ChatBoxModel>>? chatBoxesControllers;
  late final List<StreamController<UserModel>>? usersControllers;
  ChatBoxesListBloc(
      {required this.createChatBox,
      required this.fetchUser,
      required this.getChatBoxes,
      required this.listenToChatBox,
      required this.listenToUser})
      : super(ChatBoxesListInitial()) {
    on<ChatBoxesListEvent>((event, emit) async {
      if (event is CreateChatBoxEvent) {
        emit(LoadingCreateChatBoxState());
        final either = await createChatBox(event.usersIds);
        either.fold(
            (failure) => emit(FailedChatBoxesListState(failure: failure)),
            (chatBox) => emit(CreatedChatBoxState(createdChatBox: chatBox)));
      } else if (event is GetChatBoxesEvent) {
        emit(LoadingGetChatBoxesState());
        // *gettting the chatboxes
        List<UserModel> fetchedUsers = [];
        List<ChatBox> fetchedChatBoxes = [];
        int status = 1;
        final either = await getChatBoxes(event.chatBoxesIds);
        either.fold((failure) {
          status = -1;
          emit(FailedChatBoxesListState(failure: failure));
        }, (chatBoxes) async {
          status = 1;
          fetchedChatBoxes = chatBoxes;
        });
        if (status == 1) {
          fetchedUsers = await _fetchUsers(fetchedChatBoxes, emit);
          emit(LoadedUCBModelsState(
              ucbModel: UserChatBoxModel(
            chatBoxesList: fetchedChatBoxes,
            users: fetchedUsers,
          )));
        } else if (status == 0) {
          emit(const FailedChatBoxesListState(
              failure: AppFailure(
                  failureMessage: "ERROR IN FETCHING UCB models !")));
        }
      } else if (event is ListenToUsersAndChatBoxesEvent) {
        await _listenToUsersAndChatBoxes(
            event.usersIds, event.chatBoxesIds, emit);
      } else if (event is ChangedChatBoxEvent) {
        emit(ChangedChatBoxState(changedChatBox: event.changedChatBox));
      } else if (event is ChangedUserEvent) {
        emit(ChangedUserState(changedUser: event.changedUser));
      }
    });
  }

  Future<List<UserModel>> _fetchUsers(
      List<ChatBox> chatBoxes, Emitter<ChatBoxesListState> emit) async {
    final String originalUserId = await getId();
    final List<String> sortedusersIds = chatBoxes
        .map<String>((chatBox) =>
            chatBox.usersIds.firstWhere((userId) => userId != originalUserId))
        .toList();

    final List<UserModel> fetchedUsers = [];
    for (String userId in sortedusersIds) {
      //* fetch the user and add it to the list
      final either = await fetchUser(userId);
      either.fold(
        (failure) => emit(FailedChatBoxesListState(failure: failure)),
        (user) => fetchedUsers.add(user),
      );
    }
    return fetchedUsers;
  }

  Future<void> _listenToUsersAndChatBoxes(List<String> usersIds,
      List<String> chatBoxesIds, Emitter<ChatBoxesListState> emit) async {
    //* create chat boxes listeners controllers
    chatBoxesControllers = List.generate(
        chatBoxesIds.length, (index) => StreamController<ChatBoxModel>());

    //* create users listeners controllers
    usersControllers = List.generate(
        chatBoxesIds.length, (index) => StreamController<UserModel>());
    for (int i = 0; i < chatBoxesIds.length; i++) {
      //*assigne each controller to a stream in chatboxes
      await listenToChatBox(chatBoxesIds[i], chatBoxesControllers![i]);
      chatBoxesControllers![i].stream.listen((changedChatBox) async {
        add(ChangedChatBoxEvent(changedChatBox: changedChatBox));
      });

      //* first getting the user (other user) id then assigne each controller to a stream in users

      await listenToUser(usersIds[i], usersControllers![i]);
      usersControllers![i].stream.listen((changedUser) async {
        add(ChangedUserEvent(changedUser: changedUser));
      });
    }
  }

  @override
  Future<void> close() {
    // Cancel the subscription or dispose of other resources
    if (chatBoxesControllers != null) {
      chatBoxesControllers?.forEach((element) {
        element.close();
      });
    }
    if (usersControllers != null) {
      usersControllers?.forEach((element) {
        element.close();
      });
    }
    return super.close();
  }
}

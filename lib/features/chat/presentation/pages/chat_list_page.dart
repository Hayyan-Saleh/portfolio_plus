import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/util/globale_variables.dart';
import 'package:portfolio_plus/core/widgets/emtpy_data_widget.dart';
import 'package:portfolio_plus/core/widgets/failed_widget.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/chat/domain/entities/chat_box_list_tile_model.dart';
import 'package:portfolio_plus/features/chat/presentation/bloc/chat_boxes_list_bloc/chat_boxes_list_bloc.dart';
import 'package:portfolio_plus/features/chat/presentation/pages/chat_available_users_page.dart';
import 'package:portfolio_plus/features/chat/presentation/widgets/chat_list_tile.dart';
import 'package:portfolio_plus/features/chat/presentation/pages/chat_page.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

class ChatListPage extends StatefulWidget {
  final UserModel originalUser;
  const ChatListPage({super.key, required this.originalUser});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late final ChatBoxesListBloc chatBoxesListBloc;
  UserChatBoxModel? ucbModel;
  UserModel? loadedOriginalUser;
  @override
  void initState() {
    super.initState();
    chatBoxesListBloc = di.sl<ChatBoxesListBloc>();
    isOnChatPage = true;
  }

  @override
  void dispose() {
    isOnChatPage = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatBoxesListBloc>(
      create: (context) => chatBoxesListBloc
        ..add(GetChatBoxesEvent(
          chatBoxesIds: widget.originalUser.chatIds,
        )),
      child: Scaffold(
        body: RefreshIndicator(
            onRefresh: () async {
              chatBoxesListBloc.add(GetChatBoxesEvent(
                chatBoxesIds: loadedOriginalUser != null
                    ? loadedOriginalUser!.chatIds
                    : widget.originalUser.chatIds,
              ));
            },
            child: _buildBlocBody(context)),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              BlocProvider.of<UserBloc>(context).add(FetchFollowingUserEvent(
                  ids: widget.originalUser.followingIds));
              Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: ChatAvailableUsersPage(
                      originalUser: loadedOriginalUser != null
                          ? loadedOriginalUser!
                          : widget.originalUser,
                    )),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.question_answer_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
            )),
      ),
    );
  }

  Widget _buildBlocBody(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is LaodedOnlineUserState) {
          loadedOriginalUser = state.user;
        }
      },
      child: BlocBuilder<ChatBoxesListBloc, ChatBoxesListState>(
        builder: (context, state) {
          if (state is LoadingGetChatBoxesState) {
            if (ucbModel != null) {
              if (ucbModel!.chatBoxesList.isNotEmpty) {
                return _buildChatListTiles();
              }
            }
            return Center(
              child: LoadingWidget(
                  color: Theme.of(context).colorScheme.onBackground),
            );
          } else if (state is LoadedUCBModelsState) {
            ucbModel = state.ucbModel;
            chatBoxesListBloc.add(ListenToUsersAndChatBoxesEvent(
                chatBoxesIds: ucbModel!.chatBoxesList
                    .map<String>(
                      (chatBox) => chatBox.id,
                    )
                    .toList(),
                usersIds:
                    ucbModel!.users.map<String>((user) => user.id).toList()));
            if (ucbModel!.chatBoxesList.isEmpty) {
              return const EmtpyDataWidget(
                title: "No Chat Rooms found!",
                subTitle:
                    "Create some chats rooms with users you're following using the button below to chat with them",
              );
            }
            return _buildChatListTiles();
          } else if (state is ChangedUserState) {
            for (int i = 0; i < ucbModel!.users.length; i++) {
              if (ucbModel!.users[i].id == state.changedUser.id) {
                ucbModel!.users.removeAt(i);
                ucbModel!.users.insert(i, state.changedUser);
              }
            }
            return _buildChatListTiles();
          } else if (state is FailedChatBoxesListState) {
            return FailedWidget(
                title: "Error", subTitle: state.failure.failureMessage);
          }
          chatBoxesListBloc.add(GetChatBoxesEvent(
            chatBoxesIds: loadedOriginalUser != null
                ? loadedOriginalUser!.chatIds
                : widget.originalUser.chatIds,
          ));
          return ucbModel != null
              ? _buildChatListTiles()
              : ListView(
                  children: const [SizedBox()],
                );
        },
      ),
    );
  }

  Widget _buildChatListTiles() {
    return ListView.builder(
      itemCount: ucbModel!.chatBoxesList.length,
      itemBuilder: (context, index) => ChatListTile(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: ChatPage(
                    chatBox: ucbModel!.chatBoxesList[index],
                    originalUser: loadedOriginalUser != null
                        ? loadedOriginalUser!
                        : widget.originalUser,
                    otherUser: ucbModel!.users[index],
                  )),
            );
          },
          chatBox: ucbModel!.chatBoxesList[index],
          user: ucbModel!.users[index]),
    );
  }
}

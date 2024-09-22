import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/default_profile_picture.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/users_page.dart';
import 'package:portfolio_plus/features/post/domain/entities/comment_entity.dart';
import 'package:readmore/readmore.dart';

class CommentWidget extends StatelessWidget {
  final UserModel originalUser;
  final UserModel commentUser;
  final Comment comment;
  final double height;
  final String showRepliesText;
  final Function() likeFunc;
  final Function() replyFunc;
  final Function()? showRepliesFunc;
  final Function()? editFunction;
  final Function() deleteFunction;

  const CommentWidget(
      {super.key,
      required this.originalUser,
      required this.commentUser,
      required this.comment,
      required this.height,
      required this.likeFunc,
      required this.replyFunc,
      required this.showRepliesText,
      this.showRepliesFunc,
      required this.deleteFunction,
      required this.editFunction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfo(context),
        _buildCommentContent(),
        _buildLikeReply(context),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: commentUser.profilePictureUrl != null
                  ? CustomCachedNetworkImage(
                      isRounded: true,
                      height: 0.8 * height,
                      imageUrl: commentUser.profilePictureUrl!)
                  : DefaultProfilePicture(height: 0.8 * height),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commentUser.userName!,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withAlpha(230),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Row(
                  children: [
                    Text(timeAgo(comment.date.toDate()),
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(150))),
                    if (comment.isEdited)
                      Text(" . edited",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withAlpha(150)))
                  ],
                )
              ],
            )
          ],
        ),
        if (originalUser.id == comment.userId) _buildPopupmenubtn()
      ],
    );
  }

  Widget _buildPopupmenubtn() {
    return PopupMenuButton(
      itemBuilder: (context) => [
        if (editFunction != null)
          const PopupMenuItem(
            value: 1,
            child: Text("Edit"),
          ),
        const PopupMenuItem(
          value: 2,
          child: Text("Delete"),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 1:
            if (editFunction != null) {
              editFunction!();
            }
            break;
          case 2:
            deleteFunction();
            break;
        }
      },
    );
  }

  Widget _buildCommentContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ReadMoreText(
        comment.content,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildLikeReply(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (comment.likedUsersIds.isNotEmpty)
          _buildCustomTextBtn(
              onTap: () {
                BlocProvider.of<UserBloc>(context)
                    .add(FetchFollowingUserEvent(ids: comment.likedUsersIds));
                Navigator.push(
                    context,
                    PageTransition(
                        child: UsersPage(originalUser: originalUser),
                        type: PageTransitionType.bottomToTop));
              },
              child: Text(
                comment.likedUsersIds.length.toString(),
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withAlpha(200)),
              )),
        _buildCustomTextBtn(
            onTap: () => likeFunc(),
            child: Text(
              "Like",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withAlpha(220)),
            )),
        _buildCustomTextBtn(
            onTap: () => replyFunc(),
            child: Text(
              "Reply",
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.secondary.withAlpha(200)),
            )),
        showRepliesFunc != null
            ? _buildCustomTextBtn(
                onTap: () => showRepliesFunc!(),
                child: Text(
                  showRepliesText,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withAlpha(200)),
                ))
            : const SizedBox(
                width: 10,
              )
      ],
    );
  }

  Widget _buildCustomTextBtn(
      {required Function() onTap, required Widget child}) {
    return InkWell(
        onTap: () => onTap(),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5), child: child));
  }
}

class CommentLoadingWidget extends StatelessWidget {
  final double height;
  const CommentLoadingWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 0.15 * height,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    radius: 0.1 * height,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Text(
                          "Lorem ipsum ",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        child: Text(
                          "Lorem",
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          height: 20,
          width: double.infinity,
          child: const Text("Lorem ipsum corlo aserno parlo aquero"),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          height: 20,
          width: double.infinity,
          child: const Text("Lorem ipsum corlo aserno parlo aquero"),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                child: Text("Lorem  "),
              ),
              SizedBox(
                width: 10,
              ),
              SizedBox(
                child: Text("Lorem  "),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/custom_cached_network_image.dart';
import 'package:portfolio_plus/core/widgets/default_profile_picture.dart';
import 'package:portfolio_plus/core/widgets/show_image_page.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/other_user_page.dart';
import 'package:portfolio_plus/features/authentication/presentation/pages/user_pages/users_page.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/presentation/bloc/posts_curd_bloc/post_curd_bloc.dart';
import 'package:portfolio_plus/features/post/presentation/pages/comments_page.dart';
import 'package:portfolio_plus/features/post/presentation/pages/edit_post_page.dart';
import 'package:readmore/readmore.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final UserModel originalUser;
  final UserModel postUser;
  final bool isOriginalUserPost;
  final double height;

  const PostWidget(
      {super.key,
      required this.post,
      required this.height,
      required this.postUser,
      required this.isOriginalUserPost,
      required this.originalUser});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  int _picturesIndex = 1;
  late bool _isLiked;
  late bool _isSaved;
  @override
  void initState() {
    _isLiked = widget.post.likedUsersIds.contains(widget.originalUser.id);
    _isSaved = widget.originalUser.savedPostsIds
        .contains("${widget.post.userId}_${widget.post.postId}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        _buildUserInfo(),
        _buildPostContent(),
        if (widget.post.postPicturesUrls.isNotEmpty) _buildPostPictures(),
        _buildPostTypeSection(),
        _buildLikeCommentSaveSection()
      ],
    );
  }

  Widget _buildUserInfo() {
    return SizedBox(
      height: 0.12 * widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              if (!widget.isOriginalUserPost) {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: OtherUserPage(
                            originalUser: widget.originalUser,
                            otherUser: widget.postUser)));
              }
            },
            child: Row(
              children: [
                widget.postUser.profilePictureUrl != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20, right: 10),
                        child: CustomCachedNetworkImage(
                            isRounded: true,
                            height: 0.6 * widget.height,
                            imageUrl: widget.postUser.profilePictureUrl!),
                      )
                    : DefaultProfilePicture(height: 0.9 * widget.height),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.postUser.userName!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(getPublishTime(widget.post.date.toDate()),
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withAlpha(150))),
                        if (widget.post.isEdited)
                          Text(" . edited",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withAlpha(150)))
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          if (widget.isOriginalUserPost) _buildPopupmenubtn()
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: ReadMoreText(
        widget.post.content,
        textAlign: TextAlign.start,
        trimLines: 2,
      ),
    );
  }

  Widget _buildPostPictures() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          Positioned(
              child: Container(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withAlpha(50))),
          PageView.builder(
            scrollDirection: Axis.horizontal,
            onPageChanged: (value) => setState(() {
              _picturesIndex = value + 1;
            }),
            itemCount: widget.post.postPicturesUrls.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () => Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade,
                      child: ShowImagePage(
                        pictureUrl: widget.post.postPicturesUrls[index],
                      ))),
              child: CachedNetworkImage(
                height: 0.5 * widget.height,
                imageUrl: widget.post.postPicturesUrls[index],
                fadeInDuration: const Duration(milliseconds: 100),
                fadeOutDuration: const Duration(seconds: 100),
              ),
            ),
          ),
          Positioned(
              left: 10,
              top: 10,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    "$_picturesIndex / ${widget.post.postPicturesUrls.length}",
                    style: const TextStyle(color: Colors.white),
                  ),
                )),
              )),
        ],
      ),
    );
  }

  Widget _buildPostTypeSection() {
    return Center(
      child: Container(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Center(
              child: Text(
            widget.post.postType,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }

  Widget _buildLikeCommentSaveSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            if (widget.post.likesCount != 0)
              InkWell(
                  onTap: () {
                    BlocProvider.of<UserBloc>(context).add(
                        FetchFollowingUserEvent(
                            ids: widget.post.likedUsersIds));
                    Navigator.push(
                        context,
                        PageTransition(
                            child: UsersPage(originalUser: widget.originalUser),
                            type: PageTransitionType.bottomToTop));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Center(
                      child: Text(
                        formatLikesCount(widget.post.likesCount),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
            IconButton(
                onPressed: () {
                  if (!_isLiked) {
                    BlocProvider.of<PostCurdBloc>(context).add(
                        LikePostCURDEvent(
                            post: widget.post, user: widget.originalUser));
                  } else {
                    BlocProvider.of<PostCurdBloc>(context).add(
                        UnLikePostCURDEvent(
                            post: widget.post, user: widget.originalUser));
                  }
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                },
                icon: Icon(
                  _isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: Theme.of(context).colorScheme.primary,
                )),
          ],
        ),
        IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: CommentsPage(
                          originalUser: widget.originalUser, post: widget.post),
                      type: PageTransitionType.bottomToTop));
            },
            icon: Icon(
              Icons.my_library_books_outlined,
              color: Theme.of(context).colorScheme.secondary,
            )),
        IconButton(
            onPressed: () {
              // ! in remote data source check if the post is saved before saving it to delete duplicates
              if (_isSaved) {
                BlocProvider.of<PostCurdBloc>(context).add(UnSavePostCURDEvent(
                    post: widget.post, user: widget.originalUser));
              } else {
                BlocProvider.of<PostCurdBloc>(context).add(SavePostCURDEvent(
                    post: widget.post, user: widget.originalUser));
              }

              setState(() {
                _isSaved = !_isSaved;
              });
            },
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
            )),
      ],
    );
  }

  Widget _buildPopupmenubtn() {
    return PopupMenuButton(
      itemBuilder: (context) => [
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
            Navigator.push(
                context,
                PageTransition(
                    child: EditPostPage(
                        originalUser: widget.originalUser, post: widget.post),
                    type: PageTransitionType.scale,
                    alignment: Alignment.center));
            break;
          case 2:
            BlocProvider.of<PostCurdBloc>(context)
                .add(DeletePostCURDEvent(post: widget.post));
            break;
        }
      },
    );
  }
}

class LoadingPostWidget extends StatelessWidget {
  final double height;
  const LoadingPostWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    child: Text(
                      "Lorem ipsum ",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    child: Text("Lorem  "),
                  )
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 20,
                width: double.infinity,
                child: const Text("Lorem ipsum corlo aserno parlo arikano"),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 20,
                width: double.infinity,
                child: const Text("Lorem ipsum corlo aserno parlo arikano"),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 20,
                width: double.infinity,
                child: const Text("Lorem ipsum corlo aserno parlo arikano"),
              ),
            ],
          ),
        ),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            height: 0.5 * height,
            color: Colors.grey,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              child: Text("Lorem  "),
            ),
            SizedBox(
              child: Text("Lorem  "),
            ),
            SizedBox(
              child: Text("Lorem  "),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_plus/core/util/content_enum.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/widgets/emtpy_data_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/presentation/widgets/chat_text_form_field.dart';
import 'package:portfolio_plus/features/post/domain/entities/comment_entity.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/presentation/bloc/comment_curd_bloc/comment_curd_bloc.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/comment_widget.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/widget_size.dart';
import 'package:portfolio_plus/injection_container.dart' as di;
import 'package:skeletonizer/skeletonizer.dart';
import 'package:uuid/uuid.dart';

class CommentsPage extends StatefulWidget {
  final UserModel originalUser;
  final Post post;
  const CommentsPage(
      {super.key, required this.originalUser, required this.post});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late final CommentCurdBloc _commentCurdBloc;

  List<Comment>? _comments;
  List<UserModel>? _commentsUsers;
  List<List<UserModel>>? _commentsReplyUsers;

  final GlobalKey<FormState> _commentFormKey = GlobalKey<FormState>();
  final TextEditingController _commentTEC = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isEditing = false;
  Comment? _editedComment;

  bool _isReply = false;
  bool _showReplies = false;
  int? _replyCommentIndex;
  Comment? _replyComment;
  UserModel? _repliedToUser;

  void _focusTextField() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  void initState() {
    _commentCurdBloc = di.sl<CommentCurdBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _commentTEC.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = getHeight(context);
    return Scaffold(
      appBar: _buildCommentsAppBar(),
      body: BlocProvider(
        create: (context) => _commentCurdBloc
          ..add(GetCommentsCURDEvent(postId: widget.post.postId))
          ..add(ListenToCommentsEvent(postId: widget.post.postId)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildCommentsBloc(height)),
              _buildAddComment(height)
            ]),
      ),
    );
  }

  Widget _buildCommentsBloc(double height) {
    return BlocConsumer<CommentCurdBloc, CommentCurdState>(
      listener: (context, state) {
        if (state is LoadedCommentsCurdState) {
          _comments = state.comments;
          _commentsUsers = state.commentsUsers;
          _commentsReplyUsers = state.commentsReplyUsers;
        } else if (state is DoneCommentCurdState) {
          _commentCurdBloc
              .add(GetCommentsCURDEvent(postId: widget.post.postId));
        }
      },
      builder: (context, state) {
        if (state is LoadingCommentCurdState) {
          return _buildComments(true, height);
        }
        return _buildComments(false, height);
      },
    );
  }

  Widget _buildComments(bool isLoading, double height) {
    if (!isLoading) {
      if (_comments == null) {
        return const SizedBox();
      }
      if (_comments!.isEmpty) {
        return const EmtpyDataWidget(
            title: "No Comments Found",
            subTitle: "Be the first one to comment on this post");
      }
    }
    return Skeletonizer(
      enabled: isLoading,
      containersColor:
          Theme.of(context).colorScheme.onBackground.withAlpha(100),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: isLoading ? 10 : _comments!.length,
        itemBuilder: (context, index) => isLoading
            ? CommentLoadingWidget(height: 0.3 * height)
            : _showReplies && _replyCommentIndex == index
                ? _buildCommentReplyWidget(_replyCommentIndex!, height)
                : _buildCommentWidget(index, height),
      ),
    );
  }

  Widget _buildCommentReplyWidget(int index, double height) {
    return Column(
      children: [
        _buildCommentWidget(index, height),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _commentsReplyUsers![_replyCommentIndex!].length,
          itemBuilder: (context, replyIndex) => WidgetSize(
            onChange: (size) => setState(() {}),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8, left: 30, right: 5),
              child: CommentWidget(
                originalUser: widget.originalUser,
                commentUser: _commentsReplyUsers![index][replyIndex],
                comment: _comments![index].replyComments[replyIndex],
                height: 0.3 * height,
                showRepliesText: "",
                replyFunc: () {
                  _isReply = true;
                  _replyComment = _comments![index];
                  _repliedToUser = _commentsUsers![index];
                  setState(() {
                    _focusTextField();
                  });
                },
                likeFunc: () {
                  _isReply = false;
                  _replyCommentIndex = replyIndex;
                  _commentCurdBloc.add(UpdateCommentCURDEvent(
                      comment: _createLikedReplyComment(index)));
                },
                showRepliesFunc: null,
                editFunction: null,
                deleteFunction: () {
                  _isReply = false;
                  _replyCommentIndex = replyIndex;
                  _commentCurdBloc.add(UpdateCommentCURDEvent(
                      comment: _createDeletedReplyComment(index)));
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildCommentWidget(
    int index,
    double height,
  ) {
    return WidgetSize(
      onChange: (size) => setState(() {}),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CommentWidget(
          originalUser: widget.originalUser,
          commentUser: _commentsUsers![index],
          comment: _comments![index],
          height: 0.3 * height,
          showRepliesText: _showReplies && index == _replyCommentIndex
              ? "hide replies"
              : "show replies",
          replyFunc: () {
            _isReply = true;
            _replyComment = _comments![index];
            _repliedToUser = _commentsUsers![index];
            setState(() {
              _focusTextField();
            });
          },
          likeFunc: () {
            _commentCurdBloc.add(LikeCommentCURDEvent(
                comment: _comments![index], user: widget.originalUser));
          },
          showRepliesFunc: () {
            if (!_showReplies) {
              setState(() {
                _showReplies = true;
                _replyCommentIndex = index;
              });
            } else {
              setState(() {
                _showReplies = false;
                _replyCommentIndex = null;
              });
            }
          },
          editFunction: () {
            _isEditing = true;
            _editedComment = _comments![index];
            _commentTEC.text = _editedComment!.content;
            setState(() {
              _focusTextField();
            });
          },
          deleteFunction: () {
            _commentCurdBloc
                .add(DeleteCommentCURDEvent(comment: _comments![index]));
          },
        ),
      ),
    );
  }

  Widget _buildAddComment(double height) {
    if (_isReply) {
      return SizedBox(
        height: 0.2 * height,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withAlpha(100),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                              "Adding Reply to ${_repliedToUser!.userName}'s comment",
                              overflow: TextOverflow.clip,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        TextButton(
                            child: const Text("cancel"),
                            onPressed: () => _stopReplying()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildSendComment(height)
          ],
        ),
      );
    } else {
      return _buildSendComment(height);
    }
  }

  Widget _buildSendComment(double height) {
    return Container(
      height: 0.1 * height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: widget.originalUser.isDarkMode!
              ? Colors.grey[900]
              : Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
          borderRadius: _isReply
              ? null
              : const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: ChatTextFormField(
                  formkey: _commentFormKey,
                  textEditingController: _commentTEC,
                  focusNode: _focusNode,
                  errorMessage: "please enter a comment to send",
                  hintText: 'Enter your comment'),
            ),
          ),
          _buildSendBtnBloc(),
        ],
      ),
    );
  }

  Widget _buildSendBtnBloc() {
    return BlocBuilder<CommentCurdBloc, CommentCurdState>(
      builder: (context, state) {
        if (state is LoadingCommentCurdState) {
          return Center(
            child: Container(
              height: 25,
              width: 25,
              margin: const EdgeInsets.all(10),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        return IconButton(
            onPressed: () {
              if (_commentFormKey.currentState!.validate()) {
                if (_isEditing) {
                  _commentCurdBloc.add(
                      UpdateCommentCURDEvent(comment: _createEditedComment()));
                  setState(() {
                    _isEditing = false;
                  });
                } else if (!_isReply) {
                  _commentCurdBloc
                      .add(AddCommentCURDEvent(comment: _createComment()));
                } else {
                  _commentCurdBloc.add(AddReplyToCommentCURDEvent(
                      origianlComment: _replyComment!,
                      replyComment: _createComment()));
                  _stopReplying();
                }
                _commentTEC.text = "";
              }
            },
            icon: Icon(
              _isEditing ? Icons.edit : Icons.send,
              color: Theme.of(context).colorScheme.primary.withAlpha(200),
            ));
      },
    );
  }

  AppBar _buildCommentsAppBar() {
    return AppBar(
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text("Comments",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 35,
              fontFamily: 'Brilliant',
              color: Theme.of(context).colorScheme.primary)),
    );
  }

  void _stopReplying() {
    _isReply = false;
    _replyComment = null;
    _repliedToUser = null;
    setState(() {});
  }

  Comment _createLikedReplyComment(int index) {
    _comments![index]
        .replyComments[_replyCommentIndex!]
        .likedUsersIds
        .add(widget.originalUser.id);
    return Comment(
      commentId: _comments![index].commentId,
      postId: _comments![index].postId,
      userId: _comments![index].userId,
      content: _comments![index].content,
      date: _comments![index].date,
      contentType: _comments![index].contentType,
      likedUsersIds: _comments![index].likedUsersIds,
      replyComments: _comments![index].replyComments,
      isEdited: true,
    );
  }

  Comment _createDeletedReplyComment(int index) {
    _comments![index].replyComments.removeAt(_replyCommentIndex!);
    return Comment(
      commentId: _comments![index].commentId,
      postId: _comments![index].postId,
      userId: _comments![index].userId,
      content: _comments![index].content,
      date: _comments![index].date,
      contentType: _comments![index].contentType,
      likedUsersIds: _comments![index].likedUsersIds,
      replyComments: _comments![index].replyComments,
      isEdited: true,
    );
  }

  Comment _createEditedComment() {
    return Comment(
      commentId: _editedComment!.commentId,
      postId: _editedComment!.postId,
      userId: _editedComment!.userId,
      content: _commentTEC.text.trim(),
      date: _editedComment!.date,
      contentType: Content.TEXT.type,
      likedUsersIds: _editedComment!.likedUsersIds,
      replyComments: _editedComment!.replyComments,
      isEdited: true,
    );
  }

  Comment _createComment() {
    return Comment(
      commentId: const Uuid().v8(),
      postId: widget.post.postId,
      userId: widget.originalUser.id,
      content: _commentTEC.text.trim(),
      date: Timestamp.now(),
      contentType: Content.TEXT.type,
      likedUsersIds: const [],
      replyComments: const [],
      isEdited: false,
    );
  }
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/util/post_type_enum.dart';
import 'package:portfolio_plus/core/widgets/custom_button.dart';
import 'package:portfolio_plus/core/widgets/failed_widget.dart';
import 'package:portfolio_plus/core/widgets/loading_widget.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/presentation/widgets/other/drop_down_button.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_entity.dart';
import 'package:portfolio_plus/features/post/presentation/bloc/posts_curd_bloc/post_curd_bloc.dart';
import 'package:portfolio_plus/features/post/presentation/widgets/post_content_text_form_field.dart';
import 'package:portfolio_plus/injection_container.dart' as di;

class EditPostPage extends StatefulWidget {
  final UserModel originalUser;
  final Post post;
  const EditPostPage({
    super.key,
    required this.originalUser,
    required this.post,
  });

  @override
  State<EditPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<EditPostPage> {
  final GlobalKey<FormState> postContentFromKey = GlobalKey<FormState>();
  final TextEditingController postContentTEC = TextEditingController();
  final List<String> oldPictures = [];
  final List<File> newPictures = [];

  final PageController newpicturesPagesController = PageController();
  final PageController oldpicturesPagesController = PageController();
  int _oldPicturesIndex = 1;
  int _newPicturesIndex = 1;
  late String postType;

  late final PostCurdBloc _postCurdBloc;
  @override
  void initState() {
    _postCurdBloc = di.sl<PostCurdBloc>();
    postType = widget.post.postType;
    postContentTEC.text = widget.post.content;
    if (widget.post.postPicturesUrls.isNotEmpty) {
      oldPictures.addAll(widget.post.postPicturesUrls);
    }
    super.initState();
  }

  @override
  void dispose() {
    postContentTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = getHeight(context);
    return BlocProvider<PostCurdBloc>(
      create: (context) => _postCurdBloc,
      child: Scaffold(
        appBar: buildAppBar(context),
        body: BlocBuilder<PostCurdBloc, PostCurdState>(
          builder: (context, state) {
            if (state is LoadingPostCURDState) {
              return const Center(
                child: LoadingWidget(color: Colors.greenAccent),
              );
            } else if (state is DonePostCURDState) {
              _postCurdBloc.add(
                  GetOriginalUserPostsCURDEvent(user: widget.originalUser));
              Navigator.of(context).pop();
              Future.microtask(() {
                showToastMessage(
                    context, "Done", "Project updated successfully");
              });
            } else if (state is FailedPostsCURDState) {
              return FailedWidget(
                  title: "Error Occured",
                  subTitle: state.failure.failureMessage);
            }

            return _buildEditPost(height);
          },
        ),
        floatingActionButton: _buildAddPictureBloc(),
      ),
    );
  }

  Widget _buildAddPictureBloc() {
    return BlocBuilder<PostCurdBloc, PostCurdState>(
      builder: (context, state) {
        if (state is LoadingPostCURDState) {
          return const SizedBox();
        }
        return _buildAddPicture();
      },
    );
  }

  Widget _buildEditPost(double height) {
    return ListView(children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(height: 0.1 * height, child: _buildChoosePostType()),
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: _buildSelectedPostType(),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Text(
          "Project Details:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(15),
        child: _buildAddContent(),
      ),
      if (oldPictures.isNotEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text(
            "Old Pictures:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      _buildOldPhotos(height),
      if (newPictures.isNotEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text(
            "New Pictures:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      _buildNewPhotos(height),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildDoneBtn(),
      ),
    ]);
  }

  Widget _buildSelectedPostType() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: Theme.of(context).colorScheme.secondaryContainer),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          postType,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildChoosePostType() {
    return CustomDropDownButton(
        dropDownTitle: 'Project types',
        onSelect: (selectedList) {
          for (var item in selectedList) {
            if (item is SelectedListItem) {
              showSnackBar(context, "${item.name} is selected",
                  const Duration(seconds: 2));
              setState(() {
                postType = item.name;
              });
            }
          }
        },
        buttonTitle: "Select project type",
        dataList:
            PostType.values.map<String>((element) => element.type).toList());
  }

  Widget _buildAddContent() {
    return PostContentTextFormField(
        formkey: postContentFromKey,
        textEditingController: postContentTEC,
        errorMessage: "Please enter your post content",
        hintText: "enter your project details");
  }

  Widget _buildOldPhotos(double height) {
    if (oldPictures.isEmpty) {
      return const SizedBox();
    } else {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          children: [
            Container(
              height: 0.3 * height,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(75),
                  border: Border(
                    bottom: BorderSide(
                        width: 2,
                        color: Theme.of(context).colorScheme.onBackground),
                    top: BorderSide(
                        width: 2,
                        color: Theme.of(context).colorScheme.onBackground),
                  )),
              child: PageView.builder(
                controller: oldpicturesPagesController,
                scrollDirection: Axis.horizontal,
                onPageChanged: (value) => setState(() {
                  _oldPicturesIndex = value + 1;
                }),
                itemCount: oldPictures.length,
                itemBuilder: (context, index) => CachedNetworkImage(
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
                      "$_oldPicturesIndex / ${oldPictures.length}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  )),
                )),
            Positioned(
                right: 0,
                top: 0,
                child: MaterialButton(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      oldPictures.removeAt(_oldPicturesIndex - 1);
                      _oldPicturesIndex = 1;
                      oldpicturesPagesController.jumpToPage(0);
                    });
                  },
                )),
          ],
        ),
      );
    }
  }

  Widget _buildNewPhotos(double height) {
    if (newPictures.isEmpty) {
      return const SizedBox();
    } else {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          children: [
            Container(
              height: 0.3 * height,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(75),
                  border: Border(
                    bottom: BorderSide(
                        width: 2,
                        color: Theme.of(context).colorScheme.onBackground),
                    top: BorderSide(
                        width: 2,
                        color: Theme.of(context).colorScheme.onBackground),
                  )),
              child: PageView.builder(
                  controller: newpicturesPagesController,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (value) => setState(() {
                        _newPicturesIndex = value + 1;
                      }),
                  itemCount: newPictures.length,
                  itemBuilder: (context, index) => Image.file(
                        newPictures[index],
                      )),
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
                      "$_newPicturesIndex / ${newPictures.length}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  )),
                )),
            Positioned(
                right: 0,
                top: 0,
                child: MaterialButton(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      newPictures.removeAt(_newPicturesIndex - 1);
                      _newPicturesIndex = 1;
                      newpicturesPagesController.jumpToPage(0);
                    });
                  },
                )),
          ],
        ),
      );
    }
  }

  Widget _buildAddPicture() {
    return FloatingActionButton(
      onPressed: () async {
        final picture = await getImage();
        if (picture != null) {
          setState(() {
            newPictures.add(picture);
          });
        }
      },
      child: const Icon(Icons.add_photo_alternate_outlined),
    );
  }

  Widget _buildDoneBtn() {
    return CustomButton(
        onPressed: () {
          if (postContentFromKey.currentState!.validate()) {
            _postCurdBloc.add(UpdatePostCURDEvent(
                post: _createEditedPost(), pictures: newPictures));
          } else {
            showCustomAboutDialog(
                context,
                "Error",
                "Please Make sure to choose a valid project type & fill the project details",
                [],
                true);
          }
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text("Update Project"),
        ));
  }

  Post _createEditedPost() {
    return Post(
        postId: widget.post.postId,
        userId: widget.originalUser.id,
        postType: postType,
        date: widget.post.date,
        postPicturesUrls: oldPictures,
        likedUsersIds: widget.post.likedUsersIds,
        likesCount: widget.post.likesCount,
        content: postContentTEC.text.trim(),
        isEdited: true);
  }
}

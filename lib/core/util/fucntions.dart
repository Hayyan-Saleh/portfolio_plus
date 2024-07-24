import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portfolio_plus/core/util/auth_enum.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';

Future<File?> getImage() async {
  File? file;
  final ImagePicker picker = ImagePicker();
  final XFile? image =
      await picker.pickImage(source: ImageSource.gallery); //pic from gallery
  // final XFile? photo = await picker.pickImage(source: ImageSource.camera);//pic from camera
  if (image != null) {
    file = File(image.path);
  }
  return file;
}

void showCustomAboutDialog(BuildContext context, String title, String content,
    List<Widget>? actions, bool barrierDissmisable) {
  showDialog(
    barrierDismissible: barrierDissmisable,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        content: Text(
          content,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        actions: actions ??
            [
              MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: Text(
                    "ok",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.background),
                  )),
            ],
      );
    },
  );
}

void showSnackBar(BuildContext context, String content, Duration duration) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      duration: duration,
      content: Text(content,
          style: TextStyle(color: Theme.of(context).colorScheme.background))));
}

UserModel createOnlineFetchedUser({required UserModel user}) {
  return UserModel(
      id: user.id,
      authenticationType: user.authenticationType,
      lastSeenTime: Timestamp.now(),
      chatIds: user.chatIds,
      userPostsIds: user.userPostsIds,
      freindsIds: user.freindsIds,
      savedPostsIds: user.savedPostsIds,
      isOffline: false,
      birthDate: user.birthDate,
      userName: user.userName,
      accountName: user.accountName,
      email: user.email,
      profilePictureUrl: user.profilePictureUrl,
      gender: user.gender,
      isDarkMode: user.isDarkMode,
      phoneNumber: user.phoneNumber);
}

UserModel createTemporarUser(
    {required AuthenticationType authenticationType, required String email}) {
  return UserModel(
      id: FirebaseAuth.instance.currentUser!.uid,
      authenticationType: authenticationType.type,
      lastSeenTime: Timestamp.now(),
      chatIds: const [],
      userPostsIds: const [],
      freindsIds: const [],
      savedPostsIds: const [],
      isOffline: false,
      birthDate: Timestamp.now(),
      userName: '',
      accountName: '',
      email: email,
      profilePictureUrl: '',
      gender: '',
      isDarkMode: false,
      phoneNumber: '');
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
    backgroundColor: Colors.transparent,
    centerTitle: true,
    title: Text("Portfolio Plus",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 35,
            fontFamily: 'Brilliant',
            color: Theme.of(context).colorScheme.primary)),
  );
}

Timestamp dateTimeToTimestamp(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portfolio_plus/core/constants/maps.dart';
import 'package:portfolio_plus/core/errors/errors.dart';
import 'package:portfolio_plus/core/util/auth_enum.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';

Future<File?> getImage() async {
  File? file;
  final ImagePicker picker = ImagePicker();
  final XFile? image =
      await picker.pickImage(source: ImageSource.gallery); //pic from gallery
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

Future<String> getId() async {
  if (FirebaseAuth.instance.currentUser != null) {
    return FirebaseAuth.instance.currentUser!.uid;
  } else {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    if (googleAuth != null) {
      return googleAuth.idToken!;
    } else {
      throw OnlineException(message: "Error geting signed in google uid");
    }
  }
}

String getPhoneNumber(String number) {
  int index = number.lastIndexOf(RegExp(" "));
  String phoneNumber = number.substring(index + 1);
  return phoneNumber;
}

String getCountryCode(String number) {
  int index = number.lastIndexOf(RegExp(" "));
  String countryCode = number.substring(2, index);
  countryCodeMap.forEach((key, value) {
    if (value == countryCode) {
      countryCode = key;
    }
  });
  return countryCode;
}

UserModel createThemeUser({required UserModel user, required bool isDark}) {
  return UserModel(
      id: user.id,
      authenticationType: user.authenticationType,
      lastSeenTime: Timestamp.now(),
      chatIds: user.chatIds,
      userPostsIds: user.userPostsIds,
      followersIds: user.followersIds,
      followingIds: user.followingIds,
      savedPostsIds: user.savedPostsIds,
      isOffline: false,
      birthDate: user.birthDate,
      userName: user.userName,
      accountName: user.accountName,
      email: user.email,
      profilePictureUrl: user.profilePictureUrl,
      gender: user.gender,
      isDarkMode: isDark,
      phoneNumber: user.phoneNumber);
}

void showSnackBar(BuildContext context, String content, Duration duration) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      duration: duration,
      content: Text(content,
          style: TextStyle(color: Theme.of(context).colorScheme.background))));
}

UserModel createOnlineFetchedUser(
    {required UserModel user, required String authType}) {
  return UserModel(
      id: user.id,
      authenticationType: authType,
      lastSeenTime: Timestamp.now(),
      chatIds: user.chatIds,
      userPostsIds: user.userPostsIds,
      followersIds: user.followersIds,
      followingIds: user.followingIds,
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

UserModel createOpenedAppUser({required UserModel user}) {
  return UserModel(
      id: user.id,
      isOffline: false,
      birthDate: user.birthDate,
      lastSeenTime: Timestamp.now(),
      authenticationType: user.authenticationType,
      userName: user.userName,
      accountName: user.accountName,
      gender: user.gender,
      email: user.email,
      phoneNumber: user.phoneNumber,
      profilePictureUrl: user.profilePictureUrl,
      userPostsIds: user.userPostsIds,
      savedPostsIds: user.savedPostsIds,
      chatIds: user.chatIds,
      followersIds: user.followersIds,
      followingIds: user.followingIds,
      isDarkMode: user.isDarkMode);
}

UserModel createClosedAppUser({required UserModel user}) {
  return UserModel(
      id: user.id,
      isOffline: true,
      birthDate: user.birthDate,
      lastSeenTime: Timestamp.now(),
      authenticationType: user.authenticationType,
      userName: user.userName,
      accountName: user.accountName,
      gender: user.gender,
      email: user.email,
      phoneNumber: user.phoneNumber,
      profilePictureUrl: user.profilePictureUrl,
      userPostsIds: user.userPostsIds,
      savedPostsIds: user.savedPostsIds,
      chatIds: user.chatIds,
      followersIds: user.followersIds,
      followingIds: user.followingIds,
      isDarkMode: user.isDarkMode);
}

UserModel createNoAuthUser({required UserModel user}) {
  return UserModel(
      id: user.id,
      isOffline: true,
      birthDate: user.birthDate,
      lastSeenTime: Timestamp.now(),
      authenticationType: AuthenticationType.noAuth.type,
      userName: user.userName,
      accountName: user.accountName,
      gender: user.gender,
      email: user.email,
      phoneNumber: user.phoneNumber,
      profilePictureUrl: user.profilePictureUrl,
      userPostsIds: user.userPostsIds,
      savedPostsIds: user.savedPostsIds,
      chatIds: user.chatIds,
      followersIds: user.followersIds,
      followingIds: user.followingIds,
      isDarkMode: user.isDarkMode);
}

UserModel createTemporarUser(
    {required AuthenticationType authenticationType, required String email}) {
  return UserModel(
      id: FirebaseAuth.instance.currentUser!.uid,
      authenticationType: authenticationType.type,
      lastSeenTime: Timestamp.now(),
      chatIds: const [],
      userPostsIds: const [],
      followersIds: [],
      followingIds: [],
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

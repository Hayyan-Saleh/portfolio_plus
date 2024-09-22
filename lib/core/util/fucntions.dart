import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:portfolio_plus/core/constants/maps.dart';
import 'package:portfolio_plus/core/errors/errors.dart';
import 'package:portfolio_plus/core/util/auth_enum.dart';
import 'package:portfolio_plus/core/util/post_type_enum.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/chat/domain/entities/message_entity.dart';
import 'package:toastification/toastification.dart';

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
      phoneNumber: user.phoneNumber,
      isNotificationsPermissionGranted: user.isNotificationsPermissionGranted,
      userFCM: user.userFCM,
      favoritePostTypes: user.favoritePostTypes);
}

void showSnackBar(BuildContext context, String content, Duration duration) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      duration: duration,
      content: Text(content,
          style: TextStyle(color: Theme.of(context).colorScheme.background))));
}

UserModel createOnlineFetchedUser(
    {required UserModel user,
    required String authType,
    required String? userFCM}) {
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
      phoneNumber: user.phoneNumber,
      isNotificationsPermissionGranted: user.isNotificationsPermissionGranted,
      userFCM: userFCM,
      favoritePostTypes: user.favoritePostTypes);
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
      isDarkMode: user.isDarkMode,
      isNotificationsPermissionGranted: user.isNotificationsPermissionGranted,
      userFCM: user.userFCM,
      favoritePostTypes: user.favoritePostTypes);
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
      isDarkMode: user.isDarkMode,
      isNotificationsPermissionGranted: user.isNotificationsPermissionGranted,
      userFCM: user.userFCM,
      favoritePostTypes: user.favoritePostTypes);
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
      isDarkMode: user.isDarkMode,
      isNotificationsPermissionGranted: user.isNotificationsPermissionGranted,
      userFCM: user.userFCM,
      favoritePostTypes: user.favoritePostTypes);
}

UserModel createTemporarUser({
  required AuthenticationType authenticationType,
  required String email,
  required bool isNotificationsPermissionGranted,
  required String userFCM,
}) {
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
      phoneNumber: '',
      isNotificationsPermissionGranted: isNotificationsPermissionGranted,
      userFCM: userFCM,
      favoritePostTypes: []);
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

String generateUniqueId(List<String> ids) {
  ids.sort();
  return ids.join('_');
}

List<String> getUserIdsFromChatId(String chatId) {
  int index = chatId.indexOf(RegExp("_"));
  String firstUserId = chatId.substring(0, index);
  String secondUserId = chatId.substring(index + 1, chatId.length);

  return [firstUserId, secondUserId];
}

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

String getLastSeenTimeString(Timestamp timestamp) {
  final lastSeenTime = timestamp.toDate();
  final currentTime = DateTime.now();
  if (currentTime.minute == lastSeenTime.minute &&
      currentTime.hour == lastSeenTime.hour &&
      currentTime.day == lastSeenTime.day) {
    return "Last seen recently";
  } else if (currentTime.hour == lastSeenTime.hour &&
      currentTime.day == lastSeenTime.day) {
    return "Last seen ${currentTime.minute - lastSeenTime.minute} minutes ago";
  } else if (currentTime.day == lastSeenTime.day &&
      currentTime.month == lastSeenTime.month) {
    return "Last seen ${currentTime.hour - lastSeenTime.hour} hours ago";
  } else if (currentTime.month == lastSeenTime.month) {
    return "Last seen ${currentTime.day - lastSeenTime.day} days ago";
  } else {
    return "Last seen long time ago";
  }
}

MessageEntity createSeenMessage({required MessageEntity message}) {
  return MessageEntity(
      senderId: message.senderId,
      date: message.date,
      imageName: message.imageName,
      contentType: message.contentType,
      content: message.content,
      isSeen: true,
      isEdited: message.isEdited);
}

MessageEntity createEditedMessage(
    {required MessageEntity message, required String newData}) {
  return MessageEntity(
      senderId: message.senderId,
      imageName: message.imageName,
      date: message.date,
      contentType: message.contentType,
      content: newData,
      isSeen: false,
      isEdited: true);
}

String getFirstName(String name) {
  int spaceIndex = name.indexOf(' ');
  if (spaceIndex == -1) {
    // If there's no space, return the whole name
    return name;
  }
  return name.substring(0, spaceIndex);
}

Future<bool> getNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    return true;
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    return false;
  } else {
    return false;
  }
}

Future<String?> getUserFCM() async {
  return await FirebaseMessaging.instance.getToken();
}

void showToastMessage(BuildContext context, String title, String? subTitle) {
  if (subTitle != null) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(title),
      description: Text(subTitle),
      alignment: Alignment.bottomCenter,
      animationDuration: const Duration(milliseconds: 300),
      primaryColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.background,
      borderRadius: BorderRadius.circular(12),
      progressBarTheme: ProgressIndicatorThemeData(
          linearTrackColor: Theme.of(context).colorScheme.onPrimary,
          color: Theme.of(context).colorScheme.primary.withAlpha(100)),
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  } else {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(title),
      alignment: Alignment.bottomCenter,
      animationDuration: const Duration(milliseconds: 300),
      primaryColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.background,
      borderRadius: BorderRadius.circular(12),
      progressBarTheme: ProgressIndicatorThemeData(
          linearTrackColor: Theme.of(context).colorScheme.onPrimary,
          color: Theme.of(context).colorScheme.primary.withAlpha(100)),
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }
}

String generateUniqueImageName() {
  var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  var randomString = String.fromCharCodes(
      List.generate(5, (index) => Random().nextInt(33) + 89));
  return '$timestamp-$randomString';
}

int getRandomVal(int start, int end) {
  return start + Random().nextInt(end - start + 1).toInt();
}

List<String> getRandomUsersIds(List<String> usersIds, int count) {
  List<String> randomUsersIds = [];
  int usersIdsLength = usersIds.length;
  for (int i = 0; i < count; i++) {
    randomUsersIds.add(usersIds.elementAt(getRandomVal(0, usersIdsLength)));
  }
  return randomUsersIds;
}

List<String> getRandomUserFavoriteGenres(
    List<String> usersFavoriteGenres, int count) {
  List<String> randomUsersIds = [];
  int usersIdsLength = usersFavoriteGenres.length;
  for (int i = 0; i < count; i++) {
    randomUsersIds
        .add(usersFavoriteGenres.elementAt(getRandomVal(0, usersIdsLength)));
  }
  return randomUsersIds;
}

List<String> getRandomCategoriesNames(int count) {
  List<String> randomCategoriesNames = [];
  int categoriesLength = PostType.values.length;
  List<String> categoriesNames =
      PostType.values.map<String>((postType) => postType.type).toList();
  for (int i = 0; i < count; i++) {
    randomCategoriesNames
        .add(categoriesNames.elementAt(getRandomVal(0, categoriesLength)));
  }
  return randomCategoriesNames;
}

List<int> distributePostsCount(int totalPostsCount, int demanderCount) {
  Random random = Random();
  List<int> distribution = List.filled(demanderCount, 0);

  for (int i = 0; i < totalPostsCount; i++) {
    int randomPerson = random.nextInt(demanderCount);
    distribution[randomPerson]++;
  }

  return distribution;
}

String timeAgo(DateTime date) {
  final Duration difference = DateTime.now().difference(date);

  if (difference.inDays > 365) {
    final int years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 30) {
    final int months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'just now';
  }
}

String getPublishTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 2) {
    return 'yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}

String formatLikesCount(int likes) {
  if (likes >= 1000000) {
    return '${(likes / 1000000).toStringAsFixed(1)}M';
  } else if (likes >= 1000) {
    return '${(likes / 1000).toStringAsFixed(1)}K';
  } else {
    return likes.toString();
  }
}

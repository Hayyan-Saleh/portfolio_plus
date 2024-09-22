// ignore_for_file: overridden_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String authenticationType;
  @HiveField(2)
  final String? userName;
  @HiveField(3)
  final String? accountName;
  @HiveField(4)
  final String? gender;
  @HiveField(5)
  final String? email;
  @HiveField(6)
  final String? phoneNumber;
  @HiveField(7)
  final String? profilePictureUrl;
  @HiveField(8)
  final List<String> userPostsIds;
  @HiveField(9)
  final List<String> savedPostsIds;
  @HiveField(10)
  final List<String> chatIds;
  @HiveField(11)
  final bool? isDarkMode;
  @HiveField(12)
  final bool? isOffline;
  @HiveField(13)
  final Timestamp? birthDate;
  @HiveField(14)
  final Timestamp lastSeenTime;
  @HiveField(15)
  final List<String> followersIds;
  @HiveField(16)
  final List<String> followingIds;
  @HiveField(17)
  final String? userFCM;
  @HiveField(18)
  final bool? isNotificationsPermissionGranted;
  @HiveField(19)
  final List<String> favoritePostTypes;
  const UserModel(
      {required this.id,
      required this.userFCM,
      required this.isNotificationsPermissionGranted,
      required this.isOffline,
      required this.birthDate,
      required this.lastSeenTime,
      required this.authenticationType,
      required this.userName,
      required this.accountName,
      required this.gender,
      required this.email,
      required this.phoneNumber,
      required this.profilePictureUrl,
      required this.userPostsIds,
      required this.savedPostsIds,
      required this.chatIds,
      required this.followersIds,
      required this.followingIds,
      required this.isDarkMode,
      required this.favoritePostTypes});

  factory UserModel.fromJson(Map<String, dynamic> userMap) {
    return UserModel(
        id: userMap['id'],
        userFCM: userMap['userFCM'],
        isNotificationsPermissionGranted:
            userMap['isNotificationsPermissionGranted'],
        isOffline: userMap['isOffline'],
        birthDate: userMap['birthDate'],
        lastSeenTime: userMap['lastSeenTime'],
        authenticationType: userMap['authenticationType'],
        userName: userMap['userName'],
        accountName: userMap['accountName'],
        gender: userMap['gender'],
        email: userMap['email'],
        phoneNumber: userMap['phoneNumber'],
        profilePictureUrl: userMap['profilePictureUrl'],
        userPostsIds:
            (userMap['userPostsIds'] as List<dynamic>).cast<String>().toList(),
        savedPostsIds:
            (userMap['savedPostsIds'] as List<dynamic>).cast<String>().toList(),
        chatIds: (userMap['chatIds'] as List<dynamic>).cast<String>().toList(),
        followersIds:
            (userMap['followersIds'] as List<dynamic>).cast<String>().toList(),
        followingIds:
            (userMap['followingIds'] as List<dynamic>).cast<String>().toList(),
        isDarkMode: userMap['isDarkMode'],
        favoritePostTypes: (userMap['favoritePostTypes'] as List<dynamic>)
            .cast<String>()
            .toList());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userFCM': userFCM,
      'isNotificationsPermissionGranted': isNotificationsPermissionGranted,
      'isOffline': isOffline,
      'birthDate': birthDate,
      'lastSeenTime': lastSeenTime,
      'authenticationType': authenticationType,
      'userName': userName,
      'accountName': accountName,
      'gender': gender,
      'email': email,
      "phoneNumber": phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'userPostsIds': userPostsIds,
      'savedPostsIds': savedPostsIds,
      'chatIds': chatIds,
      'followersIds': followersIds,
      'followingIds': followingIds,
      'isDarkMode': isDarkMode,
      'favoritePostTypes': favoritePostTypes
    };
  }
}

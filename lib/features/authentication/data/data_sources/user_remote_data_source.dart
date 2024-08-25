import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/errors/errors.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';

abstract class UserRemoteDataSource extends Equatable {
  Future<UserModel> fetchOnlineUser(String userId);
  Future<UserModel> changeUserData(UserModel user);
  Future<UserModel> storeOnlineUser(UserModel user);
  Future<String> storeProfilePicture(String userId, File file);
  Future<bool> checkAccountName(String accountName);
  Future<List<UserModel>> getSearchedUsers(String name);
  Future<UserModel> followUser(String id);
  Future<UserModel> unfollowUser(String id);
  Future<List<UserModel>> getUsersByIds(List<String> ids);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  @override
  Future<UserModel> changeUserData(UserModel user) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      final DocumentReference userDocRef = usersCollection.doc(user.id);
      await userDocRef.set(user.toJson());
      return await fetchOnlineUser(user.id);
    } catch (exception) {
      throw OnlineException(
          message:
              "Coudn't Update data in the server ... please try again later");
    }
  }

  @override
  Future<UserModel> fetchOnlineUser(String userId) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      final DocumentReference userDocRef = usersCollection.doc(userId);
      final DocumentSnapshot userDocument = await userDocRef.get();
      if (userDocument.exists) {
        return UserModel.fromJson(userDocument.data() as Map<String, dynamic>);
      } else {
        throw OnlineException(message: NO_USER_ONLINE_FETCH_ERROR);
      }
    } on OnlineException catch (e) {
      throw OnlineException(message: e.message);
    } catch (exception) {
      throw OnlineException(
          message: "Coudn't Get data from server ... please try again later");
    }
  }

  @override
  Future<UserModel> storeOnlineUser(UserModel user) async {
    try {
      final DocumentReference usersDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.id);
      await usersDocRef.set(user.toJson());
      return await fetchOnlineUser(user.id);
    } catch (exception) {
      throw OnlineException(
          message:
              "Coudn't Store data in the server ... please try again later");
    }
  }

  @override
  Future<String> storeProfilePicture(String userId, File file) async {
    try {
      final Reference referenceForStorage =
          FirebaseStorage.instance.ref("users_profile_picture").child(userId);
      await referenceForStorage.putFile(file);
      return referenceForStorage.getDownloadURL();
    } catch (e) {
      throw OnlineException(message: PHOTO_FETCHING_ERROR);
    }
  }

  @override
  Future<bool> checkAccountName(String accountName) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      final QuerySnapshot query = await usersCollection
          .where('accountName', isEqualTo: accountName)
          .get();

      return query.docs.isEmpty;
    } catch (e) {
      throw OnlineException(message: ACCOUNT_NAME_CHECKING_ERROR);
    }
  }

  @override
  Future<List<UserModel>> getSearchedUsers(String name) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      final String userId = await getId();
      final QuerySnapshot query = await usersCollection.get();

      final List<UserModel> users = query.docs
          .map<UserModel>((userDoc) =>
              UserModel.fromJson(userDoc.data() as Map<String, dynamic>))
          .toList();
      final List<UserModel> filteredUsers = users.where((user) {
        if (user.accountName != null) {
          return user.accountName!.contains(name) ||
              user.userName!.contains(name);
        } else {
          return false;
        }
      }).toList();
      return filteredUsers..removeWhere((user) => user.id == userId);
    } catch (e) {
      throw OnlineException(message: e.toString());
    }
  }

  @override
  Future<List<UserModel>> getUsersByIds(List<String> ids) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      List<UserModel> users = [];
      for (String userId in ids) {
        final DocumentSnapshot userDoc =
            await usersCollection.doc(userId).get();
        if (userDoc.exists) {
          users.add(UserModel.fromJson(userDoc.data() as Map<String, dynamic>));
        }
      }
      return users;
    } catch (e) {
      throw OnlineException(message: e.toString());
    }
  }

  @override
  Future<UserModel> unfollowUser(String id) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Get the current user's ID
      final String currentUserId = await getId();

      // Fetch the documents for the current user and the user being followed
      final DocumentSnapshot originalUserDoc =
          await usersCollection.doc(currentUserId).get();
      final DocumentSnapshot followingUserDoc =
          await usersCollection.doc(id).get();

      // Update the "followingIds" list for the original user
      final UserModel originalUser =
          UserModel.fromJson(originalUserDoc.data() as Map<String, dynamic>);
      final List<String> followingIds = originalUser.followingIds;
      if (followingIds.contains(id)) {
        followingIds.remove(id);
        await usersCollection
            .doc(currentUserId)
            .update({'followingIds': followingIds});
      }
      // Update the "followersIds" list for the followed user
      final UserModel followingUser =
          UserModel.fromJson(followingUserDoc.data() as Map<String, dynamic>);
      final List<String> followersIds = followingUser.followersIds;
      if (followersIds.contains(currentUserId)) {
        followersIds.remove(currentUserId);
        await usersCollection.doc(id).update({'followersIds': followersIds});
      }

      // Return successfully
      return await fetchOnlineUser(id);
    } catch (e) {
      throw OnlineException(message: e.toString());
    }
  }

  @override
  Future<UserModel> followUser(String id) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Get the current user's ID
      final String currentUserId = await getId();

      // Fetch the documents for the current user and the user being followed
      final DocumentSnapshot originalUserDoc =
          await usersCollection.doc(currentUserId).get();
      final DocumentSnapshot followingUserDoc =
          await usersCollection.doc(id).get();

      // Update the "followingIds" list for the original user
      final UserModel originalUser =
          UserModel.fromJson(originalUserDoc.data() as Map<String, dynamic>);
      final List<String> followingIds = originalUser.followingIds;
      if (!followingIds.contains(id)) {
        followingIds.add(id);
        await usersCollection
            .doc(currentUserId)
            .update({'followingIds': followingIds});
      }
      // Update the "followersIds" list for the followed user
      final UserModel followingUser =
          UserModel.fromJson(followingUserDoc.data() as Map<String, dynamic>);
      final List<String> followersIds = followingUser.followersIds;
      if (!followersIds.contains(currentUserId)) {
        followersIds.add(currentUserId);
        await usersCollection.doc(id).update({'followersIds': followersIds});
      }

      // Return successfully
      return await fetchOnlineUser(id);
    } catch (e) {
      throw OnlineException(message: e.toString());
    }
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}

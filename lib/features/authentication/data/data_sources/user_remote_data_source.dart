import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/errors/errors.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';

abstract class UserRemoteDataSource extends Equatable {
  Future<UserModel> fetchOnlineUser(String userId);
  Future<UserModel> changeUserData(UserModel user);
  Future<UserModel> storeOnlineUser(UserModel user);
  Future<String> storeProfilePicture(String userId, File file);
  Future<bool> checkAccountName(String accountName);
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
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:portfolio_plus/core/constants/strings.dart';
import 'package:portfolio_plus/core/errors/errors.dart';
import 'package:portfolio_plus/core/util/fucntions.dart';
import 'package:portfolio_plus/core/util/globale_variables.dart';
import 'package:portfolio_plus/core/util/post_type_enum.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/post/data/models/post_model.dart';
import 'package:portfolio_plus/features/post/domain/entities/post_data_and_count_entity.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

abstract class PostRemoteDataSource extends Equatable {
  Future<void> addPost(PostModel post, List<File> pictures);
  Future<void> editPost(PostModel post, List<File> pictures);
  Future<void> deletePost(PostModel post);
  Future<void> savePost(PostModel post, UserModel user);
  Future<void> unSavePost(PostModel post, UserModel user);
  Future<void> likePost(PostModel post, UserModel user);
  Future<void> unlikePost(PostModel post, UserModel user);
  Future<void> addToFavorites(String postType, UserModel user);
  Future<void> removeToFavorites(String postType, UserModel user);
  Future<List<PostModel>> searchPosts(String query);
  Future<List<PostModel>> getSavedPost(List<String> savedPostsIds);
  Future<List<PostModel>> getUserPosts(UserModel user);
  Future<List<PostModel>> getOtherUsersPosts(
      UserModel originalUser, int limit, bool? discover);
  Future<void> listenToPosts(
      StreamController<PostModel> controller, UserModel user, bool? discover);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  @override
  Future<void> addPost(PostModel post, List<File> pictures) async {
    if (pictures.isNotEmpty) {
      List<String> imageUrls = [];
      for (int i = 0; i < pictures.length; i++) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('posts_pictures/${post.userId}/${post.postId}/$i');
        UploadTask uploadTask = ref.putFile(pictures[i]);
        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }
      post = _createPicturesPost(post, imageUrls);
    }

    final DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(post.userId);
    final CollectionReference postCollectionRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('user_posts');
    final CollectionReference categoriesCollectionRef = FirebaseFirestore
        .instance
        .collection('categories')
        .doc(post.postType)
        .collection('category_posts');

    // Start a Firestore batch
    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.update(userDocRef, {
      'userPostsIds': FieldValue.arrayUnion([post.postId])
    });
    batch.set(postCollectionRef.doc(post.postId), post.toJson());
    batch.set(categoriesCollectionRef.doc(post.postId), post.toJson());

    // Commit the batch
    await batch.commit();
    await _addFavoritePostsType(post.userId, post.postType);
    //* get all users to check if the notification permission is granted then send it
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Iterate through all users
    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      // Check if the user has the post ID in their savedPostsIds
      final bool isNotificationsPermissionGranted =
          userDoc['isNotificationsPermissionGranted'];
      if (isNotificationsPermissionGranted && post.userId != userDoc['id']) {
        await _sendPostNotification(await _fetchUser(post.userId),
            UserModel.fromJson(userDoc.data() as Map<String, dynamic>), post);
      }
    }
  }

  @override
  Future<void> editPost(PostModel post, List<File> pictures) async {
    if (post.postPicturesUrls.isNotEmpty) {
      final Reference folderStorageRef = FirebaseStorage.instance
          .ref()
          .child('posts_pictures/${post.userId}/${post.postId}');
      // List all files in the folder
      ListResult result = await folderStorageRef.listAll();

      // Delete each file
      for (Reference fileRef in result.items) {
        final String downUrl = await fileRef.getDownloadURL();
        if (!post.postPicturesUrls.contains(downUrl)) {
          await fileRef.delete();
        }
      }
    }
    if (pictures.isNotEmpty) {
      List<String> imageUrls = [];
      for (int i = 0; i < pictures.length; i++) {
        final now = DateTime.now();
        final String fileName =
            now.second.toString() + now.hour.toString() + now.day.toString();
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('posts_pictures/${post.userId}/${post.postId}/$fileName');
        UploadTask uploadTask = ref.putFile(pictures[i]);
        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }
      post = _createPicturesPost(post, imageUrls);
    }

    final CollectionReference postCollectionRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('user_posts');
    final CollectionReference categoriesCollectionRef = FirebaseFirestore
        .instance
        .collection('categories')
        .doc(post.postType)
        .collection('category_posts');
    // Start a Firestore batch
    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.set(postCollectionRef.doc(post.postId), post.toJson());
    batch.set(categoriesCollectionRef.doc(post.postId), post.toJson());
    // Commit the batch
    await batch.commit();
  }

  @override
  Future<void> deletePost(PostModel post) async {
    if (post.postPicturesUrls.isNotEmpty) {
      final Reference folderStorageRef = FirebaseStorage.instance
          .ref()
          .child('posts_pictures/${post.userId}/${post.postId}');
      // List all files in the folder
      ListResult result = await folderStorageRef.listAll();

      // Delete each file
      for (Reference fileRef in result.items) {
        await fileRef.delete();
      }
    }
    final DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(post.userId);
    final CollectionReference postCollectionRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('user_posts');
    final CollectionReference categoriesCollectionRef = FirebaseFirestore
        .instance
        .collection('categories')
        .doc(post.postType)
        .collection('category_posts');
    final DocumentReference commentsDocRef =
        FirebaseFirestore.instance.collection('comments').doc(post.postId);
    final CollectionReference commentsColRef =
        commentsDocRef.collection('post_comments');
    // Start a Firestore batch
    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.update(userDocRef, {
      'userPostsIds': FieldValue.arrayRemove([post.postId])
    });

    //* get all users to check if the post id inside any of their saved post ids => delete it from there
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Iterate through all users
    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      // Check if the user has the post ID in their savedPostsIds
      List<String> savedPostsIds =
          (userDoc['savedPostsIds'] as List).map<String>((savedPostId) {
        final postId = savedPostId.toString();
        return postId.substring(postId.indexOf('_') + 1);
      }).toList();
      if (savedPostsIds.contains(post.postId)) {
        // Remove the post ID from the savedPostsIds array
        batch.update(userDoc.reference, {
          'savedPostsIds':
              FieldValue.arrayRemove(["${post.userId}_${post.postId}"])
        });
      }
    }
    batch.delete(postCollectionRef.doc(post.postId));
    batch.delete(categoriesCollectionRef.doc(post.postId));
    batch.delete(commentsDocRef);
    QuerySnapshot commentsSnapshot = await commentsColRef.get();

    // Delete each comment in the subcollection
    for (QueryDocumentSnapshot doc in commentsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the parent document
    batch.delete(commentsDocRef);
    // Commit the batch
    await batch.commit();
  }

  @override
  Future<void> savePost(PostModel post, UserModel user) async {
    final DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.id);
    await userDocRef.update({
      'savedPostsIds': FieldValue.arrayUnion(
        ["${post.userId}_${post.postId}"],
      ),
      'favoritePostTypes': FieldValue.arrayUnion([post.postType]),
    });
  }

  @override
  Future<void> unSavePost(PostModel post, UserModel user) async {
    final DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.id);
    await userDocRef.update({
      'savedPostsIds': FieldValue.arrayRemove(["${post.userId}_${post.postId}"])
    });
  }

  @override
  Future<void> likePost(PostModel post, UserModel user) async {
    final Map<String, dynamic> updatedMap = {
      'likedUsersIds': FieldValue.arrayUnion([user.id]),
      'likesCount': post.likedUsersIds.length + 1
    };
    final CollectionReference postCollectionRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('user_posts');
    final CollectionReference categoriesCollectionRef = FirebaseFirestore
        .instance
        .collection('categories')
        .doc(post.postType)
        .collection('category_posts');

    // Start a Firestore batch
    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.update(postCollectionRef.doc(post.postId), updatedMap);
    batch.update(categoriesCollectionRef.doc(post.postId), updatedMap);
    await batch.commit();
  }

  @override
  Future<void> unlikePost(PostModel post, UserModel user) async {
    final Map<String, dynamic> updatedMap = {
      'likedUsersIds': FieldValue.arrayRemove([user.id]),
      'likesCount': post.likedUsersIds.length - 1
    };
    final CollectionReference postCollectionRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('user_posts');
    final CollectionReference categoriesCollectionRef = FirebaseFirestore
        .instance
        .collection('categories')
        .doc(post.postType)
        .collection('category_posts');

    // Start a Firestore batch
    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.update(postCollectionRef.doc(post.postId), updatedMap);
    batch.update(categoriesCollectionRef.doc(post.postId), updatedMap);
    await batch.commit();
  }

  @override
  Future<void> addToFavorites(String postType, UserModel user) async {
    await _addFavoritePostsType(user.id, postType);
  }

  @override
  Future<void> removeToFavorites(String postType, UserModel user) async {
    await _removeFavoritePostsType(user.id, postType);
  }

  @override
  Future<List<PostModel>> searchPosts(String query) async {
    final List<PostModel> searchedPosts = [];
    for (PostType type in PostType.values) {
      final List<PostModel> matchingPosts = [];
      // Fetch all categories
      final QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc(type.type)
          .collection('category_posts')
          .get();

      // Iterate through each post
      for (QueryDocumentSnapshot postDoc in postsSnapshot.docs) {
        // Check if the 'content' field contains the search query
        if (postDoc.get('content').toString().contains(query)) {
          // Add the matching post to the list
          matchingPosts
              .add(PostModel.fromJson(postDoc.data() as Map<String, dynamic>));
        }
      }

      searchedPosts.addAll(matchingPosts);
    }
    searchedPosts.sort(
        (firstPost, secondPost) => secondPost.date.compareTo(firstPost.date));
    return searchedPosts;
  }

  @override
  Future<List<PostModel>> getUserPosts(UserModel user) async {
    List<PostModel> posts = [];
    for (String postId in user.userPostsIds) {
      posts.add(await _fetchPost(user.id, postId));
    }
    posts.sort(
        (firstPost, secondPost) => secondPost.date.compareTo(firstPost.date));
    return posts;
  }

  @override
  Future<List<PostModel>> getSavedPost(List<String> savedPostsIds) async {
    List<PostModel> posts = [];
    for (String savedPostId in savedPostsIds) {
      List<String> seperatedIds = savedPostId.split("_");
      posts.add(await _fetchPost(seperatedIds[0], seperatedIds[1]));
    }
    posts.sort(
        (firstPost, secondPost) => secondPost.date.compareTo(firstPost.date));
    return posts;
  }

  @override
  Future<void> listenToPosts(StreamController<PostModel> controller,
      UserModel user, bool? discover) async {
    if (discover == null) {
      _listenToFollowingUsersPosts(controller, user.followingIds);
    } else if (discover) {
      await _listenToRandomUsersPosts(controller);
    } else {
      _listenToFavoriteUserGenresPosts(controller, user.favoritePostTypes);
    }
  }

  @override
  Future<List<PostModel>> getOtherUsersPosts(
      UserModel originalUser, int limit, bool? discover) async {
    final List<PostModel> posts;
    if (discover == null) {
      posts = await _getFollowingUsersPosts(originalUser.followingIds, limit);
    } else if (discover) {
      posts = await _getRandomUsersPosts(limit);
    } else {
      posts = await _getFavoriteUserGenresPosts(
          originalUser.favoritePostTypes, limit);
    }
    posts.sort(
        (firstPost, secondPost) => secondPost.date.compareTo(firstPost.date));
    return posts;
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;

  PostModel _createPicturesPost(
      PostModel post, List<String> picturesDownloadLinks) {
    return PostModel(
        postId: post.postId,
        userId: post.userId,
        postType: post.postType,
        date: post.date,
        postPicturesUrls: post.postPicturesUrls + picturesDownloadLinks,
        likedUsersIds: post.likedUsersIds,
        content: post.content,
        isEdited: post.isEdited,
        likesCount: post.likesCount);
  }

  Future<PostModel> _fetchPost(String userId, String postId) async {
    final CollectionReference postCollectionRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(userId)
        .collection('user_posts');
    final DocumentSnapshot docSnapshot =
        await postCollectionRef.doc(postId).get();
    return PostModel.fromJson(docSnapshot.data() as Map<String, dynamic>);
  }

  Future<UserModel> _fetchUser(String userId) async {
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

  Future<bool> _sendPostNotification(
    UserModel originalUser,
    UserModel otherUser,
    PostModel post,
  ) async {
    final accessToken = await _getAccessToken();
    Map<String, String> headersList = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken"
    };

    Uri url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/portfolio-plus-c2a7a/messages:send');
    Map<String, dynamic> body = {
      "message": {
        "token": otherUser.userFCM,
        "notification": {
          "title": "New Post from ${getFirstName(originalUser.userName!)}",
          "body": post.content
        },
        "android": {
          "notification": {
            "notification_priority": "PRIORITY_MAX",
            "sound": "default"
          }
        },
        "apns": {
          "payload": {
            "aps": {"content_available": true}
          }
        },
        "data": {
          "type": "post",
          "otherUserId": jsonEncode(otherUser.id),
          "originalUserId": jsonEncode(originalUser.id),
          "postId": jsonEncode(post.postId)
        }
      }
    };
    final req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);
    final res = await req.send();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return true;
    }
    return false;
  }

  Future<String?> _getAccessToken() async {
    final serviceAccountJson = {}; //TODO: Add your own service credentials

    List<String> scopes = []; //TODO: Add your own scopes
    try {
      http.Client client = await auth.clientViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
              auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
              scopes,
              client);

      client.close();
      return credentials.accessToken.data;
    } catch (e) {
      throw OnlineException(message: e.toString());
    }
  }

  void _listenToFollowingUsersPosts(
      StreamController<PostModel> controller, List<String> followingIds) {
    for (String userId in followingIds) {
      final Stream<QuerySnapshot> userPostsSnapshotStream = FirebaseFirestore
          .instance
          .collection('posts')
          .doc(userId)
          .collection('user_posts')
          .snapshots();
      userPostsSnapshotStream.listen((QuerySnapshot userPostsSnapshot) {
        for (DocumentSnapshot userPostDoc in userPostsSnapshot.docs) {
          if (userPostDoc.exists) {
            controller.add(
                PostModel.fromJson(userPostDoc.data() as Map<String, dynamic>));
          }
        }
      });
    }
  }

  Future<void> _listenToRandomUsersPosts(
      StreamController<PostModel> controller) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get all user document references from the 'posts' collection
    QuerySnapshot usersSnapshot = await firestore.collection('posts').get();

    // Iterate through each user document reference
    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      // Reference to the user's posts collection
      CollectionReference userPostsRef =
          userDoc.reference.collection('user_posts');

      // Listen to the user's posts
      userPostsRef.snapshots().listen((QuerySnapshot userPostsSnapshot) {
        for (DocumentSnapshot userPostDoc in userPostsSnapshot.docs) {
          if (userPostDoc.exists) {
            if (userPostDoc.exists) {
              controller.add(PostModel.fromJson(
                  userPostDoc.data() as Map<String, dynamic>));
            }
          }
        }
      });
    }
  }

  void _listenToFavoriteUserGenresPosts(
      StreamController<PostModel> controller, List<String> favoriteTypes) {
    for (String favoriteType in favoriteTypes) {
      final Stream<QuerySnapshot> categoriesCollectionRef = FirebaseFirestore
          .instance
          .collection('categories')
          .doc(favoriteType)
          .collection('category_posts')
          .snapshots();
      categoriesCollectionRef.listen((QuerySnapshot userPostsSnapshot) {
        for (DocumentSnapshot userPostDoc in userPostsSnapshot.docs) {
          if (userPostDoc.exists) {
            if (userPostDoc.exists) {
              controller.add(PostModel.fromJson(
                  userPostDoc.data() as Map<String, dynamic>));
            }
          }
        }
      });
    }
  }

  Future<List<PostModel>> _getRandomUsersPosts(int limit) async {
    List<PostModel> fetchedPosts = [];
    int categoriesNum =
        getRandomVal(1, 5); // get random number categories for fetching
    List<String> randomCategoriesNames = getRandomCategoriesNames(
        categoriesNum); //get random names of categories = the number of categories for fetching
    List<int> randomPostsCount = distributePostsCount(limit,
        categoriesNum); //get random fetch posts number of categories the sum of it =the number of limit
    if (postsDataCountList.isNotEmpty) {
      List<String> previousFetchedCategories =
          postsDataCountList.map<String>((element) => element.data).toList();
      for (int i = 0; i < categoriesNum; i++) {
        int matchedCategoryNameIndex = -1;
        for (int j = 0; j < previousFetchedCategories.length; j++) {
          if (previousFetchedCategories[j] == randomCategoriesNames[i]) {
            matchedCategoryNameIndex = j;
            break;
          }
        }
        if (matchedCategoryNameIndex != -1) {
          final List<PostModel> categoryPosts = await getCategoryPosts(
              postsDataCountList[matchedCategoryNameIndex].count,
              randomPostsCount[i],
              randomCategoriesNames[i]);
          fetchedPosts.addAll(categoryPosts);
          final String PDCName =
              postsDataCountList[matchedCategoryNameIndex].data;
          final int oldCount =
              postsDataCountList[matchedCategoryNameIndex].count;
          postsDataCountList[matchedCategoryNameIndex] =
              PDC(data: PDCName, count: oldCount + categoryPosts.length);
        } else {
          final List<PostModel> categoryPosts = await getCategoryPosts(
              0, randomPostsCount[i], randomCategoriesNames[i]);
          fetchedPosts.addAll(categoryPosts);
          postsDataCountList.add(
              PDC(data: randomCategoriesNames[i], count: categoryPosts.length));
        }
      }
      return fetchedPosts;
    } else {
      for (int i = 0; i < categoriesNum; i++) {
        final List<PostModel> categoryPosts = await getCategoryPosts(
            0, randomPostsCount[i], randomCategoriesNames[i]);
        fetchedPosts.addAll(categoryPosts);
        postsDataCountList.add(
            PDC(data: randomCategoriesNames[i], count: categoryPosts.length));
      }
      return fetchedPosts;
    }
  }

  Future<List<PostModel>> _getFollowingUsersPosts(
      List<String> followingIds, int limit) async {
    List<PostModel> fetchedPosts = [];
    int usersNum = getRandomVal(
        1,
        followingIds.length < 10
            ? followingIds.length
            : (followingIds.length * 0.5)
                .round()); // get random number users for fetching
    List<String> randomUsersIds = getRandomUsersIds(followingIds,
        usersNum); //get random ids of users = the number of users for fetching
    List<int> randomPostsCount = distributePostsCount(limit,
        usersNum); //get random fetch posts number of categories the sum of it =the number of limit
    if (postsDataCountList.isNotEmpty) {
      List<String> previousFetchedUserIds =
          postsDataCountList.map<String>((element) => element.data).toList();
      for (int i = 0; i < usersNum; i++) {
        int matchedUserIdIndex = -1;
        for (int j = 0; j < previousFetchedUserIds.length; j++) {
          if (previousFetchedUserIds[j] == randomUsersIds[i]) {
            matchedUserIdIndex = j;
            break;
          }
        }
        if (matchedUserIdIndex != -1) {
          final List<PostModel> userPosts = await getCustomUserIdPosts(
              postsDataCountList[matchedUserIdIndex].count,
              randomPostsCount[i],
              randomUsersIds[i]);
          fetchedPosts.addAll(userPosts);
          final String PDCName = postsDataCountList[matchedUserIdIndex].data;
          final int oldCount = postsDataCountList[matchedUserIdIndex].count;
          postsDataCountList[matchedUserIdIndex] =
              PDC(data: PDCName, count: oldCount + userPosts.length);
        } else {
          final List<PostModel> userPosts = await getCustomUserIdPosts(
              0, randomPostsCount[i], randomUsersIds[i]);
          fetchedPosts.addAll(userPosts);
          postsDataCountList
              .add(PDC(data: randomUsersIds[i], count: userPosts.length));
        }
      }
      return fetchedPosts;
    } else {
      for (int i = 0; i < usersNum; i++) {
        final List<PostModel> userPosts = await getCustomUserIdPosts(
            0, randomPostsCount[i], randomUsersIds[i]);
        fetchedPosts.addAll(userPosts);
        postsDataCountList
            .add(PDC(data: randomUsersIds[i], count: userPosts.length));
      }
      return fetchedPosts;
    }
  }

  Future<List<PostModel>> _getFavoriteUserGenresPosts(
      List<String> favoritePostTypes, int limit) async {
    List<PostModel> fetchedPosts = [];
    int categoriesNum = getRandomVal(
        1,
        favoritePostTypes.length > 5
            ? 5
            : favoritePostTypes
                .length); // get random number categories for fetching
    List<String> randomCategoriesNames = getRandomUserFavoriteGenres(
        favoritePostTypes,
        categoriesNum); //get random names of categories = the number of categories for fetching
    List<int> randomPostsCount = distributePostsCount(limit,
        categoriesNum); //get random fetch posts number of categories the sum of it =the number of limit
    if (postsDataCountList.isNotEmpty) {
      List<String> previousFetchedCategories =
          postsDataCountList.map<String>((element) => element.data).toList();
      for (int i = 0; i < categoriesNum; i++) {
        int matchedCategoryNameIndex = -1;
        for (int j = 0; j < previousFetchedCategories.length; j++) {
          if (previousFetchedCategories[j] == randomCategoriesNames[i]) {
            matchedCategoryNameIndex = j;
            break;
          }
        }
        if (matchedCategoryNameIndex != -1) {
          final List<PostModel> genrePosts = await getCategoryPosts(
              postsDataCountList[matchedCategoryNameIndex].count,
              randomPostsCount[i],
              randomCategoriesNames[i]);
          fetchedPosts.addAll(genrePosts);
          final String PDCName =
              postsDataCountList[matchedCategoryNameIndex].data;
          final int oldCount =
              postsDataCountList[matchedCategoryNameIndex].count;
          postsDataCountList[matchedCategoryNameIndex] =
              PDC(data: PDCName, count: oldCount + genrePosts.length);
        } else {
          final List<PostModel> genrePosts = await getCategoryPosts(
              0, randomPostsCount[i], randomCategoriesNames[i]);
          fetchedPosts.addAll(genrePosts);
          postsDataCountList.add(
              PDC(data: randomCategoriesNames[i], count: genrePosts.length));
        }
      }
      return fetchedPosts;
    } else {
      for (int i = 0; i < categoriesNum; i++) {
        final List<PostModel> genrePosts = await getCategoryPosts(
            0, randomPostsCount[i], randomCategoriesNames[i]);
        fetchedPosts.addAll(genrePosts);
        postsDataCountList
            .add(PDC(data: randomCategoriesNames[i], count: genrePosts.length));
      }
      return fetchedPosts;
    }
  }

  Future<List<PostModel>> getCustomUserIdPosts(
      int start, int limit, String userId) async {
    Query query = FirebaseFirestore.instance
        .collection('posts')
        .doc(userId)
        .collection('user_posts')
        .orderBy('date')
        .startAt([start]).limit(limit - start);

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs
        .map<PostModel>(
            (post) => PostModel.fromJson(post.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<PostModel>> getCategoryPosts(
      int start, int limit, String categoryName) async {
    Query query = FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryName)
        .collection('category_posts');

    QuerySnapshot querySnapshot =
        await query.orderBy('date').startAt([start]).limit(limit - start).get();
    return querySnapshot.docs
        .map<PostModel>(
            (post) => PostModel.fromJson(post.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> _addFavoritePostsType(String userId, String postType) async {
    final Map<String, dynamic> updatedMap = {
      'favoritePostTypes': FieldValue.arrayUnion([postType]),
    };
    final DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    await userDocRef.update(updatedMap);
  }

  Future<void> _removeFavoritePostsType(String userId, String postType) async {
    final Map<String, dynamic> updatedMap = {
      'favoritePostTypes': FieldValue.arrayRemove([postType]),
    };
    final DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    await userDocRef.update(updatedMap);
  }
}

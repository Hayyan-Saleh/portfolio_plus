import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:portfolio_plus/core/network_info/network_info.dart';
import 'package:portfolio_plus/core/util/timestamp_adapter.dart';
import 'package:portfolio_plus/features/authentication/data/data_sources/auth_remote_data_source.dart';
import 'package:portfolio_plus/features/authentication/data/data_sources/user_local_data_source.dart';
import 'package:portfolio_plus/features/authentication/data/data_sources/user_remote_data_source.dart';
import 'package:portfolio_plus/features/authentication/data/models/user_model.dart';
import 'package:portfolio_plus/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:portfolio_plus/features/authentication/data/repositories/user_repository_impl.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/auth_repository.dart';
import 'package:portfolio_plus/features/authentication/domain/repositories/user_repository.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/send_password_reset_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/send_verification_email_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/signin_using_email_password_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/signout_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/signup_using_email_password_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/auth_use_cases/singin_using_google_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/change_user_data_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/check_user_account_name_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/fetch_offline_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/fetch_online_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/follow_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/get_searched_users_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/get_users_by_ids_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/store_offline_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/store_online_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/store_profile_photo_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/unfollow_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/search_users_bloc/search_users_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_account_name_bloc/user_account_name_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_profile_picture_bloc/user_profile_picture_bloc.dart';
import 'package:portfolio_plus/features/chat/data/data_sources/chat_box_remote_data_source.dart';
import 'package:portfolio_plus/features/chat/data/repositories/chat_box_repo_impl.dart';
import 'package:portfolio_plus/features/chat/domain/repositories/chat_box_repository.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/add_message_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/create_chat_box_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/delete_message_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/get_chat_boxes_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/listen_to_chat_box_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/listen_to_user_use_case.dart';
import 'package:portfolio_plus/features/chat/domain/use_cases/modify_message_use_case.dart';
import 'package:portfolio_plus/features/chat/presentation/bloc/chat_box_bloc/chat_box_bloc.dart';
import 'package:portfolio_plus/features/chat/presentation/bloc/chat_boxes_list_bloc/chat_boxes_list_bloc.dart';
import 'package:portfolio_plus/features/chat/presentation/bloc/chat_page_listener_bloc/chat_page_listener_bloc.dart';

final sl = GetIt.instance;
Future<void> init() async {
  //! features - authentication

  //* bloc

  sl.registerFactory(() => UserBloc(
      changeUserData: sl(),
      fetchOfflineUser: sl(),
      fetchOnlineUser: sl(),
      storeOfflineUser: sl(),
      storeOnlineUser: sl(),
      followUser: sl(),
      unFollowUser: sl(),
      getUsersByIds: sl()));
  sl.registerFactory(() => UserProfilePictureBloc(storeProfilePhoto: sl()));
  sl.registerFactory(() => UserAccountNameBloc(checkUserAccountName: sl()));
  sl.registerFactory(() => SearchUsersBloc(getSearchedUsers: sl()));
  sl.registerFactory(() => AuthenticationBloc(
      signupUsingEmailPassword: sl(),
      sendPasswordResetEmail: sl(),
      sendVerificationEmail: sl(),
      signout: sl(),
      signinUsingEmailPassword: sl(),
      signinUsingGoogle: sl()));

  //*use_cases

  sl.registerLazySingleton(() => ChangeUserDataUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => FetchOfflineUserUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => FetchOnlineUserUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => StoreOfflineUserUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => StoreOnlineUserUseCase(userRepository: sl()));
  sl.registerLazySingleton(
      () => StoreProfilePhotoUseCase(userRepository: sl()));
  sl.registerLazySingleton(
      () => CheckUserAccountNameUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => GetSearchedUsersUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => GetUsersByIdsUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => FollowUserUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => UnFollowUserUseCase(userRepository: sl()));

  sl.registerLazySingleton(
      () => SignupUsingEmailPasswordUseCase(authRepository: sl()));
  sl.registerLazySingleton(
      () => SendPasswordResetUseCase(authRepository: sl()));
  sl.registerLazySingleton(
      () => SendVerificationEmailUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => SignoutUseCase(authRepository: sl()));
  sl.registerLazySingleton(
      () => SigninUsingEmailPasswordUseCase(authRepository: sl()));
  sl.registerLazySingleton(
      () => SigninUsingGoogleUseCase(authRepository: sl()));

  //*repository

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
      localDataSource: sl(), remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImp(networkInfo: sl(), remoteDataSource: sl()));

  //*data_sources
  Hive.registerAdapter(TimestampAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Box userBox = await Hive.openBox('USER');
  sl.registerLazySingleton<UserLocalDataSource>(
      () => UserLocalDataSourceImpl(userBox: userBox));
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl());

  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl());

  //! features - chat

  //* bloc

  sl.registerFactory(() => ChatBoxBloc(
        addMessage: sl(),
        deleteMessage: sl(),
        modifyMessage: sl(),
      ));
  sl.registerFactory(() => ChatBoxesListBloc(
      createChatBox: sl(),
      fetchUser: sl(),
      getChatBoxes: sl(),
      listenToChatBox: sl(),
      listenToUser: sl()));
  sl.registerFactory(
      () => ChatPageListenerBloc(listenToChatBox: sl(), listenToUser: sl()));

  //*use_cases

  sl.registerLazySingleton(() => AddMessageUseCase(chatBoxRepository: sl()));
  sl.registerLazySingleton(() => DeleteMessageUseCase(chatBoxRepository: sl()));
  sl.registerLazySingleton(() => ModifyMessageUseCase(chatBoxRepository: sl()));
  sl.registerLazySingleton(() => CreateChatBoxUseCase(chatBoxRepository: sl()));
  // sl.registerLazySingleton(() => FetchOnlineUserUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => GetChatBoxesUseCase(chatBoxRepository: sl()));
  sl.registerLazySingleton(() => ListenToUserUseCase(chatBoxRepository: sl()));
  sl.registerLazySingleton(
      () => ListenToChatBoxUseCase(chatBoxRepository: sl()));

  //*repository

  sl.registerLazySingleton<ChatBoxRepository>(
      () => ChatBoxRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));

  //*data_sources
  sl.registerLazySingleton<ChatBoxRemoteDataSource>(
      () => ChatBoxRemoteDataSourceImpl());

  //! core
  sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(connectionChecker: sl()));

  //!extra
  final InternetConnectionChecker connectionChecker =
      InternetConnectionChecker();
  sl.registerLazySingleton(() => connectionChecker);
}

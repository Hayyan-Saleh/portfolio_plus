import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:portfolio_plus/core/network_info/network_info.dart';
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
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/store_offline_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/store_online_user_use_case.dart';
import 'package:portfolio_plus/features/authentication/domain/use_cases/user_use_cases/store_profile_photo_use_case.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_account_name_bloc/user_account_name_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:portfolio_plus/features/authentication/presentation/bloc/user_profile_picture_bloc/user_profile_picture_bloc.dart';

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
      ));
  sl.registerFactory(() => UserProfilePictureBloc(storeProfilePhoto: sl()));
  sl.registerFactory(() => UserAccountNameBloc(checkUserAccountName: sl()));
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
  Box userBox = await Hive.openBox('USER');
  Hive.registerAdapter(UserModelAdapter());
  sl.registerLazySingleton<UserLocalDataSource>(
      () => UserLocalDataSourceImpl(userBox: userBox));
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl());

  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl());

  //! core
  sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(connectionChecker: sl()));

  //!extra
  final InternetConnectionChecker connectionChecker =
      InternetConnectionChecker();
  sl.registerLazySingleton(() => connectionChecker);
}

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:portfolio_plus/core/errors/errors.dart';
import 'package:portfolio_plus/core/util/auth_enum.dart';

import '../../../../core/constants/strings.dart';

abstract class AuthRemoteDataSource extends Equatable {
  Future<void> signinUsingGoogle();
  Future<void> singinUsingEmailPassword(String emailAddress, String password);
  Future<void> singupUsingEmailPassword(String emailAddress, String password);
  Future<void> sendVerificationEmail();
  Future<void> sendPasswordReset(String email);
  Future<void> signout(AuthenticationType authenticationType);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> singupUsingEmailPassword(
      String emailAddress, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthExceptiuon(message: 'The password provided is too weak!');
      } else if (e.code == 'email-already-in-use') {
        throw AuthExceptiuon(
            message: 'The account already exists for that email.');
      } else {
        if (e.message != null) {
          if (e.message!.contains('An internal error has occurred.')) {
            throw AuthExceptiuon(message: REGION_ERROR_MESSAGE);
          }
        }
        throw AuthExceptiuon(message: e.message ?? "AUTH ERROR OCCURED !");
      }
    } catch (e) {
      throw AuthExceptiuon(
          message: 'Unkown Error Occured .... Please Try Again Later');
    }
  }

  @override
  Future<void> singinUsingEmailPassword(
      String emailAddress, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthExceptiuon(message: 'The password provided is too weak!');
      } else if (e.code == 'email-already-in-use') {
        throw AuthExceptiuon(
            message: 'The account already exists for that email.');
      } else {
        if (e.message != null) {
          if (e.message!.contains('An internal error has occurred.')) {
            throw AuthExceptiuon(message: REGION_ERROR_MESSAGE);
          }
        }
        throw AuthExceptiuon(message: e.message ?? "AUTH ERROR OCCURED !");
      }
    } catch (e) {
      throw AuthExceptiuon(
          message: 'Unkown Error Occured .... Please Try Again Later');
    }
  }

  @override
  Future<void> signinUsingGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      if (e.toString().contains('An internal error has occurred.')) {
        throw AuthExceptiuon(message: REGION_ERROR_MESSAGE);
      }
      throw AuthExceptiuon(message: e.toString());
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw AuthExceptiuon(message: e.toString());
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (!currentUser!.emailVerified) {
      await currentUser.sendEmailVerification();
    } else {
      throw AuthExceptiuon(message: EMAIL_ALREADY_VERIFIED_MESSAGE);
    }
  }

  @override
  Future<void> signout(AuthenticationType authenticationType) async {
    switch (authenticationType) {
      case AuthenticationType.googleAuth:
        GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.disconnect();
        break;
      case AuthenticationType.emailPasswordAuth:
        await FirebaseAuth.instance.signOut();
        break;
      default:
        throw AuthExceptiuon(
            message: "Couldn't Signout ... please try again later");
    }
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => false;
}

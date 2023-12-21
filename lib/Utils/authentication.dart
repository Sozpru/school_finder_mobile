import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../Constants/sharedpref.dart';

class Authentication with ChangeNotifier {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static UserInfo? user;
  static UserCredential? userFB;

  static Future forgotPass(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  static String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<User> signInWithApple() async {
    // 1. perform the sign-in request
    final result = await TheAppleSignIn.performRequests(
        [const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
          String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final userCredential =
        await auth.signInWithCredential(credential);
        final firebaseUser = userCredential.user!;
          final fullName = appleIdCredential.fullName;

          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {
            final displayName = '${fullName.givenName} ${fullName.familyName}';
            await firebaseUser.updateDisplayName(displayName);
          }
        return firebaseUser;
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  static Future<UserInfo?> signInWithGoogle({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user?.providerData[0];
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {

           Fluttertoast.showToast(msg: e.message ?? e.toString());
        } else if (e.code == 'invalid-credential') {
          // handle the error here

          Fluttertoast.showToast(msg: e.message ?? e.toString());
        }
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
        // handle the error here
      }
    }
    return user;
  }


  // EMAIL LOGIN
  static Future loginWithEmail(String email, String password) async  {
    try{
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: email, password: password);
      if(FirebaseAuth.instance.currentUser!.emailVerified){
        return null;
      }else {
        return "First Verify Your Email then Login";
      }
    }on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return e.message!;
      } else if (e.code == 'wrong-password') {
        return e.message!;
      }
    }
  }

  Future signUp(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //SIGN IN METHOD
  Future signIn({required String email, required String password}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //SIGN OUT METHOD
  static Future signOut() async {
    await auth.signOut();
  }

  // EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      auth.currentUser!.sendEmailVerification();
      // showSnackBar(context, 'Email verification sent!');
    } on FirebaseAuthException {
      // showSnackBar(context, e.message!); // Display error message
    }
  }

  static Future signInWithFacebook() async {
    try {
      final LoginResult loginResult =
          await FacebookAuth.instance.login(permissions: ['email']);

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      await auth.signInWithCredential(facebookAuthCredential);

      var userdata = await FacebookAuth.instance.getUserData();
      var email = userdata['email'];
      SharedPred.setEmail(email);
      SharedPred.setFBSUCESS(true);
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.toString());// Displaying the error message
      SharedPred.setFBSUCESS(false);
      return e.message;
    }
  }
}

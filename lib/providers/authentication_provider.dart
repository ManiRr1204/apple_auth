import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apple_signin/html_shim.dart';
import 'package:flutter_apple_signin/loginCredentials.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// class AuthenticationProvider with ChangeNotifier {
//   final FirebaseAuth _firebaseAuth;

//   AuthenticationProvider(this._firebaseAuth);

//   Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

//   Future<void> signOut() async {
//     await _firebaseAuth.signOut();
//   }

//   /// Generates a cryptographically secure random nonce, to be included in a
//   /// credential request.
//   String generateNonce([int length = 32]) {
//     final charset =
//         '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
//     final random = Random.secure();
//     return List.generate(length, (_) => charset[random.nextInt(charset.length)])
//         .join();
//   }

//   /// Returns the sha256 hash of [input] in hex notation.
//   String sha256ofString(String input) {
//     final bytes = utf8.encode(input);
//     final digest = sha256.convert(bytes);
//     return digest.toString();
//   }

//   Future<User?> signInWithApple() async {
//     // To prevent replay attacks with the credential returned from Apple, we
//     // include a nonce in the credential request. When signing in in with
//     // Firebase, the nonce in the id token returned by Apple, is expected to
//     // match the sha256 hash of `rawNonce`.
//     final rawNonce = generateNonce();
//     final nonce = sha256ofString(rawNonce);

//     try {
//       // Request credential for the currently signed in Apple account.
//       final appleCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//         nonce: nonce,
//       );

//       print(appleCredential.authorizationCode);

//       // Create an `OAuthCredential` from the credential returned by Apple.
//       final oauthCredential = OAuthProvider("apple.com").credential(
//         idToken: appleCredential.identityToken,
//         rawNonce: rawNonce,
//       );

//       // Sign in the user with Firebase. If the nonce we generated earlier does
//       // not match the nonce in `appleCredential.identityToken`, sign in will fail.
//       final authResult =
//           await _firebaseAuth.signInWithCredential(oauthCredential);

//       final displayName =
//           '${appleCredential.givenName} ${appleCredential.familyName}';
//       final userEmail = '${appleCredential.email}';

//       final firebaseUser = authResult.user;
//       print(displayName);
//       // ignore: deprecated_member_use
//       await firebaseUser!.updateProfile(displayName: displayName);
//       await firebaseUser.updateEmail(userEmail);

//       return firebaseUser;
//     } catch (exception) {
//       print(exception);
//     }
//   }
// }

class AuthenticationProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;

  AuthenticationProvider(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      print("before logging");
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
                    // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
                    clientId:
                        'de.lunaone.flutter.signinwithappleexample.service',

                    redirectUri:
                        // For web your redirect URI needs to be the host of the "current page",
                        // while for Android you will be using the API server that redirects back into your app via a deep link
                        kIsWeb
                            ? Uri.parse('https://${window.location.host}/')
                            : Uri.parse(
                                'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
                              ),
                  ),nonce: nonce,
      );
      print("getting apple credentials");
      print('Apple Authorization Code: ${appleCredential.authorizationCode}');

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final authResult =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      final firebaseUser = authResult.user;

      if (firebaseUser != null) {
        final displayName =
            '${appleCredential.givenName} ${appleCredential.familyName}';
        final userEmail =
            appleCredential.email ?? ''; // Apple may not provide an email
        userEmailAddress = userEmail;
        userName = displayName;
        print('User Display Name: $displayName');
        print('User Email: $userEmail');
        print("appleCredential : $appleCredential");
        print("Image Url : ${appleCredential.userIdentifier}");

        // Update user profile
        await firebaseUser.updateProfile(displayName: displayName);
        if (userEmail.isNotEmpty) {
          await firebaseUser.updateEmail(userEmail);
        }

        return firebaseUser;
      } else {
        print('Firebase user is null after sign-in.');
      }
    } catch (e) {
      print('Sign in with Apple failed: $e');
    }

    return null;
  }
}

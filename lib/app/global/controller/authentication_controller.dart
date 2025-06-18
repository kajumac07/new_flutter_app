import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/services/db_service.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/presentation/auth/login/login_screen.dart';
import 'package:new_flutter_app/app/presentation/auth/register/register_screen.dart';
import 'package:new_flutter_app/app/presentation/entry/entry_screen.dart';

class AuthenticationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final bool _obscurePassword = true;

  var isUserSign = false;
  var isUserAcCreated = false;
  var forgotPass = false;

  FirebaseAuth get auth => _auth;
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get nameController => _nameController;
  TextEditingController get usernameController => _usernameController;
  TextEditingController get bioController => _bioController;
  TextEditingController get addressController => _addressController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;

  bool get obscurePassword => _obscurePassword;
  set obscurePassword(bool value) {
    obscurePassword = value;
    update();
  }

  //========================== Create account with email and password =================

  Future<void> createUserWithEmailAndPassword() async {
    isUserAcCreated = true;
    update();
    try {
      var user = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await DatabaseServices(uid: user.user!.uid).savingUserData(
        _usernameController.text,
        _nameController.text,
        _bioController.text,
        _addressController.text,
        _emailController.text,
      );

      // Send email verification
      await user.user!.sendEmailVerification();

      isUserAcCreated = false;
      update();

      // Inform the user to verify their email before logging in
      showToastMessage(
        "Verification Required",
        "A verification email has been sent to your email address. Please verify it before logging in.",
        Colors.orange,
      );

      // Sign out the user immediately after account creation, to prevent unverified access
      await _auth.signOut();

      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "The email is already in use by another account.";
          showToastMessage("Error", errorMessage, Colors.red);
          break;
        case 'invalid-email':
          errorMessage = "The email address is invalid.";
          showToastMessage("Error", errorMessage, Colors.red);
          break;
        case 'weak-password':
          errorMessage = "The password is too weak.";
          showToastMessage("Error", errorMessage, Colors.red);
          break;
        default:
          errorMessage = e.message ?? "An unknown error occurred.";
          showToastMessage("Error", errorMessage, Colors.red);
      }
    } finally {
      isUserAcCreated = false;
      update();
    }
  }

  //========================== SignIn with email and Password ===============================

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    isUserSign = true;
    update();

    try {
      final signInUser = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = signInUser.user;
      if (user == null) return;

      // Check if email is verified
      if (!user.emailVerified) {
        showToastMessage(
          "Email Not Verified",
          "Please verify your email before logging in.",
          Colors.orange,
        );
        await user.sendEmailVerification();
        await _auth.signOut();
        return;
      }

      // Check user in 'Persons' collection
      final userDoc = await FirebaseFirestore.instance
          .collection("Persons")
          .doc(user.uid)
          .get();

      isUserSign = false;
      update();

      if (userDoc.exists && userDoc['uid'] == user.uid) {
        final isActive = userDoc['isActive'] ?? false;

        if (isActive) {
          Get.offAll(() => const EntryScreen());
          showToastMessage("Success", "Login Successful", Colors.green);
        } else {
          showToastMessage(
            "Account Deactivated",
            "Your account is deactivated. Please contact your office.",
            Colors.red,
          );
          // Optionally navigate to AdminContactScreen
        }
      } else {
        // User document doesn't exist, go to register screen
        Get.to(() => const RegisterScreen());
      }
    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
    } finally {
      isUserSign = false;
      update();
    }
  }

  //========================== Handle FirebaseAuthException ==========================
  void handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        showToastMessage(
          "Error",
          "The email address is not valid.",
          Colors.red,
        );
        break;
      case 'user-not-found':
        showToastMessage("Error", "No user found for that email.", Colors.red);
        break;
      case 'wrong-password':
        showToastMessage("Error", "Wrong password provided.", Colors.red);
        break;
      default:
        showToastMessage(
          "Error",
          "Invalid email or password , create new account",
          Colors.red,
        );
    }
  }
}

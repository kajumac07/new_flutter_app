import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/presentation/onBoarding/on_boarding_screen.dart';

class UserService extends GetxService with WidgetsBindingObserver {
  static UserService get to => Get.find();

  final _auth = FirebaseAuth.instance;
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen(_handleAuthChange);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _handleAuthChange(User? user) async {
    currentUser.value = user;

    if (user == null) {
      return;
    }

    log("User signed in: ${user.email}");

    // Mark user online immediately
    await _setOnline(user.uid);
  }

  Future<void> _setOnline(String uid) async {
    await FirebaseFirestore.instance.collection("Persons").doc(uid).update({
      "isOnline": true,
      "lastSeen": FieldValue.serverTimestamp(),
    });
  }

  Future<void> _setOffline(String uid) async {
    await FirebaseFirestore.instance.collection("Persons").doc(uid).update({
      "isOnline": false,
      "lastSeen": FieldValue.serverTimestamp(),
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final uid = currentUser.value?.uid;
    if (uid == null) return;

    if (state == AppLifecycleState.resumed) {
      // App came to foreground → set online
      await _setOnline(uid);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App minimized / closed → set offline
      await _setOffline(uid);
    }
  }

  Future<void> signOut() async {
    try {
      final uid = currentUser.value?.uid;
      if (uid != null) {
        await _setOffline(uid);
      }
      await _auth.signOut();
      Get.offAll(() => const OnboardingScreen());
    } catch (e) {
      log("Sign out error: $e");
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}

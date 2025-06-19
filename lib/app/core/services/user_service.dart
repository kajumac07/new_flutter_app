import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/presentation/onBoarding/on_boarding_screen.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  final _auth = FirebaseAuth.instance;
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen(_handleAuthChange);
  }

  Future<void> _handleAuthChange(User? user) async {
    currentUser.value = user;
    if (user == null) {
      return;
    }
    log("User signed in: ${user.email}");
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAll(() => const OnboardingScreen());
    } catch (e) {
      log("Sign out error: $e");
    }
  }
}

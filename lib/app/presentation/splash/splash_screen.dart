import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/widgets/reusable_text.dart';
import 'package:new_flutter_app/app/presentation/auth/login/login_screen.dart';
import 'package:new_flutter_app/app/presentation/entry/entry_screen.dart';
import 'package:new_flutter_app/app/presentation/onBoarding/on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Timer(const Duration(seconds: 3), _navigate);
  }

  void _navigate() async {
    if (user == null) {
      Get.offAll(
        () => const OnboardingScreen(),
        transition: Transition.cupertino,
        duration: const Duration(milliseconds: 900),
      );
      return;
    }

    if (!user!.emailVerified) {
      await user!.sendEmailVerification();
      await FirebaseAuth.instance.signOut();
      showToastMessage("Verify Email", "Please verify your email", Colors.red);
      Get.offAll(
        () => const LoginScreen(),
        transition: Transition.cupertino,
        duration: const Duration(milliseconds: 900),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("Persons")
          .doc(user!.uid)
          .get();

      if (userDoc.exists && userDoc['uid'] == user!.uid) {
        if (userDoc['isActive'] == true) {
          Get.offAll(
            () => const EntryScreen(),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 900),
          );
        } else {
          showToastMessage(
            "Error",
            "Your account is deactivated. Please contact your office.",
            Colors.red,
          );
        }
      } else {
        // Document doesn't exist, redirect to onboarding
        await FirebaseAuth.instance.signOut();
        Get.offAll(
          () => const OnboardingScreen(),
          transition: Transition.cupertino,
          duration: const Duration(milliseconds: 900),
        );
      }
    } catch (e) {
      log("Error fetching user document: $e");
      showToastMessage("Error", "Something went wrong!", Colors.red);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kSecondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(Icons.apps, size: 60, color: kPrimary),
                ),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: ReusableText(
                      text: appName.toUpperCase(),
                      size: 28,
                      color: kSecondary,
                      fw: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: ReusableText(
                    text: appTagLine,
                    size: 16,
                    color: kSecondary.withOpacity(0.8),
                    fw: FontWeight.normal,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

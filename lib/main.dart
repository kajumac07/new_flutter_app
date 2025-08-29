import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/services/user_service.dart';
import 'package:new_flutter_app/app/presentation/onBoarding/on_boarding_screen.dart';
import 'package:new_flutter_app/app/presentation/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Register UserService BEFORE runApp
  await Get.putAsync(() async => UserService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Journey Junction',
          home: Obx(() {
            final userService = UserService.to;
            if (userService.currentUser.value == null) {
              return const OnboardingScreen();
            } else {
              return const SplashScreen();
            }
          }),
        );
      },
    );
  }
}

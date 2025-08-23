import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/user_service.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/controller/profile_controller.dart';
import 'package:new_flutter_app/app/presentation/home/home_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../../profile/profile_details_screen.dart';

class Builddrawer extends StatelessWidget {
  const Builddrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService.to;
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(30.r),
        bottomRight: Radius.circular(30.r),
      ),
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30.r),
            bottomRight: Radius.circular(30.r),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(3, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Custom Header with Curved Gradient
              GetBuilder<ProfileController>(
                init: ProfileController(),
                builder: (controller) {
                  if (controller.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final user = controller.currentUser;
                  return Container(
                    height: 200.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kSecondary, kSecondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      // borderRadius: BorderRadius.only(
                      //   topRight: Radius.circular(30.r),
                      //   bottomLeft: Radius.circular(50.r),
                      // ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -40.h,
                          right: -40.w,
                          child: Container(
                            width: 120.w,
                            height: 120.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kWhite.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20.w, top: 70.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 70.w,
                                height: 70.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: kSecondary,
                                    width: 2.w,
                                  ),
                                ),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: user!.profilePicture,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            width: 60.w,
                                            height: 60.h,
                                            color: Colors.white,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error, size: 30.w),
                                  ),
                                ),
                              ),

                              SizedBox(width: 15.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: appStyle(
                                      16,
                                      kWhite,
                                      FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    user.emailAddress,
                                    style: appStyle(
                                      12,
                                      Colors.white70,
                                      FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Drawer Items with Hover Effects
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0F2027),
                        Color(0xFF203A43),
                        Color(0xFF2C5364),
                      ],
                    ),
                  ),
                  child: ListView(
                    padding: EdgeInsets.only(top: 10.h),
                    children: [
                      buildListTile("assets/bookings_bw.png", "Blogs", () {}),
                      buildListTile(
                        "assets/profile_bw.png",
                        "My Profile",
                        () => Get.to(() => const UserProfileScreen()),
                      ),
                      buildListTile("assets/rating_bw.png", "Ratings", () {}),
                      buildListTile(
                        "assets/notification_setting.png",
                        "Notification ON/OFF",
                        () {
                          // Get.to(() => NotificationScreenSetting());
                        },
                      ),
                      buildListTile(
                        "assets/about_us_bw.png",
                        "About us",
                        // () => Get.to(() => AboutUsScreen()),
                        () => showToastMessage(
                          "Coming Soon",
                          "This feature is not available yet",
                          kPrimary,
                        ),
                      ),
                      buildListTile(
                        "assets/help_bw.png",
                        "Help",
                        () => showToastMessage(
                          "Coming Soon",
                          "This feature is not available yet",
                          kPrimary,
                        ),
                      ),
                      buildListTile(
                        "assets/t_c_bw.png",
                        "Terms & Conditions",
                        () => showToastMessage(
                          "Coming Soon",
                          "This feature is not available yet",
                          kPrimary,
                        ),
                      ),
                      buildListTile(
                        "assets/privacy_bw.png",
                        "Privacy Policy",
                        () => showToastMessage(
                          "Coming Soon",
                          "This feature is not available yet",
                          kPrimary,
                        ),
                      ),
                      buildListTile("assets/out_bw.png", "Logout", () {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to log out from this account',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    'Yes',
                                    style: appStyle(
                                      15,
                                      kSecondary,
                                      FontWeight.normal,
                                    ),
                                  ),
                                  onPressed: () async {
                                    await userService.signOut();
                                  },
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: Text(
                                    "No",
                                    style: appStyle(
                                      15,
                                      kPrimary,
                                      FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Footer
              // Container(
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //       colors: [
              //         Color(0xFF0F2027),
              //         Color(0xFF203A43),
              //         Color(0xFF2C5364),
              //       ],
              //     ),
              //   ),
              //   child: Column(
              //     children: [
              //       Divider(color: kGrayLight),
              //       SizedBox(height: 10.h),
              //       Text(
              //         'Journey Junction v$appVersion',
              //         style: appStyle(12, kGray, FontWeight.w400),
              //       ),
              //       SizedBox(height: 5.h),
              //       Text(
              //         '© 2025 All Rights Reserved',
              //         style: appStyle(12, kGray, FontWeight.w400),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

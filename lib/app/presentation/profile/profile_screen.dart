import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/widgets/dashed_driver.dart';
import 'package:new_flutter_app/app/global/widgets/reusable_text.dart';
import 'package:new_flutter_app/app/presentation/profile/profile_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Profile", style: appStyle(24, kDark, FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 0.h),
              GestureDetector(child: buildTopProfileSection()),
              SizedBox(height: 10.h),
              Container(
                width: double.maxFinite,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: kLightWhite,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Manage Profile",
                          style: kIsWeb
                              ? TextStyle(color: kPrimary)
                              : appStyle(18, kPrimary, FontWeight.normal),
                        ),
                        SizedBox(width: 5.w),
                        Container(width: 30.w, height: 3.h, color: kSecondary),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    const DashedDivider(color: kGrayLight),
                    SizedBox(height: 10.h),
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
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              Container(
                width: double.maxFinite,
                // margin: EdgeInsets.symmetric(horizontal: 12.w),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: kLightWhite,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "More",
                          style: kIsWeb
                              ? TextStyle(color: kPrimary)
                              : appStyle(18, kPrimary, FontWeight.normal),
                        ),
                        SizedBox(width: 5.w),
                        Container(width: 30.w, height: 3.h, color: kSecondary),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    const DashedDivider(color: kGrayLight),
                    SizedBox(height: 10.h),
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
                                onPressed: () {},
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListTile(String iconName, String title, void Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: Image.asset(
          iconName,
          height: 20.h,
          width: 20.w,
          color: kPrimary,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: kGray),
        title: Text(
          title,
          style: kIsWeb
              ? TextStyle(color: kDark)
              : appStyle(13, kDark, FontWeight.normal),
        ),
        // onTap: onTap,
      ),
    );
  }

  //================================ top Profile section =============================
  Container buildTopProfileSection() {
    return Container(
      height: kIsWeb ? 180.h : 120.h,
      width: double.maxFinite,
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.w),
      decoration: BoxDecoration(
        color: kLightWhite,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 33.r,
            backgroundColor: kSecondary,
            child: CircleAvatar(
              radius: 33.r,
              backgroundImage: NetworkImage(
                "https://imgs.search.brave.com/QBQ-rwnFl28lcob8mN6I7Hfvic_3xW3ASWL9Wt9Wzb8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvMTEz/MDg4NDYyNS92ZWN0/b3IvdXNlci1tZW1i/ZXItdmVjdG9yLWlj/b24tZm9yLXVpLXVz/ZXItaW50ZXJmYWNl/LW9yLXByb2ZpbGUt/ZmFjZS1hdmF0YXIt/YXBwLWluLWNpcmNs/ZS1kZXNpZ24uanBn/P3M9NjEyeDYxMiZ3/PTAmaz0yMCZjPTFr/eS1nTkhpUzJpeUxz/VVBRa3hBdFBCV0gx/Qlp0MFBLQkIxV0J0/eFFKUkU9",
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Padding(
            padding: EdgeInsets.only(top: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText(
                  text: "Testing User",
                  size: 16,
                  color: kDark,
                  fw: FontWeight.normal,
                ),
                ReusableText(
                  text: "testing@gmail.com",
                  size: 16,
                  color: kDark,
                  fw: FontWeight.normal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> signOut() async {
    try {
      // await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e);
    }
  }
}

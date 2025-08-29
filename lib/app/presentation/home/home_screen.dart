import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/controller/home_controller.dart';
import 'package:new_flutter_app/app/global/widgets/glowing_icon_button.dart';
import 'package:new_flutter_app/app/presentation/cloudNotificationScreen/cloud_notification_screen.dart';
import 'package:new_flutter_app/app/presentation/home/widgets/categories.dart';
import 'package:new_flutter_app/app/presentation/home/widgets/drawer.dart';
import 'package:new_flutter_app/app/presentation/home/widgets/trending_story_widget.dart';
import 'package:new_flutter_app/app/presentation/messenger/messenger_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onTap});
  final VoidCallback? onTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<QuerySnapshot> trendingStories = FirebaseFirestore.instance
      .collection('Stories')
      .get();
  bool isLoading = false;
  // bool _hasUnreadMessages = false;
  int unreadMsgCount = 0;

  @override
  void initState() {
    fetchTrendingStories();
    _setupUnreadMessagesListener();
    super.initState();
  }

  void _setupUnreadMessagesListener() {
    FirebaseFirestore.instance
        .collection("Chats")
        .where("members", arrayContains: currentUId)
        .snapshots()
        .listen(
          (querySnapshot) {
            if (mounted) {
              int totalUnread = 0;

              for (final doc in querySnapshot.docs) {
                final data = doc.data();
                final lastMessageSender = data["lastMessageSender"] ?? "";
                final unreadCount = data["unreadCount"] ?? 0;

                // Only count if the last message wasn't sent by current user
                if (lastMessageSender != currentUId && unreadCount > 0) {
                  totalUnread += unreadCount as int;
                }
              }

              setState(() {
                unreadMsgCount = totalUnread;
              });
            }
          },
          onError: (error) {
            print("Error listening for unread messages: $error");
          },
        );
  }

  void fetchTrendingStories() async {
    setState(() {
      isLoading = true;
    });
    try {
      final QuerySnapshot snapshot = await trendingStories;
      log('Fetched ${snapshot.docs.length} trending stories.');
    } catch (e) {
      log('Error fetching trending stories: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFF141E30),
      drawer: Builddrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: kSecondary))
          : GetBuilder<HomeScreenController>(
              init: HomeScreenController(),
              builder: (controller) {
                return Container(
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
                  child: CustomScrollView(
                    physics: BouncingScrollPhysics(),
                    slivers: [
                      // 1. Cosmic App Bar
                      SliverAppBar(
                        expandedHeight: 130.h,
                        floating: true,
                        pinned: true,
                        snap: true,
                        stretch: true,
                        backgroundColor: Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          title: Text(
                            'J-Junction',
                            style: appStyle(
                              25,
                              kWhite,
                              FontWeight.w900,
                            ).copyWith(letterSpacing: 1.5),
                          ),
                          centerTitle: true,
                        ),
                        leading: IconButton(
                          icon: Icon(
                            Icons.menu_rounded,
                            color: kSecondary,
                            size: 28.sp,
                          ),
                          onPressed: () =>
                              _scaffoldKey.currentState!.openDrawer(),
                        ),
                        actions: [
                          GlowingIconButton(
                            icon: Icons.notifications,
                            badgeCount: 0,
                            onTap: () =>
                                Get.to(() => CloudNotificationScreen()),
                          ),

                          SizedBox(width: 5.w),
                          GlowingIconButton(
                            icon: Iconsax.message,
                            badgeCount: unreadMsgCount,
                            onTap: () => Get.to(
                              () => MessengerScreen(),
                              transition: Transition.rightToLeftWithFade,
                              duration: Duration(milliseconds: 500),
                            ),
                          ),
                          SizedBox(width: 5.w),
                        ],
                      ),

                      // 2. Interstellar Hero Carousel
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 320.h,
                          child: PageView.builder(
                            itemCount: 3,
                            controller: PageController(viewportFraction: 0.85),
                            padEnds: false,
                            itemBuilder: (_, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 20.h,
                                ),
                                child: _GalacticDestinationCard(
                                  imageUrl: [
                                    'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
                                    'https://images.unsplash.com/photo-1506929562872-bb421503ef21',
                                    'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e',
                                  ][index],
                                  title: [
                                    'Cosmic Himalayas',
                                    'Nebula Beaches',
                                    'Stellar Deserts',
                                  ][index],
                                  subtitle: [
                                    '5D Experience',
                                    'Infinite Relaxation',
                                    'Martian Vibes',
                                  ][index],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // 3. Warp-Speed Categories
                      CategoriesSection(controller: controller),
                      // 4. Stories
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 20.w,
                            top: 20.h,
                            bottom: 10.h,
                          ),
                          child: Text(
                            'TRENDING STORIES',
                            style: appStyle(
                              20,
                              kDark,
                              FontWeight.w800,
                            ).copyWith(letterSpacing: 1.5),
                          ),
                        ),
                      ),

                      //trending stories list
                      TrendingStoryWidget(trendingStories: trendingStories),
                      // 5. Celestial Destinations
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 20.w,
                            top: 30.h,
                            bottom: 10.h,
                          ),
                          child: Text(
                            'CELESTIAL DESTINATIONS',
                            style: appStyle(
                              20,
                              kDark,
                              FontWeight.w800,
                            ).copyWith(letterSpacing: 1.5),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.3,
                                mainAxisSpacing: 16.h,
                                crossAxisSpacing: 16.w,
                              ),
                          delegate: SliverChildBuilderDelegate((_, index) {
                            return _StellarDestination(
                              imageUrl: [
                                'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
                                'https://images.unsplash.com/photo-1506929562872-bb421503ef21',
                                'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e',
                                'https://images.unsplash.com/photo-1665481512574-44b527856b71?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                              ][index],
                              title: [
                                'Moon Resort',
                                'Mars Colony',
                                'Jupiter Spa',
                                'Venus Retreat',
                              ][index],
                            );
                          }, childCount: 4),
                        ),
                      ),

                      // 6. Astral Testimonials
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 20.w,
                            top: 40.h,
                            bottom: 10.h,
                          ),
                          child: Text(
                            'TESTIMONIALS',
                            style: appStyle(
                              20,
                              kDark,
                              FontWeight.w800,
                            ).copyWith(letterSpacing: 1.5),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 220.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.only(left: 20.w, right: 20.w),
                            itemCount: 3,
                            itemBuilder: (_, index) {
                              return _CosmicTestimonial(
                                avatarUrl:
                                    'https://randomuser.me/api/portraits/women/${index + 30}.jpg',
                                name: ['Dimple', 'Kaju', 'Darling'][index],
                                quote: [
                                  'This app teleported me to another dimension of travel!',
                                  'Never imagined experiencing zero-gravity tourism so easily!',
                                  'Worth every light-year traveled for these experiences!',
                                ][index],
                              );
                            },
                          ),
                        ),
                      ),

                      // 7. Modern Footer
                      SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.only(top: 40.h),
                          padding: EdgeInsets.symmetric(
                            vertical: 40.h,
                            horizontal: 20.w,
                          ),
                          decoration: BoxDecoration(
                            color: kCardColor,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(40.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: Offset(0, -10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Decorative Top Border
                              Container(
                                width: 60.w,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: kSecondary,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                              SizedBox(height: 30.h),

                              // App Logo
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.airplanemode_active,
                                    size: 28.sp,
                                    color: kDark,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    appName,
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w900,
                                      color: kDark,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                appTagLine,
                                style: TextStyle(fontSize: 14.sp, color: kDark),
                              ),
                              SizedBox(height: 30.h),

                              // Main CTA
                              Container(
                                width: double.infinity,
                                height: 56.h,
                                margin: EdgeInsets.symmetric(horizontal: 40.w),
                                decoration: BoxDecoration(
                                  color: kSecondary,
                                  borderRadius: BorderRadius.circular(28.r),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(28.r),
                                    onTap: () {
                                      widget.onTap!();
                                    },
                                    splashColor: Colors.white.withOpacity(0.1),
                                    highlightColor: Colors.transparent,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.rocket_launch,
                                            size: 20.sp,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10.w),
                                          Text(
                                            'EXPLORE NOW',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 30.h),

                              // Social Links
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _SocialCircle(
                                    icon: Icons.install_desktop,
                                    color: kSecondary,
                                  ),
                                  SizedBox(width: 20.w),
                                  _SocialCircle(
                                    icon: Icons.facebook,
                                    color: kSecondary,
                                  ),
                                  SizedBox(width: 20.w),
                                  _SocialCircle(
                                    icon: Icons.travel_explore,
                                    color: kSecondary,
                                  ),
                                ],
                              ),
                              SizedBox(height: 30.h),

                              // Legal Text
                              Column(
                                children: [
                                  Text(
                                    '© 2025 journey junction App',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: kDark,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Made with ❤️ for travelers.',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: kDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

Widget buildListTile(String iconName, String title, void Function() onTap) {
  return GestureDetector(
    onTap: onTap,
    child: ListTile(
      // leading: Image.asset(
      //   iconName,
      //   height: 20.h,
      //   width: 20.w,
      //   color: kPrimary,
      // ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: kGray),
      title: Text(title, style: appStyle(13, kDark, FontWeight.normal)),
      // onTap: onTap,
    ),
  );
}

class _SocialCircle extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SocialCircle({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Icon(icon, size: 20.w, color: color),
    );
  }
}

// Custom Widgets with Shimmer Effects
class _GalacticDestinationCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  const _GalacticDestinationCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.r),
      child: Stack(
        children: [
          // Cached Image with Shimmer
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor: Colors.grey.shade700,
              child: Container(
                color: Colors.grey.shade900,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),

          // Pulsing Glow Effect
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: Duration(seconds: 3),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28.r),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: kWhite.withOpacity(0.2),
                  //     blurRadius: 30,
                  //     spreadRadius: 5,
                  //   ),
                  // ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: appStyle(
                    24,
                    kWhite,
                    FontWeight.w900,
                  ).copyWith(letterSpacing: 1.5),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellowAccent, size: 18.w),
                    SizedBox(width: 8.w),
                    Text(
                      subtitle,
                      style: appStyleRaleway(
                        16,
                        kWhite,
                        FontWeight.w600,
                      ).copyWith(letterSpacing: 1.2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StellarDestination extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _StellarDestination({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: Stack(
        children: [
          // Cached Image with Shimmer
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor: Colors.grey.shade700,
              child: Container(
                color: Colors.grey.shade900,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Floating Rating
          Positioned(
            top: 12.w,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 14.w),
                  SizedBox(width: 4.w),
                  Text(
                    '4.9',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CosmicTestimonial extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String quote;

  const _CosmicTestimonial({
    required this.avatarUrl,
    required this.name,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Cached Avatar with Shimmer
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: avatarUrl,
                    width: 50.w,
                    height: 50.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade800,
                      highlightColor: Colors.grey.shade700,
                      child: Container(
                        color: Colors.grey.shade900,
                        width: 50.w,
                        height: 50.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: appStyleRaleway(16, kDark, FontWeight.w800),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Nature Explorer',
                      style: appStyleRoboto(12, kGray, FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Text(
                '"$quote"',
                style: appStylePoppins(
                  15,
                  kWhite,
                  FontWeight.w600,
                ).copyWith(letterSpacing: 1.2, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SocialIcon({required this.icon, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Icon(icon, color: color, size: 20.w),
    );
  }
}

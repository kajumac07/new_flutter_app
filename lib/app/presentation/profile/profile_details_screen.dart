import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/global/controller/profile_controller.dart';
import 'package:new_flutter_app/app/global/widgets/custom_container.dart';
import 'package:new_flutter_app/app/presentation/profile/widgets/story_lists.dart';
import 'package:new_flutter_app/app/presentation/profile/widgets/user_lists_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final Future<QuerySnapshot> storiesLists = FirebaseFirestore.instance
      .collection('Stories')
      .where("uid", isEqualTo: currentUId)
      .get();
  bool isLoading = false;

  @override
  void initState() {
    fetchCurrentUserStories();
    super.initState();
  }

  void fetchCurrentUserStories() async {
    setState(() {
      isLoading = true;
    });
    try {
      final QuerySnapshot snapshot = await storiesLists;
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
      backgroundColor: kCardColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kSecondary))
          : GetBuilder<ProfileController>(
              init: ProfileController(),
              global: false,
              builder: (controller) {
                if (controller.isLoading || controller.currentUser == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: kSecondary),
                  );
                }

                final user = controller.currentUser!;
                return CustomGradientContainer(
                  child: CustomScrollView(
                    slivers: [
                      // Profile Header with proper app bar spacing
                      SliverAppBar(
                        expandedHeight: 295.h,
                        floating: false,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        iconTheme: IconThemeData(color: kDark),

                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final expanded =
                                constraints.maxHeight > kToolbarHeight * 1.5;
                            return FlexibleSpaceBar(
                              collapseMode: CollapseMode.pin,
                              titlePadding: EdgeInsets.only(
                                left: expanded ? 60.w : 16.w,
                                bottom: 16.h,
                              ),
                              title: AnimatedOpacity(
                                opacity: expanded ? 0 : 1,
                                duration: Duration(milliseconds: 200),
                                child: Text(
                                  user.fullName ?? 'User Name',
                                  style: TextStyle(color: kDark),
                                ),
                              ),
                              background: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.only(
                                  top: kToolbarHeight * 2.2,
                                ),
                                child: Column(
                                  children: [
                                    // Profile Picture and Basic Info
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                      ),
                                      child: Row(
                                        children: [
                                          // Profile Picture with shimmer and cache
                                          Container(
                                            width: 90.w,
                                            height: 90.h,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: kSecondary,
                                                width: 2.w,
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: user.profilePicture,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300]!,
                                                      highlightColor:
                                                          Colors.grey[100]!,
                                                      child: Container(
                                                        width: 90.w,
                                                        height: 90.h,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                          Icons.error,
                                                          size: 30.w,
                                                        ),
                                              ),
                                            ),
                                          ),

                                          SizedBox(width: 20.w),

                                          // User Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user.fullName,
                                                  style: TextStyle(
                                                    fontSize: 22.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: kDark,
                                                  ),
                                                ),
                                                SizedBox(height: 5.h),
                                                Text(
                                                  user.bio,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: kGray,
                                                  ),
                                                ),
                                                SizedBox(height: 10.h),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 16.w,
                                                      color: kSecondary,
                                                    ),
                                                    SizedBox(width: 5.w),
                                                    Text(
                                                      user.currentAddress,
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: kGray,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    // Stats Row
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildStatItem(
                                            onTap: () {},
                                            user.posts.length.toString(),
                                            'Posts',
                                          ),

                                          _buildStatItem(
                                            user.followers.length.toString(),
                                            'Followers',
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: kCardColor,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                    ),
                                                builder: (context) =>
                                                    UsersListBottomSheet(
                                                      userIds: user.followers,
                                                      title: "Followers",
                                                    ),
                                              );
                                            },
                                          ),
                                          _buildStatItem(
                                            user.following.length.toString(),
                                            'Following',
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: kCardColor,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                    ),
                                                builder: (context) =>
                                                    UsersListBottomSheet(
                                                      userIds: user.following,
                                                      title: "Following",
                                                    ),
                                              );
                                            },
                                          ),

                                          _buildStatItem(
                                            onTap: () {},
                                            user.stories.length.toString(),
                                            'Stories',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // Featured Stories Section
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 15.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Stories',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: kDark,
                                        ),
                                      ),
                                      Text(
                                        'See All',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: kSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15.h),

                                  UserStoriesLists(storiesLists: storiesLists),
                                ],
                              ),
                            ),

                            // Recent Posts Section
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recent Posts',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: kDark,
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                  _buildRecentPost(
                                    'Mountain Adventures',
                                    'Beautiful sunrise views from the summit',
                                    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
                                    '2 days ago',
                                    '1.2K Likes',
                                  ),
                                  _buildRecentPost(
                                    'Beach Paradise',
                                    'Relaxing weekend at the beach',
                                    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
                                    '4 days ago',
                                    '856 Likes',
                                  ),
                                  _buildRecentPost(
                                    'Urban Exploration',
                                    'Discovering hidden gems in the city',
                                    'https://images.unsplash.com/photo-1519501025264-65ba15a82390',
                                    '1 week ago',
                                    '1.5K Likes',
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // Keep your existing _buildStatItem, _buildFeaturedStory, and _buildRecentPost methods
  Widget _buildStatItem(String value, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: kSecondary,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: kGray),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPost(
    String title,
    String description,
    String imageUrl,
    String time,
    String likes,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with shimmer + caching
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 180.h,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 180.h,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 180.h,
                width: double.infinity,
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, size: 40.w, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: kDark,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  description,
                  style: TextStyle(fontSize: 14.sp, color: kGray),
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite, size: 16.w, color: kSecondary),
                        SizedBox(width: 5.w),
                        Text(
                          likes,
                          style: TextStyle(fontSize: 12.sp, color: kGray),
                        ),
                      ],
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12.sp, color: kGray),
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

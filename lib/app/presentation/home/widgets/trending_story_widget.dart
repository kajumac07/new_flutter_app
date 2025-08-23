import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/helper/truncate_with_elipsis.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/story_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class TrendingStoryWidget extends StatelessWidget {
  final Future<QuerySnapshot>? trendingStories;

  const TrendingStoryWidget({super.key, required this.trendingStories});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: trendingStories,
      builder: (ctx, index) {
        final item = index.data;
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 260.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              itemCount: item?.docs.length,
              itemBuilder: (_, index) {
                final story = item?.docs[index];
                final List<dynamic> mediaList = story?['media'] ?? [];
                final String imageUrl = mediaList.isNotEmpty
                    ? mediaList.first
                    : '';
                final String title = story?['title'] ?? 'Unknown Title';
                final String pubId = story?['uid'] ?? '';
                final String storyId = story?['sId'] ?? '';

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Persons')
                      .doc(pubId)
                      .get(),
                  builder: (context, snapshot) {
                    String authorName = "Unknown Author";
                    if (snapshot.hasData && snapshot.data!.exists) {
                      authorName =
                          snapshot.data!['fullName'] ?? 'Unknown Author';
                    }

                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => StoryDetailsScreen(
                            storyId: storyId,
                            publishedUserId: pubId,
                            currentUserId: currentUId,
                            storyTitle: title,
                          ),
                          transition: Transition.rightToLeftWithFade,
                          duration: Duration(milliseconds: 300),
                        );
                      },
                      child: _QuantumStoryCard(
                        imageUrl: imageUrl,
                        title: title,
                        author: authorName,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _QuantumStoryCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;

  const _QuantumStoryCard({
    required this.imageUrl,
    required this.title,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cached Image with Shimmer
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: CachedNetworkImage(
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
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  truncateWithEllipsis(30, title),
                  style: appStyleLato(16, kWhite, FontWeight.w800),
                ),
                SizedBox(height: 8.h),
                Text(
                  'By $author',
                  style: appStyleLato(
                    12,
                    kWhite.withOpacity(0.9),
                    FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Floating Action Button
          Positioned(
            top: 12.w,
            right: 12.w,
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: kSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border,
                color: Colors.white,
                size: 18.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_flutter_app/app/global/helper/truncate_with_elipsis.dart';
import 'package:shimmer/shimmer.dart';

class UserStoriesLists extends StatelessWidget {
  final Future<QuerySnapshot>? storiesLists;
  const UserStoriesLists({super.key, required this.storiesLists});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: storiesLists,
      builder: (ctx, index) {
        final item = index.data;
        final stories =
            item?.docs
                .where((doc) => (doc['uid'] ?? '').toString().isNotEmpty)
                .toList() ??
            [];
        return stories.isEmpty
            ? Column(
                children: [
                  Center(
                    child: Text(
                      'No stories found.',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: 180.h,
                child: ListView.builder(
                  itemCount: stories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    final story = stories[index];
                    final List<dynamic> mediaList = story['media'] ?? [];
                    final String imageUrl = mediaList.isNotEmpty
                        ? mediaList.first
                        : '';
                    final String title = story['title'] ?? 'Unknown Title';
                    // final String likes = (story['likes'] ?? 0).toString();
                    final List<dynamic> likesList = story['likes'] ?? [];
                    final String likes = likesList.length.toString();

                    return _buildFeaturedStory(title, imageUrl, likes);
                  },
                ),
              );
      },
    );
  }

  Widget _buildFeaturedStory(String title, String imageUrl, String likes) {
    return Container(
      width: 150.w,
      margin: EdgeInsets.only(right: 15.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Cached Network Image with shimmer
            CachedNetworkImage(
              imageUrl: imageUrl,
              width: 150.w,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 150.w,
                  height: double.infinity,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 150.w,
                height: double.infinity,
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, color: Colors.grey, size: 40.w),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),

            // Text and Like count
            Positioned(
              bottom: 12.h,
              left: 12.w,
              right: 12.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    truncateWithEllipsis(20, title),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 14.w, color: Colors.white),
                      SizedBox(width: 5.w),
                      Text(
                        likes,
                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

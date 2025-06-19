import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/story_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class TopStoryCard extends StatelessWidget {
  final int index;
  final String category;
  final Color color;
  final dynamic story;

  const TopStoryCard({
    required this.index,
    required this.category,
    required this.color,
    required this.story,

    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => StoryDetailsScreen(
            storyId: story.sId,
            publishedUserId: story.uid,
            currentUserId: currentUId,
            storyTitle: story.title,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Gradient Overlay
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: story.media[0],
                    width: double.infinity,
                    height: 120.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 120.h,
                      ),
                    ),
                  ),
                  Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, color.withOpacity(0.6)],
                      ),
                    ),
                  ),
                  // Price Tag
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        '₹${story.budget.total.toString()}',
                        style: appStyle(12, color, FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: appStyle(16, kDark, FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14.sp, color: kGray),
                      SizedBox(width: 5.w),
                      Text(
                        story.locations.isNotEmpty
                            ? story.locations[0]
                            : 'Unknown Location',
                        style: appStyle(12, kGray, FontWeight.normal),
                      ),
                      Spacer(),
                      Icon(Icons.star, size: 14.sp, color: Colors.amber),
                      SizedBox(width: 3.w),
                      Text('4.5 ', style: appStyle(12, kDark, FontWeight.w500)),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  LinearProgressIndicator(
                    value: (4.5 + (index * 0.1)) / 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 3.h,
                    borderRadius: BorderRadius.circular(2.r),
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

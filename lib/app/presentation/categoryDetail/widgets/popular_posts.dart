import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/models/post_model.dart';
import 'package:new_flutter_app/app/presentation/postDetailsScreen/post_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class PopularPostCard extends StatelessWidget {
  final int index;
  final String category;
  final Color color;
  final List<PostModel> posts;

  const PopularPostCard({
    required this.index,
    required this.category,
    required this.color,
    required this.posts,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final post = posts[index];

    return GestureDetector(
      onTap: () {
        Get.to(() => PostDetailsScreen(post: post));
      },
      child: Container(
        width: 250.w,
        margin: EdgeInsets.only(right: 15.w),
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
            // Post Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: post.media.isNotEmpty
                        ? post.media.first
                        : '', // Use first media URL or empty
                    width: double.infinity,
                    height: 100.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 100.h,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: Icon(Icons.error),
                    ),
                  ),
                  Container(
                    height: 100.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, color.withOpacity(0.7)],
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
                    post.title, // Directly access title from PostModel
                    style: appStyle(16, kDark, FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    post.description, // Directly access description from PostModel
                    style: appStyle(12, kGray, FontWeight.normal),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14.sp, color: color),
                      SizedBox(width: 5.w),
                      Text(
                        post.createdAt != null
                            ? _formatDate(post.createdAt!.toDate())
                            : 'Recently',
                        style: appStyle(12, color, FontWeight.w600),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}'; // Customize date format as needed
  }
}

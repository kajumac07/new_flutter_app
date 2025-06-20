import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';

class AuthorSection extends StatelessWidget {
  final String publishedUserId;
  final String currentUserId;
  final UserModel? author;
  final void Function()? toggleFollow;
  final bool isFollowing;
  const AuthorSection({
    super.key,
    required this.publishedUserId,
    required this.currentUserId,
    required this.author,
    required this.toggleFollow,
    this.isFollowing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = publishedUserId == currentUserId;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: CachedNetworkImageProvider(author!.profilePicture),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author!.fullName,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "@${author!.userName}",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrentUser)
            GestureDetector(
              onTap: toggleFollow,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.grey[200] : Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isFollowing ? "Following" : "Follow",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isFollowing ? Colors.grey[800] : Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

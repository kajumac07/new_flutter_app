import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';

class CommentsSection extends StatelessWidget {
  final List<String> comments;

  const CommentsSection({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Comments",
          style: GoogleFonts.lato(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 40.w,
          height: 3.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kPrimary, kPrimary]),
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: comments.isEmpty
              ? Column(
                  children: [
                    Icon(Icons.comment, size: 40.sp, color: Colors.grey[400]),
                    SizedBox(height: 16.h),
                    Text(
                      "No comments yet",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () {
                        // Add comment functionality
                      },
                      child: Text(
                        "Be the first to comment",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: kSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    ...comments.take(3).map((comment) => _buildCommentItem()),
                    if (comments.length > 3)
                      TextButton(
                        onPressed: () {
                          // View all comments
                        },
                        child: Text(
                          "View all ${comments.length} comments",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: kSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    SizedBox(height: 16.h),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.send,
                            size: 20.sp,
                            color: kSecondary,
                          ),
                          onPressed: () {
                            // Send comment
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: BorderSide(color: kSecondary, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCommentItem() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User Name",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "This is a sample comment about the travel experience. It was amazing!",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "2 days ago",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              size: 18.sp,
              color: Colors.grey[500],
            ),
            onPressed: () {
              // Like comment
            },
          ),
        ],
      ),
    );
  }
}

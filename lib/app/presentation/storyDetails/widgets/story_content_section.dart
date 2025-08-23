import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/global/models/travel_story_model.dart';
import 'package:readmore/readmore.dart';

class StoryContentSection extends StatelessWidget {
  final TravelStoryModel story;

  const StoryContentSection({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trip summary
        _buildSectionTitle("Journey Overview"),
        SizedBox(height: 16.h),
        _buildReadMoreText(story.summary),

        SizedBox(height: 32.h),

        // Full story
        _buildSectionTitle("The Experience"),
        SizedBox(height: 16.h),
        _buildReadMoreText(story.fullStory),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: kDark,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 40.w,
          height: 3.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kSecondary, kSecondary]),
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
      ],
    );
  }

  Widget _buildReadMoreText(String text) {
    return ReadMoreText(
      text,
      trimLines: 4,
      trimMode: TrimMode.Line,
      trimCollapsedText: ' Read more',
      trimExpandedText: ' Show less',
      moreStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: kSecondary,
      ),
      lessStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: kSecondary,
      ),
      style: GoogleFonts.poppins(
        fontSize: 15.sp,
        height: 1.8,
        color: kWhite.withOpacity(0.7),
      ),
    );
  }
}

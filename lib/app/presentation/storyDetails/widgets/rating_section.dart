import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/global/models/travel_story_model.dart';

class RatingsSection extends StatelessWidget {
  final Ratings ratings;

  const RatingsSection({super.key, required this.ratings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ratings & Reviews",
          style: GoogleFonts.lato(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: kWhite,
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
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              _RatingItem(
                category: "Trip Experience",
                rating: ratings.tripExperience,
                icon: Icons.landscape,
              ),
              _RatingItem(
                category: "Budget Friendliness",
                rating: ratings.budgetFriendliness,
                icon: Icons.attach_money,
              ),
              _RatingItem(
                category: "Safety & Security",
                rating: ratings.safety,
                icon: Icons.security,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingItem extends StatelessWidget {
  final String category;
  final double rating;
  final IconData icon;

  const _RatingItem({
    required this.category,
    required this.rating,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: kSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 20.sp, color: kSecondary),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: kWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                RatingBarIndicator(
                  rating: rating,
                  itemBuilder: (context, index) =>
                      Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 16.sp,
                  direction: Axis.horizontal,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: kSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              rating.toStringAsFixed(1),
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: kSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

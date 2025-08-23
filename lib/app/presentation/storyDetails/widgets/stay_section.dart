import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/global/models/travel_story_model.dart';

class StayReviewSection extends StatelessWidget {
  final Stay stay;

  const StayReviewSection({super.key, required this.stay});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Accommodation Review",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.grey[100],
                    ),
                    child: Icon(
                      Icons.hotel,
                      size: 24.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stay.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: kWhite,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        RatingBarIndicator(
                          rating: 4.5, // Assuming a rating
                          itemBuilder: (context, index) =>
                              Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 16.sp,
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                stay.review,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  height: 1.8,
                  color: kWhite.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

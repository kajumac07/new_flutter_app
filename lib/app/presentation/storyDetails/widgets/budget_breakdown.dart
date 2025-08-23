import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/global/models/travel_story_model.dart';

class BudgetBreakdownSection extends StatelessWidget {
  final Budget budget;

  const BudgetBreakdownSection({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Budget Breakdown",
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
          child: Column(
            children: [
              _BudgetItem(
                category: "Accommodation",
                amount: budget.accommodation,
                percentage: (budget.accommodation / budget.total * 100).round(),
                color: kSecondary,
              ),
              _BudgetItem(
                category: "Food & Dining",
                amount: budget.food,
                percentage: (budget.food / budget.total * 100).round(),
                color: const Color(0xFF4CC9F0),
              ),
              _BudgetItem(
                category: "Transport",
                amount: budget.transport,
                percentage: (budget.transport / budget.total * 100).round(),
                color: const Color(0xFF7209B7),
              ),
              _BudgetItem(
                category: "Activities",
                amount: budget.activities,
                percentage: (budget.activities / budget.total * 100).round(),
                color: const Color(0xFFF72585),
              ),
              SizedBox(height: 16.h),
              Container(
                height: 8.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: (budget.accommodation / budget.total * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSecondary,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: (budget.food / budget.total * 100).round(),
                      child: Container(color: const Color(0xFF4CC9F0)),
                    ),
                    Expanded(
                      flex: (budget.transport / budget.total * 100).round(),
                      child: Container(color: const Color(0xFF7209B7)),
                    ),
                    Expanded(
                      flex: (budget.activities / budget.total * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF72585),
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Budget",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "₹${budget.total}",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: kSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetItem extends StatelessWidget {
  final String category;
  final int amount;
  final int percentage;
  final Color color;

  const _BudgetItem({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "$percentage% of total budget",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "₹$amount",
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

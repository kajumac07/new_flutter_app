import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/controller/home_controller.dart';
import 'package:new_flutter_app/app/presentation/categoryDetail/category_detail_screen.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key, required this.controller});
  final HomeScreenController controller;

  @override
  Widget build(BuildContext context) {
    final allCategoryItems = controller.categoryList
        .expand((categoryModel) => categoryModel.lists)
        .toList();
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.9,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
        ),
        delegate: SliverChildBuilderDelegate((_, index) {
          final item = allCategoryItems[index];
          return _HolographicCategory(emoji: item.emoji, label: item.label);
        }, childCount: allCategoryItems.length),
      ),
    );
  }
}

class _HolographicCategory extends StatelessWidget {
  final String emoji;
  final String label;

  const _HolographicCategory({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Get.to(
              () => CategoryDetailScreen(
                categoryName: label,
                categoryEmoji: emoji,
                categoryColor: kPrimary,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: TextStyle(fontSize: 28.sp)),
              SizedBox(height: 8.h),
              Text(label, style: appStyleRaleway(11, kWhite, FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

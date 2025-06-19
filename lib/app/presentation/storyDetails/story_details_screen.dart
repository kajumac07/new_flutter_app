import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/models/travel_story_model.dart';
import 'package:readmore/readmore.dart';

class StoryDetailsScreen extends StatefulWidget {
  const StoryDetailsScreen({
    super.key,
    required this.storyId,
    required this.publishedUserId,
    required this.storyTitle,
  });
  final String storyId;
  final String publishedUserId;
  final String storyTitle;

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFavorite = false;
  bool isLoading = true;
  TravelStoryModel? story;

  @override
  void initState() {
    super.initState();
    fetchTravelStory();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void fetchTravelStory() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection("Stories")
          .doc(widget.storyId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          story = TravelStoryModel.fromMap(docSnapshot.data()!);
          isLoading = false;
        });
      } else {
        showToastMessage("Error", "Story not found", kRed);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showToastMessage("Error", "Error fetching story: $e", kRed);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (story == null) {
      return Scaffold(body: Center(child: Text("Story not found")));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          // Header with image gallery
          SliverAppBar(
            expandedHeight: 300.h,
            stretch: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image Gallery
                  PageView.builder(
                    controller: _pageController,
                    itemCount: story!.media.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: story!.media[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      );
                    },
                  ),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // Page indicators
                  Positioned(
                    bottom: 20.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        story!.media.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentPage == index ? 20.w : 8.w,
                          height: 8.h,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                    size: 24.sp,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.share, color: Colors.white, size: 24.sp),
                ),
                onPressed: () {
                  // Share functionality
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // Title and rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story!.title,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 18.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  story!.locations.join(", "),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          RatingBarIndicator(
                            rating: story!.ratings.tripExperience,
                            itemBuilder: (context, index) =>
                                Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20.sp,
                            direction: Axis.horizontal,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "${story!.ratings.tripExperience}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Trip summary
                  Text(
                    "Trip Summary",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ReadMoreText(
                    story!.summary,
                    trimLines: 3,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Read more',
                    trimExpandedText: 'Show less',
                    moreStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    lessStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Full story
                  Text(
                    "Full Story",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ReadMoreText(
                    story!.fullStory,
                    trimLines: 5,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Read more',
                    trimExpandedText: 'Show less',
                    moreStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    lessStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Trip details cards
                  Row(
                    children: [
                      Expanded(
                        child: _DetailCard(
                          icon: Icons.calendar_today,
                          title: "Trip Dates",
                          value:
                              "${_formatDate(story!.startDate.toDate())} - ${_formatDate(story!.endDate.toDate())}",
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _DetailCard(
                          icon: Icons.attach_money,
                          title: "Total Budget",
                          value: "₹${story!.budget.total}",
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        child: _DetailCard(
                          icon: Icons.hotel,
                          title: "Stay",
                          value: story!.stay.name,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _DetailCard(
                          icon: Icons.category,
                          title: "Category",
                          value: story!.category,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Budget breakdown
                  Text(
                    "Budget Breakdown",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _BudgetItem(
                    category: "Accommodation",
                    amount: story!.budget.accommodation,
                    color: Colors.blue,
                  ),
                  _BudgetItem(
                    category: "Food",
                    amount: story!.budget.food,
                    color: Colors.green,
                  ),
                  _BudgetItem(
                    category: "Transport",
                    amount: story!.budget.transport,
                    color: Colors.orange,
                  ),
                  _BudgetItem(
                    category: "Activities",
                    amount: story!.budget.activities,
                    color: Colors.purple,
                  ),

                  SizedBox(height: 24.h),

                  // Things to do
                  Text(
                    "Things To Do",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: story!.thingsToDo
                        .map(
                          (activity) => Chip(
                            label: Text(activity),
                            backgroundColor: Colors.blue[50],
                            labelStyle: TextStyle(color: Colors.blue[700]),
                          ),
                        )
                        .toList(),
                  ),

                  SizedBox(height: 24.h),

                  // Ratings
                  Text(
                    "Ratings",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _RatingItem(
                    category: "Trip Experience",
                    rating: story!.ratings.tripExperience,
                  ),
                  _RatingItem(
                    category: "Budget Friendliness",
                    rating: story!.ratings.budgetFriendliness,
                  ),
                  _RatingItem(
                    category: "Safety",
                    rating: story!.ratings.safety,
                  ),

                  SizedBox(height: 24.h),

                  // Travel tips
                  Text(
                    "Travel Tips",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      story!.travelTips,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Stay review
                  Text(
                    "Stay Review",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story!.stay.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          story!.stay.review,
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.5,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom action bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Iconsax.message, size: 20.sp),
                label: Text("Comment", style: TextStyle(fontSize: 16.sp)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.blue[50],
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  // Comment functionality
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                child: Text("Book Now", style: TextStyle(fontSize: 16.sp)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  // Booking functionality
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24.sp, color: Colors.blue),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _BudgetItem extends StatelessWidget {
  final String category;
  final int amount;
  final Color color;

  const _BudgetItem({
    required this.category,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              category,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
          ),
          Text(
            "₹$amount",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _RatingItem extends StatelessWidget {
  final String category;
  final double rating;

  const _RatingItem({required this.category, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
          ),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) =>
                Icon(Icons.star, color: Colors.amber),
            itemCount: 5,
            itemSize: 20.sp,
            direction: Axis.horizontal,
          ),
          SizedBox(width: 8.w),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

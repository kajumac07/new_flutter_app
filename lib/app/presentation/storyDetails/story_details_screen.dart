import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/global/models/travel_story_model.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';
import 'package:readmore/readmore.dart';

class StoryDetailsScreen extends StatefulWidget {
  final String storyId;
  final String publishedUserId;
  final String currentUserId;
  final String storyTitle;

  const StoryDetailsScreen({
    super.key,
    required this.storyId,
    required this.publishedUserId,
    required this.currentUserId,
    required this.storyTitle,
  });

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFavorite = false;
  bool isLoading = true;
  TravelStoryModel? story;
  UserModel? author;
  bool isFollowing = false;
  bool isAuthorLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch story data
      final storyDoc = await FirebaseFirestore.instance
          .collection("Stories")
          .doc(widget.storyId)
          .get();

      if (storyDoc.exists) {
        setState(() {
          story = TravelStoryModel.fromMap(storyDoc.data()!);
        });

        // Fetch author data
        final authorDoc = await FirebaseFirestore.instance
            .collection("Persons")
            .doc(widget.publishedUserId)
            .get();

        if (authorDoc.exists) {
          setState(() {
            author = UserModel.fromMap(authorDoc.data()!);
            isFollowing = author!.followers.contains(widget.currentUserId);
            isAuthorLoaded = true;
          });
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleFollow() async {
    if (author == null) return;

    try {
      final userRef = FirebaseFirestore.instance
          .collection("Persons")
          .doc(widget.publishedUserId);
      final currentUserRef = FirebaseFirestore.instance
          .collection("Persons")
          .doc(widget.currentUserId);

      if (isFollowing) {
        // Unfollow
        await userRef.update({
          'followers': FieldValue.arrayRemove([widget.currentUserId]),
        });
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([widget.publishedUserId]),
        });
      } else {
        // Follow
        await userRef.update({
          'followers': FieldValue.arrayUnion([widget.currentUserId]),
        });
        await currentUserRef.update({
          'following': FieldValue.arrayUnion([widget.publishedUserId]),
        });
      }

      setState(() {
        isFollowing = !isFollowing;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to update follow status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ),
      );
    }

    if (story == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Story not found",
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // Header with image gallery
          SliverAppBar(
            expandedHeight: 350.h,
            stretch: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
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
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      );
                    },
                  ),

                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: [0.5, 1.0],
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
                          duration: Duration(milliseconds: 300),
                          width: _currentPage == index ? 24.w : 8.w,
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
                padding: EdgeInsets.all(10.w),
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
                  padding: EdgeInsets.all(10.w),
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
                  padding: EdgeInsets.all(10.w),
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
                  SizedBox(height: 24.h),

                  // Author section
                  if (isAuthorLoaded && author != null) _buildAuthorSection(),

                  SizedBox(height: 24.h),

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
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  story!.locations.join(", "),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
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
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Trip summary
                  _buildSectionTitle("Trip Summary"),
                  SizedBox(height: 12.h),
                  _buildReadMoreText(story!.summary),

                  SizedBox(height: 24.h),

                  // Full story
                  _buildSectionTitle("Full Story"),
                  SizedBox(height: 12.h),
                  _buildReadMoreText(story!.fullStory),

                  SizedBox(height: 24.h),

                  // Trip details cards
                  _buildDetailCards(),

                  SizedBox(height: 24.h),

                  // Budget breakdown
                  _buildSectionTitle("Budget Breakdown"),
                  SizedBox(height: 12.h),
                  _buildBudgetBreakdown(),

                  SizedBox(height: 24.h),

                  // Things to do
                  _buildSectionTitle("Things To Do"),
                  SizedBox(height: 12.h),
                  _buildThingsToDo(),

                  SizedBox(height: 24.h),

                  // Ratings
                  _buildSectionTitle("Ratings"),
                  SizedBox(height: 12.h),
                  _buildRatings(),

                  SizedBox(height: 24.h),

                  // Travel tips
                  _buildSectionTitle("Travel Tips"),
                  SizedBox(height: 12.h),
                  _buildTravelTips(),

                  SizedBox(height: 24.h),

                  // Stay review
                  _buildSectionTitle("Stay Review"),
                  SizedBox(height: 12.h),
                  _buildStayReview(),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom action bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: Offset(0, -5),
            ),
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Iconsax.message, size: 20.sp),
                label: Text("Comment", style: _buttonTextStyle),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(color: Colors.blueAccent, width: 1),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // Comment functionality
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                child: Text("Book Now", style: _buttonTextStyle),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
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

  Widget _buildAuthorSection() {
    final isCurrentUser = widget.publishedUserId == widget.currentUserId;

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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildReadMoreText(String text) {
    return ReadMoreText(
      text,
      trimLines: 3,
      trimMode: TrimMode.Line,
      trimCollapsedText: 'Read more',
      trimExpandedText: 'Show less',
      moreStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.blueAccent,
      ),
      lessStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.blueAccent,
      ),
      style: GoogleFonts.poppins(
        fontSize: 15.sp,
        height: 1.6,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildDetailCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DetailCard(
                icon: Icons.calendar_today,
                title: "Trip Dates",
                value:
                    "${_formatDate(story!.startDate.toDate())} - ${_formatDate(story!.endDate.toDate())}",
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _DetailCard(
                icon: Icons.attach_money,
                title: "Total Budget",
                value: "₹${story!.budget.total}",
                color: Colors.green,
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
                color: Colors.purple,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _DetailCard(
                icon: Icons.category,
                title: "Category",
                value: story!.category,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetBreakdown() {
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
      child: Column(
        children: [
          _BudgetItem(
            category: "Accommodation",
            amount: story!.budget.accommodation,
            color: Colors.blueAccent,
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
        ],
      ),
    );
  }

  Widget _buildThingsToDo() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: story!.thingsToDo
          .map(
            (activity) => Chip(
              label: Text(activity),
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              labelStyle: GoogleFonts.poppins(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: BorderSide(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            ),
          )
          .toList(),
    );
  }

  Widget _buildRatings() {
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
      child: Column(
        children: [
          _RatingItem(
            category: "Trip Experience",
            rating: story!.ratings.tripExperience,
          ),
          _RatingItem(
            category: "Budget Friendliness",
            rating: story!.ratings.budgetFriendliness,
          ),
          _RatingItem(category: "Safety", rating: story!.ratings.safety),
        ],
      ),
    );
  }

  Widget _buildTravelTips() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber[700],
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Pro Tip",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            story!.travelTips,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStayReview() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hotel, color: Colors.blueAccent, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                story!.stay.name,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            story!.stay.review,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  final TextStyle _buttonTextStyle = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.sp, color: color),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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
      padding: EdgeInsets.only(bottom: 12.h),
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
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "₹$amount",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              rating.toStringAsFixed(1),
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

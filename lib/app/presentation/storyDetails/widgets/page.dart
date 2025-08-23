import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/models/travel_story_model.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/widgets/author_sectioon.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/widgets/budget_breakdown.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/widgets/comment_section.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/widgets/gallery_section.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/widgets/rating_section.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/widgets/stay_section.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/widgets/story_content_section.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/widgets/story_metadata.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/widgets/tags_section.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/widgets/things_to_do.dart';

class PremiumStoryDetailsScreen extends StatefulWidget {
  final TravelStoryModel story;
  final UserModel author;
  final String currentUserId;
  final String publishedUserId;
  final void Function()? toggleFollow;
  final bool isFollowing;

  const PremiumStoryDetailsScreen({
    super.key,
    required this.story,
    required this.author,
    required this.currentUserId,
    required this.publishedUserId,
    required this.toggleFollow,
    this.isFollowing = false,
  });

  @override
  State<PremiumStoryDetailsScreen> createState() =>
      _PremiumStoryDetailsScreenState();
}

class _PremiumStoryDetailsScreenState extends State<PremiumStoryDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Image Sliver App Bar
          SliverAppBar(
            expandedHeight: 450.h,
            stretch: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image Gallery
                  PageView.builder(
                    itemCount: widget.story.media.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.story.media[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
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
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),

                  // Location tags

                  // Location tags
                  Positioned(
                    bottom: 40.h,
                    left: 20.w,
                    right: 20.w,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 120.h),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8.w,
                          children: widget.story.locations
                              .map(
                                (location) => LocationChip(location: location),
                              )
                              .toList(),
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
              onPressed: () => Navigator.pop(context),
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
                    widget.story.likes.contains(widget.currentUserId)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.story.likes.contains(widget.currentUserId)
                        ? Colors.red
                        : Colors.white,
                    size: 24.sp,
                  ),
                ),
                onPressed: () {
                  // Handle like functionality
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
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  // Story Metadata
                  StoryMetadataCard(story: widget.story),

                  SizedBox(height: 24.h),
                  //Author Section
                  AuthorSection(
                    publishedUserId: widget.publishedUserId,
                    currentUserId: widget.currentUserId,
                    author: widget.author,
                    toggleFollow: widget.toggleFollow,
                    isFollowing: widget.isFollowing,
                  ),

                  SizedBox(height: 32.h),

                  // Story Content
                  StoryContentSection(story: widget.story),

                  SizedBox(height: 32.h),

                  // Budget Breakdown
                  BudgetBreakdownSection(budget: widget.story.budget),

                  SizedBox(height: 32.h),

                  // Ratings
                  RatingsSection(ratings: widget.story.ratings),

                  SizedBox(height: 32.h),

                  // Things To Do
                  ThingsToDoSection(thingsToDo: widget.story.thingsToDo),

                  SizedBox(height: 32.h),

                  // Stay Review
                  StayReviewSection(stay: widget.story.stay),

                  SizedBox(height: 32.h),

                  // Travel Tips
                  TravelTipsSection(travelTips: widget.story.travelTips),

                  SizedBox(height: 32.h),

                  // Tags
                  TagsSection(tags: widget.story.tags),

                  SizedBox(height: 32.h),

                  // Comments Section
                  if (widget.story.isComentable)
                    CommentsSection(comments: widget.story.comments),

                  SizedBox(height: 30.h),
                  // Gallery Section
                  EnhancedGallerySection(images: widget.story.media),

                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        height: 90.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Row(
          children: [
            // Bookmark button
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.bookmark_border,
                  color: Colors.grey[600],
                  size: 24.sp,
                ),
                onPressed: () {
                  // Bookmark functionality
                },
              ),
            ),
            SizedBox(width: 16.w),

            // Main action button
            Expanded(
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kSecondary, kSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: kSecondary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    showToastMessage(
                      "Info",
                      "Currently This Functionality Not Available",
                      kSecondary,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.airplane_ticket,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Book This Trip",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationChip extends StatelessWidget {
  final String location;

  const LocationChip({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 16.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            location,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class TravelTipsSection extends StatelessWidget {
  final String travelTips;

  const TravelTipsSection({super.key, required this.travelTips});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Traveler's Wisdom",
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F7FA), Color(0xFFE4E8F0)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber[800],
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "Pro Tips",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                travelTips,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  height: 1.8,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

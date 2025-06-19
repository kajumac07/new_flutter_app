import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/controller/post_coontroller.dart';
import 'package:new_flutter_app/app/global/controller/story_controller.dart';
import 'package:new_flutter_app/app/presentation/categoryDetail/widgets/popular_posts.dart';
import 'package:new_flutter_app/app/presentation/categoryDetail/widgets/top_story_card.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/story_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  final String categoryEmoji;
  final Color categoryColor;

  const CategoryDetailScreen({
    required this.categoryName,
    required this.categoryEmoji,
    required this.categoryColor,
    super.key,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Expanded Header with Parallax Effect
          SliverAppBar(
            expandedHeight: 250.h,
            collapsedHeight: 80.h,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.categoryName,
                style: appStyle(22, Colors.white, FontWeight.bold).copyWith(
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Blurred Background Image
                  CachedNetworkImage(
                    imageUrl: _getCategoryBackground(widget.categoryName),
                    fit: BoxFit.cover,
                    color: widget.categoryColor.withOpacity(0.3),
                    colorBlendMode: BlendMode.overlay,
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          widget.categoryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Category Emoji
                  Center(
                    child: Hero(
                      tag: 'category-${widget.categoryName}',
                      child: Text(
                        widget.categoryEmoji,
                        style: TextStyle(fontSize: 100.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  // Category Description
                  Text(
                    _getCategoryDescription(widget.categoryName),
                    style: appStyle(
                      16,
                      kDark.withOpacity(0.8),
                      FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Section Title with View All
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Stories',
                        style: appStyle(20, kDark, FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View all',
                          style: appStyle(14, kSecondary, FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Top stories Grid
          GetBuilder<StoryController>(
            init: StoryController(),
            builder: (storyController) {
              if (storyController.isLoading) {
                return SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: double.infinity,
                          height: 200.h,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }
              final stories = storyController.stories
                  .where(
                    (story) => story.category.contains(widget.categoryName),
                  )
                  .toList();

              if (stories.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Text(
                      'No stories found for ${widget.categoryName}',
                      style: appStyle(14, kGray, FontWeight.w500),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15.h,
                    crossAxisSpacing: 15.w,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final story = stories[index];
                    return TopStoryCard(
                      index: index,
                      category: widget.categoryName,
                      color: widget.categoryColor,
                      story: story,
                    );
                  }, childCount: stories.length),
                ),
              );
            },
          ),

          // Popular Experiences Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular Posts',
                        style: appStyle(20, kDark, FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View all',
                          style: appStyle(14, kSecondary, FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  GetBuilder<PostController>(
                    init: PostController(),
                    builder: (postController) {
                      if (postController.isLoading) {
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Center(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: double.infinity,
                                height: 200.h,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                      final posts = postController.posts
                          .where(
                            (posts) =>
                                posts.category.contains(widget.categoryName),
                          )
                          .toList();

                      if (posts.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Text(
                            'No Posts found for ${widget.categoryName}',
                            style: appStyle(14, kGray, FontWeight.w500),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 220.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: posts.length,
                          itemBuilder: (context, index) => PopularPostCard(
                            index: index,
                            category: widget.categoryName,
                            color: widget.categoryColor,
                            posts: posts,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Travel Tips Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travel Tips',
                    style: appStyle(20, kDark, FontWeight.bold),
                  ),
                  SizedBox(height: 15.h),
                  _TravelTipCard(
                    tip: _getTravelTip(widget.categoryName, 0),
                    icon: Icons.calendar_today,
                    color: widget.categoryColor,
                  ),
                  SizedBox(height: 10.h),
                  _TravelTipCard(
                    tip: _getTravelTip(widget.categoryName, 1),
                    icon: Icons.attach_money,
                    color: widget.categoryColor,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  String _getCategoryBackground(String category) {
    switch (category) {
      case 'Mountains':
        return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b';
      case 'Beaches':
        return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e';
      case 'Heritage':
        return 'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e';
      case 'Camping':
        return 'https://images.unsplash.com/photo-1504851149312-7a075b496cc7';
      case 'Food':
        return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd';
      case 'Spiritual':
        return 'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c';
      case 'Shopping':
        return 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a';
      case 'Culture':
        return 'https://images.unsplash.com/photo-1527631746610-bca00a040d60';
      default:
        return 'https://images.unsplash.com/photo-1501785888041-af3ef285b470';
    }
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'Mountains':
        return 'Discover breathtaking mountain ranges, trekking routes, and alpine adventures around the world. From the mighty Himalayas to the scenic Alps, find your perfect mountain escape.';
      case 'Beaches':
        return 'Explore pristine beaches with crystal clear waters, white sands, and tropical paradises. Whether you seek relaxation or water sports, we have the perfect beach for you.';
      case 'Heritage':
        return 'Step back in time with visits to UNESCO World Heritage sites, ancient ruins, and culturally significant landmarks that tell the story of human civilization.';
      case 'Camping':
        return 'Connect with nature through camping adventures. Find the best campsites, national parks, and outdoor experiences for your next wilderness getaway.';
      case 'Food':
        return 'Embark on a culinary journey to taste authentic local cuisines, street foods, and gourmet experiences from around the globe.';
      case 'Spiritual':
        return 'Visit sacred sites, temples, and places of spiritual significance that offer peace, enlightenment, and cultural immersion.';
      case 'Shopping':
        return 'Discover the best shopping destinations, from luxury boutiques to local markets, where you can find unique souvenirs and fashion items.';
      case 'Culture':
        return 'Immerse yourself in local traditions, festivals, and artistic expressions that define the cultural identity of destinations worldwide.';
      default:
        return 'Explore amazing destinations and experiences curated just for you.';
    }
  }

  String _getTravelTip(String category, int index) {
    final tips = {
      'Mountains': [
        'Best visited between May-September for clear skies and safe trekking conditions.',
        'Pack layers - mountain weather can change rapidly from sunny to snowy.',
      ],
      'Beaches': [
        'Early morning and late afternoon offer the best light for photos and cooler temperatures.',
        'Respect marine life - avoid touching coral or disturbing wildlife.',
      ],
      'Heritage': [
        'Hire a local guide to fully appreciate the historical significance of sites.',
        'Check for visitor limits or timed entry tickets in advance.',
      ],
      'Camping': [
        'Follow Leave No Trace principles to minimize your environmental impact.',
        'Test your gear before your trip to avoid surprises in the wilderness.',
      ],
      'Food': [
        'Eat where the locals eat - busy restaurants usually indicate good quality.',
        'Try at least one unfamiliar dish to expand your culinary horizons.',
      ],
      'Spiritual': [
        'Dress modestly and follow any posted rules about photography or behavior.',
        'Morning visits often mean fewer crowds and a more peaceful experience.',
      ],
      'Shopping': [
        'Learn basic bargaining phrases if visiting markets where haggling is expected.',
        'Check customs regulations before purchasing restricted items like antiques.',
      ],
      'Culture': [
        'Learn a few basic phrases in the local language to show respect.',
        'Research local customs to avoid unintentionally offending anyone.',
      ],
    };
    return tips[category]?[index % 2] ??
        'Plan ahead for the best travel experience.';
  }
}

class _TravelTipCard extends StatelessWidget {
  final String tip;
  final IconData icon;
  final Color color;

  const _TravelTipCard({
    required this.tip,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.sp, color: color),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              tip,
              style: appStyle(14, kDark.withOpacity(0.8), FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}

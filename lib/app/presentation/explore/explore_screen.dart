import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/global/widgets/glowing_icon_button.dart';
import 'package:new_flutter_app/app/presentation/categoryDetail/category_detail_screen.dart';
import 'package:new_flutter_app/app/presentation/cloudNotificationScreen/cloud_notification_screen.dart';
import 'package:new_flutter_app/app/presentation/profile/profile_details_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightWhite,
      appBar: AppBar(
        elevation: 0,
        title: Text('Discover', style: appStyle(24, kDark, FontWeight.bold)),
        centerTitle: true,
        actions: [
          GlowingIconButton(
            icon: Icons.notifications,
            badge: true,
            onTap: () => Get.to(() => CloudNotificationScreen()),
          ),

          SizedBox(width: 5.w),
          GlowingIconButton(
            icon: Icons.person,
            onTap: () => Get.to(() => UserProfileScreen()),
          ),
          SizedBox(width: 5.w),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Search Bar with Gradient Background
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kSecondary.withOpacity(0.1), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Container(
                  height: 50.h,
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
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: kGray),
                      hintText: 'Search destinations...',
                      hintStyle: appStyle(16, kGray, FontWeight.normal),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Categories Section with Animated Cards
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: appStyle(20, kDark, FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See all',
                      style: appStyle(14, kSecondary, FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.9,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 8.w,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final categories = [
                  {
                    'emoji': '⛰️',
                    'label': 'Mountains',
                    'color': const Color(0xFF4CAF50),
                  },
                  {
                    'emoji': '🏖️',
                    'label': 'Beaches',
                    'color': const Color(0xFF2196F3),
                  },
                  {
                    'emoji': '🏛️',
                    'label': 'Heritage',
                    'color': const Color(0xFF9C27B0),
                  },
                  {
                    'emoji': '🏕️',
                    'label': 'Camping',
                    'color': const Color(0xFF795548),
                  },
                  {
                    'emoji': '🍜',
                    'label': 'Food',
                    'color': const Color(0xFFFF5722),
                  },
                  {
                    'emoji': '🛕',
                    'label': 'Spiritual',
                    'color': const Color(0xFFFFC107),
                  },
                  {
                    'emoji': '🛒',
                    'label': 'Shopping',
                    'color': const Color(0xFFE91E63),
                  },
                  {
                    'emoji': '🎭',
                    'label': 'Culture',
                    'color': const Color(0xFF3F51B5),
                  },
                ];
                return _CategoryCard(
                  emoji: categories[index]['emoji'] as String,
                  label: categories[index]['label'] as String,
                  color: categories[index]['color'] as Color,
                  onTap: () {
                    Get.to(
                      () => CategoryDetailScreen(
                        categoryName: categories[index]['label'] as String,
                        categoryColor: categories[index]['color'] as Color,
                      ),
                    );
                  },
                );
              }, childCount: 8),
            ),
          ),

          // Trending Destinations with Parallax Effect
          SliverPadding(
            padding: EdgeInsets.only(left: 20.w, top: 20.h, bottom: 10.h),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending Now',
                    style: appStyle(20, kDark, FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View all',
                      style: appStyle(14, kSecondary, FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 240.h, // Increased height for better visuals
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                itemCount: 5,
                itemBuilder: (context, index) {
                  final destinations = [
                    {
                      'image':
                          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
                      'title': 'Himalayan Trek',
                      'location': 'Nepal',
                      'rating': 4.8,
                    },
                    {
                      'image':
                          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
                      'title': 'Goa Beaches',
                      'location': 'India',
                      'rating': 4.5,
                    },
                    {
                      'image':
                          'https://images.unsplash.com/photo-1519501025264-65ba15a82390',
                      'title': 'Tokyo City',
                      'location': 'Japan',
                      'rating': 4.9,
                    },
                    {
                      'image':
                          'https://images.unsplash.com/photo-1506929562872-bb421503ef21',
                      'title': 'Safari Tour',
                      'location': 'Kenya',
                      'rating': 4.7,
                    },
                    {
                      'image':
                          'https://images.unsplash.com/photo-1538970272646-f61fabb3bfe8',
                      'title': 'Paris Getaway',
                      'location': 'France',
                      'rating': 4.6,
                    },
                  ];
                  return _TrendingDestinationCard(
                    imageUrl: destinations[index]['image'] as String,
                    title: destinations[index]['title'] as String,
                    location: destinations[index]['location'] as String,
                    rating: destinations[index]['rating'] as double,
                  );
                },
              ),
            ),
          ),

          // Special Offers Banner
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            sliver: SliverToBoxAdapter(
              child: Container(
                height: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 20.w,
                      top: 20.h,
                      child: Opacity(
                        opacity: 0.2,
                        child: Icon(
                          Icons.airplanemode_active,
                          size: 80.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summer Special!',
                            style: appStyle(18, Colors.white, FontWeight.bold),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            'Get 30% off on all beach destinations',
                            style: appStyle(
                              14,
                              Colors.white.withOpacity(0.9),
                              FontWeight.normal,
                            ),
                          ),
                          Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                'Book Now',
                                style: appStyle(
                                  12,
                                  kSecondary,
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Popular Blogs with Featured Content
          SliverPadding(
            padding: EdgeInsets.only(left: 20.w, top: 10.h, bottom: 10.h),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Travel Stories',
                    style: appStyle(20, kDark, FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'More stories',
                      style: appStyle(14, kSecondary, FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final blogs = [
                  {
                    'image':
                        'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
                    'title': '10 Hidden Gems in Bali You Must Visit',
                    'author': 'Sarah Miller',
                    'likes': '1.2K',
                    'readTime': '8 min read',
                    'isFeatured': true,
                  },
                  {
                    'image':
                        'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e',
                    'title':
                        'Ultimate Road Trip Through Italy: A 2-Week Itinerary',
                    'author': 'Marco Rossi',
                    'likes': '2.4K',
                    'readTime': '12 min read',
                    'isFeatured': false,
                  },
                  {
                    'image':
                        'https://images.unsplash.com/photo-1527631746610-bca00a040d60',
                    'title': 'Backpacking Southeast Asia on a Budget',
                    'author': 'Lisa Wong',
                    'likes': '3.1K',
                    'readTime': '15 min read',
                    'isFeatured': true,
                  },
                ];
                return _BlogCard(
                  imageUrl: blogs[index]['image'] as String,
                  title: blogs[index]['title'] as String,
                  author: blogs[index]['author'] as String,
                  likes: blogs[index]['likes'] as String,
                  readTime: blogs[index]['readTime'] as String,
                  isFeatured: blogs[index]['isFeatured'] as bool,
                );
              }, childCount: 3),
            ),
          ),

          // Bottom Space
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }
}

// Category Place Card (New)
class _CategoryPlaceCard extends StatelessWidget {
  final int index;
  final String category;

  const _CategoryPlaceCard({
    required this.index,
    required this.category,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final places = {
      'Mountains': [
        {
          'name': 'Mount Everest Base Camp',
          'location': 'Nepal',
          'image':
              'https://images.unsplash.com/photo-1580655653885-65763b2597d0',
        },
        {
          'name': 'Swiss Alps',
          'location': 'Switzerland',
          'image':
              'https://images.unsplash.com/photo-1476231682828-37e571bc172f',
        },
        {
          'name': 'Rocky Mountains',
          'location': 'Canada',
          'image':
              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
        },
        {
          'name': 'Andes Mountains',
          'location': 'Peru',
          'image':
              'https://images.unsplash.com/photo-1452421822248-d4c2b47f0c81',
        },
        {
          'name': 'Mount Fuji',
          'location': 'Japan',
          'image':
              'https://images.unsplash.com/photo-1492571350019-22de08371fd3',
        },
      ],
      'Beaches': [
        {
          'name': 'Maldives Beaches',
          'location': 'Maldives',
          'image':
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
        },
        {
          'name': 'Bora Bora',
          'location': 'French Polynesia',
          'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5',
        },
        {
          'name': 'Whitehaven Beach',
          'location': 'Australia',
          'image':
              'https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6',
        },
        {
          'name': 'Navagio Beach',
          'location': 'Greece',
          'image':
              'https://images.unsplash.com/photo-1507699622108-4be3abd695ad',
        },
        {
          'name': 'Anse Source d\'Argent',
          'location': 'Seychelles',
          'image':
              'https://images.unsplash.com/photo-1519046904884-53103b34b206',
        },
      ],
      // Add other categories similarly...
    };

    final categoryPlaces = places[category] ?? places['Mountains']!;
    final place = categoryPlaces[index % categoryPlaces.length];

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
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
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
            child: CachedNetworkImage(
              imageUrl: place['image'] as String,
              width: double.infinity,
              height: 150.h,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: 150.h,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place['name'] as String,
                  style: appStyle(16, kDark, FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16.sp, color: kSecondary),
                    SizedBox(width: 5.w),
                    Text(
                      place['location'] as String,
                      style: appStyle(14, kGray, FontWeight.normal),
                    ),
                    Spacer(),
                    Icon(Icons.star, size: 16.sp, color: Colors.amber),
                    SizedBox(width: 5.w),
                    Text(
                      double.parse((4.5 + (index * 0.1)).toStringAsFixed(1))
                          as String,
                      style: appStyle(14, kDark, FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: TextStyle(fontSize: 28.sp)),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: appStyle(12, kDark, FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TrendingDestinationCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final double rating;

  const _TrendingDestinationCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.w, // Slightly wider for better content display
      margin: EdgeInsets.only(right: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Shimmer and Hero Animation
          Hero(
            tag: 'destination-$imageUrl',
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 140.h, // Taller image for better visuals
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: 140.h,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: appStyle(16, kDark, FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14.sp, color: kSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      location,
                      style: appStyle(12, kGray, FontWeight.normal),
                    ),
                    Spacer(),
                    Icon(Icons.star, size: 14.sp, color: Colors.amber),
                    SizedBox(width: 4.w),
                    Text(
                      rating.toStringAsFixed(1),
                      style: appStyle(12, kDark, FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                LinearProgressIndicator(
                  value: rating / 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(kSecondary),
                  minHeight: 4.h,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final String likes;
  final String readTime;
  final bool isFeatured;

  const _BlogCard({
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.likes,
    required this.readTime,
    required this.isFeatured,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Featured tag
          if (isFeatured)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: kSecondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.r),
                  topRight: Radius.circular(15.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14.sp, color: Colors.white),
                  SizedBox(width: 5.w),
                  Text(
                    'Featured Story',
                    style: appStyle(12, Colors.white, FontWeight.bold),
                  ),
                ],
              ),
            ),
          // Image with Shimmer
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: isFeatured ? Radius.zero : Radius.circular(15.r),
              bottom: Radius.circular(0),
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 160.h,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: 160.h,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: appStyle(18, kDark, FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14.r,
                          backgroundImage: NetworkImage(
                            'https://randomuser.me/api/portraits/women/${author.length}.jpg',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author,
                              style: appStyle(12, kGray, FontWeight.w500),
                            ),
                            Text(
                              readTime,
                              style: appStyle(10, kGray, FontWeight.normal),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.favorite, size: 16.sp, color: Colors.red),
                        SizedBox(width: 4.w),
                        Text(
                          likes,
                          style: appStyle(12, kGray, FontWeight.w500),
                        ),
                        SizedBox(width: 10.w),
                        Icon(
                          Icons.bookmark_border,
                          size: 16.sp,
                          color: kSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

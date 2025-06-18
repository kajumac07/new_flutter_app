import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:shimmer/shimmer.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;

  const CategoryDetailScreen({
    required this.categoryName,
    required this.categoryColor,
    Key? key,
  }) : super(key: key);

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
                categoryName,
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
                    imageUrl: _getCategoryBackground(categoryName),
                    fit: BoxFit.cover,
                    color: categoryColor.withOpacity(0.3),
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
                          categoryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Category Emoji
                  Center(
                    child: Hero(
                      tag: 'category-$categoryName',
                      child: Text(
                        _getCategoryEmoji(categoryName),
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
                    _getCategoryDescription(categoryName),
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
                        'Top Destinations',
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

          // Top Destinations Grid
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15.h,
                crossAxisSpacing: 15.w,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _CategoryPlaceCard(
                  index: index,
                  category: categoryName,
                  color: categoryColor,
                ),
                childCount: 4,
              ),
            ),
          ),

          // Popular Experiences Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Experiences',
                    style: appStyle(20, kDark, FontWeight.bold),
                  ),
                  SizedBox(height: 15.h),
                  SizedBox(
                    height: 220.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) => _ExperienceCard(
                        index: index,
                        category: categoryName,
                        color: categoryColor,
                      ),
                    ),
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
                    tip: _getTravelTip(categoryName, 0),
                    icon: Icons.calendar_today,
                    color: categoryColor,
                  ),
                  SizedBox(height: 10.h),
                  _TravelTipCard(
                    tip: _getTravelTip(categoryName, 1),
                    icon: Icons.attach_money,
                    color: categoryColor,
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

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Mountains':
        return '⛰️';
      case 'Beaches':
        return '🏖️';
      case 'Heritage':
        return '🏛️';
      case 'Camping':
        return '🏕️';
      case 'Food':
        return '🍜';
      case 'Spiritual':
        return '🛕';
      case 'Shopping':
        return '🛒';
      case 'Culture':
        return '🎭';
      default:
        return '✈️';
    }
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

class _CategoryPlaceCard extends StatelessWidget {
  final int index;
  final String category;
  final Color color;

  const _CategoryPlaceCard({
    required this.index,
    required this.category,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final places = {
      'Mountains': [
        {
          'name': 'Everest Base Camp',
          'location': 'Nepal',
          'image':
              'https://images.unsplash.com/photo-1580655653885-65763b2597d0',
          'price': '\$1,200',
        },
        {
          'name': 'Swiss Alps',
          'location': 'Switzerland',
          'image':
              'https://images.unsplash.com/photo-1476231682828-37e571bc172f',
          'price': '\$2,400',
        },
        {
          'name': 'Rocky Mountains',
          'location': 'Canada',
          'image':
              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
          'price': '\$1,800',
        },
        {
          'name': 'Andes Trek',
          'location': 'Peru',
          'image':
              'https://images.unsplash.com/photo-1452421822248-d4c2b47f0c81',
          'price': '\$1,500',
        },
      ],
      'Beaches': [
        {
          'name': 'Maldives',
          'location': 'Indian Ocean',
          'image':
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
          'price': '\$3,200',
        },
        {
          'name': 'Bora Bora',
          'location': 'French Polynesia',
          'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5',
          'price': '\$4,500',
        },
        {
          'name': 'Whitehaven',
          'location': 'Australia',
          'image':
              'https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6',
          'price': '\$2,800',
        },
        {
          'name': 'Navagio',
          'location': 'Greece',
          'image':
              'https://images.unsplash.com/photo-1507699622108-4be3abd695ad',
          'price': '\$2,100',
        },
      ],
    };

    final categoryPlaces = places[category] ?? places['Mountains']!;
    final place = categoryPlaces[index % categoryPlaces.length];

    return GestureDetector(
      onTap: () {
        // Navigate to place detail screen
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Gradient Overlay
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: place['image'] as String,
                    width: double.infinity,
                    height: 120.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 120.h,
                      ),
                    ),
                  ),
                  Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, color.withOpacity(0.6)],
                      ),
                    ),
                  ),
                  // Price Tag
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        place['price'] as String,
                        style: appStyle(12, color, FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place['name'] as String,
                    style: appStyle(16, kDark, FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14.sp, color: kGray),
                      SizedBox(width: 5.w),
                      Text(
                        place['location'] as String,
                        style: appStyle(12, kGray, FontWeight.normal),
                      ),
                      Spacer(),
                      Icon(Icons.star, size: 14.sp, color: Colors.amber),
                      SizedBox(width: 3.w),
                      Text('4.5 ', style: appStyle(12, kDark, FontWeight.w500)),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  LinearProgressIndicator(
                    value: (4.5 + (index * 0.1)) / 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 3.h,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final int index;
  final String category;
  final Color color;

  const _ExperienceCard({
    required this.index,
    required this.category,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final experiences = {
      'Mountains': [
        {
          'title': 'Sunrise Hike',
          'description':
              'Early morning trek to catch breathtaking sunrise views',
          'image':
              'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
          'duration': '4 hours',
        },
        {
          'title': 'Alpine Skiing',
          'description': 'Guided skiing through pristine mountain slopes',
          'image':
              'https://images.unsplash.com/photo-1518604666860-9ed391f76460',
          'duration': 'Full day',
        },
        {
          'title': 'Mountain Yoga',
          'description': 'Sunset yoga session with panoramic mountain views',
          'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
          'duration': '2 hours',
        },
      ],
      'Beaches': [
        {
          'title': 'Snorkeling Tour',
          'description': 'Explore vibrant coral reefs and marine life',
          'image':
              'https://images.unsplash.com/photo-1504470695779-75300268aa0e',
          'duration': '3 hours',
        },
        {
          'title': 'Sunset Cruise',
          'description': 'Relaxing boat trip with drinks and ocean views',
          'image':
              'https://images.unsplash.com/photo-1506929562872-bb421503ef21',
          'duration': '2 hours',
        },
        {
          'title': 'Beach BBQ',
          'description': 'Fresh seafood barbecue right on the sand',
          'image':
              'https://images.unsplash.com/photo-1517824806704-9040b037703b',
          'duration': 'Evening',
        },
      ],
    };

    final categoryExperiences =
        experiences[category] ?? experiences['Mountains']!;
    final experience = categoryExperiences[index % categoryExperiences.length];

    return Container(
      width: 250.w,
      margin: EdgeInsets.only(right: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Experience Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: experience['image'] as String,
                  width: double.infinity,
                  height: 100.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      color: Colors.white,
                      width: double.infinity,
                      height: 100.h,
                    ),
                  ),
                ),
                Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, color.withOpacity(0.7)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience['title'] as String,
                  style: appStyle(16, kDark, FontWeight.bold),
                ),
                SizedBox(height: 5.h),
                Text(
                  experience['description'] as String,
                  style: appStyle(12, kGray, FontWeight.normal),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14.sp, color: color),
                    SizedBox(width: 5.w),
                    Text(
                      experience['duration'] as String,
                      style: appStyle(12, color, FontWeight.w600),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Book Now',
                        style: appStyle(10, color, FontWeight.bold),
                      ),
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

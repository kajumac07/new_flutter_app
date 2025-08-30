import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/controller/community_controller.dart';
import 'package:new_flutter_app/app/global/widgets/custom_container.dart';
import 'package:new_flutter_app/app/global/widgets/glowing_icon_button.dart';
import 'package:new_flutter_app/app/presentation/cloudNotificationScreen/cloud_notification_screen.dart';
import 'package:new_flutter_app/app/presentation/profile/profile_details_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityController controller = Get.put(
    CommunityController(currentUId),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: kCardColor,
        elevation: 0,
        title: Text(
          'Community',
          style: appStyle(24, kDark, FontWeight.bold).copyWith(
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),

        // centerTitle: true,
        actions: [
          GlowingIconButton(
            icon: Icons.notifications,
            badgeCount: 0,
            onTap: () => Get.to(() => CloudNotificationScreen()),
          ),
          SizedBox(width: 8.w),
          GlowingIconButton(
            badgeCount: 0,
            icon: Icons.person,
            onTap: () => Get.to(() => UserProfileScreen()),
          ),
          SizedBox(width: 15.w),
        ],
      ),
      body: CustomGradientContainer(
        child: Obx(() {
          if (!controller.isMember.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group, size: 100, color: kSecondary),
                    SizedBox(height: 20.h),
                    Text(
                      "Join Our Travel Community!",
                      style: appStyle(22, kDark, FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Connect with travelers, share experiences, and get inspired.",
                      style: appStyle(
                        16,
                        kDark.withOpacity(0.7),
                        FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () => controller.joinCommunity(),
                      child: Text(
                        "Join Community",
                        style: appStyle(16, Colors.white, FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Community Header with Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    children: [
                      // Animated Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _AnimatedStatCard(
                              value: '${controller.memberCount.value}',
                              label: 'Members',
                              icon: Icons.people_alt_outlined,
                              color: kSecondary,
                            ),
                          ),

                          SizedBox(width: 15.w),
                          Expanded(
                            child: _AnimatedStatCard(
                              value: '${controller.onlineCount.value}',
                              label: 'Online Now',
                              icon: Icons.online_prediction,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // Community Description
                      Text(
                        'Connect with fellow travelers, share experiences, and get inspired for your next adventure!',
                        style: appStyle(
                          16,
                          kDark.withOpacity(0.8),
                          FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Featured Post with Parallax
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _FeaturedPostCard(),
                ),
              ),

              // Trending Topics
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trending Topics',
                            style: appStyle(20, kDark, FontWeight.bold)
                                .copyWith(
                                  shadows: [
                                    Shadow(
                                      color: kSecondary.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'See All',
                              style: appStyle(14, kSecondary, FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 150.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _TrendingTopicCard(
                              emoji: '✈️',
                              title: 'Flight Deals',
                              color: Colors.blue,
                              posts: '248',
                            ),
                            SizedBox(width: 12.w),
                            _TrendingTopicCard(
                              emoji: '🏝️',
                              title: 'Island Getaways',
                              color: Colors.teal,
                              posts: '176',
                            ),
                            SizedBox(width: 12.w),
                            _TrendingTopicCard(
                              emoji: '📸',
                              title: 'Photo Spots',
                              color: Colors.purple,
                              posts: '312',
                            ),
                            SizedBox(width: 12.w),
                            _TrendingTopicCard(
                              emoji: '🍽️',
                              title: 'Local Eats',
                              color: Colors.orange,
                              posts: '421',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Popular Discussions
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Popular Discussions',
                            style: appStyle(20, kDark, FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'View All',
                              style: appStyle(14, kSecondary, FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),

              // Discussion List
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final discussions = [
                    {
                      'username': 'TravelLover22',
                      'avatar':
                          'https://randomuser.me/api/portraits/women/44.jpg',
                      'time': '2h ago',
                      'title': 'Best hidden gems in Bali?',
                      'content':
                          'Looking for recommendations beyond the usual tourist spots...',
                      'likes': '124',
                      'comments': '32',
                      'isHot': true,
                    },
                    {
                      'username': 'WandererMike',
                      'avatar':
                          'https://randomuser.me/api/portraits/men/32.jpg',
                      'time': '5h ago',
                      'title': 'Solo travel safety tips',
                      'content':
                          'Sharing my top 10 safety tips for solo travelers...',
                      'likes': '89',
                      'comments': '24',
                      'isHot': false,
                    },
                    {
                      'username': 'FoodExplorer',
                      'avatar':
                          'https://randomuser.me/api/portraits/women/68.jpg',
                      'time': '1d ago',
                      'title': 'Must-try street foods in Bangkok',
                      'content':
                          'Compiled a list after living there for 3 months...',
                      'likes': '215',
                      'comments': '47',
                      'isHot': true,
                    },
                  ];
                  return _DiscussionCard(
                    discussion: discussions[index % discussions.length],
                  );
                }, childCount: 3),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 30.h)),
            ],
          );
        }),
      ),
      floatingActionButton: Obx(() {
        if (controller.isMember.value) {
          return FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) {
                  return Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Text(
                          "Choose an option",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kWhite,
                          ),
                        ),
                        SizedBox(height: 20),
                        // New Conversation
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kSecondary.withOpacity(0.1),
                            child: Icon(Iconsax.story1, color: kSecondary),
                          ),
                          title: Text(
                            "Create Community Post",
                            style: TextStyle(color: kWhite, fontSize: 16),
                          ),
                          trailing: Icon(
                            Iconsax.arrow_right_3,
                            color: kSecondary,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            // Navigate to user selection screen
                          },
                        ),
                        Divider(color: Colors.grey[700]),
                        // Create Group
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                            child: Icon(
                              Iconsax.people,
                              color: Colors.blueAccent,
                            ),
                          ),
                          title: Text(
                            "Start a Discussion",
                            style: TextStyle(color: kWhite, fontSize: 16),
                          ),
                          trailing: Icon(
                            Iconsax.arrow_right_3,
                            color: Colors.blueAccent,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(
                              () => Container(),
                              transition: Transition.leftToRight,
                            );
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              );
            },
            backgroundColor: kSecondary,
            child: Icon(Iconsax.edit, color: kWhite, size: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        } else {
          return SizedBox.shrink(); // Hide FAB when not a member
        }
      }),
    );
  }
}

class _AnimatedStatCard extends StatefulWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _AnimatedStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 24.sp, color: widget.color),
            ),
            SizedBox(width: 15.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.value, style: appStyle(18, kDark, FontWeight.bold)),
                Text(
                  widget.label,
                  style: appStyle(10, kGray, FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedPostCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: 25.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              // Background Image with Gradient
              SizedBox(
                height: 220.h,
                width: double.infinity,
                child: Image.network(
                  'https://images.unsplash.com/photo-1501555088652-021faa106b9b',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 220.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: kSecondary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'FEATURED EVENT',
                          style: appStyle(12, Colors.white, FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Community Travel Meetup - June Edition',
                        style: appStyle(20, Colors.white, FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Join us for stories, tips and adventure planning!',
                        style: appStyle(
                          14,
                          Colors.white.withOpacity(0.9),
                          FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16.r,
                            backgroundImage: NetworkImage(
                              'https://randomuser.me/api/portraits/men/22.jpg',
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'TravelCommunity',
                            style: appStyle(14, Colors.white, FontWeight.w500),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'RSVP',
                              style: appStyle(12, kSecondary, FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendingTopicCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final String posts;

  const _TrendingTopicCard({
    required this.emoji,
    required this.title,
    required this.color,
    required this.posts,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: TextStyle(fontSize: 32.sp)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: appStyle(16, kDark, FontWeight.w600)),
                  SizedBox(height: 5.h),
                  Text(
                    '$posts posts',
                    style: appStyle(12, color, FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  final Map<String, dynamic> discussion;

  const _DiscussionCard({required this.discussion});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h, left: 20.w, right: 20.w),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hot discussion indicator
          if (discussion['isHot'] as bool)
            Container(
              height: 4.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kSecondary, Colors.orange],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundImage: NetworkImage(
                        discussion['avatar'] as String,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          discussion['username'] as String,
                          style: appStyle(15, kDark, FontWeight.w600),
                        ),
                        Text(
                          discussion['time'] as String,
                          style: appStyle(12, kGray, FontWeight.normal),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.more_vert, size: 22.sp, color: kGray),
                  ],
                ),
                SizedBox(height: 15.h),
                Text(
                  discussion['title'] as String,
                  style: appStyle(18, kDark, FontWeight.bold),
                ),
                SizedBox(height: 10.h),
                Text(
                  discussion['content'] as String,
                  style: appStyle(14, kGray, FontWeight.normal),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    _ReactionButton(
                      icon: Icons.favorite_outline,
                      count: discussion['likes'] as String,
                      activeColor: Colors.red,
                    ),
                    SizedBox(width: 15.w),
                    _ReactionButton(
                      icon: Icons.comment_outlined,
                      count: discussion['comments'] as String,
                      activeColor: kSecondary,
                    ),
                    Spacer(),
                    Icon(Icons.share_outlined, size: 20.sp, color: kGray),
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

class _ReactionButton extends StatefulWidget {
  final IconData icon;
  final String count;
  final Color activeColor;

  const _ReactionButton({
    required this.icon,
    required this.count,
    required this.activeColor,
  });

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
      },
      child: Row(
        children: [
          Icon(
            widget.icon,
            size: 22.sp,
            color: isActive ? widget.activeColor : kGray,
          ),
          SizedBox(width: 6.w),
          Text(
            widget.count,
            style: appStyle(
              13,
              isActive ? widget.activeColor : kGray,
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

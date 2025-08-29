import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/global/controller/profile_controller.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animations/animations.dart';
import 'package:new_flutter_app/app/presentation/followedUsers/widgets/posts_lists_widget.dart';
import 'package:new_flutter_app/app/presentation/followedUsers/widgets/stories_lists.dart';
import 'package:new_flutter_app/app/presentation/messenger/widgets/chat_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/presentation/profile/widgets/user_lists_bottom_sheet.dart';

class FollowedUserProfilePage extends StatefulWidget {
  final UserModel user;

  const FollowedUserProfilePage({Key? key, required this.user})
    : super(key: key);

  @override
  _FollowedUserProfilePageState createState() =>
      _FollowedUserProfilePageState();
}

class _FollowedUserProfilePageState extends State<FollowedUserProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  double _expandedHeight = 390;
  bool _isFollowing = false;
  final double _headerHeight = 220;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkIfFollowing();
  }

  void _checkIfFollowing() {
    setState(() {
      _isFollowing = widget.user.followers.contains(currentUId);
    });
  }

  Future<void> _toggleFollow() async {
    final userRef = FirebaseFirestore.instance
        .collection("Persons")
        .doc(widget.user.uid);
    final currentUserRef = FirebaseFirestore.instance
        .collection("Persons")
        .doc(currentUId);

    try {
      if (_isFollowing) {
        // Unfollow
        await userRef.update({
          "followers": FieldValue.arrayRemove([currentUId]),
        });
        await currentUserRef.update({
          "following": FieldValue.arrayRemove([widget.user.uid]),
        });
      } else {
        // Follow
        await userRef.update({
          "followers": FieldValue.arrayUnion([currentUId]),
        });
        await currentUserRef.update({
          "following": FieldValue.arrayUnion([widget.user.uid]),
        });
      }

      setState(() {
        _isFollowing = !_isFollowing;
      });

      // Force refresh the profile controller
      Get.find<ProfileController>().fetchUserProfile();
    } catch (e) {
      print('Error toggling follow: $e');
      // Handle error appropriately
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardColor,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: _expandedHeight,
              pinned: true,
              floating: true,
              backgroundColor: kCardColor,
              automaticallyImplyLeading: false,
              flexibleSpace: _buildFlexibleSpaceBar(),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: kWhite),
                onPressed: () => Get.back(),
              ),
              actions: [
                // IconButton(
                //   icon: Icon(Icons.more_vert, color: kWhite),
                //   onPressed: () {},
                // ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: kCardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: kSecondary,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3.0,
                labelColor: kWhite,
                unselectedLabelColor: kSecondary,
                labelStyle: appStyleLato(14, kWhite, FontWeight.w600),
                unselectedLabelStyle: appStyleLato(
                  14,
                  kSecondary,
                  FontWeight.w500,
                ),
                tabs: [
                  Tab(icon: Icon(Iconsax.book_1, size: 20), text: "Stories"),
                  Tab(icon: Icon(Iconsax.grid_3, size: 20), text: "Posts"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  BuildStoriesLists(fUID: widget.user.uid),
                  BuildPostsLists(fUID: widget.user.uid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlexibleSpaceBar() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final flexibleSpace = constraints.biggest.height;
        final opacity =
            (flexibleSpace - kToolbarHeight) /
            (_expandedHeight - kToolbarHeight);

        return Stack(
          children: [
            // Background with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kCardColor,
                    kCardColor.withOpacity(0.9),
                    kCardColor.withOpacity(0.8),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Content that fades as we scroll
            Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: _headerHeight * 0.25),
                    _buildProfileHeader(),
                  ],
                ),
              ),
            ),

            // Username that appears as we scroll up
            if (opacity < 0.8)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: (1 - opacity).clamp(0.0, 1.0),
                  child: Center(
                    child: Text(
                      widget.user.fullName,
                      style: appStyleLato(18, kWhite, FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfileInfo(),
          SizedBox(height: 16),
          _buildStatsRow(),
          SizedBox(height: 16),
          _buildActionButtons(),
          SizedBox(height: 16),
          _buildBioSection(),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring with gradient
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kCardColor, kSecondary, kCardColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
        ),

        // Profile image container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: kCardColor,
            shape: BoxShape.circle,
            border: Border.all(color: kCardColor, width: 4),
          ),
          child: OpenContainer(
            transitionDuration: Duration(milliseconds: 500),
            openBuilder: (context, action) {
              return Scaffold(
                backgroundColor: kCardColor,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: kWhite),
                    onPressed: () => Get.back(),
                  ),
                ),
                body: Center(
                  child: Hero(
                    tag: 'profile_image_${widget.user.uid}',
                    child: CachedNetworkImage(
                      imageUrl: widget.user.profilePicture,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
            closedElevation: 0,
            closedShape: CircleBorder(),
            closedColor: Colors.transparent,
            closedBuilder: (context, action) {
              return Hero(
                tag: 'profile_image_${widget.user.uid}',
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.user.profilePicture,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        CircularProgressIndicator(color: kPrimary),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.person, color: kWhite, size: 40),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(widget.user.posts.length.toString(), 'Posts'),
          _buildVerticalDivider(),
          _buildStatItem(widget.user.stories.length.toString(), 'Stories'),
          _buildVerticalDivider(),
          InkWell(
            onTap: () {
              Get.to(
                () => UsersListBottomSheet(
                  userIds: widget.user.following,
                  title: "Followers",
                ),
                transition: Transition.native,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: _buildStatItem(
              widget.user.followers.length.toString(),
              'Followers',
            ),
          ),
          _buildVerticalDivider(),
          InkWell(
            onTap: () {
              Get.to(
                () => UsersListBottomSheet(
                  userIds: widget.user.following,
                  title: "Followers",
                ),
                transition: Transition.native,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: _buildStatItem(
              widget.user.following.length.toString(),
              'Following',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 24, color: kSecondary.withOpacity(0.3));
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: appStyleLato(16, kWhite, FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, style: appStyleLato(12, kSecondary, FontWeight.normal)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _toggleFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFollowing ? Colors.transparent : kSecondary,
            foregroundColor: _isFollowing ? kPrimary : kWhite,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: _isFollowing
                  ? BorderSide(color: kCardColor, width: 1)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_isFollowing ? Icons.check : Icons.add, size: 18),
              SizedBox(width: 6),
              Text(
                _isFollowing ? "Following" : "Follow",
                style: appStyleLato(
                  14,
                  _isFollowing ? kPrimary : kWhite,
                  FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kSecondary.withOpacity(0.5)),
          ),
          child: IconButton(
            icon: Icon(Iconsax.message, color: kWhite, size: 20),
            onPressed: () {
              String currentUid = currentUId;
              String otherUid = widget.user.uid;

              // Generate chatId (sorted so it’s same for both users)
              String chatId = currentUid.compareTo(otherUid) < 0
                  ? "${currentUid}_$otherUid"
                  : "${otherUid}_$currentUid";
              Get.to(
                () => ChatScreen(chatId: chatId, receiver: widget.user),
                transition: Transition.rightToLeftWithFade,
                duration: Duration(milliseconds: 500),
              );
            },
          ),
        ),
        SizedBox(width: 12),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kSecondary.withOpacity(0.5)),
          ),
          child: IconButton(
            icon: Icon(Iconsax.notification, color: kWhite, size: 20),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.user.fullName,
          style: appStyleLato(18, kWhite, FontWeight.bold),
        ),
        SizedBox(height: 6),
        if (widget.user.bio.isNotEmpty)
          Text(
            widget.user.bio,
            textAlign: TextAlign.center,
            style: appStyleLato(14, kSecondary, FontWeight.normal),
          ),
      ],
    );
  }
}

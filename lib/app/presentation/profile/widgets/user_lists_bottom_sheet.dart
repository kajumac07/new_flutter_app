import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/controller/profile_controller.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';
import 'package:new_flutter_app/app/global/widgets/custom_container.dart';
import 'package:new_flutter_app/app/presentation/followedUsers/followed_user_profile_page.dart';
import 'package:iconsax/iconsax.dart';

class UsersListBottomSheet extends StatelessWidget {
  final List<dynamic> userIds;
  final String title;
  final bool isFollowersList;

  const UsersListBottomSheet({
    Key? key,
    required this.userIds,
    required this.title,
    this.isFollowersList = true,
  }) : super(key: key);

  Future<List<UserModel>> _fetchUsers() async {
    if (userIds.isEmpty) return [];
    final querySnapshot = await FirebaseFirestore.instance
        .collection("Persons")
        .where("uid", whereIn: userIds)
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomGradientContainer(
        child: Column(
          children: [
            // Custom header
            Container(
              height: 120.h,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(color: kCardColor),
              child: Center(
                child: Text(
                  title,
                  style: appStyleLato(24, kWhite, FontWeight.w800),
                ),
              ),
            ),

            // User count badge
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 20),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: kSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: kSecondary.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: FutureBuilder<List<UserModel>>(
                future: _fetchUsers(),
                builder: (context, snapshot) {
                  final count = snapshot.hasData ? snapshot.data!.length : 0;
                  return Text(
                    "$count ${count == 1 ? 'Person' : 'People'}",
                    style: appStyleLato(14, kSecondary, FontWeight.w500),
                  );
                },
              ),
            ),

            // List of users
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                future: _fetchUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingList();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final users = snapshot.data!;
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: users.length,
                    separatorBuilder: (context, index) => Divider(
                      color: kSecondary.withOpacity(0.2),
                      height: 1,
                      indent: 70,
                    ),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserCard(user, context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Shimmer avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: kSecondary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 16),
              // Shimmer text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: kSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: kSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              // Shimmer button
              Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: kSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFollowersList ? Iconsax.people : Iconsax.user,
            size: 64,
            color: kSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            isFollowersList ? "No followers yet" : "Not following anyone",
            style: appStyleLato(18, kWhite, FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            isFollowersList
                ? "When someone follows you, they'll appear here."
                : "When you follow someone, they'll appear here.",
            textAlign: TextAlign.center,
            style: appStyleLato(14, kSecondary, FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFD1D1D),
                      Color(0xFF833AB4),
                      Color(0xFF405DE6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.profilePicture),
                    backgroundColor: kCardColor,
                  ),
                ),
              ),
              if (user.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: kPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: kCardColor, width: 2),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUId == user.uid
                      ? "${user.fullName} (You)"
                      : user.fullName,
                  style: appStyleLato(16, kWhite, FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "@${user.userName}",
                  style: appStyleLato(12, kSecondary, FontWeight.normal),
                ),
                SizedBox(height: 6),
                if (user.bio.isNotEmpty)
                  Text(
                    user.bio,
                    style: appStyleLato(
                      12,
                      kSecondary.withOpacity(0.8),
                      FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          SizedBox(width: 12),

          // Action buttons
          Column(
            children: [
              // Follow/Unfollow button
              if (user.uid != currentUId) CustomFollowButton(user: user),

              SizedBox(height: 8),

              // Profile button
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => FollowedUserProfilePage(user: user),
                    transition: Transition.rightToLeft,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kSecondary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.profile_circle,
                    size: 20,
                    color: kSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomFollowButton extends StatefulWidget {
  final UserModel user;
  const CustomFollowButton({Key? key, required this.user}) : super(key: key);

  @override
  State<CustomFollowButton> createState() => _CustomFollowButtonState();
}

class _CustomFollowButtonState extends State<CustomFollowButton> {
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  void _checkIfFollowing() {
    setState(() {
      isFollowing = widget.user.followers.contains(currentUId);
    });
  }

  Future<void> _toggleFollow() async {
    setState(() {
      isLoading = true;
    });

    final userRef = FirebaseFirestore.instance
        .collection("Persons")
        .doc(widget.user.uid);
    final currentUserRef = FirebaseFirestore.instance
        .collection("Persons")
        .doc(currentUId);

    try {
      if (isFollowing) {
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
        isFollowing = !isFollowing;
      });

      // Force refresh the profile controller
      Get.find<ProfileController>().fetchUserProfile();
    } catch (e) {
      print('Error toggling follow: $e');
      Get.snackbar(
        'Error',
        'Failed to ${isFollowing ? 'unfollow' : 'follow'} user',
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 36,
      decoration: BoxDecoration(
        gradient: isFollowing
            ? LinearGradient(
                colors: [Color(0xFF2D3B4C), Color(0xFF1A2639)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Color(0xFFE94560), Color(0xFFFF7B9C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _toggleFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(kWhite),
                ),
              )
            : Text(
                isFollowing ? "Following" : "Follow",
                style: TextStyle(
                  color: kWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

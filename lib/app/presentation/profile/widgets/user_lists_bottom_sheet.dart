import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/controller/profile_controller.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';
import 'package:new_flutter_app/app/presentation/followedUsers/followed_user_profile_page.dart';

class UsersListBottomSheet extends StatelessWidget {
  final List<dynamic> userIds;
  final String title;

  const UsersListBottomSheet({
    Key? key,
    required this.userIds,
    required this.title,
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
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Small drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: kSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(title, style: appStyleLato(16, kWhite, FontWeight.w300)),
            Divider(color: kSecondary.withOpacity(0.7)),

            // List of users
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                future: _fetchUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No users found",
                        style: appStyleLato(16, kWhite, FontWeight.normal),
                      ),
                    );
                  }

                  final users = snapshot.data!;
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Close the bottom sheet
                          Get.to(
                            () => FollowedUserProfilePage(user: user),
                            transition: Transition.rightToLeft,
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.profilePicture),
                          ),
                          title: Text(
                            user.fullName,
                            style: appStyleLato(16, kWhite, FontWeight.w500),
                          ),
                          subtitle: Text(
                            "@${user.userName}",
                            style: appStyleLato(11, kWhite, FontWeight.normal),
                          ),
                          trailing: FollowButton(user: user),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class FollowButton extends StatefulWidget {
  final UserModel user;
  const FollowButton({Key? key, required this.user}) : super(key: key);

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  void _checkIfFollowing() {
    // currentUId should be your logged-in user’s ID
    setState(() {
      isFollowing = widget.user.followers.contains(currentUId);
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
      if (isFollowing) {
        // 🔹 Unfollow
        await userRef.update({
          "followers": FieldValue.arrayRemove([currentUId]),
        });
        await currentUserRef.update({
          "following": FieldValue.arrayRemove([widget.user.uid]),
        });
      } else {
        // 🔹 Follow
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
      // Handle error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _toggleFollow,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? kSecondary : kSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        isFollowing ? "Unfollow" : "Follow",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

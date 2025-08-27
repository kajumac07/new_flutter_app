import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/models/post_model.dart';
import 'package:new_flutter_app/app/presentation/followedUsers/widgets/post_card.dart';
import 'package:new_flutter_app/app/presentation/postDetailsScreen/post_details_screen.dart';

class BuildPostsLists extends StatelessWidget {
  const BuildPostsLists({super.key, required this.fUID});
  final String fUID;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('Posts')
          .where("uid", isEqualTo: fUID)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: kSecondary));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.grid_3, size: 48, color: kSecondary),
                SizedBox(height: 16),
                Text(
                  "No posts yet",
                  style: appStyleLato(16, kSecondary, FontWeight.normal),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final PostModel post = PostModel.fromMap(
              posts[index].data() as Map<String, dynamic>,
            );

            final String userId = post.uid;

            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("Persons")
                  .doc(userId)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  );
                }
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return SizedBox.shrink();
                }

                final userData = userSnapshot.data!;
                final userName = userData['userName'] ?? 'Unknown';
                final userProfilePic = userData['profilePicture'] ?? '';
                final fullName = userData['fullName'] ?? 'Unknown';

                return InkWell(
                  onTap: () {
                    Get.to(
                      () => PostDetailsScreen(post: post),
                      transition: Transition.rightToLeft,
                      duration: Duration(milliseconds: 300),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: PostCard(
                      userName: userName,
                      userProfilePic: userProfilePic,
                      fullName: fullName,
                      post: PostModel(
                        uid: post.uid,
                        postId: post.postId,
                        title: post.title,
                        description: post.description,
                        media: post.media,
                        category: post.category,
                        location: post.location,
                        isPublic: post.isPublic,
                        allowComments: post.allowComments,
                        tags: post.tags,
                        createdAt: post.createdAt,
                        likes: post.likes,
                        comments: post.comments,
                        scheduledAt: post.scheduledAt,
                        status: post.status,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// app/global/widgets/post_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  final PostModel post;
  final String userName;
  final String userProfilePic;
  final String fullName;
  const PostCard({
    Key? key,
    required this.post,
    required this.userName,
    required this.userProfilePic,
    required this.fullName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with user info
          _buildPostHeader(),
          SizedBox(height: 8),

          // Post image
          _buildPostImage(),
          SizedBox(height: 8),

          // Post actions (like, comment, share)
          _buildPostActions(),
          SizedBox(height: 4),

          // Likes count
          _buildLikesCount(),
          SizedBox(height: 4),

          // Caption
          _buildCaption(),
          SizedBox(height: 4),

          // Comments preview
          _buildCommentsPreview(),
          SizedBox(height: 4),

          // Timestamp
          _buildTimestamp(),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfilePic),
            radius: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: appStyleLato(14, kWhite, FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  '@${userName}',
                  style: appStyleLato(12, kSecondary, FontWeight.normal),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: kSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {
        // Handle like on double tap
      },
      child: Container(
        height: Get.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(post.media.first),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildPostActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              post.likes.contains('currentUserId')
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: post.likes.contains('currentUserId') ? Colors.red : kWhite,
            ),
            onPressed: () {
              // Handle like
            },
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: kWhite),
            onPressed: () {
              // Handle comment
            },
          ),
          IconButton(
            icon: Icon(Icons.send, color: kWhite),
            onPressed: () {
              // Handle share
            },
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.bookmark_border, color: kWhite),
            onPressed: () {
              // Handle save
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLikesCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '${post.likes.length} likes',
        style: appStyleLato(14, kWhite, FontWeight.w600),
      ),
    );
  }

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: userName,
              style: appStyleLato(14, kWhite, FontWeight.w600),
            ),
            TextSpan(
              text: ' ${post.title}',
              style: appStyleLato(14, kWhite, FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsPreview() {
    if (post.comments.isEmpty) {
      return SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          // Navigate to comments screen
        },
        child: Text(
          'View all ${post.comments.length} comments',
          style: appStyleLato(14, kSecondary, FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        timeago.format(post.createdAt!.toDate()),
        style: appStyleLato(12, kSecondary, FontWeight.normal),
      ),
    );
  }
}

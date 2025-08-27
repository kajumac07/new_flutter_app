import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:iconsax/iconsax.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final String userName;
  final String userProfilePic;
  final String fullName;
  final VoidCallback? onTap;

  const PostCard({
    Key? key,
    required this.post,
    required this.userName,
    required this.userProfilePic,
    required this.fullName,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header with user info
            _buildPostHeader(),

            // Post image with gradient overlay
            _buildPostImage(),

            // Post actions (like, comment, share)
            _buildPostActions(),

            // Post details (likes, caption)
            _buildPostDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
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
              padding: const EdgeInsets.all(1.5),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(userProfilePic),
                radius: 16,
                backgroundColor: kCardColor,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: appStyleLato(13, kWhite, FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1),
                Text(
                  '@${userName}',
                  style: appStyleLato(11, kSecondary, FontWeight.normal),
                ),
              ],
            ),
          ),
          Text(
            timeago.format(post.createdAt!.toDate()),
            style: appStyleLato(11, kSecondary, FontWeight.normal),
          ),
          SizedBox(width: 4),
          IconButton(
            icon: Icon(Iconsax.more, color: kSecondary, size: 18),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    return Stack(
      children: [
        Container(
          height: Get.width * 0.7, // Reduced height
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(post.media.first),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradient overlay at bottom only
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildActionButton(
            icon: post.likes.contains(currentUId)
                ? Iconsax.heart5
                : Iconsax.heart,
            color: post.likes.contains(currentUId) ? Colors.red : kWhite,
            onPressed: () {},
          ),
          SizedBox(width: 12),
          _buildActionButton(icon: Iconsax.message, onPressed: () {}),
          SizedBox(width: 12),
          _buildActionButton(icon: Iconsax.send_2, onPressed: () {}),
          Spacer(),
          _buildActionButton(
            icon: post.comments.isNotEmpty
                ? Iconsax.bookmark_25
                : Iconsax.bookmark_2,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color color = kWhite,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: null,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      splashRadius: 16,
    );
  }

  Widget _buildPostDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Likes count
          if (post.likes.isNotEmpty) ...[
            Text(
              '${post.likes.length} ${post.likes.length == 1 ? 'like' : 'likes'}',
              style: appStyleLato(13, kWhite, FontWeight.w600),
            ),
            SizedBox(height: 6),
          ],

          // Caption (truncated)
          if (post.title.isNotEmpty) ...[
            RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: userName,
                    style: appStyleLato(13, kWhite, FontWeight.w600),
                  ),
                  TextSpan(
                    text: ' ${post.title}',
                    style: appStyleLato(13, kWhite, FontWeight.normal),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),
          ],

          // Tags (single line)
          if (post.tags.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 6,
                children: post.tags.map((tag) {
                  return InkWell(
                    onTap: () {},
                    child: Text(
                      '#$tag',
                      style: appStyleLato(12, kPrimary, FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 6),
          ],

          // Comments preview
          if (post.comments.isNotEmpty) ...[
            GestureDetector(
              onTap: () {
                // Navigate to comments screen
              },
              child: Text(
                'View all ${post.comments.length} comments',
                style: appStyleLato(12, kSecondary, FontWeight.normal),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

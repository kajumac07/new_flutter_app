import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/global/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailsScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailsScreen({super.key, required this.post});

  @override
  // ignore: library_private_types_in_public_api
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  bool isLiked = false;
  int likeCount = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<String> comments = [];
  late String userName = "";
  late String userProfileImage = "";

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    isLiked = widget.post.likes.contains(
      currentUId,
    ); // Replace with actual user ID
    likeCount = widget.post.likes.length;
  }

  fetchUserDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Persons")
          .doc(widget.post.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userName = doc.data()?['fullName'] ?? 'Unknown User';
          userProfileImage =
              doc.data()?['profilePicture'] ??
              'https://via.placeholder.com/150'; // Default image if none exists
        });
      } else {
        Get.snackbar('Error', 'User not found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.h,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'post-${widget.post.postId}',
                child: _buildPostImage(),
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: _sharePost,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundImage: NetworkImage(
                          userProfileImage,
                        ), // User avatar
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            timeago.format(
                              widget.post.createdAt?.toDate() ?? DateTime.now(),
                            ),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                        onPressed: _toggleLike,
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    widget.post.title,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    children: widget.post.category
                        .map(
                          (category) => Chip(
                            label: Text(category),
                            backgroundColor: Colors.blue.withOpacity(0.2),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    widget.post.description,
                    style: TextStyle(fontSize: 16.sp, height: 1.5),
                  ),
                  SizedBox(height: 30.h),
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 20.sp),
                      SizedBox(width: 5.w),
                      Text('$likeCount likes'),
                      SizedBox(width: 20.w),
                      Icon(Icons.comment, color: Colors.blue, size: 20.sp),
                      SizedBox(width: 5.w),
                      Text('${widget.post.comments.length} comments'),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...comments
                      .map((comment) => _buildCommentItem(comment))
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCommentInput(),
    );
  }

  Widget _buildPostImage() {
    // Check if media is available and URL is valid
    final hasMedia =
        widget.post.media.isNotEmpty &&
        widget.post.media.first.isNotEmpty &&
        Uri.tryParse(widget.post.media.first)?.hasAbsolutePath == true;

    return hasMedia
        ? CachedNetworkImage(
            imageUrl: widget.post.media.first,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildImagePlaceholder(),
          )
        : _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildCommentItem(String comment) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(comment),
                SizedBox(height: 4.h),
                Text(
                  '2 minutes ago', // Replace with actual time
                  style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: _postComment,
          ),
        ],
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  void _postComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      comments.add(_commentController.text);
      _commentController.clear();
    });
  }

  void _sharePost() {
    Get.snackbar('Shared', 'Post shared successfully');
  }
}

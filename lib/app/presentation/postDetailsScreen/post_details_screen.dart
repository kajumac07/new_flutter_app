import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/global/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailsScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailsScreen({super.key, required this.post});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  late bool isLiked;
  late int likeCount;
  final TextEditingController _commentController = TextEditingController();
  late List<Map<String, dynamic>> comments = [];
  late String userName = "Loading...";
  late String userProfileImage = "https://via.placeholder.com/150";
  late String currentUserName = "";
  late String currentUserProfileImage = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.likes.contains(currentUId);
    likeCount = widget.post.likes.length;
    comments = widget.post.comments;
    fetchUserDetails();
    fetchCurrentUserDetails();
    _fetchComments();
  }

  Future<void> fetchCurrentUserDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Persons")
          .doc(currentUId)
          .get();

      if (doc.exists) {
        setState(() {
          currentUserName = doc.data()?['fullName'] ?? 'Current User';
          currentUserProfileImage =
              doc.data()?['profilePicture'] ??
              'https://via.placeholder.com/150';
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch current user details');
    }
  }

  Future<void> fetchUserDetails() async {
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
              'https://via.placeholder.com/150';
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user details');
    }
  }

  Future<void> _fetchComments() async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection("Posts")
          .doc(widget.post.postId)
          .get();

      if (postDoc.exists) {
        final data = postDoc.data() as Map<String, dynamic>;
        if (data['comments'] != null && data['comments'] is List) {
          setState(() {
            comments = List<Map<String, dynamic>>.from(data['comments']);
          });
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load comments');
    }
  }

  Future<void> _toggleLike() async {
    setState(() {
      isLoading = true;
    });

    try {
      final postRef = FirebaseFirestore.instance
          .collection("Posts")
          .doc(widget.post.postId);

      if (isLiked) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([currentUId]),
        });
        setState(() {
          isLiked = false;
          likeCount--;
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([currentUId]),
        });
        setState(() {
          isLiked = true;
          likeCount++;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update like status');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final isAuthor = currentUId == widget.post.uid;
      final authorTag = isAuthor ? ' (Author)' : '';

      final newComment = {
        'text': _commentController.text,
        'userId': currentUId,
        'timestamp': Timestamp.now(),
        'userName': '$currentUserName$authorTag', // Add (Author) tag if needed
        'userImage': currentUserProfileImage,
        'isAuthor': isAuthor, // Store this for easy checking later
      };

      await FirebaseFirestore.instance
          .collection("Posts")
          .doc(widget.post.postId)
          .update({
            'comments': FieldValue.arrayUnion([newComment]),
          });

      setState(() {
        comments.insert(0, newComment);
        _commentController.clear();
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to post comment');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _sharePost() {
    // Implement share functionality
    Get.snackbar('Shared', 'Post shared successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350.h,
            flexibleSpace: FlexibleSpaceBar(background: _buildPostImage()),
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: EdgeInsets.all(8.w),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: Icon(Iconsax.share, color: Colors.white, size: 20.w),
                    onPressed: _sharePost,
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.h),
                  _buildPostHeader(),
                  SizedBox(height: 20.h),
                  _buildPostContent(),
                  SizedBox(height: 25.h),
                  _buildInteractionStats(),
                  SizedBox(height: 30.h),
                  _buildCommentsSection(),
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
    return Stack(
      children: [
        if (widget.post.media.isNotEmpty)
          CachedNetworkImage(
            imageUrl: widget.post.media.first,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildImagePlaceholder(),
          )
        else
          _buildImagePlaceholder(),
        Positioned(
          bottom: 20.h,
          right: 20.w,
          child: FloatingActionButton(
            onPressed: _toggleLike,
            backgroundColor: Colors.white,
            mini: true,
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.grey[600],
              size: 24.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image, size: 50.w, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildPostHeader() {
    final isAuthor = currentUId == widget.post.uid;
    final authorTag = isAuthor ? ' (You)' : '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24.r,
          backgroundImage: NetworkImage(userProfileImage),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$userName$authorTag',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                timeago.format(
                  widget.post.createdAt?.toDate() ?? DateTime.now(),
                ),
                style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey[600],
          ),
          onPressed: _toggleLike,
        ),
      ],
    );
  }

  Widget _buildPostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.title,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        SizedBox(height: 12.h),
        if (widget.post.category.isNotEmpty)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.post.category
                .map(
                  (category) => Chip(
                    label: Text(category, style: TextStyle(fontSize: 12.sp)),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        SizedBox(height: 16.h),
        Text(
          widget.post.description,
          style: TextStyle(
            fontSize: 16.sp,
            height: 1.6,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16.h),
        if (widget.post.location.isNotEmpty)
          Row(
            children: [
              Icon(Icons.location_on, size: 16.w, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                widget.post.location,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInteractionStats() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: isLiked ? Iconsax.heart5 : Iconsax.heart5,
            count: likeCount,
            isActive: isLiked,
            label: 'Likes',
          ),
          _buildStatItem(
            icon: Iconsax.message,
            count: comments.length,
            isActive: false,
            label: 'Comments',
          ),
          _buildStatItem(
            icon: Iconsax.share5,
            count: 0,
            isActive: false,
            label: 'Share',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required bool isActive,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 22.w, color: isActive ? kRed : Colors.grey[600]),
        SizedBox(height: 4.h),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.blue : Colors.grey[600],
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${comments.length})',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        if (comments.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            child: Center(
              child: Text(
                'No comments yet. Be the first to comment!',
                style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
              ),
            ),
          ),
        ...comments.map((comment) => _buildCommentItem(comment)).toList(),
      ],
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: NetworkImage(
              comment['userImage'] ?? 'https://via.placeholder.com/150',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12.r),
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['userName'] ?? 'Anonymous',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        comment['text'],
                        style: TextStyle(fontSize: 14.sp, height: 1.4),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6.h),
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    timeago.format(
                      (comment['timestamp'] as Timestamp).toDate(),
                    ),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
                  ),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: NetworkImage(userProfileImage),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: _postComment,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

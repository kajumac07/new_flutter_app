import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/global/models/travel_story_model.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';
import 'package:new_flutter_app/app/presentation/storyDetails/widgets/page.dart';

class StoryDetailsScreen extends StatefulWidget {
  final String storyId;
  final String publishedUserId;
  final String currentUserId;
  final String storyTitle;

  const StoryDetailsScreen({
    super.key,
    required this.storyId,
    required this.publishedUserId,
    required this.currentUserId,
    required this.storyTitle,
  });

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  bool isLoading = true;
  TravelStoryModel? story;
  UserModel? author;
  bool isFollowing = false;
  bool isAuthorLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch story data
      final storyDoc = await FirebaseFirestore.instance
          .collection("Stories")
          .doc(widget.storyId)
          .get();

      if (storyDoc.exists) {
        setState(() {
          story = TravelStoryModel.fromMap(storyDoc.data()!);
        });

        // Fetch author data
        final authorDoc = await FirebaseFirestore.instance
            .collection("Persons")
            .doc(widget.publishedUserId)
            .get();

        if (authorDoc.exists) {
          setState(() {
            author = UserModel.fromMap(authorDoc.data()!);
            isFollowing = author!.followers.contains(widget.currentUserId);
            isAuthorLoaded = true;
          });
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleFollow() async {
    if (author == null) return;

    try {
      final userRef = FirebaseFirestore.instance
          .collection("Persons")
          .doc(widget.publishedUserId);
      final currentUserRef = FirebaseFirestore.instance
          .collection("Persons")
          .doc(widget.currentUserId);

      if (isFollowing) {
        // Unfollow
        await userRef.update({
          'followers': FieldValue.arrayRemove([widget.currentUserId]),
        });
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([widget.publishedUserId]),
        });
      } else {
        // Follow
        await userRef.update({
          'followers': FieldValue.arrayUnion([widget.currentUserId]),
        });
        await currentUserRef.update({
          'following': FieldValue.arrayUnion([widget.publishedUserId]),
        });
      }

      setState(() {
        isFollowing = !isFollowing;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to update follow status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ),
      );
    }

    if (story == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Story not found",
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }
    return PremiumStoryDetailsScreen(
      story: story!,
      author: author!,
      currentUserId: currentUId,
      publishedUserId: widget.publishedUserId,
      toggleFollow: toggleFollow,
      isFollowing: isFollowing,
    );
  }
}

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/global/models/category_model.dart';
import 'package:new_flutter_app/app/global/models/community_post_model.dart';

class CommunityController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxInt memberCount = 0.obs;
  RxInt onlineCount = 0.obs;
  RxBool isMember = false.obs;
  RxList<CommunityPost> trendingPosts = <CommunityPost>[].obs;
  RxList<CommunityPost> allPosts = <CommunityPost>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingCategories = true.obs;
  String? selectedCategoryId;

  List<CategoryItem> allCategories = [];

  final String currentUserId;
  CommunityController(this.currentUserId);

  //======================== Check Membership Status =======================
  Future<void> checkMembership() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Persons")
          .doc(currentUserId)
          .get();

      if (doc.exists) {
        isMember.value = doc["isCommunityMember"] ?? false;
        if (isMember.value) {
          await fetchMemberAndOnlineCount();
        }
      }
    } catch (e) {
      log("Error checking membership: $e");
    }
  }

  //==================== Join Community =======================
  Future<void> joinCommunity() async {
    try {
      await FirebaseFirestore.instance
          .collection("Persons")
          .doc(currentUserId)
          .update({"isCommunityMember": true});

      isMember.value = true;
      await fetchMemberAndOnlineCount();
    } catch (e) {
      log("Error joining community: $e");
    }
  }

  //===================== Fetch Member and Online Count =====================
  Future<void> fetchMemberAndOnlineCount() async {
    try {
      final membersSnapshot = await FirebaseFirestore.instance
          .collection("Persons")
          .where("isCommunityMember", isEqualTo: true)
          .get();

      memberCount.value = membersSnapshot.docs.length;

      final onlineSnapshot = await FirebaseFirestore.instance
          .collection("Persons")
          .where("isCommunityMember", isEqualTo: true)
          .where("isOnline", isEqualTo: true)
          .get();

      onlineCount.value = onlineSnapshot.docs.length;
    } catch (e) {
      log("Error fetching counts: $e");
    }
  }

  //========================== Create Community Post=========================
  Future<void> createPost(CommunityPost post) async {
    try {
      isLoading.value = true;
      final docRef = await _firestore
          .collection('community_posts')
          .add(post.toMap());
      await _firestore.collection('community_posts').doc(docRef.id).update({
        'id': docRef.id,
      });
      isLoading.value = false;
      Get.back();
      Get.snackbar('Success', 'Post created successfully!');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to create post: $e');
    }
  }

  //================= get posts stream=======================
  Stream<List<CommunityPost>> getPostsStream() {
    return _firestore
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityPost.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  //==================== get trending posts==================
  Stream<List<CommunityPost>> getTrendingPosts() {
    return _firestore
        .collection('community_posts')
        .where('isTrending', isEqualTo: true)
        .orderBy('likes', descending: true)
        .limit(5)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityPost.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  //=============like posts===================
  Future<void> likePost(String postId) async {
    try {
      await _firestore.collection('community_posts').doc(postId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  //================ Add Comment ======================
  Future<void> addComment(String postId) async {
    try {
      await _firestore.collection('community_posts').doc(postId).update({
        'comments': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  //fetch trending posts
  Future<void> fetchTrendingPosts() async {
    try {
      final snapshot = await _firestore
          .collection('community_posts')
          .where('isTrending', isEqualTo: true)
          .orderBy('likes', descending: true)
          .limit(4)
          .get();

      trendingPosts.value = snapshot.docs
          .map((doc) => CommunityPost.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching trending posts: $e');
    }
  }

  //======================= fetch Community Categories ======================

  void fetchCommunityCategories() async {
    try {
      isLoadingCategories = true.obs;
      update();

      final snapshot = await FirebaseFirestore.instance
          .collection("Categories")
          .get();

      // Flatten and filter categories
      allCategories = [];
      for (var doc in snapshot.docs) {
        final categoryModel = CategoryModel.fromDoc(doc.id, doc.data());
        allCategories.addAll(
          categoryModel.lists.where((item) => item.isCommunity == true),
        );
      }
      update();
    } catch (e) {
      // Handle error gracefully (maybe show a snackbar or toast)
      debugPrint("Error fetching categories: $e");
    } finally {
      isLoadingCategories = false.obs;
      update();
    }
  }

  @override
  void onInit() {
    super.onInit();
    checkMembership();
    fetchTrendingPosts();
    fetchCommunityCategories();
    // Listen to posts stream
    ever(allPosts, (_) => fetchTrendingPosts());
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/models/post_model.dart';

class PostController extends GetxController {
  List<PostModel> posts = [];
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  void fetchPosts() async {
    try {
      isLoading = true;
      update();

      final snapshot = await FirebaseFirestore.instance
          .collection("Posts")
          .get();

      posts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data()))
          .toList();

      // Sort by scheduledAt or created_at (optional)
      posts.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

      isLoading = false;
      update(); // notify GetBuilder widgets
    } catch (e) {
      isLoading = false;
      update();
      showToastMessage("Error", "Failed to fetch posts: $e", kRed);
    }
  }
}

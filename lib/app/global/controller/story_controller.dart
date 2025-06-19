import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/models/travel_story_model.dart';

class StoryController extends GetxController {
  List<TravelStoryModel> stories = [];
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    fetchTravelStories();
  }

  void fetchTravelStories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("Stories")
          .get();

      stories = querySnapshot.docs
          .map((doc) => TravelStoryModel.fromMap(doc.data()))
          .toList();

      isLoading = false;
      update(); // if using GetBuilder
    } catch (e) {
      showToastMessage("Error", "Error fetching stories: $e", kRed);
      isLoading = false;
      update();
    } finally {
      isLoading = false;
      update();
    }
  }
}

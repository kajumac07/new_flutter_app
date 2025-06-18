import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/global/models/category_model.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';

class HomeScreenController extends GetxController {
  List<CategoryModel> categoryList = [];
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Categories")
          .get();

      categoryList = snapshot.docs.map((doc) {
        return CategoryModel.fromDoc(doc.id, doc.data());
      }).toList();

      update(); // Trigger UI update if using GetBuilder
    } catch (e) {
      showToastMessage("Error", e.toString(), kRed);
    } finally {
      isLoading = false;
      update(); // Ensure UI updates after loading
    }
  }
}

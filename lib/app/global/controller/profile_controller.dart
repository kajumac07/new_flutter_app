import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';

class ProfileController extends GetxController {
  UserModel? currentUser;
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Persons")
          .doc(currentUId)
          .get();

      if (doc.exists && doc.data() != null) {
        currentUser = UserModel.fromMap(doc.data()!);
      } else {
        showToastMessage("Error", "User not found", kRed);
      }
    } catch (e) {
      showToastMessage("Error", e.toString(), kRed);
    } finally {
      isLoading = false;
      update();
    }
  }
}

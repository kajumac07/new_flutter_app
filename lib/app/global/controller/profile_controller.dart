// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:new_flutter_app/app/core/constants/constdata.dart';
// import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
// import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
// import 'package:new_flutter_app/app/global/models/user_model.dart';

// class ProfileController extends GetxController {
//   UserModel? currentUser;
//   bool isLoading = true;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchUserProfile();
//   }

//   Future<void> fetchUserProfile() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection("Persons")
//           .doc(currentUId)
//           .get();

//       if (doc.exists && doc.data() != null) {
//         currentUser = UserModel.fromMap(doc.data()!);
//       } else {
//         showToastMessage("Error", "User not found", kRed);
//       }
//     } catch (e) {
//       showToastMessage("Error", e.toString(), kRed);
//     } finally {
//       isLoading = false;
//       update();
//     }
//   }
// }

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';

class ProfileController extends GetxController {
  UserModel? currentUser;
  bool isLoading = true;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupUserListener();
    fetchUserProfile();
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }

  void _setupUserListener() {
    _userSubscription = FirebaseFirestore.instance
        .collection("Persons")
        .doc(currentUId)
        .snapshots()
        .listen(
          (docSnapshot) {
            if (docSnapshot.exists && docSnapshot.data() != null) {
              currentUser = UserModel.fromMap(docSnapshot.data()!);
              update(); // This will rebuild the GetBuilder
            }
          },
          onError: (error) {
            showToastMessage("Error", error.toString(), kRed);
          },
        );
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
      setState(() => isLoading = false);
    }
  }

  void setState(VoidCallback fn) {
    fn();
    update();
  }
}

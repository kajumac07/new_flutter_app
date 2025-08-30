import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CommunityController extends GetxController {
  RxInt memberCount = 0.obs;
  RxInt onlineCount = 0.obs;
  RxBool isMember = false.obs;

  final String currentUserId;
  CommunityController(this.currentUserId);

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

  @override
  void onInit() {
    super.onInit();
    checkMembership();
  }
}

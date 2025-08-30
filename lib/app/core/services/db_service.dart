import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  String? uid;

  DatabaseServices({required this.uid});

  //===============reference from user collection====================

  final fireStoreDatabase = FirebaseFirestore.instance.collection("Persons");

  //save user data to firebase

  Future savingUserData(
    String userName,
    String fullName,
    String bio,
    String currentAddress,
    String emailAddress,
  ) async {
    return fireStoreDatabase.doc(uid!).set({
      "isAdmin": false,
      "isActive": true,
      "status": true,
      "uid": uid,
      "fullName": fullName,
      "userName": userName,
      "bio": bio,
      "isCommunityMember": false,
      "currentAddress": currentAddress,
      "emailAddress": emailAddress,
      "profilePicture":
          "https://firebasestorage.googleapis.com/v0/b/rabbit-service-d3d90.appspot.com/o/profile.png?alt=media&token=43b149e9-b4ee-458f-8271-5946b77ff658",
      "posts": [],
      "stories": [],
      "followers": [],
      "following": [],
      "isOnline": true,
      "created_at": DateTime.now(),
      "updated_at": DateTime.now(),
    });
  }
}

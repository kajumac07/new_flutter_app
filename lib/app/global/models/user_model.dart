import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String userName;
  final String bio;
  final String currentAddress;
  final String emailAddress;
  final String profilePicture;
  final bool isAdmin;
  final bool isActive;
  final bool status;
  final bool isOnline;
  final List<dynamic> posts;
  final List<dynamic> stories;
  final List<dynamic> followers;
  final List<dynamic> following;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.userName,
    required this.bio,
    required this.currentAddress,
    required this.emailAddress,
    required this.profilePicture,
    required this.isAdmin,
    required this.isActive,
    required this.status,
    required this.isOnline,
    required this.posts,
    required this.stories,
    required this.followers,
    required this.following,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? '',
      userName: data['userName'] ?? '',
      bio: data['bio'] ?? '',
      currentAddress: data['currentAddress'] ?? '',
      emailAddress: data['emailAddress'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      isActive: data['isActive'] ?? true,
      status: data['status'] ?? true,
      isOnline: data['isOnline'] ?? false,
      posts: List.from(data['posts'] ?? []),
      stories: List.from(data['stories'] ?? []),
      followers: List.from(data['followers'] ?? []),
      following: List.from(data['following'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'userName': userName,
      'bio': bio,
      'currentAddress': currentAddress,
      'emailAddress': emailAddress,
      'profilePicture': profilePicture,
      'isAdmin': isAdmin,
      'isActive': isActive,
      'status': status,
      'isOnline': isOnline,
      'posts': posts,
      'stories': stories,
      'followers': followers,
      'following': following,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}

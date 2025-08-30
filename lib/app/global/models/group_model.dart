import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String groupName;
  final String creatorId;
  final String groupDescription;
  final String groupPicture;
  final List<String> members;
  final List<String> pendingInvites;
  final Timestamp createdAt;

  GroupModel({
    required this.id,
    required this.groupName,
    required this.creatorId,
    required this.groupDescription,
    required this.groupPicture,
    required this.members,
    required this.pendingInvites,
    required this.createdAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> data, String id) {
    return GroupModel(
      id: id,
      groupName: data['groupName'] ?? '',
      creatorId: data['creatorId'] ?? '',
      groupDescription: data['groupDescription'] ?? "",
      groupPicture: data['groupPicture'] ?? "",
      members: List<String>.from(data['members'] ?? []),
      pendingInvites: List<String>.from(data['pendingInvites'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupName': groupName,
      'creatorId': creatorId,
      'groupDescription': groupDescription,
      'groupPicture': groupPicture,
      'members': members,
      'pendingInvites': pendingInvites,
      'createdAt': createdAt,
    };
  }
}

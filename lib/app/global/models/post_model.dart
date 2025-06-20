import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String uid;
  final String postId;
  final String title;
  final String description;
  final List<String> media;
  final List<String> category;
  final String location;
  final bool isPublic;
  final bool allowComments;
  final List<String> tags;
  final Timestamp? createdAt;
  final List<String> likes;
  final List<Map<String, dynamic>> comments; // Changed to Map
  final DateTime scheduledAt;
  final String status;

  PostModel({
    required this.uid,
    required this.postId,
    required this.title,
    required this.description,
    required this.media,
    required this.category,
    required this.location,
    required this.isPublic,
    required this.allowComments,
    required this.tags,
    this.createdAt,
    required this.likes,
    required this.comments, // Changed to Map
    required this.scheduledAt,
    required this.status,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      uid: map['uid'] ?? '',
      postId: map['postId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      media: List<String>.from(map['media'] ?? []),
      category: List<String>.from(map['category'] ?? []),
      location: map['location'] ?? '',
      isPublic: map['isPublic'] ?? true,
      allowComments: map['allowComments'] ?? true,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: map['created_at'],
      likes: List<String>.from(map['likes'] ?? []),
      comments: List<Map<String, dynamic>>.from(
        map['comments'] ?? [],
      ), // Changed to Map
      scheduledAt:
          (map['scheduled_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'published',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'postId': postId,
      'title': title,
      'description': description,
      'media': media,
      'category': category,
      'location': location,
      'isPublic': isPublic,
      'allowComments': allowComments,
      'tags': tags,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'likes': likes,
      'comments': comments, // Changed to Map
      'scheduled_at': Timestamp.fromDate(scheduledAt),
      'status': status,
    };
  }
}

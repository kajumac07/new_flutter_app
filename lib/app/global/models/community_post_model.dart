// models/community_post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  String id;
  String userId;
  String title;
  String content;
  List<String> images;
  String category;
  String categoryId;
  int likes;
  int comments;
  int views;
  DateTime createdAt;
  bool isTrending;
  String? emoji;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.images = const [],
    required this.category,
    required this.categoryId,
    this.likes = 0,
    this.comments = 0,
    this.views = 0,
    required this.createdAt,
    this.isTrending = false,
    this.emoji,
  });

  factory CommunityPost.fromMap(Map<String, dynamic> map, String id) {
    return CommunityPost(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? 'General',
      categoryId: map['categoryId'] ?? '', // Add this
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      views: map['views'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isTrending: map['isTrending'] ?? false,
      emoji: map['emoji'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'images': images,
      'category': category,
      'categoryId': categoryId,
      'likes': likes,
      'comments': comments,
      'views': views,
      'createdAt': Timestamp.fromDate(createdAt),
      'isTrending': isTrending,
      'emoji': emoji,
    };
  }
}

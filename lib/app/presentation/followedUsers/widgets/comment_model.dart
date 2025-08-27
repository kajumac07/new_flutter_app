// app/global/models/comment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String userId;
  final String userName;
  final String text;
  final Timestamp timestamp;

  Comment({
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': timestamp,
    };
  }
}

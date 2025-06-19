import 'package:cloud_firestore/cloud_firestore.dart';

class TravelStoryModel {
  final String sId;
  final String uid;
  final String title;
  final String summary;
  final String fullStory;
  final List<String> locations;
  final Budget budget;
  final Stay stay;
  final List<String> thingsToDo;
  final List<String> media;
  final String category;
  final List<String> tags;
  final Timestamp startDate;
  final Timestamp endDate;
  final Ratings ratings;
  final String travelTips;
  final List<String> likes;
  final List<String> comments;
  final bool isComentable;
  final bool isPublic;
  final bool isFeatured;
  final bool isShared;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  TravelStoryModel({
    required this.sId,
    required this.uid,
    required this.title,
    required this.summary,
    required this.fullStory,
    required this.locations,
    required this.budget,
    required this.stay,
    required this.thingsToDo,
    required this.media,
    required this.category,
    required this.tags,
    required this.startDate,
    required this.endDate,
    required this.ratings,
    required this.travelTips,
    required this.likes,
    required this.comments,
    required this.isComentable,
    required this.isPublic,
    required this.isFeatured,
    required this.isShared,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TravelStoryModel.fromMap(Map<String, dynamic> map) {
    return TravelStoryModel(
      sId: map['sId'] ?? '',
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      fullStory: map['fullStory'] ?? '',
      locations: List<String>.from(map['locations'] ?? []),
      budget: Budget.fromMap(map['budget']),
      stay: Stay.fromMap(map['stay']),
      thingsToDo: List<String>.from(map['thingsToDo'] ?? []),
      media: List<String>.from(map['media'] ?? []),
      category: map['category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      startDate: map['startDate'] ?? Timestamp.now(),
      endDate: map['endDate'] ?? Timestamp.now(),
      ratings: Ratings.fromMap(map['ratings']),
      travelTips: map['travelTips'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      comments: List<String>.from(map['comments'] ?? []),
      isComentable: map['isComentable'] ?? true,
      isPublic: map['isPublic'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      isShared: map['isShared'] ?? true,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sId': sId,
      'uid': uid,
      'title': title,
      'summary': summary,
      'fullStory': fullStory,
      'locations': locations,
      'budget': budget.toMap(),
      'stay': stay.toMap(),
      'thingsToDo': thingsToDo,
      'media': media,
      'category': category,
      'tags': tags,
      'startDate': startDate,
      'endDate': endDate,
      'ratings': ratings.toMap(),
      'travelTips': travelTips,
      'likes': likes,
      'comments': comments,
      'isComentable': isComentable,
      'isPublic': isPublic,
      'isFeatured': isFeatured,
      'isShared': isShared,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Budget {
  final int accommodation;
  final int food;
  final int transport;
  final int activities;
  final int total;

  Budget({
    required this.accommodation,
    required this.food,
    required this.transport,
    required this.activities,
    required this.total,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      accommodation: map['accommodation'] ?? 0,
      food: map['food'] ?? 0,
      transport: map['transport'] ?? 0,
      activities: map['activities'] ?? 0,
      total: map['total'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accommodation': accommodation,
      'food': food,
      'transport': transport,
      'activities': activities,
      'total': total,
    };
  }
}

class Stay {
  final String name;
  final String review;

  Stay({required this.name, required this.review});

  factory Stay.fromMap(Map<String, dynamic> map) {
    return Stay(name: map['name'] ?? '', review: map['review'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'review': review};
  }
}

class Ratings {
  final double tripExperience;
  final double budgetFriendliness;
  final double safety;

  Ratings({
    required this.tripExperience,
    required this.budgetFriendliness,
    required this.safety,
  });

  factory Ratings.fromMap(Map<String, dynamic> map) {
    return Ratings(
      tripExperience: (map['tripExperience'] ?? 0).toDouble(),
      budgetFriendliness: (map['budgetFriendliness'] ?? 0).toDouble(),
      safety: (map['safety'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripExperience': tripExperience,
      'budgetFriendliness': budgetFriendliness,
      'safety': safety,
    };
  }
}

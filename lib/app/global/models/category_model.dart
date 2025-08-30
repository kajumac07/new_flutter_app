class CategoryModel {
  final String id;
  final List<CategoryItem> lists;

  CategoryModel({required this.id, required this.lists});

  factory CategoryModel.fromDoc(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      lists: (data['lists'] as List<dynamic>)
          .map((e) => CategoryItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategoryItem {
  final String id;
  final String emoji;
  final String label;
  final bool isCommunity;

  CategoryItem({
    required this.id,
    required this.emoji,
    required this.label,
    required this.isCommunity,
  });

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'],
      emoji: map['emoji'] ?? '',
      label: map['label'] ?? '',
      isCommunity: map['isCommunity'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emoji': emoji,
      'label': label,
      'isCommunity': isCommunity,
    };
  }
}

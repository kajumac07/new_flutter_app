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
  final String emoji;
  final String label;

  CategoryItem({required this.emoji, required this.label});

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(emoji: map['emoji'] ?? '', label: map['label'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'emoji': emoji, 'label': label};
  }
}

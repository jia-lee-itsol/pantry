class Category {
  final String id;
  final String name;
  final String iconName; // IconData를 문자열로 저장
  final int order; // 정렬 순서
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    this.order = 0,
    required this.createdAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    int? order,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

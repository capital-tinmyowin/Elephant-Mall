class Category {
  final int categoryId;
  final String categoryName;
  final String photoPath;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.photoPath,
  });

  factory Category.fromJson(
    Map<String, dynamic> json,
  ) {
    return Category(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      photoPath: json['photoPath'] ?? '',
    );
  }
}
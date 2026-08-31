class Category {
  final int categoryId;
  final String categoryName;
  final String photoPath;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.photoPath,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // 🔥 Get image from multiple possible fields
    String imagePath = json['categoryImageUrl'] ?? 
                       json['photoPath'] ?? 
                       json['imageUrl'] ?? 
                       json['icon'] ?? 
                       '';
    
    if (imagePath.isEmpty) {
      imagePath = 'assets/images/placeholders/category_placeholder.jpg';
    }
    
    return Category(
      categoryId: json['id'] ?? json['categoryId'] ?? 0,
      categoryName: json['name'] ?? json['categoryName'] ?? '',
      photoPath: imagePath,
    );
  }

  // For mock data
  factory Category.fromMockJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      photoPath: json['photoPath'] ?? '',
    );
  }
}
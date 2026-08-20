class NewInModel {
  final int id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final int reviewCount;
  final String imagePath;
  final bool isNew;

  NewInModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imagePath,
    this.isNew = true,
  });
}
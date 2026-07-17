class BannerModel {
  final int bannerId;
  final String title;
  final String description;
  final String imagePath;
  final String? link;
  final int sortOrder;
  final bool isActive;

  BannerModel({
    required this.bannerId,
    required this.title,
    required this.description,
    required this.imagePath,
    this.link,
    required this.sortOrder,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      bannerId: json["bannerId"],
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      imagePath: json["imagePath"] ?? "",
      link: json["link"],
      sortOrder: json["sortOrder"] ?? 0,
      isActive: json["isActive"] ?? true,
    );
  }

  @override
  String toString() {
    return 'BannerModel(id:$bannerId, title:$title, image:$imagePath,desc: $description)';
  }
}

class Product {
  final int productId;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final int quantity;
  final double rating;
  final int categoryId;
  final bool isActive;

  Product({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.quantity,
    required this.rating,
    required this.categoryId,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json["productId"],
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      price: (json["price"] as num).toDouble(),
      imagePath: json["imagePath"] ?? "",
      quantity: json["quantity"] ?? 0,
      rating: (json["rating"] as num).toDouble(),
      categoryId: json["categoryId"] ?? 0,
      isActive: json["isActive"] ?? true,
    );
  }

  @override
  String toString() {
    return 'Product(id:$productId, name:$name, image:$imagePath,rating:$rating)';
  }
}

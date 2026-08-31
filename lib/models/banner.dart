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
  final int productCode;
  final String productName;
  final String description;
  final double price;
  final String imagePath; 
  final double rating;
  final int categoryId;
  final bool isActive;

  Product({
    required this.productCode,
    required this.productName,
    required this.description,
    required this.price,
    required this.imagePath,   
    required this.rating,
    required this.categoryId,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productCode: json["productCode"],
      productName: json["productName"] ?? "",
      description: json["description"] ?? "",
      price: (json["price"] as num).toDouble(),
      imagePath: json["imagePath"] ?? "",    
      rating: (json["rating"] as num).toDouble(),
      categoryId: json["categoryId"] ?? 0,
      isActive: json["isActive"] ?? true,
    );
  }

  @override
  String toString() {
    return 'Product(productCode:$productCode, productName:$productName, imagePath:$imagePath,rating:$rating)';
  }
}

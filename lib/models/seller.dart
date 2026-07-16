class Seller {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final double rating;
  final int ratingCount;
  final DateTime joinDate;
  final int productCount;

  Seller({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    this.rating = 0,
    this.ratingCount = 0,
    required this.joinDate,
    this.productCount = 0,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      joinDate: json['joinDate'] != null 
          ? DateTime.parse(json['joinDate']) 
          : DateTime.now(),
      productCount: json['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'ratingCount': ratingCount,
      'joinDate': joinDate.toIso8601String(),
      'productCount': productCount,
    };
  }
}
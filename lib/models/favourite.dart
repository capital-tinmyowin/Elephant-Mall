import 'product.dart';
import 'user.dart';

class Favorite {
  final int id;
  final int userId;
  final int productId;
  final DateTime addedDate;
  final String? note;
  final Product? product;
  final User? user;

  Favorite({
    required this.id,
    required this.userId,
    required this.productId,
    required this.addedDate,
    this.note,
    this.product,
    this.user,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      productId: json['productId'] ?? 0,
      addedDate: json['addedDate'] != null
          ? DateTime.parse(json['addedDate'])
          : DateTime.now(),
      note: json['note'],
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'addedDate': addedDate.toIso8601String(),
      'note': note,
      'product': product?.toJson(),
      'user': user?.toJson(),
    };
  }

}
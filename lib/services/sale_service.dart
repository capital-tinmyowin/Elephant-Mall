import '../models/sale.dart';

class SaleService {
  Future<List<SaleModel>> getSaleProducts() async {

    final List<Map<String, dynamic>> jsonData = [
      {
        "productName": "Men's Sneakers",
        "category": "Shoes",
        "originalPrice": 89.00,
        "salePrice": 71.20,
        "discount": 20,
        "rating": 4.5,
        "reviewCount": 128,
        "imagePath": "assets/man-sneaker.png",
        "isNew": false,
      },
      {
        "productName": "Women's Wristwatch",
        "category": "Accessories",
        "originalPrice": 65.00,
        "salePrice": 42.25,
        "discount": 35,
        "rating": 4.5,
        "reviewCount": 86,
        "imagePath": "assets/woman-watch.png",
        "isNew": false,
      },
      {
        "productName": "Leather Backpack",
        "category": "Bags",
        "originalPrice": 110.00,
        "salePrice": 82.50,
        "discount": 25,
        "rating": 4.5,
        "reviewCount": 74,
        "imagePath": "assets/leatherbackpack.jpg",
        "isNew": false,
      },
      {
        "productName": "Linen Shirt (New Item)",
        "category": "Clothing",
        "originalPrice": 45.00,
        "salePrice": 31.50,
        "discount": 30,
        "rating": 4.5,
        "reviewCount": 52,
        "imagePath": "assets/linenshirt.jpg",
        "isNew": true,
      },
      {
        "productName": "Straw Hat (New Item)",
        "category": "Accessories",
        "originalPrice": 25.00,
        "salePrice": 18.00,
        "discount": 28,
        "rating": 4.5,
        "reviewCount": 91,
        "imagePath": "assets/strawhat.png",
        "isNew": true,
      },
      {
        "productName": "Women's Blouse",
        "category": "Clothing",
        "originalPrice": 39.00,
        "salePrice": 31.20,
        "discount": 20,
        "rating": 4.5,
        "reviewCount": 63,
        "imagePath": "assets/cottonblouse.jpg",
        "isNew": false,
      },
      {
        "productName": "Ladies Handbag",
        "category": "Bags",
        "originalPrice": 75.00,
        "salePrice": 56.25,
        "discount": 25,
        "rating": 4.5,
        "reviewCount": 84,
        "imagePath": "assets/bag.jpg",
        "isNew": false,
      },
      {
        "productName": "Women's Sandals",
        "category": "Shoes",
        "originalPrice": 49.00,
        "salePrice": 34.30,
        "discount": 30,
        "rating": 4.5,
        "reviewCount": 47,
        "imagePath": "assets/leatherscandal.jpg",
        "isNew": false,
      },
      {
        "productName": "Sunglasses",
        "category": "Accessories",
        "originalPrice": 35.00,
        "salePrice": 24.50,
        "discount": 30,
        "rating": 4.5,
        "reviewCount": 115,
        "imagePath": "assets/sunglass.jpg",
        "isNew": false,
      },
      {
        "productName": "Heart Necklace",
        "category": "Jewelry",
        "originalPrice": 30.00,
        "salePrice": 18.00,
        "discount": 40,
        "rating": 4.5,
        "reviewCount": 72,
        "imagePath": "assets/necklace.jpg",
        "isNew": false,
      },
    ];

    await Future.delayed(const Duration(milliseconds: 300));

    return jsonData
        .map((json) => SaleModel.fromJson(json))
        .toList();
  }
}
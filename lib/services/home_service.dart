// import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../models/Category.dart';
import '../models/banner.dart';
import '../models/promo.dart';

// class HomeService {
//   static const String baseUrl = "http://localhost:5086/api";

//   final http.Client client = http.Client();

//   Future<List<BannerModel>> getBanners() async {
//     final response = await client.get(
//       Uri.parse("$baseUrl/Banners/GetBannerList"),
//     );
//     if (response.statusCode == 200) {
//       final List jsonData = jsonDecode(response.body);
//       return jsonData.map((e) => BannerModel.fromJson(e)).toList();
//     }
//     throw Exception("Failed to load banners");
//   }

//   Future<List<Category>> getCategories() async {
//     final response = await client.get(
//       Uri.parse("$baseUrl/Categories/GetCategoryList"),
//     );

//     if (response.statusCode == 200) {
//       final List jsonData = jsonDecode(response.body);

//       return jsonData.map((e) => Category.fromJson(e)).toList();
//     }

//     throw Exception("Failed to load categories");
//   }

//   Future<List<Product>> getProducts() async {
//     final response = await client.get(
//       Uri.parse("$baseUrl/Products/GetProductList"),
//     );
//     if (response.statusCode == 200) {
//       final List jsonData = jsonDecode(response.body);
//       return jsonData.map((e) => Product.fromJson(e)).toList();
//     }
//     throw Exception("Failed to load products");
//   }

//   Future<List<Promo>> getPromos() async {
//     final response = await client.get(
//       Uri.parse("$baseUrl/Promos/GetPromoList"),
//     );
//     if (response.statusCode == 200) {
//       final List jsonData = jsonDecode(response.body);
//       return jsonData.map((e) => Promo.fromJson(e)).toList();
//     }
//     throw Exception("Failed to load promos");
//   }
// }
class HomeService {
  Future<List<BannerModel>> getBanners() async {
    final List jsonData = [
      {
        "bannerId":1,
        "title":"YANGON SUMMER HEATWAVE SAVINGS!",
        "description":"Cool styles for Yangon’s hottest days.",
        "imagePath":"assets/promotion-banner.png",
        "link":"/sale",
        "sortOrder":1,
        "isActive":true
      },
      {
        "bannerId":2,
        "title":"NEW ARRIVALS",
        "description":"Discover latest fashion trends.",
        "imagePath":"assets/promotion-banner2.png",
        "link":"/products/new",
        "sortOrder":2,
        "isActive":true
      },
      {
        "bannerId":3,
        "title":"BIG SALE 50% OFF",
        "description":"Don’t miss the best deals.",
        "imagePath":"assets/promotion-banner.png",
        "link":"/promotion",
        "sortOrder":3,
        "isActive":true
      },
      {
        "bannerId":4,
        "title":"NEW ARRIVALS",
        "description":"Discover latest fashion trends.",
        "imagePath":"assets/promotion-banner2.png",
        "link":"/products/new",
        "sortOrder":2,
        "isActive":true
      },

    ];
    return jsonData
        .map((e)=>BannerModel.fromJson(e))
        .toList();
  }
  Future<List<Category>> getCategories() async {
    final List jsonData = [
      {
        "categoryId":1,
        "categoryName":"T-Shirts",
        "photoPath":"assets/tshirt.png",
        "sortOrder":1,
        "isActive":true
      },
      {
        "categoryId":2,
        "categoryName":"Blouses",
        "photoPath":"assets/blouse.png",
        "sortOrder":2,
        "isActive":true
      },
      {
        "categoryId":3,
        "categoryName":"Bags",
        "photoPath":"assets/bag.png",
        "sortOrder":3,
        "isActive":true
      },
      {
        "categoryId":4,
        "categoryName":"Shoes",
        "photoPath":"assets/shoe.png",
        "sortOrder":4,
        "isActive":true
      },
       {
        "categoryId":5,
        "categoryName":"T-Shirts",
        "photoPath":"assets/tshirt.png",
        "sortOrder":1,
        "isActive":true
      },
      {
        "categoryId":6,
        "categoryName":"Blouses",
        "photoPath":"assets/blouse.png",
        "sortOrder":2,
        "isActive":true
      },
      {
        "categoryId":7,
        "categoryName":"Bags",
        "photoPath":"assets/bag.png",
        "sortOrder":3,
        "isActive":true
      },
      {
        "categoryId":8,
        "categoryName":"Shoes",
        "photoPath":"assets/shoe.png",
        "sortOrder":4,
        "isActive":true
      },
       {
        "categoryId":9,
        "categoryName":"T-Shirts",
        "photoPath":"assets/tshirt.png",
        "sortOrder":1,
        "isActive":true
      },
      {
        "categoryId":10,
        "categoryName":"Blouses",
        "photoPath":"assets/blouse.png",
        "sortOrder":2,
        "isActive":true
      },
      {
        "categoryId":11,
        "categoryName":"Bags",
        "photoPath":"assets/bag.png",
        "sortOrder":3,
        "isActive":true
      },
      {
        "categoryId":12,
        "categoryName":"Shoes",
        "photoPath":"assets/shoe.png",
        "sortOrder":4,
        "isActive":true
      }
    ];

    return jsonData
        .map((e)=>Category.fromJson(e))
        .toList();
  }
  Future<List<Product>> getProducts() async {
    final List jsonData=[
      {
        "productId":1,
        "name":"Men's Sneakers",
        "description":"Comfort shoes",
        "price":89,
        "imagePath":"assets/man-sneaker.png",
        "quantity":20,
        "rating":5
      },
      {
        "productId":2,
        "name":"Women's Wristwatch",
        "description":"Luxury watch",
        "price":65,
        "imagePath":"assets/woman-watch.png",
        "quantity":10,
        "rating":4
      },
      {
        "productId":3,
        "name":"Leather Backpack",
        "description":"Travel bag",
        "price":110,
        "imagePath":"assets/bagpack.jpg",
        "quantity":15,
        "rating":3
      },
      {
        "productId":4,
        "name":"Linen Shirt",
        "description":"Fashion shirt",
        "price":45,
        "imagePath":"assets/linen.webp",
        "quantity":30,
        "rating":2
      },
       {
        "productId":5,
        "name":"Men's Sneakers",
        "description":"Comfort shoes",
        "price":89,
        "imagePath":"assets/man-sneaker.png",
        "quantity":20,
        "rating":1
      },
      {
        "productId":6,
        "name":"Women's Wristwatch",
        "description":"Luxury watch",
        "price":65,
        "imagePath":"assets/woman-watch.png",
        "quantity":10,
        "rating":0
      },
      {
        "productId":7,
        "name":"Leather Backpack",
        "description":"Travel bag",
        "price":110,
        "imagePath":"assets/bagpack.jpg",
        "quantity":15,
        "rating":5
      },
      {
        "productId":8,
        "name":"Linen Shirt",
        "description":"Fashion shirt",
        "price":45,
        "imagePath":"assets/linen.webp",
        "quantity":30,
        "rating":4
      },
      {
        "productId":9,
        "name":"Men's Sneakers",
        "description":"Comfort shoes",
        "price":89,
        "imagePath":"assets/man-sneaker.png",
        "quantity":20,
        "rating":5
      },
      {
        "productId":10,
        "name":"Women's Wristwatch",
        "description":"Luxury watch",
        "price":65,
        "imagePath":"assets/woman-watch.png",
        "quantity":10,
        "rating":4
      },
      {
        "productId":11,
        "name":"Leather Backpack",
        "description":"Travel bag",
        "price":110,
        "imagePath":"assets/bagpack.jpg",
        "quantity":15,
        "rating":5
      },
      {
        "productId":12,
        "name":"Linen Shirt",
        "description":"Fashion shirt",
        "price":45,
        "imagePath":"assets/linen.webp",
        "quantity":30,
        "rating":4
      }
    ];
    return jsonData
        .map((e)=>Product.fromJson(e))
        .toList();
  }
  Future<List<Promo>> getPromos() async {
    final List jsonData=[
      {
        "promoId":1,
        "title":"Summer Sale 50% OFF",
        "imagePath":"assets/promotion-banner.png",
        "link":"/sale",
        "sortOrder":1,
        "isActive":true
      },
      {
        "promoId":2,
        "title":"New Fashion Collection",
        "imagePath":"assets/promotion-banner2.png",
        "link":"/products/new",
        "sortOrder":2,
        "isActive":true
      }
    ];
    return jsonData
        .map((e)=>Promo.fromJson(e))
        .toList();
  }
}

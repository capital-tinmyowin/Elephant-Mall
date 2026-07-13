import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Category.dart';
import 'dart:typed_data';

class ProductService {
  Future<bool> createProduct({
    required String title,
    required String description,
    required String price,
    required String sku,
    required String quantity,
    required String phoneNumber,
    required String messengerLink,
    required String telegram,
    required String viber,
    required List<Uint8List?> images,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:7138/api/Products/Create'),
    );

    request.fields['Title'] = title;
    request.fields['Description'] = description;
    request.fields['Price'] = price;
    request.fields['SKU'] = sku;
    request.fields['Quantity'] = quantity;
    request.fields['PhoneNumber'] = phoneNumber;
    request.fields['MessengerLink'] = messengerLink;
    request.fields['Telegram'] = telegram;
    request.fields['Viber'] = viber;

    int index = 0;

    for (var image in images) {
      if (image != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'Images', // must match API property name
            image,
            filename: 'image_$index.jpg',
          ),
        );

        index++;
      }
    }

    var response = await request.send();

    return response.statusCode == 200;
  }

  Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse('http://localhost:7138/api/Products/getCategory'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((e) => Category.fromJson(e)).toList();
    }

    throw Exception('Failed to load categories');
  }
}

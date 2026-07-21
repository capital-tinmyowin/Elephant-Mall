import 'package:elephant_mall/view/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/Category_service.dart';
import 'view/category_page.dart';
import 'view/product_detail_page.dart';
import 'view/sell.dart';
import 'view/login.dart';
import 'view/seller.dart';

void main() {
  final apiService = ApiService();

  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/seller': (context) => const SellerPage(),
      },
    );
  }
}

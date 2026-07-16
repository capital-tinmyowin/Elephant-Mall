import 'package:flutter/material.dart';
import 'view/sell.dart';
import 'view/login.dart';
import 'view/seller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: LoginPage(),
      home: SellPage(),
      // home: SellerPage(),
    );
  }
}
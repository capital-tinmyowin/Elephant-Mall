import 'package:elephant_mall/services/auth_service.dart';
import 'package:elephant_mall/view/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/Category_service.dart';
import 'view/category_page.dart';
import 'view/product_detail_page.dart';
import 'view/sell.dart';
import 'view/login.dart';
import 'view/seller.dart';
import 'view/signup.dart';
import 'view/new_in.dart';
void main() {
  final apiService = ApiService();

  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🔥 ADD THIS - AuthService at root level
        ChangeNotifierProvider(create: (_) => AuthService()),

        // Keep existing providers
        ChangeNotifierProvider.value(value: apiService),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'NotoSansMyanmar', 
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 15),
            bodyMedium: TextStyle(fontSize: 15),
            bodySmall: TextStyle(fontSize: 15),

            titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

            titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),

            labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const NewInPage(),
          '/seller': (context) => const SellerPage(),
        },
      ),
    );
  }
}

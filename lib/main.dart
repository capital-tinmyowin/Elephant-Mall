import 'package:elephant_mall/services/auth_service.dart';
import 'package:elephant_mall/view/category_detail.dart';
import 'package:elephant_mall/view/favourite_page.dart';
import 'package:elephant_mall/view/home.dart';
import 'package:elephant_mall/view/profile.dart';
import 'package:elephant_mall/view/sale.dart';
import 'package:elephant_mall/view/sellerpage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'services/Category_service.dart';
import 'view/category_page.dart';
import 'view/product_detail_page.dart';
import 'view/sell.dart';
import 'view/login.dart';
import 'view/seller.dart';
import 'view/signup.dart';
import 'view/new_in.dart';
import 'services/product_service.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final auth = AuthService();
  await auth.restoreSession();
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: apiService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize GoRouter
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/favourites',
          builder: (context, state) => const MyFavouritePage(),
        ),
        GoRoute(
          path: '/sell',
          builder: (context, state) => const SellPage(),
        ),
        GoRoute(
          path: '/category',
          builder: (context, state) => const CategoryPage(),
        ),
        GoRoute(
          path: '/sale',
          builder: (context, state) => const SalePage(),
        ),
        GoRoute(
          path: '/new-in',
          builder: (context, state) => const NewInPage(),
        ),
        
        // Product Detail (e.g. /product/123)
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final productId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return ProductDetailPage(productId: productId);
          },
        ),
        GoRoute(
          path: '/seller',
          builder: (context, state) => const SellerPage(),
        ),

        // Category Detail (e.g. /category/5?name=T-Shirts)
        GoRoute(
          path: '/category/:id',
          builder: (context, state) {
            final categoryId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            final categoryName = state.uri.queryParameters['name'] ?? 'Category';
            return CategoryDetailPage(
              categoryId: categoryId,
              categoryName: categoryName,
            );
          },
        ),

        // Seller Store (e.g. /seller-store/123?name=John)
        GoRoute(
          path: '/seller-store/:id',
          builder: (context, state) {
            final sellerId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            final sellerName = state.uri.queryParameters['name'] ?? '';
            return SellerStorePage(sellerId: sellerId, sellerName: sellerName);
          },
        ),
      ],
    );

    return MaterialApp.router(
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
      routerConfig: router,
    );
  }
}

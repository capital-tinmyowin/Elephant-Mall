import 'package:elephant_mall/services/auth_service.dart';
import 'package:elephant_mall/view/category_detail.dart';
import 'package:elephant_mall/view/favourite_page.dart';
import 'package:elephant_mall/view/home.dart';
import 'package:elephant_mall/view/myListing.dart';
import 'package:elephant_mall/view/profile.dart';
import 'package:elephant_mall/view/sale.dart';
import 'package:elephant_mall/view/sellerListing.dart';
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
          pageBuilder: (context, state) => NoTransitionPage(child: const HomePage()),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => NoTransitionPage(child: const LoginPage()),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (context, state) => NoTransitionPage(child: const RegisterPage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => NoTransitionPage(child: const ProfilePage()),
        ),
        GoRoute(
          path: '/favourites',
          pageBuilder: (context, state) => NoTransitionPage(child: const MyFavouritePage()),
        ),
        GoRoute(
          path: '/sell',
          pageBuilder: (context, state) => NoTransitionPage(child: const SellPage()),
        ),
        GoRoute(
          path: '/sell/:id',
          pageBuilder: (context, state) {
            final productId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return NoTransitionPage(child: SellPage(productId: productId));
          },
        ),
        GoRoute(
          path: '/category',
          pageBuilder: (context, state) => NoTransitionPage(child: const CategoryPage()),
        ),
        GoRoute(
          path: '/sale',
          pageBuilder: (context, state) => NoTransitionPage(child: const SalePage()),
        ),
        GoRoute(
          path: '/new-in',
          pageBuilder: (context, state) => NoTransitionPage(child: const NewInPage()),
        ),
        
        // Product Detail (e.g. /product/123)
        GoRoute(
          path: '/product/:id',
          pageBuilder: (context, state) {
            final productId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return NoTransitionPage(child: ProductDetailPage(productId: productId));
          },
        ),
        GoRoute(
          path: '/seller/:id',
          pageBuilder: (context, state) {
            final sellerId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            final sellerName = state.uri.queryParameters['name'] ?? '';
            return NoTransitionPage(child: SellerListingPage(sellerId: sellerId, sellerName: sellerName));
          },
        ),

        // Category Detail (e.g. /category/5?name=T-Shirts)
        GoRoute(
          path: '/category/:id',
          pageBuilder: (context, state) {
            final categoryId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            final categoryName = state.uri.queryParameters['name'] ?? 'Category';
            return NoTransitionPage(
              child: CategoryDetailPage(
                categoryId: categoryId,
                categoryName: categoryName,
              ),
            );
          },
        ),

        // Seller Store (e.g. /seller-store/123?name=John)
        GoRoute(
          path: '/my-store/:id',
          pageBuilder: (context, state) {
            final sellerId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            final sellerName = state.uri.queryParameters['name'] ?? '';
            return NoTransitionPage(child: SellerStorePage(sellerId: sellerId, sellerName: sellerName));
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

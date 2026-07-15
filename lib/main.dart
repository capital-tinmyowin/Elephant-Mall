import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/Category_service.dart';
import 'view/category_page.dart';
import 'view/product_detail_page.dart';
import 'view/sell.dart';
import 'view/login.dart';


void main() {
  final apiService = ApiService();
  
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
 final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  // @override
  // Widget build(BuildContext context) {
  //   return const MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     // home: LoginPage(),
  //     home: SellPage(),
  //   );
  // }
  
@override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: apiService,
      child: MaterialApp(
        title: 'Elephant Mall',
        theme: ThemeData(
          primarySwatch: Colors.green,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: const Color(0xFF2B6E3B),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const MainScreen(initialIndex: 0),
          '/home': (context) => const MainScreen(initialIndex: 0),
          '/categories': (context) => const MainScreen(initialIndex: 0),
          '/sell': (context) => const MainScreen(initialIndex: 1),
          '/favorite': (context) => const MainScreen(initialIndex: 3),
          '/profile': (context) => const MainScreen(initialIndex: 4),
        },
        onGenerateRoute: (settings) {
          if (settings.name != null && settings.name!.startsWith('/product/')) {
            final idString = settings.name!.replaceAll('/product/', '');
            final productId = int.tryParse(idString);
            if (productId != null) {
              return MaterialPageRoute(
                builder: (context) => MainScreen(
                  initialIndex: 1,
                  initialProductId: productId,
                ),
              );
            }
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final int? initialProductId;

  const MainScreen({
    super.key, 
    this.initialIndex = 0,
    this.initialProductId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  bool _isDetailView = false;
  int? _detailProductId;

  final List<Widget> _pages = const [
    // HomePage(),
    CategoryPage(),
    SellPage(),
    // MyFavouritePage(),
    // ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    if (widget.initialProductId != null) {
      _isDetailView = true;
      _detailProductId = widget.initialProductId;
    }
  }

  void _goBackFromDetail() {
    setState(() {
      _isDetailView = false;
      _detailProductId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      body: _isDetailView && _detailProductId != null
          ? ProductDetailPage(
              productId: _detailProductId!,
              onBack: _goBackFromDetail,
            )
          : _pages[_currentIndex],
      bottomNavigationBar: isMobile && !_isDetailView
          ? Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, 'Home', 0),
                  _buildNavItem(Icons.category_outlined, 'Categories', 1),
                  _buildSellNavItem(),
                  _buildNavItem(Icons.favorite_border, 'Favorite', 3),
                  _buildNavItem(Icons.person_outline, 'Profile', 4),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _isDetailView = false;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF2B6E3B) : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2B6E3B) : Colors.grey[600],
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellNavItem() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = 2;
          _isDetailView = false;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2B6E3B) : const Color(0xFFD68247),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: isSelected ? Colors.white : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Sell',
            style: TextStyle(
              color: isSelected ? const Color(0xFF2B6E3B) : const Color(0xFFD68247),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
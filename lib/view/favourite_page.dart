import 'package:elephant_mall/models/favourite.dart';
import 'package:elephant_mall/services/Category_service.dart';
import 'package:elephant_mall/view/common/footer.dart';
import 'package:elephant_mall/view/common/header.dart';
import 'package:elephant_mall/view/login.dart';
import 'package:elephant_mall/view/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/auth_service.dart';

class MyFavouritePage extends StatefulWidget {
  const MyFavouritePage({super.key});

  @override
  State<MyFavouritePage> createState() => _MyFavouritePageState();
}

class _MyFavouritePageState extends State<MyFavouritePage> {
  List<Favorite> _favorites = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // 🔥 Generate mock favorites for non-logged in users
  List<Favorite> _getMockFavorites() {
    final mockProducts = _getMockProducts();
    return mockProducts.asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      return Favorite(
        id: index + 1,
        userId: 0,
        productId: product.id,
        addedDate: DateTime.now().subtract(Duration(days: index * 5)),
        product: product,
      );
    }).toList();
  }

  // 🔥 Mock products for favorites
  List<Product> _getMockProducts() {
    return [
      Product(
        id: 101,
        name: 'Premium Leather Tote Bag',
        price: 120.00,
        description: 'Premium leather tote bag with elegant design',
        image: 'https://i1-e.pinimg.com/736x/ba/9c/87/ba9c87fb2c220594e494aaa628c6342b.jpg',
        category: 'Bags',
        rating: 4.8,
        ratingCount: 45,
      ),
      Product(
        id: 102,
        name: 'Elegant Silk Blouse',
        price: 39.99,
        description: 'Beautiful silk blouse perfect for any occasion',
        image: 'https://i1-e.pinimg.com/736x/4c/51/b7/4c51b7e99173c170c5db866a5ccff75e.jpg',
        category: 'Blouses',
        rating: 4.5,
        ratingCount: 32,
      ),
      Product(
        id: 103,
        name: 'Wireless Noise-Cancelling Headphones',
        price: 89.99,
        description: 'Premium wireless headphones with noise cancellation',
        image: 'https://i1-e.pinimg.com/736x/8d/54/5f/8d545f2a363a450f58dfd9c49a03e81b.jpg',
        category: 'Electronics',
        rating: 4.7,
        ratingCount: 28,
      ),
    ];
  }

  Future<void> _loadFavorites() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // 🔥 If not logged in, show mock data
    if (!authService.isLoggedIn) {
      setState(() {
        _favorites = _getMockFavorites();
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      final response = await apiService.getUserFavorites(authService.currentUser!.id);
      
      if (response['success'] == true && response['data'] != null) {
        final List favoritesData = response['data'];
        setState(() {
          _favorites = favoritesData.map((json) => Favorite.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Error loading favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading favorites: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final authService = Provider.of<AuthService>(context);
    final isLoggedIn = authService.isLoggedIn;

    return Scaffold(
      body: Column(
        children: [
          const CommonHeader(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title with login status
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 8, left: 20),
                    child: Row(
                      children: [
                        const Text(
                          'My Favorites',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        if (!isLoggedIn)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Demo Mode',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Favorites List
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _favorites.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite_border,
                                      size: 64,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No favourites yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(context, '/categories');
                                      },
                                      child: const Text(
                                        'Browse Products',
                                        style: TextStyle(
                                          color: Color(0xFFD68247),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : isMobile
                                ? ListView.builder(
                                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                                    itemCount: _favorites.length,
                                    itemBuilder: (context, index) {
                                      final favorite = _favorites[index];
                                      return _buildFavoriteCard(favorite, isLoggedIn);
                                    },
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(top: 16, bottom: 16, left: 60, right: 60),
                                    itemCount: _favorites.length,
                                    itemBuilder: (context, index) {
                                      final favorite = _favorites[index];
                                      return _buildFavoriteCard(favorite, isLoggedIn);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
          if (!isMobile) const CommonFooter(),
        ],
      ),
      bottomNavigationBar: isMobile
          ? const CommonBottomBar(currentIndex: 3)
          : null,
    );
  }

  Widget _buildFavoriteCard(Favorite favorite, bool isLoggedIn) {
    final product = favorite.product;
    if (product == null) return const SizedBox.shrink();

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.proxiedImageUrl,
                height: 120,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 70,
                    width: 70,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 30),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${favorite.id.toString().padLeft(6, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Date
                  Text(
                    _formatDate(favorite.addedDate),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Product Name
                  Text(
                    product.name + ' - \$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(productId: product.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      minimumSize: const Size(80, 28),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // ID and FAVOURITED badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'FAVOURITED',
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFF2B6E3B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
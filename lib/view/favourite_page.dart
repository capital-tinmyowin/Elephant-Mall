import 'package:cached_network_image/cached_network_image.dart';
import 'package:elephant_mall/models/favourite.dart';
import 'package:elephant_mall/services/Category_service.dart';
import 'package:elephant_mall/view/common/footer.dart';
import 'package:elephant_mall/view/common/header.dart';
import 'package:elephant_mall/view/login.dart';
import 'package:elephant_mall/view/product_detail_page.dart';
import 'package:elephant_mall/widgets/app_image.dart';
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
  bool _isGridView = true;
  String _selectedSort = 'Recently Added';
  String _selectedFilter = 'All';
  
  final List<String> _sortOptions = [
    'Recently Added',
    'Price: Low to High',
    'Price: High to Low',
    'Name: A to Z',
  ];
  
  final List<String> _filterOptions = [
    'All',
    'Fashion',
    'Accessories',
    'Newest',
    'Price',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Generate mock favorites for non-logged in users
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

  // Mock products for favorites (unchanged)
  List<Product> _getMockProducts() {
    return [
      Product(
        id: 2,
        name: "OverSize T-Shirt",
        price: 19.99,
        category: "T-Shirts",
        image: "https://i.pinimg.com/1200x/7b/9b/64/7b9b64157c65859e958063af2284b620.jpg",
        rating: 4.8,
        ratingCount: 189,
        seller: Seller(
          id: 1,
          name: "Sarah J.",
          rating: 4.7,
          ratingCount: 234,
          joinDate: DateTime.now(),
        ),
        description: "Crisp white tee, 100% organic cotton. Regular fit.",
        productImages: [
          "https://i.pinimg.com/1200x/dd/67/30/dd6730be42684378f2abd82900072e72.jpg",
          "https://i.pinimg.com/736x/bd/a0/ca/bda0ca23a55ffd326145a2dbb8e139f4.jpg",
          "https://i.pinimg.com/1200x/51/6e/ab/516eab223c22a36d1051ba9bc46f5695.jpg",
        ],
        colors: ['white', 'black', 'brown'],
      ),
      Product(
        id: 4,
        name: "White Blouse",
        price: 39.99,
        category: "Blouses",
        image: "https://i.pinimg.com/1200x/bd/6c/f9/bd6cf9e39bb3ea86086bb1f89c789ee6.jpg",
        rating: 4.9,
        ratingCount: 234,
        seller: Seller(
          id: 1,
          name: "Sarah J.",
          rating: 4.7,
          ratingCount: 234,
          joinDate: DateTime.now(),
        ),
        description: "Luxurious silk blend, perfect for office or brunch.",
        productImages: [
          "https://i.pinimg.com/1200x/d3/db/ae/d3dbaeb17fcee123f3c128fd9e0c1223.jpg",
          "https://i.pinimg.com/736x/14/3f/4a/143f4ab55d79b2b53a9c6a342153bbbf.jpg",
        ],
        colors: ['white', 'flower'],
      ),
      Product(
        id: 6,
        name: 'White Shoulder Bag',
        price: 34.99,
        description: 'Handwoven straw tote, roomy interior. Ideal for beach or market',
        image: 'images/categories/bags/LeatherBag/white.jpg',
        category: 'Bags',
        rating: 4.7,
        ratingCount: 234,
      ),
      Product(
        id: 8,
        name: "Wool Fedora Hat",
        price: 24.99,
        category: "Hats",
        image: "https://i.pinimg.com/736x/4e/81/11/4e8111d7aea3eeb01500a1f6ad88cdae.jpg",
        rating: 4.7,
        ratingCount: 123,
        seller: Seller(
          id: 2,
          name: "Sunny Days",
          rating: 4.7,
          ratingCount: 234,
          joinDate: DateTime.now(),
        ),
        description: "Classic fedora, UV protection, adjustable inner band.",
        productImages: [
          "https://i.pinimg.com/736x/e5/a5/21/e5a5215a1fbf1f5cdacb7b19aac0c691.jpg",
        ],
        colors: ['gray', 'black'],
      ),
      Product(
        id: 10,
        name: "Running Shoes",
        price: 49.99,
        category: "Shoes",
        image: "https://i.pinimg.com/736x/71/4f/a1/714fa1434d9f007388ddf0da7be76873.jpg",
        rating: 4.8,
        ratingCount: 567,
        seller: Seller(
          id: 2,
          name: "Sunny Days",
          rating: 4.7,
          ratingCount: 234,
          joinDate: DateTime.now(),
        ),
        description: "Comfortable footbed, leather straps. True to size.",
        productImages: [
          "https://i.pinimg.com/1200x/78/72/65/787265628f6bed641d4fd4e4e08565ae.jpg",
          "https://i.pinimg.com/736x/71/b3/44/71b34468e864cf0d74a842e48bf9a323.jpg",
          "https://i.pinimg.com/1200x/23/ca/47/23ca47a3bd603425460c669259cbb215.jpg",
        ],
        colors: ['white', 'black', 'blue', 'gray'],
      ),
      Product(
        id: 11,
        name: 'Wedding Heel',
        price: 79.99,
        description: 'Breathable mesh, cushioned sole for running',
        image: 'images/categories/shoes/WeddingHeel/w1.jpg',
        category: 'Shoes',
        rating: 4.9,
        ratingCount: 345,
      ),
      Product(
        id: 12,
        name: "Sneaker Shoe",
        price: 49.99,
        category: "Shoes",
        image: "https://i.pinimg.com/1200x/57/62/a6/5762a6c77d9ac297e2cdce5de6287875.jpg",
        rating: 4.7,
        ratingCount: 234,
        seller: Seller(
          id: 3,
          name: "John Doe",
          rating: 4.7,
          ratingCount: 234,
          joinDate: DateTime.now(),
        ),
        description: "Metallic finish, lightweight EVA sole.",
        productImages: [],
        colors: ['brown'],
      ),
      Product(
        id: 16,
        name: "Neck Accessories",
        price: 29.99,
        category: "Accessories",
        image: "https://i.pinimg.com/1200x/60/d6/8a/60d68a58460c418cffd3f90d682348cc.jpg",
        rating: 4.3,
        ratingCount: 123,
        seller: Seller(
          id: 4,
          name: "Emma Style",
          rating: 4.7,
          ratingCount: 234,
          joinDate: DateTime.now(),
        ),
        description: "Genuine leather belt, reversible style.",
        productImages: [
          "https://i.pinimg.com/736x/3c/dd/f8/3cddf8b5d82b6d76f17225c2dfd06609.jpg",
          "https://i.pinimg.com/1200x/44/4c/23/444c23747643d1a3a1f251a22dcccf02.jpg",
          "https://i.pinimg.com/736x/62/4d/42/624d42e8002e0de2de11099e02d86f9f.jpg",
          "https://i.pinimg.com/1200x/89/40/34/894034509c10c8e02cd1ea7ef7e6ff27.jpg",
        ],
        colors: ['N1', 'N2', 'N3', 'N4', 'N5'],
      ),
      Product(
        id: 18,
        name: 'Press On Nail',
        price: 29.99,
        description: 'Gold-plated statement pieces.',
        image: 'images/categories/accessories/Nail/N1.jpg',
        category: 'Accessories',
        rating: 4.7,
        ratingCount: 234,
      ),
    ];
  }

  Widget _buildFavouriteImage(String imageUrl, double height, double width) {
      return AppImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
  }

  Future<void> _loadFavorites() async {
    final authService = Provider.of<AuthService>(context, listen: false);

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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isMobile, isLoggedIn),
                    isMobile? 
                    _buildFilterChips(isMobile): SizedBox(height: 1,),
                    const SizedBox(height: 12),
                    _buildSortBar(isMobile),
                    const SizedBox(height: 16),
                    _buildContent(isMobile),
                    const SizedBox(height: 40),
                    if (!isMobile) const CommonFooter(),
                  ],
                ),
              ),
            ),
          ),
          if (isMobile) const CommonBottomBar(currentIndex: 3),
        ],
      ),
    );
  }

  // ============= HEADER =============
  Widget _buildHeader(bool isMobile, bool isLoggedIn) {
    return Row(
      children: [
        Container(
          width: isMobile ? 50 : 70,
          height: isMobile ? 50 : 70,
          decoration: BoxDecoration(
            color: const Color(0xFF2B6E3B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.favorite,
              color: Color(0xFF2B6E3B),
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Favourites',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Here you have added to your favourites',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  color: Colors.grey[600],
                ),
              ),
              if (!isLoggedIn) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B6E3B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Sign In to Save Favourites'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ============= FILTER CHIPS =============
  Widget _buildFilterChips(bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Filters',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ..._filterOptions.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? filter : 'All';
                  });
                },
                backgroundColor: Colors.grey[100],
                selectedColor: const Color(0xFF2B6E3B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ============= SORT BAR =============
  Widget _buildSortBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedSort,
                items: _sortOptions.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                },
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Grid View Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isGridView = true;
                  });
                },
                icon: Icon(
                  Icons.grid_view,
                  color: _isGridView ? const Color(0xFFC77C2E) : Colors.grey[400],
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
              // List View Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isGridView = false;
                  });
                },
                icon: Icon(
                  Icons.view_list,
                  color: _isGridView ? Colors.grey[400] : const Color(0xFFC77C2E),
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
              if (!isMobile)
                Text(
                  '${_favorites.length} items',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============= CONTENT =============
  Widget _buildContent(bool isMobile) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
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
                style: TextStyle(color: Color(0xFFD68247)),
              ),
            ),
          ],
        ),
      );
    }

    // Grid View (PC and mobile)
    if (_isGridView) {
      int crossAxisCount = isMobile ? 3 : 6;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
          childAspectRatio: 0.6,
        ),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final favorite = _favorites[index];
          return _buildGridFavoriteCard(favorite,isMobile);
        },
      );
    }

    // List View (PC and mobile)
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile? 10:70),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final favorite = _favorites[index];
          return _buildListFavoriteCard(favorite, isMobile);
        },
      ),
    );
  }

  // ============= GRID FAVORITE CARD =============
  Widget _buildGridFavoriteCard(Favorite favorite,bool isMobile) {
    final product = favorite.product;
    if (product == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildFavouriteImage(
                    product.proxiedImageUrl,
                    double.infinity,
                    double.infinity,
                  ),
                ),
                Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite,
                          size: isMobile? 16: 20,
                          color: Colors.red,
                        ),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.house_outlined,
                        color: Color(0xFF2B6E3B),
                        size: 14,
                      ),
                      Expanded(
                        child: Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============= LIST FAVORITE CARD =============
  Widget _buildListFavoriteCard(Favorite favorite, bool isMobile) {
    final product = favorite.product;
    if (product == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product.id),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: isMobile ? 90 : 120,
              height: isMobile ? 100 : 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildFavouriteImage(
                  product.proxiedImageUrl,
                  double.infinity,
                  double.infinity,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFF2B6E3B),
                        size: 14,
                      ),
                      Expanded(
                        child: Text(
                          product.description ?? product.category,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
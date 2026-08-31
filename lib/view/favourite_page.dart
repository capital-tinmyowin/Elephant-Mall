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
  List<Favorite> _displayedFavorites = [];

  bool _isLoading = false;
  bool _isGridView = true;
  String _selectedSort = 'Recently Added';
  String _selectedFilter = 'All';
  String _searchQuery = '';

  int _currentPage = 1; // Start from 1
  final int _itemsPerPage = 12; // 10 items per page
  bool _isLoadingMore = false;

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

  @override
  void dispose() {
    super.dispose();
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
        productId: product.productCode,
        addedDate: DateTime.now().subtract(Duration(days: index * 5)),
        product: product,
      );
    }).toList();
  }

  // Mock products for favorites (unchanged)
  List<Product> _getMockProducts() {
    return [
      Product(
        productCode: 2,
        productName: "OverSize T-Shirt",
        price: 19.99,
        category: "T-Shirts",
        image:
            "https://i.pinimg.com/1200x/7b/9b/64/7b9b64157c65859e958063af2284b620.jpg",
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
        productCode: 4,
        productName: "White Blouse",
        price: 39.99,
        category: "Blouses",
        image:
            "https://i.pinimg.com/1200x/bd/6c/f9/bd6cf9e39bb3ea86086bb1f89c789ee6.jpg",
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
        productCode: 6,
        productName: 'White Shoulder Bag',
        price: 34.99,
        description:
            'Handwoven straw tote, roomy interior. Ideal for beach or market',
        image: 'images/categories/bags/LeatherBag/white.jpg',
        category: 'Bags',
        rating: 4.7,
        ratingCount: 234,
      ),
      Product(
        productCode: 8,
        productName: "Wool Fedora Hat",
        price: 24.99,
        category: "Hats",
        image:
            "https://i.pinimg.com/736x/4e/81/11/4e8111d7aea3eeb01500a1f6ad88cdae.jpg",
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
        productCode: 10,
        productName: "Running Shoes",
        price: 49.99,
        category: "Shoes",
        image:
            "https://i.pinimg.com/736x/71/4f/a1/714fa1434d9f007388ddf0da7be76873.jpg",
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
        productCode: 11,
        productName: 'Wedding Heel',
        price: 79.99,
        description: 'Breathable mesh, cushioned sole for running',
        image: 'images/categories/shoes/WeddingHeel/w1.jpg',
        category: 'Shoes',
        rating: 4.9,
        ratingCount: 345,
      ),
      Product(
        productCode: 12,
        productName: "Sneaker Shoe",
        price: 49.99,
        category: "Shoes",
        image:
            "https://i.pinimg.com/1200x/57/62/a6/5762a6c77d9ac297e2cdce5de6287875.jpg",
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
        productCode: 16,
        productName: "Neck Accessories",
        price: 29.99,
        category: "Accessories",
        image:
            "https://i.pinimg.com/1200x/60/d6/8a/60d68a58460c418cffd3f90d682348cc.jpg",
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
        productCode: 18,
        productName: 'Press On Nail',
        price: 29.99,
        description: 'Gold-plated statement pieces.',
        image: 'images/categories/accessories/Nail/N1.jpg',
        category: 'Accessories',
        rating: 4.7,
        ratingCount: 234,
      ),
      Product(
        productCode: 19,
        productName: "Ipad 10th Gen",
        price: 89.99,
        category: "Electronics",
        image:
            "https://i5.walmartimages.com/seo/2022-Apple-10-9-inch-iPad-Wi-Fi-64GB-Pink-10th-Generation_4fdae443-4f60-4a3e-9efe-12758bf5f128.f4d7333626b4e6b27e8be25d1f698373.jpeg",
        rating: 4.7,
        ratingCount: 892,
        seller: Seller(
          id: 4,
          name: "Emma Style",
          rating: 4.7,
          ratingCount: 234,
          joinDate: DateTime.now(),
        ),
        description: "Apple iPad 10.9-inch, A14 Bionic chip.",
        productImages: [
          "https://i.pinimg.com/736x/5f/5a/0f/5f5a0f5dc3e79507d21307977ff48d26.jpg",
          "https://i.pinimg.com/736x/a4/3a/31/a43a3139c7dbe8cdf069747a1adbf065.jpg",
          "https://i.pinimg.com/736x/03/50/b4/0350b4a8e67383b0b9f2117782b22724.jpg",
        ],
        colors: ['I1', 'I2', 'I3', 'I4'],
      ),
      Product(
        productCode: 20,
        productName: "Earphone",
        price: 29.99,
        category: "Headphones",
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTndMcJW71HLgi9ntgoterJiJJjLxbtOVVpyA&s",
        rating: 4.4,
        ratingCount: 234,
        seller: Seller(
          id: 4,
          name: "Emma Style",
          rating: 4.7,
          ratingCount: 234,
          joinDate: DateTime.now(),
        ),
        description: "Bluetooth 5.0, long battery life.",
        productImages: [
          "https://i.pinimg.com/1200x/7d/b9/5c/7db95c3d96c5abd7072f01fcc69b21b7.jpg",
          "https://i.pinimg.com/736x/d6/69/30/d66930383d6b21a09e4182d433e67e3d.jpg",
          "https://i.pinimg.com/736x/e0/41/a1/e041a16d06691b38cc35316dc48e1b16.jpg",
          "https://i.pinimg.com/736x/1b/9e/b1/1b9eb1ac0d99e6656414273a1e1b0141.jpg",
        ],
        colors: ['Eph1', 'Eph2', 'Eph3', 'Eph4', 'Eph5'],
      ),
      Product(
        productCode: 21,
        productName: "Powerbank",
        price: 39.99,
        category: "Power Banks",
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnwF3fpDIATeZ_9o5h3vNu_X8KUHSq5O739g&s",
        rating: 4.5,
        ratingCount: 342,
        seller: Seller(
          id: 2,
          name: "Sunny Days",
          rating: 4.7,
          ratingCount: 234,
          joinDate: DateTime.now(),
        ),
        description: "Dual USB output, fast charging.",
        productImages: [
          "https://i.pinimg.com/736x/5c/a1/99/5ca19986d3af978a1a8f3c54cc735f93.jpg",
          "https://i.pinimg.com/736x/18/db/7f/18db7fe2ac7dfd458029317fab2d612d.jpg",
          "https://i.pinimg.com/1200x/9d/d5/39/9dd539a08fec5a2c382e3789ab836841.jpg",
        ],
        colors: ['pb1', 'pb2', 'pb3', 'pb4'],
      ),
      Product(
        productCode: 23,
        productName: "Home Decor",
        price: 29.99,
        category: "Home Decor",
        image:
            "https://i.pinimg.com/736x/4e/6d/4e/4e6d4eb03c6518de8b527b4bd30eab55.jpg",
        rating: 4.3,
        ratingCount: 123,
        seller: Seller(
          id: 2,
          name: "Sunny Days",
          rating: 4.7,
          ratingCount: 234,
          joinDate: DateTime.now(),
        ),
        description: "Create your living style as your wish",
        productImages: [
          "https://i.pinimg.com/736x/7b/a5/1b/7ba51b7efce94e322de45d1d5f9c9ac3.jpg",
          "https://i.pinimg.com/736x/e9/c7/3c/e9c73c3a65e26fb6e28c10076754a0c1.jpg",
          "https://i.pinimg.com/736x/2a/be/0b/2abe0be2238bbfd0960b5ff5d87b4f34.jpg",
          "https://i.pinimg.com/736x/03/f8/c9/03f8c9c43933272f1ff2d8a9b9be731d.jpg",
        ],
        colors: ['H1', 'H2', 'H3', 'H4', 'H5'],
      ),
      Product(
        productCode: 24,
        productName: "Appliance",
        price: 29.99,
        category: "Appliances",
        image:
            "https://i.pinimg.com/736x/73/39/1c/73391c325a95b74a077bbac31a260da4.jpg",
        rating: 4.1,
        ratingCount: 78,
        seller: Seller(
          id: 3,
          name: "John Doe",
          rating: 4.7,
          ratingCount: 234,
          joinDate: DateTime.now(),
        ),
        description: "Create your living style as your wish",
        productImages: [
          "https://i.pinimg.com/736x/84/43/1b/84431bd72e0a814e4789df37676b745f.jpg",
          "https://i.pinimg.com/1200x/76/80/73/76807304b60563e0ae18216ffe8fd624.jpg",
          "https://i.pinimg.com/736x/fb/3f/b8/fb3fb8251599116e2bdb1aa1cd39c0b2.jpg",
          "https://i.pinimg.com/736x/b0/a6/58/b0a6581c5dc2781e3f4c4410f4fbd501.jpg",
        ],
        colors: ['A1', 'A2', 'A3', 'A4', 'A5'],
      ),
    ];
  }

  Widget _buildFavouriteImage(String imageUrl, double height, double width) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: isMobile ? 0 : 10, color: Colors.white),
      ),
      child: AppImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        borderRadius: 10,
      ),
    );
  }

  Future<void> _loadFavorites() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isLoggedIn) {
      setState(() {
        _favorites = _getMockFavorites();
        _isLoading = false;
        _resetPagination();
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.getUserFavorites(
        authService.currentUser!.id,
      );

      if (response['success'] == true && response['data'] != null) {
        final List favoritesData = response['data'];
        setState(() {
          _favorites = favoritesData
              .map((json) => Favorite.fromJson(json))
              .toList();
          _isLoading = false;
          _resetPagination();
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
                    if (isMobile) ...[
                      const SizedBox(height: 12),
                      _buildMobileSearchFilterBar(),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 12),
                    if (!isMobile) _buildSortBar(isMobile),
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
            color: isMobile
                ? Color(0xFF2B6E3B).withOpacity(0.1)
                : const Color.fromARGB(255, 250, 250, 250),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              isMobile ? Icons.favorite : Icons.favorite_border,
              color: isMobile ? Color(0xFF2B6E3B) : Color(0xFFC77C2E),
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
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Items you have added to your favourites',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        if (!isMobile)
          Text(
            '${_favorites.length} items',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
      ],
    );
  }

  Widget _buildMobileSearchFilterBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Box with Filter Icon
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _resetPagination();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search your saved items...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Filter Icon
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.filter_list,
                  size: 20,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  // Show filter dialog or bottom sheet
                  _showFilterBottomSheet();
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? filter : 'All';
                        _resetPagination();
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFF2B6E3B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF2B6E3B)
                          : Colors.grey[300]!,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Saved Items Count and Clear All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.bookmark_border,size: 15,color: const Color(0xFF2B6E3B),),
                Text(
                  '${_favorites.length} saved items',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _favorites.clear();
                  _searchQuery = '';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All favorites cleared'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC77C2E),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateBottomSheet) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? filter : 'All';
                          _resetPagination();
                        });
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: const Color(0xFF2B6E3B),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

  // ============= SORT BAR =============
  Widget _buildSortBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 231, 231, 231),
                  ),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const Text(
                      '     Sort by:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedSort,
                      items: _sortOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value!;
                          _resetPagination();
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
              ),
              SizedBox(width: 3),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 231, 231, 231),
                  ),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsetsGeometry.all(12),
                  child: Icon(Icons.filter_list_rounded),
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Grid View Button
              Text(
                'View: ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isGridView = true;
                  });
                },
                icon: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _isGridView
                          ? const Color(0xFFC77C2E)
                          : Colors.grey,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(5),
                    child: Icon(
                      Icons.grid_view,
                      color: _isGridView
                          ? const Color(0xFFC77C2E)
                          : Colors.grey[400],
                      size: _isGridView ? 22 : 18,
                    ),
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
              SizedBox(width: 2),
              // List View Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isGridView = false;
                  });
                },
                icon: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _isGridView
                          ? Colors.grey
                          : const Color(0xFFC77C2E),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(5),
                    child: Icon(
                      Icons.view_list,
                      color: _isGridView
                          ? Colors.grey[400]
                          : const Color(0xFFC77C2E),
                      size: _isGridView ? 18 : 22,
                    ),
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
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
          Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No favourites yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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

  if (_displayedFavorites.isEmpty && !_isLoading) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No matching items found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedFilter = 'All';
                _resetPagination();
              });
            },
            child: const Text(
              'Clear Search',
              style: TextStyle(color: Color(0xFFD68247)),
            ),
          ),
        ],
      ),
    );
  }

  return Column(
    children: [
      // Grid View (PC and mobile)
      if (_isGridView)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _displayedFavorites.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            // UPDATED: Smaller max width for 3 items per row on mobile
            maxCrossAxisExtent: isMobile ? 130 : 230, // Changed from 170 to 120
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            // UPDATED: Adjust height for smaller cards
            mainAxisExtent: isMobile ? 210 : 320, // Reduced height for mobile
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final favorite = _displayedFavorites[index];
            return _buildGridFavoriteCard(favorite, isMobile);
          },
        ),

      // List View (PC and mobile)
      if (!_isGridView)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 70),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _displayedFavorites.length,
            itemBuilder: (context, index) {
              final favorite = _displayedFavorites[index];
              return _buildListFavoriteCard(favorite, isMobile);
            },
          ),
        ),
      // Pagination
      const SizedBox(height: 16),
      _buildPagination(),
    ],
  );
}

  // ============= UPDATED GRID FAVORITE CARD =============
  Widget _buildGridFavoriteCard(Favorite favorite, bool isMobile) {
    final product = favorite.product;
    if (product == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product.productCode),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  _buildFavouriteImage(
                    product.proxiedImageUrl,
                    isMobile ? 80 : 180,
                    double.infinity,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite,
                          size: isMobile ? 16 : 18,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Handle remove from favorites
                          setState(() {
                            _favorites.removeWhere(
                              (f) => f.productId == product.productCode,
                            );
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.productName} removed from favorites',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                product.productName,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Price and Rating Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Price
                  Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 11 : 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(width: 1),
                  if(!isMobile)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                    ],
                  ),
                ],
              ),
            ),

            // Category
            Padding(
              padding: EdgeInsetsGeometry.only(left: 5),
              child: Row(
                children: [
                  Icon(
                    Icons.house_outlined,
                    color: const Color(0xFF2B6E3B),
                    size: 15,
                  ),
                  SizedBox(width: 1),
                  Text(
                    product.category,
                    style: TextStyle(fontSize: isMobile? 9: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Column(
              children: [
                isMobile
                    ? 
                    // Padding(
                        // padding: const EdgeInsets.all(8),
                        // child: 
                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 24 : 32,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF2B6E3B),
                              ),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      productId: product.productCode,
                                    ),
                                  ),
                                );
                              },
                              child: Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      color: const Color(0xFF2B6E3B),
                                      size: 9,
                                    ),
                                    SizedBox(width: 1),
                                    Text(
                                      "Saved",
                                      style: TextStyle(
                                        color: const Color(0xFF2B6E3B),
                                        fontSize: isMobile ? 9 : 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      // )
                    : SizedBox(width: 1),
                    SizedBox(height: 2),
                // View Detail Button
                SizedBox(
                  width: double.infinity,
                  height: isMobile ? 24 : 32,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFC77C2E)),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(productId: product.productCode),
                          ),
                        );
                      },
                      child: Text(
                        "View Details",
                        style: TextStyle(
                          color: const Color(0xFFC77C2E),
                          fontSize: isMobile ? 8 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
            builder: (context) => ProductDetailPage(productId: product.productCode),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: isMobile ? 90 : 120,
              height: isMobile ? 100 : 150,
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
                    product.productName,
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
                  SizedBox(
                  width: 100,
                  height: isMobile ? 28 : 32,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFC77C2E)),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(productId: product.productCode),
                          ),
                        );
                      },
                      child: Text(
                        "View Details",
                        style: TextStyle(
                          color: const Color(0xFFC77C2E),
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetPagination() {
    setState(() {
      _currentPage = 1;
      _displayedFavorites = [];
      _isLoadingMore = false;
    });
    _loadPageItems();
  }

  void _loadPageItems() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Get filtered favorites
    List<Favorite> filteredFavorites = _getFilteredFavorites();

    // Calculate start and end index
    final totalPages = (filteredFavorites.length / _itemsPerPage).ceil();

    // Ensure current page is valid
    if (_currentPage > totalPages && totalPages > 0) {
      _currentPage = totalPages;
    }

    // Calculate start and end index
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage > filteredFavorites.length
        ? filteredFavorites.length
        : startIndex + _itemsPerPage;

    // Get the items for current page
    final pageItems = filteredFavorites.sublist(startIndex, endIndex);

    setState(() {
      _displayedFavorites = pageItems;
      _isLoadingMore = false;
    });
  }

  Widget _buildPagination() {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final filteredFavorites = _getFilteredFavorites();
    final totalItems = filteredFavorites.length;
    final totalPages = (totalItems / _itemsPerPage).ceil();

    if (totalPages <= 1) return const SizedBox.shrink();

    // Calculate current page items range
    final startIndex = (_currentPage - 1) * _itemsPerPage + 1;
    final endIndex = (_currentPage * _itemsPerPage) > totalItems
        ? totalItems
        : _currentPage * _itemsPerPage;

    return Column(
      children: [
        // Page info
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Showing $startIndex-$endIndex of $totalItems items',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
        ),

        // Page numbers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous button
            IconButton(
              onPressed: _currentPage > 1
                  ? () {
                      setState(() {
                        _currentPage--;
                        _loadPageItems();
                      });
                    }
                  : null,
              icon: const Icon(Icons.chevron_left),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32),
              color: _currentPage > 1 ? Colors.black87 : Colors.grey[400],
            ),

            // Page numbers
            ...List.generate(totalPages > 5 ? 5 : totalPages, (index) {
              int pageNumber;
              if (totalPages <= 5) {
                pageNumber = index + 1;
              } else {
                // Show pages around current page
                if (_currentPage <= 3) {
                  pageNumber = index + 1;
                } else if (_currentPage >= totalPages - 2) {
                  pageNumber = totalPages - 4 + index;
                } else {
                  pageNumber = _currentPage - 2 + index;
                }
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentPage = pageNumber;
                    _loadPageItems();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _currentPage == pageNumber
                        ? const Color(0xFFC77C2E)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    pageNumber.toString(),
                    style: TextStyle(
                      color: _currentPage == pageNumber
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: _currentPage == pageNumber
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),

            // Next button
            IconButton(
              onPressed: _currentPage < totalPages
                  ? () {
                      setState(() {
                        _currentPage++;
                        _loadPageItems();
                      });
                    }
                  : null,
              icon: const Icon(Icons.chevron_right),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32),
              color: _currentPage < totalPages
                  ? Colors.black87
                  : Colors.grey[400],
            ),
          ],
        ),
      ],
    );
  }

  // s Get filtered favorites based on search and category
  List<Favorite> _getFilteredFavorites() {
    List<Favorite> filtered = _favorites;
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((favorite) {
        final product = favorite.product;
        if (product == null) return false;
        return product.productName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    // Filter by category
    if (_selectedFilter != 'All') {
      filtered = filtered.where((favorite) {
        final product = favorite.product;
        if (product == null) return false;
        return product.category == _selectedFilter;
      }).toList();
    }
    // Sort
    filtered = _sortFavorites(filtered);
    return filtered;
  }

  //  Sort favorites
  List<Favorite> _sortFavorites(List<Favorite> favorites) {
    final sorted = List<Favorite>.from(favorites);

    switch (_selectedSort) {
      case 'Price: Low to High':
        sorted.sort(
          (a, b) => (a.product?.price ?? 0).compareTo(b.product?.price ?? 0),
        );
        break;
      case 'Price: High to Low':
        sorted.sort(
          (a, b) => (b.product?.price ?? 0).compareTo(a.product?.price ?? 0),
        );
        break;
      case 'Name: A to Z':
        sorted.sort(
          (a, b) => (a.product?.productName ?? '').compareTo(b.product?.productName ?? ''),
        );
        break;
      case 'Recently Added':
      default:
        sorted.sort((a, b) => b.addedDate.compareTo(a.addedDate));
        break;
    }

    return sorted;
  }
}

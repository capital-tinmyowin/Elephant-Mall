import 'package:flutter/material.dart';
import 'package:elephant_mall/models/sellerpagemodel.dart';
import 'package:elephant_mall/services/sellerpageservice.dart';

class SellerPage extends StatefulWidget {
  final String sellerId;

  const SellerPage({
    super.key,
    this.sellerId = 'sarah-j',
  });

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final SellerPageService _service = SellerPageService();
  final TextEditingController _searchController = TextEditingController();

  SellerInfo? _seller;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.fetchSellerInfo(widget.sellerId),
        _service.fetchSellerProducts(widget.sellerId),
      ]);

      setState(() {
        _seller = results[0] as SellerInfo;
        _products = results[1] as List<Product>;
        _filteredProducts = List.from(_products);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredProducts = List.from(_products);
      } else {
        final q = query.toLowerCase();
        _filteredProducts = _products
            .where((p) =>
                p.productName.toLowerCase().contains(q) ||
                (p.description?.toLowerCase().contains(q) ?? false))
            .toList();
      }
    });
  }

  Future<void> _toggleFavourite(Product product) async {
    final newStatus = await _service.toggleFavourite(
      product.productId,
      product.favourite == 1,
    );

    setState(() {
      final index = _products.indexWhere((p) => p.productId == product.productId);
      if (index != -1) {
        _products[index] = product.copyWith(favourite: newStatus ? 1 : 0);
      }
      final fIndex =
          _filteredProducts.indexWhere((p) => p.productId == product.productId);
      if (fIndex != -1) {
        _filteredProducts[fIndex] =
            product.copyWith(favourite: newStatus ? 1 : 0);
      }
    });
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$formatted Kyat';
  }

  // Brand colors matching the image
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentOrange = Color(0xFFE85A2A);
  static const Color bgColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;
    final isTablet = width >= 650 && width < 1000;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryGreen))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildTopBar(isDesktop),
                      Expanded(
                        child: _buildBody(isDesktop, isTablet, width),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
    );
  }

  // ===================== TOP BAR =====================
  Widget _buildTopBar(bool isDesktop) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 16,
        vertical: isDesktop ? 14 : 10,
      ),
      child: Row(
        children: [
          // Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 6),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'elephant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                    TextSpan(
                      text: ' mall',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (isDesktop) ...[
            // On desktop show a small search in the top bar too (optional)
            SizedBox(
              width: 280,
              height: 38,
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: "Search in ${_seller?.name ?? 'Store'}",
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade500),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===================== BODY =====================
  Widget _buildBody(bool isDesktop, bool isTablet, double width) {
    return CustomScrollView(
      slivers: [
        // Seller header + search + filters
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 40 : 16,
              8,
              isDesktop ? 40 : 16,
              12,
            ),
            child: Column(
              children: [
                // Seller row
                Row(
                  children: [
                    CircleAvatar(
                      radius: isDesktop ? 28 : 24,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _seller?.avatarUrl != null
                          ? NetworkImage(_seller!.avatarUrl!)
                          : null,
                      child: _seller?.avatarUrl == null
                          ? Text(
                              (_seller?.name.isNotEmpty == true)
                                  ? _seller!.name[0].toUpperCase()
                                  : 'S',
                              style: TextStyle(
                                fontSize: isDesktop ? 22 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _seller?.name ?? "Sarah J's Full Store",
                        style: TextStyle(
                          fontSize: isDesktop ? 22 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Follow feature coming soon')),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Follow Seller'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 18 : 12,
                          vertical: isDesktop ? 12 : 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Search bar (matches image)
                TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: "Search in ${_seller?.name ?? "Sarah J's Store"}",
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, size: 22, color: Colors.grey.shade500),
                    suffixIcon: Icon(Icons.tune, size: 22, color: Colors.grey.shade600),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryGreen, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('By Category'),
                      const SizedBox(width: 8),
                      _filterChip('Price : 45,000'),
                      const SizedBox(width: 8),
                      _filterChip('Primns by Price'),
                      const SizedBox(width: 8),
                      _filterChip('Shipping & Roen'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Product grid
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 40 : 12,
            16,
            isDesktop ? 40 : 12,
            8,
          ),
          sliver: _filteredProducts.isEmpty
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No products found'),
                    ),
                  ),
                )
              : SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: isDesktop ? 0.70 : 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _ProductCard(
                        product: _filteredProducts[index],
                        formatPrice: _formatPrice,
                        onFavouriteTap: () =>
                            _toggleFavourite(_filteredProducts[index]),
                        onAddToCart: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${_filteredProducts[index].productName} added to cart'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        onViewDetails: () {},
                      );
                    },
                    childCount: _filteredProducts.length,
                  ),
                ),
        ),

        // Newest Arrivals + Best Sellers
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 40 : 16,
              20,
              isDesktop ? 40 : 16,
              12,
            ),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _sectionBlock(
                          title: 'Newest Arrivals',
                          products: _products.take(4).toList(),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _sectionBlock(
                          title: 'Best Sellers',
                          products: _products.skip(4).take(4).toList(),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionBlock(
                        title: 'Newest Arrivals',
                        products: _products.take(4).toList(),
                      ),
                      const SizedBox(height: 24),
                      _sectionBlock(
                        title: 'Best Sellers',
                        products: _products.skip(4).take(4).toList(),
                      ),
                    ],
                  ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _filterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _sectionBlock({
    required String title,
    required List<Product> products,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final p = products[index];
              return Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Image.network(
                          p.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatPrice(p.price),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===================== BOTTOM NAV =====================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', false),
              _navItem(Icons.grid_view_rounded, 'Categories', false),
              // Center Sell button
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: accentOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Sell',
                    style: TextStyle(fontSize: 11, color: accentOrange),
                  ),
                ],
              ),
              _navItem(Icons.shopping_cart_outlined, 'Cart', false),
              _navItem(Icons.person_outline, 'Profile', true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    final color = isActive ? accentOrange : Colors.grey.shade600;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

// ==================== PRODUCT CARD ====================
class _ProductCard extends StatelessWidget {
  final Product product;
  final String Function(double) formatPrice;
  final VoidCallback onFavouriteTap;
  final VoidCallback onAddToCart;
  final VoidCallback onViewDetails;

  const _ProductCard({
    required this.product,
    required this.formatPrice,
    required this.onFavouriteTap,
    required this.onAddToCart,
    required this.onViewDetails,
  });

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey.shade400, size: 40),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryGreen,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavouriteTap,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product.favourite == 1
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 17,
                        color: product.favourite == 1
                            ? Colors.red
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (product.rating != null) ...[
                        const SizedBox(width: 3),
                        const Icon(Icons.star, size: 12, color: Color(0xFFFFB800)),
                        Text(
                          product.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (product.description != null)
                    Text(
                      product.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
                    ),
                  const Spacer(),
                  // Price
                  Text(
                    formatPrice(product.price),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 28,
                          child: OutlinedButton(
                            onPressed: onAddToCart,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryGreen,
                              side: const BorderSide(color: primaryGreen),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: SizedBox(
                          height: 28,
                          child: ElevatedButton(
                            onPressed: onViewDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

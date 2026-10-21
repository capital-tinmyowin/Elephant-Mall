import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/sellerpagemodel.dart';
import '../models/SellerInfo.dart';
import '../models/category.dart';
import '../models/new_in.dart';
import '../services/sellerListing_service.dart';
import '../services/auth_service.dart';
import 'common/footer.dart';
import 'common/header.dart';
import 'common/loading_widget.dart';
import 'product_detail_page.dart';
import 'new_in.dart';

class SellerListingPage extends StatefulWidget {
  final int? sellerId;
  final String? sellerName;

  const SellerListingPage({
    super.key,
    this.sellerId,
    this.sellerName,
  });

  @override
  State<SellerListingPage> createState() => _SellerListingPageState();
}

class _SellerListingPageState extends State<SellerListingPage> {
  final SellerListingService _service = SellerListingService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> products = [];
  bool loading = true;
  String? errorMessage;

  bool isFollowing = false;

  final Set<int> favouriteProductIds = {};
  final Set<int> favouriteLoadingIds = {};

  List<Category> categories = [];
  bool categoryLoading = false;

  String selectedCategory = 'By Category';
  int? selectedCategoryId;
  String selectedPrice = 'Price';
  String selectedSort = 'Primmys by Price';

  List<NewInModel> newestArrivals = [];
  bool newestArrivalsLoading = true;
  String? newestArrivalsError;

  SellerInfo? sellerInfo;
  bool sellerInfoLoading = true;

  static const int pageSize = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    loadSellerInfo();
    loadProducts();
    loadCategories();
    loadNewestArrivals();
    _currentPage = 1;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOADERS
  // ============================================================

  Future<void> loadSellerInfo() async {
    setState(() => sellerInfoLoading = true);
    try {
      final authService = context.read<AuthService>();
      final info = await _service.fetchSellerInfo(
        authService: authService,
        sellerId: widget.sellerId?.toString(),
      );
      if (!mounted) return;
      setState(() {
        sellerInfo = info;
        isFollowing = info.isFollowing;
        sellerInfoLoading = false;
      });
    } catch (e) {
      debugPrint('Seller listing info error: $e');
      if (!mounted) return;
      setState(() {
        sellerInfo = null;
        sellerInfoLoading = false;
      });
    }
  }

  Future<void> loadCategories() async {
    if (!mounted) return;
    setState(() => categoryLoading = true);
    try {
      final result = await _service.fetchCategories();
      if (!mounted) return;
      setState(() {
        categories = result;
        categoryLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        categories = [];
        categoryLoading = false;
      });
    }
  }

  Future<void> loadNewestArrivals() async {
    if (!mounted) return;
    setState(() {
      newestArrivalsLoading = true;
      newestArrivalsError = null;
    });
    try {
      final authService = context.read<AuthService>();
      final result =
          await _service.fetchNewestArrivals(authService: authService);
      if (!mounted) return;
      setState(() {
        newestArrivals = result;
        newestArrivalsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        newestArrivals = [];
        newestArrivalsLoading = false;
        newestArrivalsError = e.toString();
      });
    }
  }

  Future<void> loadProducts() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final sellerId = widget.sellerId;
      if (sellerId == null) {
        throw Exception('Seller ID is required.');
      }

      final result = await _service.fetchSellerProducts(sellerId.toString());
      result.sort((a, b) => (b.productId ?? 0).compareTo(a.productId ?? 0));

      final existingFavouriteIds = <int>{};
      for (final product in result) {
        if (product.productId != null && product.favourite == 1) {
          existingFavouriteIds.add(product.productId!);
        }
      }

      if (!mounted) return;
      setState(() {
        products = result;
        favouriteProductIds
          ..clear()
          ..addAll(existingFavouriteIds);
        loading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        products = [];
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // FILTER + PAGING
  // ============================================================

  List<Product> get filteredProducts {
    List<Product> result = List.from(products);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((p) => p.productName.toLowerCase().contains(query))
          .toList();
    }

    if (selectedCategoryId != null) {
      result =
          result.where((p) => p.categoryId == selectedCategoryId).toList();
    }

    double priceOf(Product p) {
      if (p.price is num) return (p.price as num).toDouble();
      return double.tryParse(p.price.toString().replaceAll(',', '')) ?? 0;
    }

    if (selectedPrice == 'Under 50,000') {
      result = result.where((p) => priceOf(p) < 50000).toList();
    } else if (selectedPrice == '50,000 - 100,000') {
      result = result
          .where((p) => priceOf(p) >= 50000 && priceOf(p) <= 100000)
          .toList();
    } else if (selectedPrice == 'Over 100,000') {
      result = result.where((p) => priceOf(p) > 100000).toList();
    }

    if (selectedSort == 'Lowest Price') {
      result.sort((a, b) => priceOf(a).compareTo(priceOf(b)));
    } else if (selectedSort == 'Highest Price') {
      result.sort((a, b) => priceOf(b).compareTo(priceOf(a)));
    } else {
      result.sort((a, b) => (b.productId ?? 0).compareTo(a.productId ?? 0));
    }

    return result;
  }

  int get totalPages {
    final total = filteredProducts.length;
    if (total == 0) return 1;
    return (total / pageSize).ceil();
  }

  List<Product> get pagedProducts {
    final list = filteredProducts;
    final start = (_currentPage - 1) * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  String formatPrice(String price) {
    final value = double.tryParse(price);
    if (value == null) return price;
    return NumberFormat('#,##0').format(value);
  }

  String? getProductImageUrl(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Column(
        children: [
          const CommonHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mobile ? 6 : 20,
                      vertical: mobile ? 5 : 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSellerHeader(mobile),
                        const SizedBox(height: 5),
                        buildSearchBox(mobile),
                        const SizedBox(height: 4),
                        buildFilters(mobile),
                        const SizedBox(height: 7),
                        if (loading)
                          const CommonLoading(
                            size: 42,
                            height: 300,
                            message: 'Loading products...',
                          )
                        else if (errorMessage != null)
                          CommonError(
                            height: 250,
                            onRetry: loadProducts,
                            isRetryEnabled: true,
                          )
                        else if (products.isEmpty) ...[
                          CommonEmpty(onRetry: loadProducts),
                          const SizedBox(height: 12),
                          buildProductSections(mobile),
                        ] else if (filteredProducts.isEmpty) ...[
                          CommonEmpty(
                            message: 'Try another search or filter.',
                            onRetry: () {
                              setState(() {
                                _searchController.clear();
                                selectedCategory = 'By Category';
                                selectedCategoryId = null;
                                selectedPrice = 'Price';
                                selectedSort = 'Primmys by Price';
                                _currentPage = 1;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          buildProductSections(mobile),
                        ] else ...[
                          buildProductGrid(mobile),
                          _buildPagination(),
                          const SizedBox(height: 12),
                          buildProductSections(mobile),
                        ],
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!mobile) const CommonFooter(),
        ],
      ),
      bottomNavigationBar:
          mobile ? const CommonBottomBar(currentIndex: 4) : null,
    );
  }

  // ============================================================
  // HEADER — Follow + Chat Seller (public listing)
  // ============================================================

  Widget buildSellerHeader(bool mobile) {
    final name = (sellerInfo?.name.isNotEmpty == true)
        ? sellerInfo!.name
        : (widget.sellerName ?? 'Seller Store');

    final location = (sellerInfo?.location != null &&
            sellerInfo!.location!.trim().isNotEmpty)
        ? sellerInfo!.location!
        : '—';

    final followers = sellerInfo?.followerCount ?? 0;
    final productCount = sellerInfo?.productCount ?? products.length;
    final avatarUrl = sellerInfo?.avatarUrl;

    if (sellerInfoLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 8 : 16,
        vertical: mobile ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerLeft(name, avatarUrl, mobile),
                const SizedBox(height: 12),
                _headerStats(location, followers, productCount, mobile),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 4, child: _headerLeft(name, avatarUrl, mobile)),
                Expanded(
                  flex: 3,
                  child:
                      _headerStats(location, followers, productCount, mobile),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/seller_banner.png',
                      height: 90,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _headerLeft(String name, String? avatarUrl, bool mobile) {
    final hasAvatar = avatarUrl != null &&
        avatarUrl.trim().isNotEmpty &&
        (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'));

    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: mobile ? 52 : 64,
            height: mobile ? 52 : 64,
            child: hasAvatar
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarPlaceholder(mobile),
                  )
                : _avatarPlaceholder(mobile),
          ),
        ),
        SizedBox(width: mobile ? 10 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: mobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff28733D),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Follow Seller
                  GestureDetector(
                    onTap: () {
                      setState(() => isFollowing = !isFollowing);
                      // TODO: follow / unfollow API
                    },
                    child: Container(
                      height: mobile ? 28 : 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isFollowing
                            ? Colors.grey.shade600
                            : const Color(0xff2E7D32),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFollowing ? Icons.check : Icons.add,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isFollowing ? 'Following' : 'Follow',
                            style: TextStyle(
                              fontSize: mobile ? 11 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Chat Seller
                  GestureDetector(
                    onTap: () {
                      // TODO: open chat with this seller
                    },
                    child: Container(
                      height: mobile ? 28 : 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xffF28C00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Chat Seller',
                            style: TextStyle(
                              fontSize: mobile ? 11 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatarPlaceholder(bool mobile) {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: mobile ? 28 : 36,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _headerStats(
    String location,
    int followers,
    int productCount,
    bool mobile,
  ) {
    final style = TextStyle(
      fontSize: mobile ? 11 : 13,
      color: Colors.black87,
    );

    Widget row(IconData icon, String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(icon, size: mobile ? 14 : 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(Icons.location_on_outlined, location),
        row(
          Icons.people_outline,
          '${NumberFormat('#,###').format(followers)} Followers',
        ),
        row(
          Icons.inventory_2_outlined,
          '${NumberFormat('#,###').format(productCount)} Products',
        ),
        row(Icons.schedule, 'Usually responds within 2 hours'),
      ],
    );
  }

  // SEARCH + FILTERS

  Widget buildSearchBox(bool mobile) {
    return SizedBox(
      height: mobile ? 28 : 38,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() => _currentPage = 1),
        style: TextStyle(fontSize: mobile ? 10 : 13),
        decoration: InputDecoration(
          hintText: 'Search Items',
          hintStyle: TextStyle(
            fontSize: mobile ? 9 : 12,
            color: Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: mobile ? 15 : 20,
            color: Colors.grey.shade600,
          ),
          isDense: true,
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xffC77C2E)),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryFilter(bool mobile) {
    return SizedBox(
      width: mobile ? 125 : 170,
      height: mobile ? 27 : 34,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            isDense: true,
            icon: Icon(Icons.keyboard_arrow_down, size: mobile ? 13 : 17),
            style: TextStyle(
              color: Colors.black87,
              fontSize: mobile ? 8.5 : 12,
            ),
            dropdownColor: Colors.white,
            items: [
              const DropdownMenuItem<String>(
                value: 'By Category',
                child: Text(
                  'By Category',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...categories.map(
                (category) => DropdownMenuItem<String>(
                  value: category.categoryName,
                  child: Text(
                    category.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: categoryLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      selectedCategory = value;
                      if (value == 'By Category') {
                        selectedCategoryId = null;
                      } else {
                        final match = categories
                            .firstWhere((c) => c.categoryName == value);
                        selectedCategoryId = match.categoryId;
                      }
                      _currentPage = 1;
                    });
                  },
          ),
        ),
      ),
    );
  }

  Widget buildFilters(bool mobile) {
    return SizedBox(
      height: mobile ? 27 : 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            buildCategoryFilter(mobile),
            SizedBox(width: mobile ? 8 : 12),
            buildFilter(
              selectedPrice,
              ['Price', 'Under 50,000', '50,000 - 100,000', 'Over 100,000'],
              (value) {
                setState(() {
                  selectedPrice = value;
                  _currentPage = 1;
                });
              },
              mobile,
            ),
            SizedBox(width: mobile ? 8 : 12),
            buildFilter(
              selectedSort,
              ['Primmys by Price', 'Lowest Price', 'Highest Price'],
              (value) {
                setState(() {
                  selectedSort = value;
                  _currentPage = 1;
                });
              },
              mobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilter(
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
    bool mobile,
  ) {
    return SizedBox(
      width: mobile ? 125 : 170,
      height: mobile ? 27 : 34,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            icon: Icon(Icons.keyboard_arrow_down, size: mobile ? 13 : 17),
            style: TextStyle(
              color: Colors.black87,
              fontSize: mobile ? 8.5 : 12,
            ),
            dropdownColor: Colors.white,
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }

  // PRODUCT GRID — NO EDIT BUTTON

  Widget buildProductGrid(bool mobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        if (constraints.maxWidth < 500) {
          columns = 2;
        } else if (constraints.maxWidth < 800) {
          columns = 3;
        } else {
          columns = 5;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pagedProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: mobile ? 6 : 10,
            mainAxisSpacing: mobile ? 6 : 10,
            childAspectRatio: mobile ? 0.62 : 1.1,
          ),
          itemBuilder: (context, index) {
            return buildProductCard(pagedProducts[index], mobile);
          },
        );
      },
    );
  }

  Widget buildProductCard(Product product, bool mobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image only — no edit button
          SizedBox(
            height: mobile ? 75 : 145,
            width: double.infinity,
            child: _buildProductImage(product.imageUrl, mobile),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 9 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatPrice(product.price.toString())} Kyat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 9.5 : 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: mobile ? 22 : 28,
                    child: ElevatedButton(
                      onPressed: () {
                        if (product.productId != null) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  ProductDetailPage(
                                productId: product.productId!,
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF28C00),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: mobile ? 9 : 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: favouriteLoadingIds.contains(product.productId)
                      ? null
                      : () => toggleFavourite(product),
                  child: SizedBox(
                    width: mobile ? 26 : 32,
                    height: mobile ? 26 : 32,
                    child: favouriteLoadingIds.contains(product.productId)
                        ? Padding(
                            padding: const EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                favouriteProductIds
                                        .contains(product.productId)
                                    ? Colors.red
                                    : Colors.grey.shade600,
                              ),
                            ),
                          )
                        : Icon(
                            favouriteProductIds.contains(product.productId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: mobile ? 18 : 22,
                            color: favouriteProductIds
                                    .contains(product.productId)
                                ? Colors.red
                                : Colors.grey.shade600,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imagePath, bool mobile) {
    final url = getProductImageUrl(imagePath);
    if (url == null) {
      return Container(
        color: const Color(0xffF2F2F2),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: mobile ? 25 : 40,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xffF2F2F2),
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              size: mobile ? 25 : 40,
              color: Colors.grey.shade400,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xffF2F2F2),
          child: Center(
            child: SizedBox(
              width: mobile ? 15 : 22,
              height: mobile ? 15 : 22,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Widget _buildPagination() {
    final total = totalPages;
    if (filteredProducts.isEmpty || total <= 1) {
      return const SizedBox.shrink();
    }

    final pages = _visiblePageNumbers(current: _currentPage, total: total);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageArrow(
            icon: Icons.chevron_left,
            enabled: _currentPage > 1,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: 4),
          ...pages.map((page) {
            if (page == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              );
            }
            final isSelected = page == _currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  if (page != _currentPage) {
                    setState(() => _currentPage = page);
                  }
                },
                child: Container(
                  width: 40,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF28C00)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF28C00)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '$page',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          _pageArrow(
            icon: Icons.chevron_right,
            enabled: _currentPage < total,
            onTap: () => setState(() => _currentPage++),
          ),
        ],
      ),
    );
  }

  Widget _pageArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled ? Colors.grey.shade400 : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.black87 : Colors.grey.shade400,
        ),
      ),
    );
  }

  List<int?> _visiblePageNumbers({
    required int current,
    required int total,
  }) {
    if (total <= 7) {
      return List<int?>.generate(total, (i) => i + 1);
    }

    final Set<int> set = {1, total, current};
    for (int i = current - 1; i <= current + 1; i++) {
      if (i >= 1 && i <= total) set.add(i);
    }
    if (current <= 3) set.addAll([1, 2, 3, 4]);
    if (current >= total - 2) {
      set.addAll([total - 3, total - 2, total - 1, total]);
    }

    final sorted = set.where((p) => p >= 1 && p <= total).toList()..sort();
    final List<int?> result = [];
    int? prev;
    for (final p in sorted) {
      if (prev != null && p - prev > 1) result.add(null);
      result.add(p);
      prev = p;
    }
    return result;
  }

  // ============================================================
  // NEWEST + SALES SECTIONS
  // ============================================================

  Widget buildProductSections(bool mobile) {
    final sales = products.length > 4
        ? products.skip(4).take(4).toList()
        : <Product>[];

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildNewestArrivalsSection(true),
          const SizedBox(height: 15),
          buildProductSection(title: 'Sales', items: sales, mobile: true),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: buildNewestArrivalsSection(false)),
        const SizedBox(width: 20),
        Expanded(
          child: buildProductSection(
            title: 'Sales',
            items: sales,
            mobile: false,
          ),
        ),
      ],
    );
  }

  Widget buildNewestArrivalsSection(bool mobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Newest Arrivals',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: mobile ? 20 : 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewInPage()),
                );
              },
              child: Text(
                'VIEW ALL',
                style: TextStyle(
                  fontSize: mobile ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff28733D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        if (newestArrivalsLoading)
          const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (newestArrivalsError != null)
          SizedBox(
            height: 100,
            child: Center(
              child: TextButton(
                onPressed: loadNewestArrivals,
                child: const Text('Failed to load. Tap to retry'),
              ),
            ),
          )
        else if (newestArrivals.isEmpty)
          const SizedBox(
            height: 100,
            child: Center(child: Text('No newest arrivals available.')),
          )
        else
          SizedBox(
            height: mobile ? 150 : 205,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount:
                  newestArrivals.length > 4 ? 4 : newestArrivals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 5),
              itemBuilder: (context, index) {
                final item = newestArrivals[index];
                return SizedBox(
                  width: mobile ? 135 : 180,
                  child: buildSmallNewInCard(item, mobile),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget buildSmallNewInCard(NewInModel item, bool mobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: mobile ? 85 : 125,
            width: double.infinity,
            child: _buildProductImage(item.imageUrl, mobile),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 9 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${NumberFormat('#,##0').format(item.price)} Kyat',
                  style: TextStyle(
                    fontSize: mobile ? 9 : 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 1, 7, 6),
            child: SizedBox(
              width: double.infinity,
              height: mobile ? 22 : 28,
              child: ElevatedButton(
                onPressed: () {
                  if (item.productId != 0) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, a, b) =>
                            ProductDetailPage(productId: item.productId),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF28C00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'VIEW DETAILS',
                  style: TextStyle(
                    fontSize: mobile ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductSection({
    required String title,
    required List<Product> items,
    required bool mobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: mobile ? 20 : 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'VIEW ALL',
                style: TextStyle(
                  fontSize: mobile ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff28733D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: mobile ? 150 : 205,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 5),
            itemBuilder: (context, index) {
              final product = items[index];
              return SizedBox(
                width: mobile ? 135 : 180,
                child: buildSmallProductCard(product, mobile),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSmallProductCard(Product product, bool mobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: mobile ? 85 : 125,
            width: double.infinity,
            child: _buildProductImage(product.imageUrl, mobile),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 9 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatPrice(product.price.toString())} Kyat',
                  style: TextStyle(
                    fontSize: mobile ? 9 : 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 1, 7, 6),
            child: SizedBox(
              width: double.infinity,
              height: mobile ? 22 : 28,
              child: ElevatedButton(
                onPressed: () {
                  if (product.productId != null) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, a, b) => ProductDetailPage(
                          productId: product.productId!,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF28C00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'VIEW DETAILS',
                  style: TextStyle(
                    fontSize: mobile ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FAVOURITE
  // ============================================================

  Future<void> toggleFavourite(Product product) async {
    final productId = product.productId;
    if (productId == null) return;
    if (favouriteLoadingIds.contains(productId)) return;

    final bool isFavourite = favouriteProductIds.contains(productId);
    setState(() => favouriteLoadingIds.add(productId));

    try {
      final authService = context.read<AuthService>();
      bool success;

      if (isFavourite) {
        success = await _service.removeFavourite(
          authService: authService,
          productId: productId,
        );
        if (!mounted) return;
        if (success) {
          setState(() => favouriteProductIds.remove(productId));
        }
      } else {
        success = await _service.addFavourite(
          authService: authService,
          productId: productId,
        );
        if (!mounted) return;
        if (success) {
          setState(() => favouriteProductIds.add(productId));
        }
      }
    } finally {
      if (mounted) {
        setState(() => favouriteLoadingIds.remove(productId));
      }
    }
  }
}
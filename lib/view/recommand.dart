import 'package:elephant_mall/services/recommand_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/new_in.dart';
import '../services/new_in_service.dart' show CategoryOption;
import '../services/auth_service.dart';
import '../services/Category_service.dart' show ApiService;

import 'common/header.dart';
import 'common/footer.dart';
import 'common/favorite_helper.dart';
import 'common/loading_widget.dart';

class RecommendedPage extends StatefulWidget {
  const RecommendedPage({super.key});

  @override
  State<RecommendedPage> createState() => _RecommendedPageState();
}

class _RecommendedPageState extends State<RecommendedPage> {
  String selectedCategoryId = '';   // '' = All
  String selectedPrice = 'All Prices';
  String selectedSort = 'Newest';

  List<NewInModel> allProducts = [];
  List<CategoryOption> categories = [];

  static const int pageSize = 18;
  int _currentPage = 1;

  final RecommendedService _service = RecommendedService();

  bool isLoading = true;
  bool isCategoryLoading = true;
  String? errorMessage;
  String? categoryErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await _service.getCategories();
      if (!mounted) return;
      setState(() {
        categories = result;
        isCategoryLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isCategoryLoading = false;
        categoryErrorMessage = e.toString();
      });
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final auth = context.read<AuthService>();
      if (!auth.isLoggedIn) {
        await _showLoginRequiredDialog();
        if (!mounted) return;
        setState(() => isLoading = false);
        return;
      }

      final products = await _service.getRecommendedProducts(
        authService: auth,
      );

      if (!mounted) return;

      setState(() {
        allProducts = products;
        isLoading = false;
        errorMessage = null;
        _currentPage = 1;
      });
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString().toLowerCase();
      if (msg.contains('401') || msg.contains('unauthorized')) {
        await _showLoginRequiredDialog();
        if (!mounted) return;
        setState(() {
          isLoading = false;
          allProducts = [];
        });
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  // ─────────────────────────── FILTERING ───────────────────────────

  List<NewInModel> get filteredProducts {
    List<NewInModel> result = List.from(allProducts);

    if (selectedCategoryId.isNotEmpty) {
      result = result.where((p) => p.categoryId == selectedCategoryId).toList();
    }

    if (selectedPrice == 'Under 50,000') {
      result = result.where((p) => p.price < 50000).toList();
    } else if (selectedPrice == '50,000 - 100,000') {
      result = result
          .where((p) => p.price >= 50000 && p.price <= 100000)
          .toList();
    } else if (selectedPrice == 'Over 100,000') {
      result = result.where((p) => p.price > 100000).toList();
    }

    if (selectedSort == 'Price: Low to High') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedSort == 'Price: High to Low') {
      result.sort((a, b) => b.price.compareTo(a.price));
    } else {
      result.sort((a, b) => b.productId.compareTo(a.productId));
    }
    return result;
  }

  int get totalPages {
    final total = filteredProducts.length;
    if (total == 0) return 1;
    return (total / pageSize).ceil();
  }

  List<NewInModel> get pagedProducts {
    final list = filteredProducts;
    final start = (_currentPage - 1) * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  // ─────────────────────────── DIALOGS ───────────────────────────

  Future<void> _showLoginRequiredDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xfffdfaf4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFFC77C2E), size: 28),
            SizedBox(width: 10),
            Text(
              "Login Required",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Your session has expired or you are not logged in.\n\n"
          "Please login to see recommendations.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC77C2E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              if (!mounted) return;
              final auth = context.read<AuthService>();
              auth.logout();
              context.go('/login');
            },
            child: const Text(
              "Login",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── FAVOURITE ───────────────────────────

  Future<void> _toggleFavourite(NewInModel product) async {
    await FavoriteHelper.toggleFavorite(
      context,
      productId: product.productId,
      isCurrentlyFavorite: product.favourite == 1,
    );

    if (!mounted) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      product.favourite = authService.isFavorite(product.productId) ? 1 : 0;
    });
  }

  // ─────────────────────────── DROPDOWNS ───────────────────────────

  Widget _buildCategoryDropdown() {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: '', child: Text('All Categories')),
      ...categories.map(
        (c) => DropdownMenuItem(
          value: c.id,
          child: Text(c.name, overflow: TextOverflow.ellipsis),
        ),
      ),
    ];

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffD8D8D8)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategoryId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: const TextStyle(fontSize: 11, color: Colors.black87),
          items: items,
          onChanged: isCategoryLoading
              ? null
              : (v) => setState(() {
                    selectedCategoryId = v ?? '';
                    _currentPage = 1;
                  }),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffD8D8D8)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: const TextStyle(fontSize: 11, color: Colors.black87),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFilterRow(bool mobileView) {
    if (mobileView) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildCategoryDropdown()),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdown(
                  value: selectedPrice,
                  items: const [
                    'All Prices',
                    'Under 50,000',
                    '50,000 - 100,000',
                    'Over 100,000',
                  ],
                  onChanged: (v) => setState(() {
                    selectedPrice = v!;
                    _currentPage = 1;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: selectedSort,
            items: const [
              'Newest',
              'Price: Low to High',
              'Price: High to Low',
            ],
            onChanged: (v) => setState(() {
              selectedSort = v!;
              _currentPage = 1;
            }),
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(width: 180, child: _buildCategoryDropdown()),
        const SizedBox(width: 10),
        SizedBox(
          width: 180,
          child: _buildDropdown(
            value: selectedPrice,
            items: const [
              'All Prices',
              'Under 50,000',
              '50,000 - 100,000',
              'Over 100,000',
            ],
            onChanged: (v) => setState(() {
              selectedPrice = v!;
              _currentPage = 1;
            }),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 180,
          child: _buildDropdown(
            value: selectedSort,
            items: const [
              'Newest',
              'Price: Low to High',
              'Price: High to Low',
            ],
            onChanged: (v) => setState(() {
              selectedSort = v!;
              _currentPage = 1;
            }),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── PAGINATION ───────────────────────────

  Widget _buildPagination() {
    final total = totalPages;
    if (filteredProducts.isEmpty || total <= 1) return const SizedBox.shrink();

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
                child: Text('...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    )),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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

  List<int?> _visiblePageNumbers({required int current, required int total}) {
    if (total <= 7) return List<int?>.generate(total, (i) => i + 1);
    final set = <int>{1, total, current};
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

  // ─────────────────────────── GRID + CARD ───────────────────────────

  Widget _buildProductGrid(List<NewInModel> products, bool mobileView) {
    if (products.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 240,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.recommend_outlined,
                  size: 45, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                'No recommendations yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Browse products and we\'ll suggest things for you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mobileView ? 2 : 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: mobileView ? 195 : 205,
      ),
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(NewInModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffE1E1E1)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xffF4F4F4),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // OWNER-ONLY MENU
                Positioned(
                  top: 4,
                  left: 4,
                  child: Consumer<AuthService>(
                    builder: (context, authService, child) {
                      final isLoggedIn = authService.isLoggedIn;
                      final currentUserId = authService.currentUser?.id;
                      if (!isLoggedIn || currentUserId == null) {
                        return const SizedBox.shrink();
                      }
                      return FutureBuilder<int?>(
                        future: context
                            .read<ApiService>()
                            .getProductOwnerId(product.productId),
                        builder: (context, snapshot) {
                          final isOwner =
                              snapshot.hasData &&
                              snapshot.data.toString() ==
                                  currentUserId.toString();
                          if (!isOwner) return const SizedBox.shrink();
                          return PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            icon: const Icon(Icons.more_vert,
                                color: Colors.black87),
                            onSelected: (value) {
                              if (value == 'edit') {
                                context.go(
                                  '/sell?productId=${product.productId}',
                                );
                              } else if (value == 'delete') {
                                _deleteProduct(
                                  product.productId,
                                  product.productName,
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined,
                                        size: 18,
                                        color: Color(0xff28733D)),
                                    SizedBox(width: 10),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        size: 18, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text('Delete',
                                        style:
                                            TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),

                // FAVOURITE
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => _toggleFavourite(product),
                    borderRadius: BorderRadius.circular(20),
                    child: Icon(
                      product.favourite == 1
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 22,
                      color: product.favourite == 1
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Text(
              product.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Text(
              "${NumberFormat('#,##0').format(product.price)} MMK",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 1, 7, 6),
            child: SizedBox(
              width: double.infinity,
              height: 28,
              child: OutlinedButton(
                onPressed: () async {
                  if (product.productId == 0) return;
                  final auth =
                      Provider.of<AuthService>(context, listen: false);
                  if (auth.currentUser != null) {
                    _service
                        .saveRecentView(
                          authService: auth,
                          productId: product.productId,
                        )
                        .catchError((e) {
                      debugPrint('saveRecentView error: $e');
                      return false;
                    });
                  }
                  if (!mounted) return;
                  context.go('/product/${product.productId}');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "View Details",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
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

  Future<void> _deleteProduct(int productId, String productName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final apiService = context.read<ApiService>();
    final ok = await apiService.deleteProductFromServer(productId);
    if (!mounted) return;

    if (ok) {
      setState(() {
        allProducts.removeWhere((p) => p.productId == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete product.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─────────────────────────── BUILD ───────────────────────────

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final products = pagedProducts;

    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Column(
        children: [
          const CommonHeader(showMobileHeader: true),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mobileView ? 12 : 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'RECOMMENDED FOR YOU',
                          style: TextStyle(
                            fontSize: mobileView ? 16 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildFilterRow(mobileView),
                        const SizedBox(height: 10),

                        if (!isLoading && errorMessage == null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              filteredProducts.isEmpty
                                  ? 'No results'
                                  : 'Showing '
                                      '${((_currentPage - 1) * pageSize) + 1}–'
                                      '${((( _currentPage - 1) * pageSize) + pageSize)
                                          .clamp(0, filteredProducts.length)} '
                                      'of ${filteredProducts.length} results',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        const SizedBox(height: 5),

                        if (isLoading)
                          const CommonLoading(
                            size: 42,
                            message: 'Loading recommendations...',
                            height: 240,
                          )
                        else if (errorMessage != null)
                          CommonError(
                            height: 240,
                            onRetry: isLoading ? null : _loadProducts,
                            isRetryEnabled: !isLoading,
                          )
                        else
                          _buildProductGrid(products, mobileView),

                        _buildPagination(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!mobileView) const CommonFooter(),
        ],
      ),
      bottomNavigationBar: mobileView
          ? const CommonBottomBar(currentIndex: 0)
          : null,
    );
  }
}
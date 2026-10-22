import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/sale.dart';
import '../services/sale_service.dart';
import 'common/header.dart';
import 'common/footer.dart';
import 'package:intl/intl.dart';
import '../services/new_in_service.dart';

import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'product_detail_page.dart';
import 'common/loading_widget.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  String selectedCategoryId = ''; // '' = All
  String selectedDiscount = 'Discount %';
  String selectedPrice = 'Price Range';
  String selectedSort = 'Biggest Savings';

  List<SaleModel> allProducts = [];
  static const int pageSize = 10;
  int _currentPage = 1;

  bool isLoading = true;
  String? errorMessage;

  List<CategoryOption> categories = [];
  bool isCategoryLoading = false;

  final SaleService _saleService = SaleService();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => isCategoryLoading = true);
    try {
      final result = await NewInService().getCategories();
      // final result = await _saleService.getCategories();

      if (!mounted) return;
      setState(() {
        categories = result;
        isCategoryLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isCategoryLoading = false);
      debugPrint('Category load error: $e');
    }
  }

  List<SaleModel> get filteredProducts {
    List<SaleModel> result = List.from(allProducts);

    if (selectedCategoryId.isNotEmpty) {
      result = result.where((p) => p.categoryId == selectedCategoryId).toList();
    }

    if (selectedDiscount == '20%+') {
      result = result.where((p) => p.discount >= 20).toList();
    } else if (selectedDiscount == '30%+') {
      result = result.where((p) => p.discount >= 30).toList();
    } else if (selectedDiscount == '40%+') {
      result = result.where((p) => p.discount >= 40).toList();
    }

    if (selectedPrice == 'Under 50,000') {
      result = result.where((p) => p.salePrice < 50000).toList();
    } else if (selectedPrice == '50,000 - 100,000') {
      result = result
          .where((p) => p.salePrice >= 50000 && p.salePrice <= 100000)
          .toList();
    } else if (selectedPrice == 'Over 100,000') {
      result = result.where((p) => p.salePrice > 100000).toList();
    }

    if (selectedSort == 'Biggest Savings') {
      result.sort(
        (a, b) => (b.originalPrice - b.salePrice).compareTo(
          a.originalPrice - a.salePrice,
        ),
      );
    } else if (selectedSort == 'Discount: High to Low') {
      result.sort((a, b) => b.discount.compareTo(a.discount));
    } else if (selectedSort == 'Price: Low to High') {
      result.sort((a, b) => a.salePrice.compareTo(b.salePrice));
    } else if (selectedSort == 'Price: High to Low') {
      result.sort((a, b) => b.salePrice.compareTo(a.salePrice));
    }

    return result;
  }

  int get totalPages {
    final total = filteredProducts.length;
    if (total == 0) return 1;
    return (total / pageSize).ceil();
  }

  List<SaleModel> get pagedProducts {
    final list = filteredProducts;
    final start = (_currentPage - 1) * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final products = await _saleService.getSaleProducts(
        // authService: Provider.of<AuthService>(context, listen: false),
      );
      if (!mounted) return;
      setState(() {
        allProducts = products;
        isLoading = false;
        _currentPage = 1;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }
  // RESPONSIVE

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  bool _isUnauthorizedError(Object error) {
    final m = error.toString().toLowerCase();
    return m.contains('401') ||
        m.contains('unauthorized') ||
        m.contains('please login');
  }

  Future<void> _showLoginRequiredDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xfffdfaf4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: Color(0xFFC77C2E), size: 28),
              SizedBox(width: 10),
              Text(
                'Login Required',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Your session has expired or you are not logged in.\n\n'
            'Please login to continue.',
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text(
                'Login',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleFavourite(SaleModel product) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.currentUser == null) {
      await _showLoginRequiredDialog();
      return;
    }

    final productId = product.productId;
    if (productId == 0) return;

    final isFav = product.favourite == 1;

    try {
      final success = isFav
          ? await _saleService.removeFavourite(
              authService: authService,
              productId: productId,
            )
          : await _saleService.addFavourite(
              authService: authService,
              productId: productId,
            );

      if (!mounted) return;

      if (success) {
        setState(() {
          product.favourite = isFav ? 0 : 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFav ? 'Could not remove favourite' : 'Could not add favourite',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (_isUnauthorizedError(e)) {
        await _showLoginRequiredDialog();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);

    // if (isLoading) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    final products = pagedProducts;

    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),

      body: Column(
        children: [
          // HEADER
          const CommonHeader(showMobileHeader: true),

          // CONTENT
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
                        const SizedBox(height: 8),

                        _buildHeroBanner(mobileView),

                        const SizedBox(height: 10),

                        _buildFilterRow(mobileView),

                        const SizedBox(height: 8),

                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF28C00),
                              ),
                            ),
                          )
                        else if (errorMessage != null)
                          CommonError(
                            height: 240,
                            onRetry: isLoading ? null : _loadProducts,
                            isRetryEnabled: !isLoading,
                          )
                        else ...[
                          _buildProductCount(filteredProducts.length),
                          const SizedBox(height: 5),
                          _buildProductGrid(products, mobileView),
                          _buildPagination(),
                          const SizedBox(height: 20),
                          // _buildSaleCategories(mobileView),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // FOOTER
          if (!mobileView) const CommonFooter(),
        ],
      ),

      // ==========================================================
      // MOBILE BOTTOM BAR
      // ==========================================================
      bottomNavigationBar: mobileView
          ? const CommonBottomBar(currentIndex: 2)
          : null,
    );
  }

  // HERO BANNER

  Widget _buildHeroBanner(bool mobileView) {
    return Container(
      height: mobileView ? 150 : 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: AssetImage('assets/sale.png'),
          fit: BoxFit.fill,
          alignment: Alignment(0, -0.3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: mobileView ? 20 : 35,
          top: mobileView ? 1 : 1,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: mobileView ? 16 : 150,
            top: mobileView ? 12 : 10,
            right: mobileView ? 100 : 300,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text("YANGON",
              //   style: TextStyle(
              //     color: Colors.black87,
              //     fontSize: mobileView ? 11 : 16,
              //     fontWeight: FontWeight.w500,
              //     letterSpacing: 6,
              //   ),
              // ),
              Text(
                "YANGON SUMMER",
                style: TextStyle(
                  color: const Color(0xFF4A4A4A),
                  fontSize: mobileView ? 24 : 32,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                  height: 1.0,
                ),
              ),
              Text(
                "SALE",
                style: TextStyle(
                  color: const Color(0xFFF28C00),
                  fontSize: mobileView ? 30 : 72,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  height: 1.0,
                ),
              ),
              // SizedBox(height: mobileView ? 6 : 10),
              Text(
                "Cool styles for Yangon's hottest days.\n"
                "Fashion, bags, shoes, and more.",
                style: TextStyle(
                  color: const Color(0xFF4A4A4A),
                  fontSize: mobileView ? 11 : 14,
                  height: 1.4,
                ),
              ),
              SizedBox(height: mobileView ? 10 : 16),
              SizedBox(
                height: mobileView ? 32 : 40,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF28C00),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: mobileView ? 16 : 24,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "SHOP NOW",
                        style: TextStyle(
                          fontSize: mobileView ? 11 : 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right,
                        size: mobileView ? 16 : 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FILTER ROW
  Widget _buildCategoryDropdown() {
    final ids = categories.map((c) => c.id).toSet();
    final value = selectedCategoryId.isEmpty || ids.contains(selectedCategoryId)
        ? selectedCategoryId
        : '';

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
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: const TextStyle(fontSize: 11, color: Colors.black87),
          items: items,
          onChanged: (v) {
            setState(() {
              selectedCategoryId = v ?? '';
              _currentPage = 1;
            });
          },
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
                  value: selectedDiscount,
                  items: const ["Discount %", "20%+", "30%+", "40%+"],
                  onChanged: (value) {
                    setState(() {
                      selectedDiscount = value!;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: selectedPrice,
                  items: const [
                    'Price Range',
                    'Under 50,000',
                    '50,000 - 100,000',
                    'Over 100,000',
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPrice = value!;
                      _currentPage = 1;
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildDropdown(
                  value: selectedSort,
                  items: const [
                    'Biggest Savings',
                    'Discount: High to Low',
                    'Price: Low to High',
                    'Price: High to Low',
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedSort = value!;
                      _currentPage = 1;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }

    // DESKTOP
    return Row(
      children: [
        SizedBox(width: 180, child: _buildCategoryDropdown()),

        const SizedBox(width: 10),

        SizedBox(
          width: 150,
          child: _buildDropdown(
            value: selectedDiscount,
            items: const ['Discount %', '20%+', '30%+', '40%+'],
            onChanged: (value) {
              setState(() {
                selectedDiscount = value!;
                _currentPage = 1;
              });
            },
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 150,
          child: _buildDropdown(
            value: selectedPrice,
            items: const [
              'Price Range',
              'Under 50,000',
              '50,000 - 100,000',
              'Over 100,000',
            ],
            onChanged: (value) {
              setState(() {
                selectedPrice = value!;
                _currentPage = 1;
              });
            },
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 180,
          child: _buildDropdown(
            value: selectedSort,
            items: const [
              'Biggest Savings',
              'Discount: High to Low',
              'Price: Low to High',
              'Price: High to Low',
            ],
            onChanged: (value) {
              setState(() {
                selectedSort = value!;
                _currentPage = 1;
              });
            },
          ),
        ),

        const Spacer(),
      ],
    );
  }

  // DROPDOWN

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
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // PRODUCT COUNT

  Widget _buildProductCount(int filteredCount) {
    final total = filteredCount;
    final start = total == 0 ? 0 : ((_currentPage - 1) * pageSize) + 1;
    final end = (start + pageSize - 1).clamp(0, total);

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        total == 0 ? 'No results' : 'Showing $start–$end of $total results',
        style: const TextStyle(fontSize: 15, color: Colors.black54),
      ),
    );
  }

  // PRODUCT GRID

  Widget _buildProductGrid(List<SaleModel> products, bool mobileView) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No sale products found.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // 2 products on mobile
        // 5 products on desktop
        crossAxisCount: mobileView ? 2 : 5,

        crossAxisSpacing: 8,
        mainAxisSpacing: 8,

        mainAxisExtent: mobileView ? 225 : 235,
      ),
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  // PRODUCT CARD

  Widget _buildProductCard(SaleModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffE1E1E1)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          SizedBox(
            height: 125,
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

                // DISCOUNT BADGE
                if (product.discount > 0)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffE85B0A),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '-${product.discount}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // FAVORITE
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
                      color: product.favourite == 1 ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PRODUCT NAME
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

          // PRICE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Row(
              children: [
                Text(
                  '${NumberFormat('#,##0').format(product.originalPrice)} Ks',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${NumberFormat('#,##0').format(product.salePrice)} Ks',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // RATING
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),

            // child: Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     // Stars
            //     Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: List.generate(5, (index) {
            //         return Icon(
            //           index < product.rating.round()
            //               ? Icons.star
            //               : Icons.star_border,
            //           size: 13,
            //           color: Colors.orange,
            //         );
            //       }),
            //     ),

            //     const SizedBox(width: 5),

            //     // Review count
            //     Text(
            //       "(${product.reviewCount})",
            //       style: const TextStyle(fontSize: 10, color: Colors.grey),
            //     ),
            //   ],
            // ),
          ),

          const Spacer(),

          // VIEW DEAL BUTTON
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 1, 7, 6),
            child: SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                onPressed: () async {
                  if (product.productId == 0) return;

                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );

                  // Fire-and-forget recent view (only when logged in)
                  if (authService.currentUser != null) {
                    _saleService
                        .saveRecentView(
                          authService: authService,
                          productId: product.productId,
                        )
                        .then((success) {
                          print(
                            'saveRecentView (Sale) finished → success=$success, productId=${product.productId}',
                          );
                        })
                        .catchError((e) {
                          print(
                            'saveRecentView (Sale) failed (ignored) → $e, productId=${product.productId}',
                          );
                          // Optional: force login on 401
                          // if (_isUnauthorizedError(e) && mounted) {
                          //   _showLoginRequiredDialog();
                          // }
                        });
                  } else {
                    print(
                      'saveRecentView (Sale) skipped – user not logged in, productId=${product.productId}',
                    );
                  }

                  // Navigate immediately
                  if (!mounted) return;
                  context.go('/product/${product.productId}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF28C00),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "VIEW DEAL",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              );
            }
            final selected = page == _currentPage;
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
                  height: 32,
                  constraints: const BoxConstraints(minWidth: 32),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFF28C00)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFF28C00)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '$page',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.black87,
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
    if (total <= 7) {
      return List<int?>.generate(total, (i) => i + 1);
    }

    final set = <int>{1, total, current};
    for (int i = current - 1; i <= current + 1; i++) {
      if (i >= 1 && i <= total) set.add(i);
    }
    if (current <= 3) set.addAll([1, 2, 3, 4]);
    if (current >= total - 2) {
      set.addAll([total - 3, total - 2, total - 1, total]);
    }

    final sorted = set.where((p) => p >= 1 && p <= total).toList()..sort();
    final result = <int?>[];
    int? prev;
    for (final p in sorted) {
      if (prev != null && p - prev > 1) result.add(null);
      result.add(p);
      prev = p;
    }
    return result;
  }

  // // SALE CATEGORY STRIP
  // Widget _buildSaleCategories(bool mobileView) {
  //   final categories = [
  //     {
  //       "title": "Fashion Sale",
  //       "subtitle": "Up to 50% Off",
  //       "icon": Icons.checkroom,
  //     },
  //     {
  //       "title": "Accessories Sale",
  //       "subtitle": "Up to 50% Off",
  //       "icon": Icons.watch,
  //     },
  //     {
  //       "title": "Bags Sale",
  //       "subtitle": "Up to 50% Off",
  //       "icon": Icons.shopping_bag,
  //     },
  //     {
  //       "title": "Shoes Sale",
  //       "subtitle": "Up to 50% Off",
  //       "icon": Icons.directions_run,
  //     },
  //     {
  //       "title": "Clearance",
  //       "subtitle": "Extra Discounts",
  //       "icon": Icons.local_offer,
  //     },
  //   ];

  //   Widget _buildSaleCategoryCard(
  //     Map<String, Object> category, {
  //     required double width,
  //     required double height,
  //   }) {
  //     return Container(
  //       width: width,
  //       height: height,
  //       padding: const EdgeInsets.symmetric(horizontal: 10),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         border: Border.all(color: const Color(0xffE1E1E1)),
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Row(
  //         children: [
  //           // ICON
  //           Container(
  //             width: 42,
  //             height: 42,
  //             decoration: const BoxDecoration(
  //               color: Color(0xffEEF6EE),
  //               shape: BoxShape.circle,
  //             ),
  //             child: Icon(
  //               category["icon"] as IconData,
  //               size: 22,
  //               color: const Color(0xff3A7D44),
  //             ),
  //           ),

  //           const SizedBox(width: 8),

  //           // TEXT
  //           Expanded(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   category["title"] as String,
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: const TextStyle(
  //                     fontSize: 11,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 Text(
  //                   category["subtitle"] as String,
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: const TextStyle(fontSize: 9, color: Colors.grey),
  //                 ),
  //               ],
  //             ),
  //           ),

  //           const Icon(Icons.chevron_right, size: 18),
  //         ],
  //       ),
  //     );
  //   }

  //   // MOBILE

  //   if (mobileView) {
  //     return SizedBox(
  //       height: 85,
  //       child: ListView.separated(
  //         scrollDirection: Axis.horizontal,
  //         itemCount: categories.length,
  //         separatorBuilder: (_, _) => const SizedBox(width: 8),
  //         itemBuilder: (context, index) {
  //           return _buildSaleCategoryCard(
  //             categories[index],
  //             width: 180,
  //             height: 85,
  //           );
  //         },
  //       ),
  //     );
  //   }

  //   // DESKTOP

  //   return SizedBox(
  //     height: 70,
  //     width: double.infinity,
  //     child: Row(
  //       children: List.generate(categories.length, (index) {
  //         return Expanded(
  //           child: Padding(
  //             padding: EdgeInsets.only(
  //               right: index == categories.length - 1 ? 0 : 8,
  //             ),
  //             child: _buildSaleCategoryCard(
  //               categories[index],
  //               width: double.infinity,
  //               height: 70,
  //             ),
  //           ),
  //         );
  //       }),
  //     ),
  //   );
  // }
}

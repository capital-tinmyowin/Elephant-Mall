import 'dart:async';
import 'package:elephant_mall/models/product.dart';
import 'package:elephant_mall/view/category_detail.dart';
import 'package:elephant_mall/view/new_in.dart';
import 'package:elephant_mall/view/sale.dart';
import 'package:elephant_mall/widgets/app_image.dart';
import 'package:intl/intl.dart';

import '../models/Category.dart';
import '../models/banner.dart';
import 'package:elephant_mall/services/home_service.dart';
import 'package:flutter/material.dart';
import '../models/promo.dart';
import 'common/footer.dart';
import 'common/header.dart';
import '../view/product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final PageController _bannerController = PageController();
  // Timer? _timer;
  // int currentBanner = 0;
  final HomeService _service = HomeService();
  List<BannerModel> banners = [];
  List<Category> categories = [];
  List<Product> products = [];
  List<Promo> promos = [];
  bool loading = true;
  final Set<int> _favoriteProductIds = {};
  int _currentPage = 1;
  final int _itemsPerPage = 14;
  int get totalPages {
    final total = products.length;
    if (total == 0) return 1;
    return (total / _itemsPerPage).ceil();
  }

  @override
  void initState() {
    super.initState();
    loadHome();
  }

  Future<void> loadHome() async {
    try {
      final result = await Future.wait([
        _service.getBanners(),
        _service.getCategories(),
        _service.getProducts(),
        _service.getPromos(),
      ]);
      if (!mounted) return;
      setState(() {
        banners = result[0] as List<BannerModel>;
        categories = result[1] as List<Category>;
        products = result[2] as List<Product>;
        promos = result[3] as List<Promo>;
        _currentPage = 1;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

  String imageUrl(dynamic path) {
    final value = path?.toString() ?? '';

    if (value.isEmpty) {
      return "";
    }

    if (value.startsWith("http")) {
      return value;
    }

    // return "http://localhost:5086$value";
    return value;
  }

  // void startAutoSlide() {
  //   _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
  //     if (!mounted) return;
  //     if (!_bannerController.hasClients) return;
  //     currentBanner = (currentBanner + 1) % banners.length;
  //     _bannerController.animateToPage(
  //       currentBanner,
  //       duration: const Duration(milliseconds: 500),
  //       curve: Curves.easeInOut,
  //     );
  //   });
  // }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  bool mobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = mobile(context);
    const sectionGap = SizedBox(height: 10);
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
                    padding: const EdgeInsets.all(20),
                    // padding: EdgeInsets.only(left: 80,right: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildHero(),
                        sectionGap,
                        if (isMobile) ...[buildPromotions(), sectionGap],
                        buildTitle("TRENDING CATEGORIES"),
                        sectionGap,
                        buildCategories(),
                        buildTitle("Trending Now in YANGON"),
                        sectionGap,
                        buildProducts(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (!isMobile) const CommonFooter(),
        ],
      ),
      bottomNavigationBar: isMobile ? CommonBottomBar(currentIndex: 0) : null,
    );
  }

  Widget buildHero() {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: isMobile ? 150 : 250,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // SINGLE BANNER IMAGE
              Image.asset(
                'assets/YangonSummerSunsetStyle.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.3),
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 40),
                  );
                },
              ),

              // DARK OVERLAY
              Container(color: Colors.black.withValues(alpha: 0.25)),

              // TEXT
              // Positioned(
              //   left: isMobile ? 15 : 40,
              //   top: isMobile ? 15 : 40,
              //   right: 10,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'YANGON SUMMER HEATWAVE SAVINGS!',
              //         maxLines: 1,
              //         overflow: TextOverflow.ellipsis,
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: isMobile ? 14 : 28,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),

              //       const SizedBox(height: 8),

              //       Text(
              //         'Cool styles for Yangon’s hottest days.',
              //         maxLines: 2,
              //         overflow: TextOverflow.ellipsis,
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: isMobile ? 11 : 16,
              //         ),
              //       ),

              //       const SizedBox(height: 15),

              //       ElevatedButton(
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.orange,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(20),
              //           ),
              //         ),
              //         onPressed: () {},
              //         child: const Text(
              //           'SHOP NOW',
              //           style: TextStyle(
              //             color: Colors.white,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPromotions() {
    if (promos.isEmpty) return const SizedBox();

    // Hardcode which promo goes to which page. Update these indices if you add more promos.
    // promo[0] = "Summer Sale 50% OFF"   -> /sale
    // promo[1] = "New Fashion Collection" -> /new-in
    final destinations = <Widget>[const NewInPage(), const SalePage()];

    return Row(
      spacing: 10,
      children: List.generate(promos.take(2).length, (i) {
        return Expanded(
          child: promo(promos[i], destinations[i % destinations.length]),
        );
      }),
    );
  }

  Widget promo(Promo item, Widget destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                destination,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.asset(
              item.imagePath,
              height: 110,
              width: double.infinity,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 110,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, size: 40),
              ),
            ),
            // Optional overlay so the card looks tappable
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.05)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  final ScrollController _categoryController = ScrollController();
  bool _showCategoryLeft = false;
  bool _showCategoryRight = false;

  void _scrollCategoryLeft() {
    final width = MediaQuery.of(context).size.width;

    _categoryController.animateTo(
      (_categoryController.offset - width * 0.6).clamp(
        0.0,
        _categoryController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollCategoryRight() {
    final width = MediaQuery.of(context).size.width;

    _categoryController.animateTo(
      (_categoryController.offset + width * 0.6).clamp(
        0.0,
        _categoryController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget buildCategories() {
    if (categories.isEmpty) {
      return const SizedBox();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_categoryController.hasClients) return;

          final position = _categoryController.position;

          final canScroll = position.maxScrollExtent > 0;

          if (mounted) {
            setState(() {
              _showCategoryLeft = position.pixels > 0;
              _showCategoryRight = canScroll;
            });
          }
        });

        return SizedBox(
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Category List
              ListView.builder(
                controller: _categoryController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 0),
                    child: Column(
                      children: [
                        Container(
                          height: 90,
                          width: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xffF3F3F3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            // onTap: () {
                            //   Navigator.push(
                            //     context,
                            //     PageRouteBuilder(
                            //       pageBuilder:
                            //           (
                            //             context,
                            //             animation,
                            //             secondaryAnimation,
                            //           ) => ProductDetailPage(
                            //             productId: item.categoryId,
                            //           ),
                            //       transitionDuration: Duration.zero,
                            //       reverseTransitionDuration: Duration.zero,
                            //     ),
                            //   );
                            // },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryDetailPage(
                                    categoryId: item.categoryId,
                                    categoryName: item.categoryName,
                                  ),
                                ),
                              );
                            },
                            child: AppImage(
                              imageUrl: item.photoPath,
                              height: 90,
                              width: 80,
                              fit: BoxFit.cover,
                              borderRadius: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailPage(
                                  categoryId: item.categoryId,
                                  categoryName: item.categoryName,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            item.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff6c8855),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Left Arrow
              if (_showCategoryLeft)
                Positioned(
                  left: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      color: Colors.black,
                      icon: const Icon(Icons.chevron_left, size: 35),
                      onPressed: _scrollCategoryLeft,
                    ),
                  ),
                ),

              // Right Arrow
              if (_showCategoryRight)
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      color: Colors.black,
                      icon: const Icon(Icons.chevron_right, size: 35),
                      onPressed: _scrollCategoryRight,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _resolveProductImage(String raw) {
    if (raw.isEmpty) {
      return 'https://picsum.photos/seed/home/400/400';
    }
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      // gstatic, googleusercontent, picsum are CORS-friendly
      if (raw.contains('gstatic.com') ||
          raw.contains('picsum.photos') ||
          raw.contains('googleusercontent.com')) {
        return raw;
      }
      // Everything else → placeholder (replace with your backend proxy URL if you have one)
      return 'https://picsum.photos/seed/${raw.hashCode.abs()}/400/400';
    }

    // Bare filename like "PI_1_1_260930192330493.jpg" — prefix with your backend's image host.
    // Change this prefix once you confirm the folder on the server (e.g. /Uploads/, /Images/).
    const prefix = 'https://www.capital-sys.net/CKMMallAPI/Uploads/';
    return '$prefix$raw';
  }

  Widget buildProducts() {
    if (products.isEmpty) {
      return const SizedBox();
    }

    final int totalProducts = products.length;
    final int totalPages = (totalProducts / _itemsPerPage).ceil();

    // Guard against invalid page after data changes
    final int currentPage = _currentPage.clamp(
      1,
      totalPages == 0 ? 1 : totalPages,
    );

    final int startIndex = (currentPage - 1) * _itemsPerPage;
    final int endIndex = startIndex + _itemsPerPage > totalProducts
        ? totalProducts
        : startIndex + _itemsPerPage;

    final List<Product> pageProducts = products.sublist(startIndex, endIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 0.5),
          child: Text(
            'Showing ${startIndex + 1}–$endIndex of $totalProducts products',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pageProducts.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200, // product card width
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 220,
          ),
          itemBuilder: (context, index) {
            final p = pageProducts[index];
            final isFav = _favoriteProductIds.contains(p.productId);

            return Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  // ClipRRect(
                  //   borderRadius: const BorderRadius.vertical(
                  //     top: Radius.circular(8),
                  //   ),
                  //   child: Image.asset(
                  //     p.imagePath,
                  //     height: 120,
                  //     width: double.infinity,
                  //     fit: BoxFit.contain,
                  //     errorBuilder: (context, error, stackTrace) {
                  //       return const SizedBox(
                  //         height: 120,
                  //         child: Center(
                  //           child: Icon(Icons.image_not_supported, size: 40),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  Center(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: AppImage(
                        imageUrl: p.image,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        borderRadius: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Text(
                      p.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        // Price
                        Flexible(
                          child: Text(
                            '${NumberFormat('#,##0').format(p.price)} MMK',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Rating
                        // Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: List.generate(
                        //     5,
                        //     (i) => Icon(
                        //       Icons.star,
                        //       size: 12,
                        //       color: i < p.rating.round()
                        //           ? Colors.amber
                        //           : Colors.grey,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        // VIEW DETAILS BUTTON
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => ProductDetailPage(
                                          productId: p.productId,
                                        ),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              },
                              child: const Text(
                                "View Details",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        // FAVORITE BUTTON
                        SizedBox(
                          width: 32,
                          height: 30,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            splashRadius: 18,
                            icon: Icon(
                              _favoriteProductIds.contains(p.productId)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: _favoriteProductIds.contains(p.productId)
                                  ? Colors.red
                                  : Colors.grey.shade700,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_favoriteProductIds.contains(p.productId)) {
                                  _favoriteProductIds.remove(p.productId);
                                } else {
                                  _favoriteProductIds.add(p.productId);
                                }
                              });
                            },
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
        const SizedBox(height: 16),
        _buildPagination(),
      ],
    );
  }

  Widget _buildPagination() {
    final int total = totalPages;
    if (products.isEmpty || total <= 1) {
      return const SizedBox.shrink();
    }

    final pages = _visiblePageNumbers(current: _currentPage, total: total);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // <
          _pageArrow(
            icon: Icons.chevron_left,
            enabled: _currentPage > 1,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: 4),

          // 1 2 3 ... N
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

          // >
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

  /// Builds [1, 2, 3, null, 11] where null = "..."
  List<int?> _visiblePageNumbers({required int current, required int total}) {
    if (total <= 7) {
      return List<int?>.generate(total, (i) => i + 1);
    }

    final Set<int> set = {1, total, current};

    for (int i = current - 1; i <= current + 1; i++) {
      if (i >= 1 && i <= total) set.add(i);
    }

    // Near start: 1 2 3 4 ... last
    if (current <= 3) {
      set.addAll([1, 2, 3, 4]);
    }
    // Near end: 1 ... last-3 last-2 last-1 last
    if (current >= total - 2) {
      set.addAll([total - 3, total - 2, total - 1, total]);
    }

    final sorted = set.where((p) => p >= 1 && p <= total).toList()..sort();

    final List<int?> result = [];
    int? prev;
    for (final p in sorted) {
      if (prev != null && p - prev > 1) {
        result.add(null); // ellipsis
      }
      result.add(p);
      prev = p;
    }
    return result;
  }
}

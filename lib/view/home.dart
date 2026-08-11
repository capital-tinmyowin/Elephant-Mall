import 'dart:async';
import '../models/Category.dart';
import '../models/banner.dart';
import 'package:elephant_mall/services/home_service.dart';
import 'package:flutter/material.dart';
import '../models/promo.dart';
import 'common/footer.dart';
import 'common/header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  Timer? _timer;
  int currentBanner = 0;
  final HomeService _service = HomeService();
  List<BannerModel> banners = [];
  List<Category> categories = [];
  List<Product> products = [];
  List<Promo> promos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHome();
    startAutoSlide();
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

  void startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (!_bannerController.hasClients) return;
      currentBanner = (currentBanner + 1) % banners.length;
      _bannerController.animateToPage(
        currentBanner,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerController.dispose();
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
    if (banners.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    return SizedBox(
      height: isMobile ? 150 : 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // BANNER SLIDER
            PageView.builder(
              controller: _bannerController,
              itemCount: banners.length,
              onPageChanged: (index) {
                setState(() {
                  currentBanner = index;
                });
              },
              itemBuilder: (context, index) {
                final item = banners[index];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // IMAGE
                    Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                          ),
                        );
                      },
                    ),

                    // OVERLAY
                    Container(color: Colors.black.withValues(alpha: 0.25)),

                    // TEXT
                    Positioned(
                      left: isMobile ? 15 : 40,
                      top: isMobile ? 15 : 40,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 14 : 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 11 : 16,
                            ),
                          ),

                          const SizedBox(height: 15),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "SHOP NOW",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: currentBanner == i ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentBanner == i
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPromotions() {
    if (promos.isEmpty) return const SizedBox();

    return Row(
      spacing: 10,
      children: promos
          .take(2)
          .map((item) => Expanded(child: promo(item)))
          .toList(),
    );
  }

  Widget promo(Promo item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        item.imagePath,
        height: 110,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 110,
            color: Colors.grey.shade300,
            child: const Icon(Icons.image_not_supported, size: 40),
          );
        },
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
                          child: Image.asset(
                            item.photoPath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 30,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 5),
                        Text(
                          item.categoryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff6c8855),
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

  Widget buildProducts() {
    if (products.isEmpty) {
      return const SizedBox();
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200, // product card width
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 220,
      ),
      itemBuilder: (context, index) {
        final p = products[index];
        return Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Image.asset(
                  p.imagePath,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 120,
                      child: Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    // Price
                    Flexible(
                      child: Text(
                        "${p.price} MMK",
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 12,
                          color: i < p.rating.round()
                              ? Colors.amber
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "ADD TO FAVORITE",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

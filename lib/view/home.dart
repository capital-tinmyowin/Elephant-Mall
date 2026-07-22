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

  return "http://localhost:5086$value";
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
                        if (isMobile) ...[
                        buildPromotions(),
                        sectionGap,
                      ],
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
                    Image.network(
                      imageUrl(item.imagePath),
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
        .map(
          (item) => Expanded(
            child: promo(item),
          ),
        )
        .toList(),
  );
}

  Widget promo(Promo item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl(item.imagePath),
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
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 9, 11, 1),
      ),
    );
  }

  Widget buildCategories() {
    if (categories.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
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
                  child: Image.network(
                    imageUrl(item.photoPath),

                    fit: BoxFit.contain,

                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported,size: 30);
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
    );
  }

  Widget buildProducts() {
    if (products.isEmpty) {
      return const SizedBox();
    }
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 4),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    imageUrl(p.imagePath),
                    height: 100,
                    width: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 100,
                        width: double.infinity,                     
                        child: Icon(Icons.image_not_supported,size: 40),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Text(
                          "\$${p.price}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Row(
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
                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.zero,
                        ),

                        onPressed: () {},

                        child: const Text(
                          "ADD TO CART",
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

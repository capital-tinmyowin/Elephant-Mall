import 'dart:async';
import 'package:flutter/material.dart';
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

  final List<Map<String, String>> banners = [
    {
      "image": "assets/promotion-banner.png",
      "title": "YANGON SUMMER HEATWAVE SAVINGS!",
      "desc": "Cool styles for Yangon’s hottest days.",
    },
    {
      "image": "promotion-banner2.png",
      "title": "NEW ARRIVALS",
      "desc": "Discover latest fashion trends.",
    },
    {
      "image": "assets/promotion-banner.png",
      "title": "BIG SALE 50% OFF",
      "desc": "Don’t miss the best deals.",
    },
  ];

  final List<Map<String, String>> categories = [
    {"name": "T-Shirts", "image": "assets/tshirt.png"},
    {"name": "Blouses", "image": "assets/blouse.png"},
    {"name": "Bags", "image": "assets/bag.png"},
    {"name": "Hats", "image": "assets/hat.png"},
    {"name": "Jewelry", "image": "assets/jewelry.png"},
    {"name": "Shoes", "image": "assets/shoe.png"},
    {"name": "Jeans", "image": "assets/bag.png"},
    {"name": "Electronic", "image": "assets/hat.png"},
    {"name": "Blouses", "image": "assets/blouse.png"},
    {"name": "Bags", "image": "assets/bag.png"},
    {"name": "Hats", "image": "assets/hat.png"},
    {"name": "Jewelry", "image": "assets/jewelry.png"},
  ];

  final List<Map<String, dynamic>> products = [
    {"name": "Men's Sneakers", "price": 89, "image": "assets/man-sneaker.png"},
    {
      "name": "Women's Wristwatch",
      "price": 65,
      "image": "assets/woman-watch.png",
    },
    {"name": "Leather Backpack", "price": 110, "image": "assets/bagpack.jpg"},
    {"name": "Linen Shirt", "price": 45, "image": "assets/linen.webp"},
    {"name": "Straw Hat", "price": 25, "image": "assets/hat.png"},
    {"name": "Leather Backpack", "price": 110, "image": "assets/bagpack.jpg"},
    {"name": "Linen Shirt", "price": 45, "image": "assets/linen.webp"},
    {"name": "Men's Sneakers", "price": 89, "image": "assets/man-sneaker.png"},
  ];

  @override
  void initState() {
    super.initState();
    startAutoSlide();
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
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Column(
        children: [
          const CommonHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HERO
                        buildHero(),
                        const SizedBox(height: 20),
                        if (isMobile) buildPromotions(),
                        const SizedBox(height: 20),
                        buildTitle("TRENDING CATEGORIES"),
                        const SizedBox(height: 10),
                        buildCategories(),
                        const SizedBox(height: 1),
                        buildTitle("Trending Now in YANGON"),
                        const SizedBox(height: 10),
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
    return SizedBox(
      height: isMobile ? 150 : 230,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PageView.builder(
          controller: _bannerController,
          itemCount: banners.length,
          itemBuilder: (context, index) {
            final item = banners[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(item["image"]!, fit: BoxFit.cover),
                /// DARK OVERLAY
                Container(color: Colors.black.withValues(alpha: 0.15),),
                /// TEXT AREA
                Positioned(
                  left: isMobile ? 15 : 40,
                  top: isMobile ? 15 : 40,
                  right: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item["title"]!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 14 : 28,
                        ),
                      ),

                      SizedBox(height: isMobile ? 5 : 10),
                      Text(
                        item["desc"]!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 11 : 16,
                        ),
                      ),

                      SizedBox(height: isMobile ? 5 : 15),
                      SizedBox(
                        height: isMobile ? 25 : 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 10 : 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          onPressed: () {},
                          child: Text(
                            "SHOP NOW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 10 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildPromotions() {
    return Row(
      children: [
        Expanded(child: promo("assets/promotion-banner.png")),
        const SizedBox(width: 10),
        Expanded(child: promo("assets/promotion-banner2.png")),
      ],
    );
  }

  Widget promo(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(image, height: 100, fit: BoxFit.cover),
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
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 5),
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xffF3F3F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(item["image"]!, fit: BoxFit.contain),
                ),

                const SizedBox(height: 5),
                Text(
                  item["name"]!,
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
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 10),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    p["image"],
                    height: 100,
                    width: 180,
                    fit: BoxFit.contain,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      p["name"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        // Price
                        Text(
                          "\$${p["price"]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Rating Stars
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        /// ADD TO FAVORITE Button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              // Add to Favorite
                            },
                            child: const Text(
                              "ADD TO CARD",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        /// Shopping Cart Icon
                        Container(
                          width: 34,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () {
                              // Open Cart
                            },
                          ),
                        ),
                      ],
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

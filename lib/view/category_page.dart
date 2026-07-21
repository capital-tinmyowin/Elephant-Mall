import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/Category_service.dart';
import 'common/footer.dart';
import 'common/header.dart';
import 'product_detail_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

bool mobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 800;
}

class _CategoryPageState extends State<CategoryPage> {
  late ApiService _apiService;
  final ScrollController _scrollController = ScrollController();
  int _currentSlideIndex = 0;
 int _currentTrendingIndex = 0;
  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService.loadProducts();
      _apiService.loadCategories();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = mobile(context);
    return ChangeNotifierProvider.value(
      value: _apiService,
      child: Scaffold(
        body: Column(
          children: [
            //  Header - ONLY on Desktop (NOT mobile)
            const CommonHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8.0 : 16.0,
                    vertical: 16.0,
                  ),
                  child: isMobile
                      ? _buildMobileLayout()
                      : _buildDesktopLayout(),
                ),
              ),
            ),
            //  Footer - ONLY on Desktop (NOT mobile)
            if (!isMobile) const CommonFooter(),
          ],
        ),
        //  Bottom Bar - ONLY on Mobile
        bottomNavigationBar: isMobile
            ? const CommonBottomBar(currentIndex: 1)
            : null,
      ),
    );
  }

  // ============= DESKTOP LAYOUT =============
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column - Products
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCarousel(false),
              const SizedBox(height: 16),
              _buildCategorySection(),
              const SizedBox(height: 16),
              _buildDesktopProducts(),
            ],
          ),
        ),
        // Right Column - Trending Sidebar
        const SizedBox(width: 16),
        SizedBox(
          width: 320, //  Fixed width for sidebar
          child: _buildTrendingSidebar(),
        ),
      ],
    );
  }

  // ============= MOBILE LAYOUT =============
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroCarousel(true),
        const SizedBox(height: 12),
        _buildCategorySection(),
        const SizedBox(height: 12),
        _buildMobileProducts(),
        const SizedBox(height: 20),
        _buildMobileTrendingSection(),
        const SizedBox(height: 20),
      ],
    );
  }

  // ============= MOBILE TRENDING SECTION =============
  Widget _buildMobileTrendingSection() {
    return Consumer<ApiService>(
      builder: (context, productController, child) {
        if (productController.allProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        final fashionTrending = productController.allProducts
            .where(
              (p) =>
                  p.category == "Blouses" ||
                  p.category == "Jeans" ||
                  p.category == "Bags" ||
                  p.category == "Shoes" ||
                  p.category == "T-Shirts",
            )
            .take(5)
            .toList();

        final electronicsTrending = productController.allProducts
            .where(
              (p) =>
                  p.category == "Electronics" ||
                  p.category == "Power Banks" ||
                  p.category == "Headphones",
            )
            .take(5)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fashionTrending.isNotEmpty)
              _buildTrendingSlider(
                title: ' Trending Now In Category',
                products: fashionTrending,
              ),
            const SizedBox(height: 20),
            if (electronicsTrending.isNotEmpty)
              _buildTrendingSlider(
                title: ' Trending Now In Category',
                products: electronicsTrending,
              ),
          ],
        );
      },
    );
  }

  // ============= HERO CAROUSEL =============
  Widget _buildHeroCarousel(bool isMobile) {
    final List<Map<String, dynamic>> slides = [
      {
        'title': 'SUMMER ESSENTIALS!',
        'subtitle':
            'Get the latest dresses, shorts, lightweight fabrics,\nand accessories for your sunny days.',
        'offer': 'Up to 30% off on selected items',
        'images': [
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/736x/ba/9c/87/ba9c87fb2c220594e494aaa628c6342b.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/736x/4c/51/b7/4c51b7e99173c170c5db866a5ccff75e.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/736x/8d/54/5f/8d545f2a363a450f58dfd9c49a03e81b.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/1200x/2b/3a/47/2b3a478de5e4aa1d6b5fa3fa23818f07.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/1200x/9c/a2/43/9ca243ade3b1a493f0ec98e8aa3ef69f.jpg',
          ),
        ],
      },
      {
        'title': 'BEACH READY',
        'subtitle':
            'Straw hats, sandals, linen shirts & summer totes.\nMake a splash with our new arrivals.',
        'offer': 'Free shipping on orders \$50+',
        'images': [
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/736x/ba/9c/87/ba9c87fb2c220594e494aaa628c6342b.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/736x/4c/51/b7/4c51b7e99173c170c5db866a5ccff75e.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/736x/8d/54/5f/8d545f2a363a450f58dfd9c49a03e81b.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/1200x/2b/3a/47/2b3a478de5e4aa1d6b5fa3fa23818f07.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/1200x/9c/a2/43/9ca243ade3b1a493f0ec98e8aa3ef69f.jpg',
          ),
        ],
      },
      {
        'title': 'SUMMER GADGETS',
        'subtitle':
            'Wireless earbuds, power banks & smart accessories.\nStay connected on the go.',
        'offer': 'Limited time offers',
        'images': [
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/736x/ba/9c/87/ba9c87fb2c220594e494aaa628c6342b.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/736x/4c/51/b7/4c51b7e99173c170c5db866a5ccff75e.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/736x/8d/54/5f/8d545f2a363a450f58dfd9c49a03e81b.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/1200x/2b/3a/47/2b3a478de5e4aa1d6b5fa3fa23818f07.jpg',
          ),
          ApiService.getProxiedImageUrl(
            'https://i1-e.pinimg.com/1200x/9c/a2/43/9ca243ade3b1a493f0ec98e8aa3ef69f.jpg',
          ),
        ],
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: isMobile ? 180 : 200, //  Proper height
          child: CarouselSlider(
            options: CarouselOptions(
              height: isMobile ? 180 : 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 20),
              autoPlayAnimationDuration: const Duration(milliseconds: 3000),
              autoPlayCurve: Curves.fastOutSlowIn,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentSlideIndex = index;
                });
              },
            ),
            items: slides.map((slide) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD68247), Color(0xFF2B6E3B)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12.0 : 24.0,
                        vertical: isMobile ? 8.0 : 16.0,
                      ),
                      child: isMobile
                          ? _buildMobileSlide(slide)
                          : _buildDesktopSlide(slide),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: slides.asMap().entries.map((entry) {
            final isActive = _currentSlideIndex == entry.key;
            return Container(
              width: isActive ? 20 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isActive
                    ? const Color(0xFFFFD966)
                    : Colors.grey.withOpacity(0.4),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============= DESKTOP SLIDE =============
  Widget _buildDesktopSlide(Map<String, dynamic> slide) {
    final images = slide['images'] as List<String>;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Text Content
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slide['title']!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                slide['subtitle']!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slide['offer']!,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        // Right: Images
        Expanded(
          flex: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 65,
                height: 100,
                margin: const EdgeInsets.only(right: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    images[0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 47,
                            margin: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                images[1],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 47,
                            margin: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                images[2],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 47,
                            margin: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                images[3],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 47,
                            margin: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                images[4],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
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
      ],
    );
  }

  // ============= MOBILE SLIDE =============
  Widget _buildMobileSlide(Map<String, dynamic> slide) {
    final images = slide['images'] as List<String>;
    final displayImages = images.take(3).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Text
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slide['title']!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                slide['subtitle']!.replaceAll('\n', ' '),
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slide['offer']!,
                  style: const TextStyle(fontSize: 7, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Right: Images
        Expanded(
          flex: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 45,
                height: 70,
                margin: const EdgeInsets.only(right: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    displayImages[0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 16,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 33,
                      margin: const EdgeInsets.only(bottom: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          displayImages[1],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 14,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 33,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          displayImages[2],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 14,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============= CATEGORY SECTION =============
  Widget _buildCategorySection() {
    return Consumer<ApiService>(
      builder: (context, categoryController, child) {
        if (categoryController.isLoading) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isMobile = MediaQuery.of(context).size.width < 768;

        // If categories are empty, show fallback
        if (categoryController.categories.isEmpty) {
          final categories = categoryController.allProducts
              .map((p) => p.category)
              .toSet()
              .toList();

          if (categories.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📂 Shop by Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3E2B),
                ),
              ),
              const SizedBox(height: 10),
              isMobile
                  ? _buildFallbackMobileChips(categories)
                  : _buildFallbackDesktopChips(categories),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📂 Shop by Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3E2B),
              ),
            ),
            const SizedBox(height: 10),
            isMobile
                ? _buildMobileCategoryChips(categoryController)
                : _buildDesktopCategoryChips(categoryController),
          ],
        );
      },
    );
  }

  // ============= FALLBACK MOBILE CATEGORY CHIPS =============
  Widget _buildFallbackMobileChips(List<String> categories) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============= FALLBACK DESKTOP CATEGORY CHIPS =============
  Widget _buildFallbackDesktopChips(List<String> categories) {
    return Wrap(
      spacing: 5.0,
      runSpacing: 8.0,
      children: categories.map((category) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(
            category,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============= MOBILE CATEGORY CHIPS =============
  Widget _buildMobileCategoryChips(ApiService categoryController) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categoryController.categories.length,
        itemBuilder: (context, index) {
          final category = categoryController.categories[index];
          final isSelected =
              categoryController.selectedCategory == category.categoryName;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                categoryController.selectCategory(category.categoryName);
                categoryController.filterByCategory(category.categoryName);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2B6E3B)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  category.categoryName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============= DESKTOP CATEGORY CHIPS =============
  Widget _buildDesktopCategoryChips(ApiService categoryController) {
    return Wrap(
      spacing: 5.0,
      runSpacing: 8.0,
      children: categoryController.categories.map((category) {
        final isSelected = categoryController.selectedCategory == category.categoryName;

        return GestureDetector(
          onTap: () {
            categoryController.selectCategory(category.categoryName);
            categoryController.filterByCategory(category.categoryName);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2B6E3B) : Colors.grey[200],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              category.categoryName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============= DESKTOP PRODUCTS =============
  Widget _buildDesktopProducts() {
    return Consumer<ApiService>(
      builder: (context, productController, child) {
        if (productController.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final products = productController.products;
        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('✨ No products found ✨'),
            ),
          );
        }

        final Map<String, List<Product>> groupedProducts = {};
        for (var product in products) {
          if (!groupedProducts.containsKey(product.category)) {
            groupedProducts[product.category] = [];
          }
          groupedProducts[product.category]!.add(product);
        }

        final categoryEntries = groupedProducts.entries.toList();

        return Wrap(
          spacing: 20,
          runSpacing: 10,
          children: categoryEntries.map((entry) {
            final productCount = entry.value.length;
            final dynamicWidth = (productCount * 90.0) + 20.0;
            final finalWidth = dynamicWidth < 80.0 ? 80.0 : dynamicWidth;

            return Container(
              width: finalWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.value.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final product = entry.value[index];
                        return Container(
                          width: 100.0,
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Center(
                            child: _buildDesktopProductCard(product),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ============= DESKTOP PRODUCT CARD =============
  Widget _buildDesktopProductCard(Product product) {
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
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.proxiedImageUrl,
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 70,
                    width: 70,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2B6E3B),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    return Container(
                      height: 70,
                      width: 70,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.broken_image,
                        size: 30,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                width: double.infinity,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPage(productId: product.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: const Color(0xFF2B6E3B),
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(double.infinity, 22),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============= MOBILE PRODUCTS =============
  Widget _buildMobileProducts() {
    return Consumer<ApiService>(
      builder: (context, productController, child) {
        if (productController.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final products = productController.products;
        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('✨ No products found ✨'),
            ),
          );
        }

        final Map<String, List<Product>> groupedProducts = {};
        for (var product in products) {
          if (!groupedProducts.containsKey(product.category)) {
            groupedProducts[product.category] = [];
          }
          groupedProducts[product.category]!.add(product);
        }

        return Center(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 10.0,
            children: groupedProducts.entries.map((entry) {
              final firstProduct = entry.value.first;

              return SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(productId: firstProduct.id),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                firstProduct.proxiedImageUrl,
                                height: 85,
                                width: 85,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 70,
                                    width: 70,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 30,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2B6E3B),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ============= TRENDING SIDEBAR =============
  Widget _buildTrendingSidebar() {
    return Consumer<ApiService>(
      builder: (context, productController, child) {
        // If no products, show nothing
        if (productController.allProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        final fashionTrending = productController.allProducts
            .where(
              (p) =>
                  p.category == "Blouses" ||
                  p.category == "Jeans" ||
                  p.category == "Bags" ||
                  p.category == "Shoes" ||
                  p.category == "T-Shirts",
            )
            .take(5)
            .toList();

        final electronicsTrending = productController.allProducts
            .where(
              (p) =>
                  p.category == "Electronics" ||
                  p.category == "Power Banks" ||
                  p.category == "Headphones",
            )
            .take(5)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fashionTrending.isNotEmpty)
              _buildTrendingSlider(
                title: ' Trending Now In Category',
                products: fashionTrending,
              ),
            const SizedBox(height: 20),
            if (electronicsTrending.isNotEmpty)
              _buildTrendingSlider(
                title: ' Trending Now In Category',
                products: electronicsTrending,
              ),
          ],
        );
      },
    );
  }

  // ============= TRENDING SLIDER =============
  Widget _buildTrendingSlider({
    required String title,
    required List<Product> products,
  }) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC2410C),
                  ),
                ),
                
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCarouselSlider(products),
          const SizedBox(height: 8),
          _buildDotIndicator(products),
        ],
      ),
    );
  }

  // ============= CAROUSEL SLIDER =============
  Widget _buildCarouselSlider(List<Product> products) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return CarouselSlider(
      options: CarouselOptions(
        height: isMobile ? 300 : 250,
        autoPlay: false,
        // enlargeCenterPage: true, // Enlarge center item
        viewportFraction: isMobile
            ? 0.7
            : 0.9, //  0.7 = show 70% width on mobile
        padEnds: false,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index, reason) {  //  ADD THIS
        setState(() {
          _currentTrendingIndex = index;
        });
      },
      ),
      items: products.map((product) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 4.0 : 5.0),
              child: _buildTrendingItem(product),
            );
          },
        );
      }).toList(),
    );
  }

  // ============= TRENDING ITEM =============
  Widget _buildTrendingItem(Product product) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

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
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: product.proxiedImageUrl,
                height: isMobile ? 110 : 80,
                width: isMobile ? 110 : 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: isMobile ? 110 : 80,
                  width: isMobile ? 110 : 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2B6E3B)),
                  ),
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    height: isMobile ? 110 : 80,
                    width: isMobile ? 110 : 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 30),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: TextStyle(
                fontSize: isMobile ? 13 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2B6E3B),
                fontSize: isMobile ? 15 : 14,
              ),
            ),
            const SizedBox(height: 4),
            _buildRatingRow(product),
            const SizedBox(height: 8),
            _buildFavoriteButton(product),
          ],
        ),
      ),
    );
  }

  // ============= RATING ROW =============
  Widget _buildRatingRow(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, color: Color(0xFFFFD700), size: 12),
        const Icon(Icons.star, color: Color(0xFFFFD700), size: 12),
        const Icon(Icons.star, color: Color(0xFFFFD700), size: 12),
        const Icon(Icons.star, color: Color(0xFFFFD700), size: 12),
        const Icon(Icons.star_half, color: Color(0xFFFFD700), size: 12),
        const SizedBox(width: 4),
        Text(
          '(${product.ratingCount})',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ============= FAVORITE BUTTON =============
  Widget _buildFavoriteButton(Product product) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Consumer<ApiService>(
      builder: (context, cartController, child) {
        final inCart = cartController.isInCart(product.id);
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (inCart) {
                cartController.removeItem(product.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} removed'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              } else {
                cartController.addItem(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to favourites'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: inCart ? Colors.grey : const Color(0xFFD68247),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 10 : 8,
              ), //  Larger on mobile
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: Size(
                double.infinity,
                isMobile ? 40 : 32,
              ), //  Taller on mobile
            ),
            child: Text(
              inCart ? 'REMOVED' : 'ADD TO Favourite',
              style: TextStyle(
                fontSize: isMobile ? 12 : 10, //  Larger text on mobile
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============= DOT INDICATOR =============
  Widget _buildDotIndicator(List<Product> products) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: products.asMap().entries.map((entry) {
        final bool isActive = entry.key == _currentTrendingIndex;
        return Container(
          width: isActive ? 20 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive 
              ? const Color(0xFF2B6E3B)  //  Green when active
              : Colors.grey[300],        //  Grey when inactive
          ),
        );
      }).toList(),
    );
  }
}

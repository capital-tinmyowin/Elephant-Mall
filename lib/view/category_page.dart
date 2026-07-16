import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/Category_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/footer_widget.dart';
import 'product_detail_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentSlideIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiService>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          return Column(
            children: [
              const HeaderWidget(),
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
              if (!isMobile) const FooterWidget(),
            ],
          );
        },
      ),
    );
  }

  // ============= DESKTOP LAYOUT =============
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN - Products side by side (col-lg-9)
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

        // RIGHT COLUMN - Trending Sliders (col-lg-3)
        const SizedBox(width: 16),
        Expanded(flex: 1, child: _buildTrendingSidebar()),
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
        //  TWO TRENDING SLIDERS FOR MOBILE
        _buildMobileTrendingSection(),
        const SizedBox(height: 20),
      ],
    );
  }

  // ============= MOBILE TRENDING SLIDER =============
  Widget _buildMobileTrendingSection() {
    return Consumer<ApiService>(
      builder: (context, productController, child) {
        if (productController.allProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        // First Trending - Fashion (Blouses, Jeans, Bags, Shoes, T-Shirts)
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

        //  Second Trending - Electronics (Electronics, Power Banks, Headphones)
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
            // First Trending Slider - Fashion
            if (fashionTrending.isNotEmpty)
              TrendingSliderWidget(
                title: ' Trending Now In Category',
                products: fashionTrending,
              ),

            const SizedBox(height: 20),

            // Second Trending Slider - Electronics
            if (electronicsTrending.isNotEmpty)
              TrendingSliderWidget(
                title: '💻 Trending Now In Category',
                products: electronicsTrending,
              ),
          ],
        );
      },
    );
  }

  // ============= HERO SLIDER =============
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
        CarouselSlider(
          options: CarouselOptions(
            height: isMobile ? 190 : 210,
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
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD68247), Color(0xFF2B6E3B)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16.0 : 30.0,
                      vertical: isMobile ? 12.0 : 20.0,
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
        const SizedBox(height: 12),
        //  FIXED: Dot Indicator with better visibility
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
                    ? const Color(0xFFFFD966) // Gold color for active
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
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slide['title']!,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                slide['subtitle']!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slide['offer']!,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // Right: Images (2 columns layout like HTML)
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left column: Big image (hero-first)
              Container(
                width: 80,
                height: 125,
                margin: const EdgeInsets.only(right: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
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

              // Right column: 2x2 grid of small images
              SizedBox(
                width: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Row 1
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 58,
                            margin: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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
                            height: 58,
                            margin: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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
                    // Row 2
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 58,
                            margin: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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
                            height: 58,
                            margin: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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

  // ============= MOBILE Hero SLIDE =============
  Widget _buildMobileSlide(Map<String, dynamic> slide) {
    final images = slide['images'] as List<String>;
    //  Only take first 3 images for mobile
    final displayImages = images.take(3).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Text Content (smaller)
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slide['title']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                slide['subtitle']!.replaceAll('\n', ' '),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slide['offer']!,
                  style: const TextStyle(fontSize: 8, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Right: 3 Images (not 5)
        Expanded(
          flex: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Big image
              Container(
                width: 50,
                height: 80,
                margin: const EdgeInsets.only(right: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    displayImages[0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 2 small images stacked vertically
              SizedBox(
                width: 45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 38,
                      margin: const EdgeInsets.only(bottom: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          displayImages[1],
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
                    Container(
                      height: 38,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          displayImages[2],
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

        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 768;

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
              categoryController.selectedCategory == category.name;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                categoryController.selectCategory(category.name);
                Provider.of<ApiService>(
                  context,
                  listen: false,
                ).filterByCategory(category.name);
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
                  category.name,
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
        final isSelected = categoryController.selectedCategory == category.name;

        return GestureDetector(
          onTap: () {
            categoryController.selectCategory(category.name);
            Provider.of<ApiService>(
              context,
              listen: false,
            ).filterByCategory(category.name);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2B6E3B) : Colors.grey[200],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              category.name,
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
        Navigator.pushNamed(
          context,
              '/product/${product.id}',
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
                        Navigator.pushNamed(
                          context,
                              '/product/${firstProduct.id}',
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

  // ============= TRENDING SIDEBAR (Desktop) =============
  Widget _buildTrendingSidebar() {
    return Consumer<ApiService>(
      builder: (context, productController, child) {
        //  First Trending Slider - Fashion
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

        //  Second Trending Slider - Electronics
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
            // First Trending Slider - Fashion
            if (fashionTrending.isNotEmpty)
              TrendingSliderWidget(
                title: ' Trending Now In Category',
                products: fashionTrending,
              ),

            const SizedBox(height: 20),

            // Second Trending Slider - Electronics
            if (electronicsTrending.isNotEmpty)
              TrendingSliderWidget(
                title: ' Trending Now In Category',
                products: electronicsTrending,
              ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryProductCard(Product product) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: product.proxiedImageUrl,
                  height: 70,
                  width: 70,
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
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: const Color(0xFF2B6E3B),
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(double.infinity, 20),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingSliderWidgetState extends State<TrendingSliderWidget> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    //  Check if mobile
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC2410C),
            ),
          ),
          const SizedBox(height: 12),
          //  Carousel Slider with Navigation
          Stack(
            children: [
              CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                  height: isMobile ? 270 : 250, // Slightly taller on mobile
                  autoPlay: false,
                  enlargeCenterPage: false,
                  viewportFraction: isMobile ? 0.75 : 0.85,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: widget.products.map((product) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: TrendingItemWidget(product: product),
                      );
                    },
                  );
                }).toList(),
              ),
              //  Left Navigation Arrow
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: isMobile ? 24 : 28,
                      height: isMobile ? 24 : 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: const Color(0xFF2B6E3B),
                        size: isMobile ? 16 : 20,
                      ),
                    ),
                  ),
                ),
              ),
              //  Right Navigation Arrow
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: isMobile ? 24 : 28,
                      height: isMobile ? 24 : 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: const Color(0xFF2B6E3B),
                        size: isMobile ? 16 : 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          //  Dot Indicators
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.products.asMap().entries.map((entry) {
              return Container(
                width: _currentIndex == entry.key ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentIndex == entry.key
                      ? const Color(0xFF2B6E3B)
                      : Colors.grey[300],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class TrendingSliderWidget extends StatefulWidget {
  final String title;
  final List<Product> products;

  const TrendingSliderWidget({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  State<TrendingSliderWidget> createState() => _TrendingSliderWidgetState();
}

// ============= TRENDING ITEM WIDGET =============
class TrendingItemWidget extends StatelessWidget {
  final Product product;

  const TrendingItemWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
              '/product/${product.id}',
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
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
            //  Product Image - Use proxiedImageUrl
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: product.proxiedImageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 80,
                  width: 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2B6E3B)),
                  ),
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 30),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            //  Product Name
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            //  Price
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B6E3B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),

            //  Rating
            Row(
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
            ),
            const SizedBox(height: 6),

            //  ADD TO Favourite Button
            Consumer<ApiService>(
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
                            content: Text(
                              '${product.name} added to favourites',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: inCart
                          ? Colors.grey
                          : const Color(0xFFD68247),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(double.infinity, 32),
                    ),
                    child: Text(
                      inCart ? 'REMOVED' : 'ADD TO Favourite',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

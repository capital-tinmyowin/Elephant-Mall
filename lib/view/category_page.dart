import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:elephant_mall/view/category_detail.dart';
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
  final Map<String, int> _sliderIndexes = {};
  final Map<String, CarouselSliderController> _sliderControllers = {};
  // ADD method to get or create a slider index
  int _getSliderIndex(String id) {
    if (!_sliderIndexes.containsKey(id)) {
      _sliderIndexes[id] = 0;
    }
    return _sliderIndexes[id]!;
  }

  // ADD method to update slider index
  void _updateSliderIndex(String id, int index) {
    _sliderIndexes[id] = index;
  }

  // ADD method to get or create a controller for a specific slider
  CarouselSliderController _getController(String id) {
    if (!_sliderControllers.containsKey(id)) {
      _sliderControllers[id] = CarouselSliderController();
    }
    return _sliderControllers[id]!;
  }

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService.loadProducts();
      // _apiService.loadCategories();
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
        //  Check if mobile
        final bool isMobile = MediaQuery.of(context).size.width < 768;

        //  If mobile, show in a row (side by side)
        if (isMobile) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fashionTrending.isNotEmpty)
                Expanded(
                  child: _buildTrendingSlider(
                    title: 'New Arrivals',
                    products: fashionTrending,
                    sliderId: 'fashion_mobile',
                    isCompact: true, //  Add compact mode
                  ),
                ),
              if (fashionTrending.isNotEmpty && electronicsTrending.isNotEmpty)
                const SizedBox(width: 8),
              if (electronicsTrending.isNotEmpty)
                Expanded(
                  child: _buildTrendingSlider(
                    title: 'Trending Now',
                    products: electronicsTrending,
                    sliderId: 'electronics_mobile',
                    isCompact: true, // Add compact mode
                  ),
                ),
            ],
          );
        }

        //  Desktop view - stacked vertically
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fashionTrending.isNotEmpty)
              _buildTrendingSlider(
                title: ' New Arrivals',
                products: fashionTrending,
                sliderId: 'fashion_mobile',
              ),
            const SizedBox(height: 20),
            if (electronicsTrending.isNotEmpty)
              _buildTrendingSlider(
                title: ' Trending Now In Category',
                products: electronicsTrending,
                sliderId: 'electronics_mobile',
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
            'Get the latest dresses, shorts, lightweight,\nand accessories',
        'offer': 'Up to 30% off on selected items',
        'imageCount': 5, // Number of images for this slide
        'baseName': 'slide',
      },
      {
        'title': 'BEACH READY',
        'subtitle':
            'Straw hats, sandals, linen shirts & summer totes.\nMake a splash with our new arrivals.',
        'offer': 'Free shipping on orders \$50+',
        'imageCount': 5,
        'baseName': 'slide',
      },
      {
        'title': 'SUMMER GADGETS',
        'subtitle':
            'Wireless earbuds, power banks & smart accessories.\nStay connected on the go.',
        'offer': 'Limited time offers',
        'imageCount': 5,
        'baseName': 'slide',
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: isMobile ? 110 : 140, //  Proper height
          child: CarouselSlider(
            options: CarouselOptions(
              height: isMobile ? 110 : 150,
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
                  List<String> images = [];
                  int count = slide['imageCount'] as int;
                  String baseName = slide['baseName'] as String;
                  for (int i = 1; i <= count; i++) {
                    images.add('assets/images/heroslider/${baseName}_$i.jpg');
                  }

                  // Add images to slide data
                  slide['images'] = images;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2B6E3B), Color(0xFFD68247)],
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
        Transform.translate(
          offset: Offset(0, -12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: slides.asMap().entries.map((entry) {
              final isActive = _currentSlideIndex == entry.key;
              return Container(
                width: isActive ? (isMobile ? 6 : 20) : (isMobile ? 5 : 7),
                height: isMobile ? 6 : 6,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive ? Colors.white : Colors.grey.withOpacity(0.7),
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
        ),
      ],
    );
  }

  Widget _buildHeroImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
    // If it's a local asset
    if (imageUrl.startsWith('assets/')) {
      String cleanPath = imageUrl.replaceFirst('assets/', '');
      return Image.asset(
        cleanPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }

    // If it's a network URL
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
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
                  child: _buildHeroImage(images[0]),
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
                              child: _buildHeroImage(images[1]),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 47,
                            margin: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: _buildHeroImage(images[2]),
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
                              child: _buildHeroImage(images[3]),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 47,
                            margin: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: _buildHeroImage(images[4]),
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
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
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
                  child: _buildHeroImage(displayImages[0]),
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
                        child: _buildHeroImage(displayImages[1]),
                      ),
                    ),
                    Container(
                      height: 33,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _buildHeroImage(displayImages[2]),
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
          runSpacing: 5,
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
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.value.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final product = entry.value[index];
                        return Container(
                          width: 100.0,
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Center(
                            child: _buildDesktopProductCard(product),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDetailPage(
                            categoryName: entry.key,
                          ),
                        ),
                      );
                    },
                    child: Center(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B6E3B),
                        ),
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
        height: 130,
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
              padding: const EdgeInsets.all(2.0),
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
                height: 20,
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
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final products = productController.products;
        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
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
                                height: 75,
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
                            GestureDetector(
                              onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryDetailPage(
                                    categoryName: entry.key,
                                  ),
                                ),
                              );
                            },
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2B6E3B),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                title: ' New Arrivals',
                products: fashionTrending,
                sliderId: 'fashion',
              ),
            // const SizedBox(height: 20),
            if (electronicsTrending.isNotEmpty)
              _buildTrendingSlider(
                title: ' Trending Now In Category',
                products: electronicsTrending,
                sliderId: 'electronics',
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
    required String sliderId,
    bool isCompact = false,
  }) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final controller = _getController(sliderId);

    return Container(
      width: MediaQuery.of(context).size.width,
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 12),
          _buildCarouselSlider(products, controller, sliderId, isCompact),
        ],
      ),
    );
  }

  // ============= CAROUSEL SLIDER =============
  Widget _buildCarouselSlider(
    List<Product> products,
    CarouselSliderController controller,
    String sliderId,
    bool isCompact,
  ) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Stack(
      children: [
        CarouselSlider(
          carouselController: controller,
          options: CarouselOptions(
            height: isMobile ? 240 : 200,
            autoPlay: false,
            viewportFraction: isMobile
                ? 0.5
                : 0.32, //  0.7 = show 70% width on mobile
            padEnds: false,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              //  ADD THIS
              setState(() {
                _updateSliderIndex(sliderId, index);
              });
            },
          ),
          items: products.map((product) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isMobile ? 1.0 : 5.0,
                  ),
                  child: _buildTrendingItem(product, isCompact),
                );
              },
            );
          }).toList(),
        ),
        // LEFT ARROW - Positioned at center-left
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                controller.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF2B6E3B),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        // RIGHT ARROW - Positioned at center-right
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF2B6E3B),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============= TRENDING ITEM =============
  Widget _buildTrendingItem(Product product, bool isCompact) {
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
        // width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 8 : 5),
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
                // width: isMobile ? 110 : 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: isMobile ? 110 : 80,
                  // width: isMobile ? 110 : 80,
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
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
            Text(
              '\MMK${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: isMobile ? 11 : 12,
              ),
            ),
            _buildRatingRow(product),
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
          width: 100,
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
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: Size(
                double.infinity,
                isMobile ? 40 : 32,
              ), //  Taller on mobile
            ),
            child: Text(
              inCart ? 'REMOVED' : 'ADD TO FAVOURITE',
              style: TextStyle(
                fontSize: isMobile ? 11 : 9, //  Larger text on mobile
                fontWeight: FontWeight.bold,
              ),
              maxLines: isMobile ? 2 : 2,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  // ============= DOT INDICATOR =============
  Widget _buildDotIndicator(List<Product> products, String sliderId) {
    final currentIndex = _getSliderIndex(sliderId);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: products.asMap().entries.map((entry) {
        final bool isActive = entry.key == currentIndex;
        return Container(
          width: isActive ? 20 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? const Color(0xFF2B6E3B) //  Green when active
                : Colors.grey[300], //  Grey when inactive
          ),
        );
      }).toList(),
    );
  }
}

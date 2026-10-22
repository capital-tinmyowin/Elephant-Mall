import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:elephant_mall/models/Category.dart';
import 'package:elephant_mall/services/auth_service.dart';
import 'package:elephant_mall/view/category_detail.dart';
import 'package:elephant_mall/view/common/favorite_helper.dart';
import 'package:elephant_mall/view/common/loading_widget.dart';
import 'package:elephant_mall/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
  String? _loadError;

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
      // _apiService.loadProducts();
      _apiService.loadTrendingProducts();
      _apiService.loadNewProducts();
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
                'assets/ShopbyCategorySummerStyle.png',
                fit: BoxFit.cover,
                // alignment: const Alignment(0, -0.3),
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
              buildHero(),
              // _buildHeroCarousel(false),
              const SizedBox(height: 16),
              _buildProducts(),
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
        buildHero(),
        // _buildHeroCarousel(true),
        const SizedBox(height: 12),
        Center(child: _buildProducts()),
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
        // Get trending products from the service
        final trending = productController.trendingProducts;
        final news = productController.newProducts;

        final bool isMobile = MediaQuery.of(context).size.width < 768;
        if (isMobile) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (news.isNotEmpty)
                Expanded(
                  child: _buildTrendingSlider(
                    title: 'New Arrivals',
                    products: news,
                    sliderId: 'fashion_mobile',
                    isCompact: true,
                    viewAllRoute: '/new-in',
                  ),
                ),
              // if (fashionTrending.isNotEmpty && electronicsTrending.isNotEmpty)
              const SizedBox(width: 8),
              if (trending.isNotEmpty)
                Expanded(
                  child: _buildTrendingSlider(
                    title: 'Trending Now',
                    products: trending,
                    sliderId: 'electronics_mobile',
                    isCompact: true,
                    viewAllRoute: '/',
                  ),
                ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.isNotEmpty)
              _buildTrendingSlider(
                title: ' New Arrivals',
                products: news,
                sliderId: 'fashion_mobile',
                viewAllRoute: '/new-in',
              ),
            const SizedBox(height: 20),
            if (trending.isNotEmpty)
              _buildTrendingSlider(
                title: ' Trending Now In Product',
                products: trending,
                sliderId: 'electronics_mobile',
                viewAllRoute: '/',
              ),
          ],
        );
      },
    );
  }

  // ============= HERO CAROUSEL =============
  // Widget _buildHeroCarousel(bool isMobile) {
  //   final List<Map<String, dynamic>> slides = [
  //     {
  //       'title': 'SUMMER ESSENTIALS!',
  //       'subtitle':
  //           'Get the latest dresses, shorts, lightweight,\nand accessories',
  //       'offer': 'Up to 30% off on selected items',
  //       'imageCount': 5, // Number of images for this slide
  //       'baseName': 'slide',
  //     },
  //     {
  //       'title': 'BEACH READY',
  //       'subtitle':
  //           'Straw hats, sandals, linen shirts & summer totes.\nMake a splash with our new arrivals.',
  //       'offer': 'Free shipping on orders \$50+',
  //       'imageCount': 5,
  //       'baseName': 'slide',
  //     },
  //     {
  //       'title': 'SUMMER GADGETS',
  //       'subtitle':
  //           'Wireless earbuds, power banks & smart accessories.\nStay connected on the go.',
  //       'offer': 'Limited time offers',
  //       'imageCount': 5,
  //       'baseName': 'slide',
  //     },
  //   ];

  //   return Column(
  //     children: [
  //       SizedBox(
  //         height: isMobile ? 110 : 140, //  Proper height
  //         child: CarouselSlider(
  //           options: CarouselOptions(
  //             height: isMobile ? 110 : 150,
  //             autoPlay: true,
  //             autoPlayInterval: const Duration(seconds: 20),
  //             autoPlayAnimationDuration: const Duration(milliseconds: 3000),
  //             autoPlayCurve: Curves.fastOutSlowIn,
  //             viewportFraction: 1.0,
  //             enableInfiniteScroll: true,
  //             onPageChanged: (index, reason) {
  //               setState(() {
  //                 _currentSlideIndex = index;
  //               });
  //             },
  //           ),
  //           items: slides.map((slide) {
  //             return Builder(
  //               builder: (BuildContext context) {
  //                 List<String> images = [];
  //                 int count = slide['imageCount'] as int;
  //                 String baseName = slide['baseName'] as String;
  //                 for (int i = 1; i <= count; i++) {
  //                   images.add('assets/images/heroslider/${baseName}_$i.jpg');
  //                 }

  //                 // Add images to slide data
  //                 slide['images'] = images;
  //                 return Container(
  //                   width: double.infinity,
  //                   margin: const EdgeInsets.symmetric(horizontal: 0),
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(12),
  //                     gradient: const LinearGradient(
  //                       colors: [Color(0xFF2B6E3B), Color(0xFFD68247)],
  //                       begin: Alignment.centerLeft,
  //                       end: Alignment.centerRight,
  //                     ),
  //                   ),
  //                   child: Padding(
  //                     padding: EdgeInsets.symmetric(
  //                       horizontal: isMobile ? 12.0 : 24.0,
  //                       vertical: isMobile ? 8.0 : 16.0,
  //                     ),
  //                     child: isMobile
  //                         ? _buildMobileSlide(slide)
  //                         : _buildDesktopSlide(slide),
  //                   ),
  //                 );
  //               },
  //             );
  //           }).toList(),
  //         ),
  //       ),
  //       Transform.translate(
  //         offset: Offset(0, -12),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: slides.asMap().entries.map((entry) {
  //             final isActive = _currentSlideIndex == entry.key;
  //             return Container(
  //               width: isActive ? (isMobile ? 6 : 20) : (isMobile ? 5 : 7),
  //               height: isMobile ? 6 : 6,
  //               margin: const EdgeInsets.symmetric(horizontal: 4),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(4),
  //                 color: isActive ? Colors.white : Colors.grey.withOpacity(0.7),
  //                 boxShadow: isActive
  //                     ? [
  //                         BoxShadow(
  //                           color: Colors.white.withOpacity(0.3),
  //                           blurRadius: 4,
  //                         ),
  //                       ]
  //                     : null,
  //               ),
  //             );
  //           }).toList(),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildHeroImage(String imageUrl) {
  //     // String cleanPath = imageUrl.replaceFirst('assets/', '');
  //     return AppImage(
  //       imageUrl:  imageUrl,
  //       fit: BoxFit.cover,
  //     );
  // }

  // // ============= DESKTOP SLIDE =============
  // Widget _buildDesktopSlide(Map<String, dynamic> slide) {
  //   final images = slide['images'] as List<String>;

  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       // Left: Text Content
  //       Expanded(
  //         flex: 6,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(
  //               slide['title']!,
  //               style: const TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               slide['subtitle']!,
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 color: Colors.white.withOpacity(0.9),
  //               ),
  //             ),
  //             const SizedBox(height: 4),
  //           ],
  //         ),
  //       ),
  //       // Right: Images
  //       Expanded(
  //         flex: 4,
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children: [
  //             Container(
  //               width: 65,
  //               height: 100,
  //               margin: const EdgeInsets.only(right: 4),
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(8),
  //                 child: _buildHeroImage(images[0]),
  //               ),
  //             ),
  //             SizedBox(
  //               width: 80,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Container(
  //                           height: 47,
  //                           margin: const EdgeInsets.all(2),
  //                           child: ClipRRect(
  //                             borderRadius: BorderRadius.circular(6),
  //                             child: _buildHeroImage(images[1]),
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: Container(
  //                           height: 47,
  //                           margin: const EdgeInsets.all(2),
  //                           child: ClipRRect(
  //                             borderRadius: BorderRadius.circular(6),
  //                             child: _buildHeroImage(images[2]),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Container(
  //                           height: 47,
  //                           margin: const EdgeInsets.all(2),
  //                           child: ClipRRect(
  //                             borderRadius: BorderRadius.circular(6),
  //                             child: _buildHeroImage(images[3]),
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: Container(
  //                           height: 47,
  //                           margin: const EdgeInsets.all(2),
  //                           child: ClipRRect(
  //                             borderRadius: BorderRadius.circular(6),
  //                             child: _buildHeroImage(images[4]),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // // ============= MOBILE SLIDE =============
  // Widget _buildMobileSlide(Map<String, dynamic> slide) {
  //   final images = slide['images'] as List<String>;
  //   final displayImages = images.take(3).toList();

  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       // Left: Text
  //       Expanded(
  //         flex: 6,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(
  //               slide['title']!,
  //               style: const TextStyle(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //               maxLines: 1,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //             const SizedBox(height: 2),
  //             Text(
  //               slide['subtitle']!.replaceAll('\n', ' '),
  //               style: TextStyle(
  //                 fontSize: 11,
  //                 color: Colors.white.withOpacity(0.9),
  //               ),
  //               maxLines: 2,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //             const SizedBox(height: 2),
  //           ],
  //         ),
  //       ),
  //       // Right: Images
  //       Expanded(
  //         flex: 4,
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children: [
  //             Container(
  //               width: 45,
  //               height: 70,
  //               margin: const EdgeInsets.only(right: 2),
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(6),
  //                 child: _buildHeroImage(displayImages[0]),
  //               ),
  //             ),
  //             SizedBox(
  //               width: 40,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Container(
  //                     height: 33,
  //                     margin: const EdgeInsets.only(bottom: 2),
  //                     child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(4),
  //                       child: _buildHeroImage(displayImages[1]),
  //                     ),
  //                   ),
  //                   Container(
  //                     height: 33,
  //                     child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(4),
  //                       child: _buildHeroImage(displayImages[2]),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ============= DESKTOP PRODUCTS =============
  Widget _buildProducts() {
    return Consumer<ApiService>(
      builder: (context, api, _) {
        // Loading / error only replaces the categories grid
        if (api.isLoading) {
          return const CommonLoading(
            size: 42,
            message: 'Loading categories...',
            height: 300,
          );
        }

        if (_loadError != null) {
          return CommonError(
            height: 300,
            title: 'Failed to load categories',
            message: _loadError!,
            onRetry: () {
              setState(() => _loadError = null);
              _apiService.loadCategories();
            },
          );
        }

        final categories = api.categories;
        if (categories.isEmpty) {
          return const CommonError(
            height: 300,
            title: 'Failed to load categories',
            message:
                'Categories could not be loaded. Please check your connection.',
          );
        }

        return Wrap(
          spacing: 20,
          runSpacing: 5,
          children: categories.map((category) {
            return Container(
              width: 100, // Fixed width for single product
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    child: Center(
                      child: Container(
                        width: 100.0,
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Center(child: _buildProductCard(category)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () {
                      context.go(
                        '/category/${category.categoryId}?name=${Uri.encodeComponent(category.categoryName)}',
                      );
                    },
                    child: Center(
                      child: Text(
                        category.categoryName,
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
  Widget _buildProductCard(Category category) {
    return GestureDetector(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ProductDetailPage(productId: product.productId),
      //     ),
      //   );
      // },
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
                child: AppImage(
                  imageUrl: ApiService.getProxiedImageUrl(category.photoPath),
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(2.0),
            //   child: SizedBox(
            //     width: double.infinity,
            //     height: 20,
            //     child: ElevatedButton(
            //       onPressed: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) =>
            //                 ProductDetailPage(productId: product.productId),
            //           ),
            //         );
            //       },
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.grey[100],
            //         foregroundColor: const Color(0xFF2B6E3B),
            //         padding: const EdgeInsets.symmetric(vertical: 3),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //         minimumSize: const Size(double.infinity, 22),
            //       ),
            //       child: const Text(
            //         'View Details',
            //         style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ============= TRENDING SIDEBAR =============
  Widget _buildTrendingSidebar() {
    return Consumer<ApiService>(
      builder: (context, productController, child) {
        // Get trending products from the service
        final trending = productController.trendingProducts;
        final news = productController.newProducts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.isNotEmpty)
              _buildTrendingSlider(
                title: ' New Arrivals',
                products: news,
                sliderId: 'fashion',
                viewAllRoute: '/new-in',
              )
            else if (news.isEmpty)
              const CommonError(
                height: 300,
                title: 'Failed to New Arrivals',
                message:
                    'News could not be loaded. Please check your connection.',
              ),
            if (trending.isNotEmpty)
              _buildTrendingSlider(
                title: ' Trending Now In Product',
                products: trending,
                sliderId: 'electronics',
                viewAllRoute: '/',
              )
            else if (trending.isEmpty)
              const CommonError(
                height: 300,
                title: 'Failed to load Products',
                message:
                    'Products could not be loaded. Please check your connection.',
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
    String? viewAllRoute,
  }) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final controller = _getController(sliderId);

    return Container(
      // width: MediaQuery.of(context).size.width,
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
                //  ADD VIEW ALL BUTTON HERE
                if (viewAllRoute != null)
                  GestureDetector(
                    onTap: () => context.go(viewAllRoute),
                    child: Row(
                      children: [
                        Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
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
    final int initialIndex = _sliderIndexes[sliderId] ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Just try to jump. The controller handles safety internally.
      controller.jumpToPage(initialIndex);
    });

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
            initialPage: initialIndex,
            onPageChanged: (index, reason) {
              //  ADD THIS
              if (_sliderIndexes[sliderId] != index) {
                setState(() {
                  _updateSliderIndex(sliderId, index);
                });
              }
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
        context.go('/product/${product.productId}');
      },
      child: Container(
        // width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 1 : 5),
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
              child: AppImage(
                imageUrl: product.proxiedImageUrl,
                height: isMobile ? 110 : 80,
                // width: isMobile ? 110 : 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.productName,
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
              '\MMK${NumberFormat('#,##0').format(product.price)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: isMobile ? 11 : 12,
              ),
              maxLines: 1,
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
        // const SizedBox(width: 4),
      ],
    );
  }

  // ============= FAVORITE BUTTON =============
  Widget _buildFavoriteButton(Product product) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final isFav = authService.isFavorite(product.productId);
        final isLoggedIn = authService.isLoggedIn;

        return SizedBox(
          width: 100,
          child: ElevatedButton(
            onPressed: () async {
              // 1) Not logged in → prompt to log in
              await FavoriteHelper.toggleFavorite(
                context,
                productId: product.productId,
                isCurrentlyFavorite: isFav,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isFav ? Colors.grey : const Color(0xFFD68247),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: Size(double.infinity, isMobile ? 40 : 32),
            ),
            child: Text(
              isFav ? 'REMOVED' : 'ADD TO FAVOURITE',
              style: TextStyle(
                fontSize: isMobile ? 10 : 9,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

import 'package:elephant_mall/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/Category_service.dart';
import 'common/footer.dart';
import 'common/header.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  final VoidCallback? onBack; //  Add callback
  const ProductDetailPage({super.key, required this.productId, this.onBack});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

bool mobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 800;
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ApiService _apiService;
  int _selectedImageIndex = 0;
  bool _isMobile = false;
  List<Product> _sellerProducts = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 🔥 Load list AND detail together
      await Future.wait([
        // _apiService.loadProducts(),
        _apiService.loadProductDetail(widget.productId),
      ]);

      if (!mounted) return;
      setState(
        () {},
      ); // force rebuild so _getSellerProducts sees the populated list
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = mobile(context);
    _isMobile = isMobile;
    return ChangeNotifierProvider.value(
      // ← ADD THIS WRAPPER
      value: _apiService, // ← ADD THIS
      child: Scaffold(
        body: Consumer<ApiService>(
          builder: (context, productController, child) {
            if (productController.isLoading) {
              return const Column(
                children: [
                  CommonHeader(),
                  Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              );
            }

            final product = productController.selectedProduct;
            if (product == null) {
              return const Column(
                children: [
                  CommonHeader(),
                  // Expanded(child: Center(child: Text('Product not found'))),
                ],
              );
            }
            _sellerProducts = _getSellerProducts(product, productController);
            print(product.productId);
            return Column(
              children: [
                const CommonHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _isMobile
                        ? _buildMobileLayout(product)
                        : _buildDesktopLayout(product),
                  ),
                ),
                //  Add Footer for PC view
                if (!isMobile) const CommonFooter(),
              ],
            );
          },
        ),
        //  ADD BOTTOM NAVIGATION BAR ONLY FOR MOBILE
        bottomNavigationBar: isMobile ? CommonBottomBar(currentIndex: 1) : null,
      ),
    );
  }

  Widget _buildImage(String imageUrl, double height, double width) {
    //  TRY BOTH WAYS - This will work no matter what
    return AppImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
    );
  }

  // ============= DESKTOP LAYOUT =============
  Widget _buildDesktopLayout(Product product) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 1000;
    final bool isVerySmallScreen = MediaQuery.of(context).size.width < 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Gallery + Info - Responsive Row
        if (isSmallScreen)
          //  On small screens: Stack vertically (Gallery on top, Info below)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildProductGallery(product)),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(product),
                  const SizedBox(height: 16),
                  _buildActionButtons(product),
                  const SizedBox(height: 16),
                  _buildDescription(product),
                  _buildSellerInfo(product),
                ],
              ),
            ],
          )
        else
          //  On larger screens: Row layout (Gallery left, Info right)
          Container(
            padding: EdgeInsets.only(right: isVerySmallScreen ? 100 : 250),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(child: _buildProductGallery(product)),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductInfo(product),
                            const SizedBox(height: 16),
                            _buildActionButtons(product),
                            const SizedBox(height: 16),
                            _buildDescription(product),
                            _buildSellerInfo(product),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        _buildMoreFromStore(product),
      ],
    );
  }

  // ============= MOBILE LAYOUT =============
  Widget _buildMobileLayout(Product product) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Prevents overflow
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductInfo(product),
        const SizedBox(height: 16),
        _buildProductGallery(product),
        const SizedBox(height: 16),
        _buildActionButtons(product),
        const SizedBox(height: 16),
        _buildDescription(product),
        const SizedBox(height: 16),
        _buildSellerInfo(product),
        const SizedBox(height: 16),
        _buildMoreFromStore(product),
      ],
    );
  }

  // ============= PRODUCT GALLERY =============
  Widget _buildProductGallery(Product product) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    final bool isSmallScreen = MediaQuery.of(context).size.width < 1000;

    List<String> images = product.proxiedAllImages;
    // product.proxiedAllImages;
    print('🖼️ Gallery images: ${product.proxiedAllImages}');
    print('🖼️ selectedIndex: $_selectedImageIndex');
    // Ensure selected index is valid
    if (_selectedImageIndex >= images.length) {
      _selectedImageIndex = 0;
    }

    final mainImage = images.isNotEmpty ? images[_selectedImageIndex] : '';

    // Responsive image sizes
    double imageWidth = isMobile ? 180 : (isSmallScreen ? 200 : 280);
    double imageHeight = isMobile ? 230 : (isSmallScreen ? 260 : 320);
    double thumbSize = isMobile ? 50 : 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, //  IMPORTANT: Prevents overflow
      children: [
        // Main image with navigation buttons
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT ARROW
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImageIndex =
                        (_selectedImageIndex - 1) % images.length;
                    if (_selectedImageIndex < 0) {
                      _selectedImageIndex = images.length - 1;
                    }
                  });
                },
                child: Container(
                  width: isMobile ? 28 : 36,
                  height: isMobile ? 28 : 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: const Color(0xFF2B6E3B),
                    size: isMobile ? 18 : 24,
                  ),
                ),
              ),

              // Main Image
              Container(
                width: imageWidth,
                height: imageHeight,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[50]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImage(mainImage, imageHeight, double.infinity),
                ),
              ),

              // RIGHT ARROW
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImageIndex =
                        (_selectedImageIndex + 1) % images.length;
                  });
                },
                child: Container(
                  width: isMobile ? 28 : 36,
                  height: isMobile ? 28 : 36,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: const Color(0xFF2B6E3B),
                    size: isMobile ? 18 : 24,
                  ),
                ),
              ),
            ],
          )
        else
          // Single image - no arrows
          Container(
            width: imageWidth,
            height: imageHeight,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(mainImage, imageHeight, double.infinity),
            ),
          ),

        const SizedBox(height: 12),

        //  Thumbnails - Limited to 5 visible with horizontal scroll
        if (images.length > 1)
          SizedBox(
            height: thumbSize + 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final imageUrl = images[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    width: thumbSize,
                    height: thumbSize + 20,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedImageIndex == index
                            ? const Color(0xFF2B6E3B)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImage(imageUrl, thumbSize, thumbSize),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ============= PRODUCT INFO =============
  Widget _buildProductInfo(Product product) {
    final String category = product.category.isNotEmpty
        ? product.category
        : '';
    final String sku =
        'EL-${category.substring(0, category.length > 3 ? 3 : category.length).toUpperCase()}-${product.productCode}';
    final String qty = '22';
    final String location = product.location;
    final String condition = product.condition;
    print(location);
    print(condition);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          product.productName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E2B),
          ),
        ),
        const SizedBox(height: 4),

        // Price
        Text(
          '\$${product.price.toStringAsFixed(2)} Kyats',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Meta Table - 2x2 grid like HTML
        Container(
          // padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildMetaRow('Category', category, 'Condition', condition),
              SizedBox(
                height: 0.9,
                width: double.infinity,
                child: Container(color: Colors.grey),
              ),
              _buildMetaRow('SKU', sku, 'Location', location),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildVariantTable(product),
      ],
    );
  }

  Widget _buildVariantTable(Product product) {
    final variants = product.variants;

    // Hide if no variants or only one
    if (variants == null || variants.length <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Variants',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E2B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    _variantCell('Variant Name', flex: 3, isHeader: true),
                    _variantCell('Price', flex: 2, isHeader: true),
                    _variantCell('Qty', flex: 1, isHeader: true),
                  ],
                ),
              ),
              // Rows
              ...variants.asMap().entries.map((entry) {
                final idx = entry.key;
                final v = entry.value;
                final isLast = idx == variants.length - 1;
                return Container(
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(bottom: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      _variantCell(v.variantName, flex: 3),
                      _variantCell('\$${v.price.toStringAsFixed(2)}', flex: 2),
                      _variantCell('${v.quantity}', flex: 1),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _variantCell(String text, {required int flex, bool isHeader = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildMetaRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Row(
      children: [
        // Label 1
        Container(
          width: 100,
          padding: EdgeInsets.all(10),
          color: Colors.grey[200],
          child: Text(
            label1,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        // Value 1
        Expanded(child: Container(child: Text(value1))),
        // Label 2
        Container(
          width: 100,
          padding: EdgeInsets.all(10),
          color: Colors.grey[200],
          child: Text(
            label2,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        // Value 2
        Expanded(child: Container(child: Text(value2))),
      ],
    );
  }

  // ============= ACTION BUTTONS =============
  Widget _buildActionButtons(Product product) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final sellerName = product.userId != null
                  ? 'Seller #${product.userId}'
                  : 'seller';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📩 Message sent to $sellerName!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B6E3B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ask Seller'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Consumer<ApiService>(
            builder: (context, cartController, child) {
              final inCart = cartController.isInCart(product.productId);
              return ElevatedButton(
                onPressed: () {
                  if (inCart) {
                    cartController.removeItem(product.productId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Removed from favourites'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } else {
                    cartController.addItem(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to favourites 🛒'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: inCart
                      ? Colors.grey
                      : const Color(0xFFFFA500),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(inCart ? 'Added to Favourite' : 'Add to Favourite'),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============= DESCRIPTION =============
  Widget _buildDescription(Product product) {
    final desc =
        product.description ??
        'Crafted from premium materials. Free shipping included. Sustainable packaging.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          desc,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
        ),
        const SizedBox(height: 8),
        Text(
          'Manufacturer: Elephant Co. & contains no harmful substances.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }

  // ============= SELLER INFO =============
  Widget _buildSellerInfo(Product product) {
    final int? userId = product.userId;
    // Since the API doesn't send seller name, show a friendly fallback
    final String sellerName = userId != null
        ? 'Seller #$userId'
        : 'Unknown Seller';
    final String avatarText = sellerName.substring(0, 1).toUpperCase();

    //  Check if screen is smaller than 1100px
    final bool isSmallScreen = MediaQuery.of(context).size.width < 1100;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: isSmallScreen
          ? Column(
              //  Stack vertically on screens < 1100px
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Avatar + Name + Rating
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB58B5C),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          avatarText,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/seller');
                            },
                            child: Text(
                              sellerName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .blue, // Optional: makes it look clickable
                                decoration:
                                    TextDecoration.underline, // Optional
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                '★★★★★',
                                style: TextStyle(color: Color(0xFFF5B042)),
                              ),
                              // Text(
                              //   rating.toStringAsFixed(1),
                              //   style: const TextStyle(
                              //     fontSize: 12,
                              //     fontWeight: FontWeight.w800,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Bottom row: Follow button full width
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(' You are now following $sellerName!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2B6E3B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 4),
                        Text('Follow Seller'),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Row(
              //  Desktop - Row layout (unchanged)
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB58B5C),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      avatarText,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/seller');
                        },
                        child: Text(
                          sellerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .blue, // Optional: makes it look clickable
                            decoration: TextDecoration.underline, // Optional
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            '★★★★★',
                            style: TextStyle(color: Color(0xFFF5B042)),
                          ),
                          // Text(
                          //   rating.toStringAsFixed(1),
                          //   style: const TextStyle(
                          //     fontSize: 12,
                          //     fontWeight: FontWeight.w800,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(' You are now following $sellerName!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2B6E3B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 16),
                      SizedBox(width: 4),
                      Text('Follow Seller'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ============= MORE FROM SELLER =============
  Widget _buildMoreFromStore(Product product) {
    final int? userId = product.userId;
    final String sellerName = userId != null
        ? 'Seller #$userId'
        : 'this seller';

    if (_sellerProducts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More from $sellerName\'s Store',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          // const SizedBox(height: 16),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No other items from this seller'),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 100, right: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More from $sellerName\'s Store',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _isMobile ? 4 : 12,
              crossAxisSpacing: 10,
              mainAxisSpacing: 5,
              childAspectRatio: 0.50,
            ),
            itemCount: _sellerProducts.length,
            itemBuilder: (context, index) {
              final sellerProduct = _sellerProducts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailPage(productId: sellerProduct.productId),
                    ),
                  );
                },
                child: Container(
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
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                          child: _buildImage(
                            sellerProduct.proxiedImageUrl,
                            double.infinity,
                            double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 6.0,
                        ),
                        child: Text(
                          sellerProduct.productName.length > 18
                              ? '${sellerProduct.productName.substring(0, 15)}...'
                              : sellerProduct.productName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '\$${sellerProduct.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD68247),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  //  Get products from same seller
  // List<Product> _getSellerProducts(Product currentProduct, ApiService productController) {
  //   if (currentProduct.seller == null) return [];

  //   try {
  //     List<Product> allProducts = [];

  //     //  Check if we're using mock data or real API
  //     print('useMockDataStatic: ${ApiService.useMockDataStatic}');
  //     if (ApiService.useMockDataStatic) {
  //       // Use mock data
  //       print(' Using mock data for seller products');
  //       allProducts = MockApiService.getMockProducts();
  //     } else {
  //       // Use real data from API
  //       print(' Using real API data for seller products');
  //       allProducts = productController.allProducts;

  //       // If allProducts is empty, wait and retry
  //       if (allProducts.isEmpty) {
  //        print(' No products loaded, trying to load from backend...');
  //       // Try to load products if not loaded
  //       productController.loadProducts();
  //       allProducts = productController.allProducts;

  //       // If still empty, use mock as fallback
  //       if (allProducts.isEmpty) {
  //         allProducts = MockApiService.getMockProducts();
  //       }
  //     }
  //     }

  //     // Filter products by same seller (excluding current product)
  //     final filtered = allProducts
  //         .where(
  //           (p) =>
  //               p.seller?.name == currentProduct.seller?.name &&
  //               p.productId != currentProduct.productId,
  //         )
  //         .take(8)
  //         .toList();

  //     print('Found ${filtered.length} products from seller: ${currentProduct.seller?.name}');
  //     return filtered;

  //   } catch (e) {
  //     // Fallback to mock data if anything fails
  //     print('Error getting seller products: $e');
  //     final allProducts = MockApiService.getMockProducts();
  //     return allProducts
  //         .where(
  //           (p) =>
  //               p.seller?.name == currentProduct.seller?.name &&
  //               p.productId != currentProduct.productId,
  //         )
  //         .take(8)
  //         .toList();
  //   }
  // }
  List<Product> _getSellerProducts(
    Product currentProduct,
    ApiService productController,
  ) {
    if (currentProduct.userId == null) {
      print('❌ currentProduct.userID is null');
      return [];
    }

    final allProducts = productController.allProducts;
    print('📋 allProducts count: ${allProducts.length}');
    print('👤 current userId: id=${currentProduct.userId}');
    print('🔍 current productId: ${currentProduct.productId}');

    final filtered = allProducts
        .where(
          (p) =>
              p.userId == currentProduct.userId && // 🔥 match by userId
              p.productId != currentProduct.productId,
        )
        .take(8)
        .toList();

    print('Found ${filtered.length} products from user');
    return filtered;
  }
}

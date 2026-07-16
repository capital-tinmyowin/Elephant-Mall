import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../services/Category_service.dart';
import '../services/mock_api_service.dart';
import 'common/footer.dart';
import 'common/header.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
 final VoidCallback? onBack;  //  Add callback
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService.loadProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = mobile(context);
_isMobile = isMobile; 
    return ChangeNotifierProvider.value(  // ← ADD THIS WRAPPER
    value: _apiService,                  // ← ADD THIS
    child:Scaffold(
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
                Expanded(child: Center(child: Text('Product not found'))),
              ],
            );
          }
          _sellerProducts = _getSellerProducts(product);
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
      bottomNavigationBar: isMobile
          ? CommonBottomBar(currentIndex: 1)
          : null,
      ),
    );
  }

  // ============= DESKTOP LAYOUT =============
  Widget _buildDesktopLayout(Product product) {
  final bool isSmallScreen = MediaQuery.of(context).size.width < 1000;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Product Gallery + Info - Responsive Row
      isSmallScreen
          ? Column(  // ✅ Stack vertically on smaller screens
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
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildProductGallery(product)),
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
                Expanded(flex: 1, child: const SizedBox(width: 24)),
              ],
            ),
      const SizedBox(height: 16),
      _buildMoreFromStore(product),
    ],
  );
}

  // ============= MOBILE LAYOUT =============
  Widget _buildMobileLayout(Product product) {
    return Column(
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
  
  final images = product.proxiedAllImages;
  final mainImage = images.isNotEmpty ? images[_selectedImageIndex] : '';

  // ✅ Responsive image sizes
  double imageWidth = isMobile ? 180 : (isSmallScreen ? 220 : 200);
  double imageHeight = isMobile ? 250 : (isSmallScreen ? 280 : 300);
  double thumbSize = isMobile ? 60 : (isSmallScreen ? 70 : 80);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Center(
        child: Container(
          width: imageWidth,
          height: imageHeight,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[50]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: mainImage,
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: imageHeight,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: imageHeight,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 80),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      if (images.length > 1)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              final index = entry.key;
              final imageUrl = entry.value;
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
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 20),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 20),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
    ],
  );
}

  // ============= PRODUCT INFO =============
  Widget _buildProductInfo(Product product) {
    final String category = product.category.isNotEmpty
        ? product.category
        : 'Fashion';
    final String sku =
        'EL-${category.substring(0, category.length > 3 ? 3 : category.length).toUpperCase()}-${product.id}';
    final String qty = '22';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          product.name,
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
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildMetaRow('Category', category, 'Condition', 'New'),
              _buildMetaRow('SKU', sku, 'Quantity Available', qty),
            ],
          ),
        ),
      ],
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: Colors.grey[200],
          child: Text(
            label1,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        // Value 1
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(value1),
          ),
        ),
        // Label 2
        Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: Colors.grey[200],
          child: Text(
            label2,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        // Value 2
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(value2),
          ),
        ),
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
              final sellerName = product.seller?.name ?? 'seller';
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
              final inCart = cartController.isInCart(product.id);
              return ElevatedButton(
                onPressed: () {
                  if (inCart) {
                    cartController.removeItem(product.id);
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
  final seller = product.seller;
  final String sellerName = seller?.name ?? 'Sarah J.';
  final double rating = seller?.rating ?? product.rating;
  final String avatarText = sellerName.substring(0, 1).toUpperCase();
  
  // ✅ Check if screen is smaller than 1100px
  final bool isSmallScreen = MediaQuery.of(context).size.width < 1100;

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: isSmallScreen
        ? Column(  // ✅ Stack vertically on screens < 1100px
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
                        Text(
                          sellerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              '★★★★★',
                              style: TextStyle(color: Color(0xFFF5B042)),
                            ),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
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
        : Row(  // ✅ Desktop - Row layout (unchanged)
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
                    Text(
                      sellerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          '★★★★★',
                          style: TextStyle(color: Color(0xFFF5B042)),
                        ),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
    final String sellerName = product.seller?.name ?? 'Sarah J.';

    //  If no seller products, show message
    if (_sellerProducts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More from $sellerName\'s Store',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No other items from this seller'),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More from $sellerName\'s Store',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        //  Grid like HTML store-grid with proper sizing
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _isMobile ? 3 : 7,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.80,
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
                        ProductDetailPage(productId: sellerProduct.id),
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
                    //  Product Image - Fixed aspect ratio
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: sellerProduct.proxiedImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2B6E3B),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    //  Product Name (like HTML store-item-name)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 6.0,
                      ),
                      child: Text(
                        sellerProduct.name.length > 18
                            ? '${sellerProduct.name.substring(0, 15)}...'
                            : sellerProduct.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    //  Price (like HTML store-item-price)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '\$${sellerProduct.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD68247),
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
    );
  }

   //  Get products from same seller
  List<Product> _getSellerProducts(Product currentProduct) {
    if (currentProduct.seller == null) return [];

    final allProducts = MockApiService.getMockProducts();
    return allProducts
        .where(
          (p) =>
              p.seller?.name == currentProduct.seller?.name &&
              p.id != currentProduct.id,
        )
        .take(8)
        .toList();
  }
}

import 'package:elephant_mall/models/business_contact.dart';
import 'package:elephant_mall/services/auth_service.dart';
import 'package:elephant_mall/view/common/loading_widget.dart';
import 'package:elephant_mall/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../services/Category_service.dart';
import 'common/footer.dart';
import 'common/header.dart';
import 'myListing.dart';
import 'sellerListing.dart';

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
  bool _pageLoading = true; // 🔥 new
  String? _pageError;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProduct());
  }

  @override
  void didUpdateWidget(covariant ProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    //  If the productId changes, reload the new product data
    if (oldWidget.productId != widget.productId) {
      setState(() {
        _pageLoading = true;
        _pageError = null;
        _selectedImageIndex = 0; // Reset image gallery
        _sellerProducts = []; // Clear old seller products
      });
      _loadProduct(); // Fetch the new product
    }
  }

  Future<void> _loadProduct() async {
    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      if (auth.isLoggedIn) {
        await auth.getUserFavorites();
        if (!mounted) return;
      }

      final json = await auth.getProductDetail(widget.productId);
      if (!mounted) return;

      if (json == null) {
        setState(() {
          _pageLoading = false;
          _pageError = 'Product not found';
        });
        return;
      }

      _apiService.setProductFromJson(json);
      final product = _apiService.selectedProduct;
      final uid = product?.userId;
      if (uid != null) {
        await _apiService.loadSellerProducts(uid);
      }

      if (mounted) setState(() => _pageLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pageLoading = false;
        _pageError = e.toString();
      });
    }
  }

  void openSellerFromProduct(BuildContext context, Product product) {
    final sellerId = product.userId;
    if (sellerId == null) return;

    final auth = Provider.of<AuthService>(context, listen: false);
    final currentUserId = auth.currentUser?.id;

    final sellerName = 'Seller #$sellerId';

    if (currentUserId != null && currentUserId == sellerId) {
      // My listing
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SellerStorePage(sellerId: sellerId, sellerName: sellerName),
        ),
      );
    } else {
      // Other seller
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SellerListingPage(sellerId: sellerId, sellerName: sellerName),
        ),
      );
    }
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
            Widget body;
            if (_pageLoading) {
              body = const CommonLoading(
                size: 42,
                message: 'Loading product...',
                height: 400,
              );
            } else if (_pageError != null) {
              body = CommonError(
                height: 400,
                title: 'Failed to load product',
                message: _pageError!,
                onRetry: () {
                  setState(() {
                    _pageLoading = true;
                    _pageError = null;
                  });
                  _loadProduct(); // 🔥 see below
                },
              );
            } else {
              final product = productController.selectedProduct;
              if (product == null) {
                body = const Center(child: Text('Product not found'));
              } else {
                _sellerProducts = productController.sellerProducts
                    .where((p) => p.productId != product.productId)
                    .take(8)
                    .toList();
                body = _isMobile
                    ? _buildMobileLayout(product)
                    : _buildDesktopLayout(product);
              }
            }

            return Column(
              children: [
                const CommonHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: body,
                  ),
                ),
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
                  _buildBusinessContacts(product), // Add this
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
                            _buildBusinessContacts(product), // Add this
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
        Center(child: _buildProductGallery(product)),
        const SizedBox(height: 16),
        _buildActionButtons(product),
        _buildBusinessContacts(product), //  Add this
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
    final List<String> categories = product.categories.isNotEmpty
        ? product.categories
        : (product.category.isNotEmpty ? [product.category] : []);
    // final String sku =
    //     'EL-${category.substring(0, category.length > 3 ? 3 : category.length).toUpperCase()}-${product.productCode}';
    // final String qty = '22';
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
          '${NumberFormat('#,##0').format(product.price)} Kyats',
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
              _buildCategoryRow(categories),
              SizedBox(
                height: 0.9,
                width: double.infinity,
                child: Container(color: Colors.grey),
              ),
              _buildMetaRow('Condition', condition, 'Location', location),
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
                      _variantCell(
                        '${NumberFormat('#,##0').format(v.price)}MMK',
                        flex: 2,
                      ),
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

  Widget _buildCategoryRow(List<String> categories) {
    final value = categories.isEmpty ? '' : categories.join(' / ');
    return Row(
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.all(10),
          color: Colors.grey[200],
          child: const Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              value,
              // style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
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
          padding: EdgeInsets.all(10),
          color: Colors.grey[200],
          child: Text(
            label1,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        // Value 1
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(value1),
          ),
        ),
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(value2),
          ),
        ),
      ],
    );
  }

  // ============= ACTION BUTTONS =============
  Widget _buildActionButtons(Product product) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final sellerName = product.userName != null
                  ? 'Seller ${product.userName}'
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
          child: Consumer<AuthService>(
            builder: (context, authService, child) {
              final isFav = authService.isFavorite(product.productId);
              final isLoggedIn = authService.isLoggedIn;
              return ElevatedButton(
                onPressed: () async {
                  if (!isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please sign in to save favourites'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  if (isFav) {
                    final ok = await authService.removeFavorite(
                      product.productId,
                    );
                    if (!context.mounted) return;
                    if (ok) {
                      await authService.getUserFavorites(); // 🔥 refetch
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok ? 'Removed from favourites' : 'Could not remove',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  } else {
                    final ok = await authService.addFavorite(product.productId);
                    if (!context.mounted) return;
                    if (ok) {
                      await authService.getUserFavorites(); // 🔥 refetch
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Added to favourites ❤️'
                              : authService.errorMessage ?? 'Could not add',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFav
                      ? Colors.grey
                      : const Color(0xFFFFA500),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isFav ? 'Added to Favourite' : 'Add to Favourite'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessContacts(Product product) {
    final contacts = product.businessContacts;
    if (contacts.isEmpty) return const SizedBox.shrink();

    // Create a map to hold only ONE contact per type (preferring primary)
    final Map<String, BusinessContact> uniqueContacts = {};
    for (var contact in contacts) {
      final type = contact.type.toLowerCase();
      if (type == 'phone' ||
          type == 'messenger' ||
          type == 'telegram' ||
          type == 'viber') {
        if (!uniqueContacts.containsKey(type) || contact.isPrimary) {
          uniqueContacts[type] = contact;
        }
      }
    }

    if (uniqueContacts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        // color: Colors.blue[50], // Light blue background like the photo
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(color: Colors.blue[200]!),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          if (uniqueContacts.containsKey('phone'))
            _contactIcon(
              Icons.phone,
              Colors.green,
              'Phone',
              uniqueContacts['phone']!,
            ),
          if (uniqueContacts.containsKey('messenger'))
            _contactIcon(
              FontAwesomeIcons.facebookMessenger,
              Colors.blue,
              'Messenger',
              uniqueContacts['messenger']!,
            ),
          if (uniqueContacts.containsKey('telegram'))
            _contactIcon(
              FontAwesomeIcons.telegram,
              Colors.blue[700]!,
              'Telegram',
              uniqueContacts['telegram']!,
            ),
          if (uniqueContacts.containsKey('viber'))
            _contactIcon(
              FontAwesomeIcons.viber,
              Colors.purple,
              'Viber',
              uniqueContacts['viber']!,
            ),
        ],
      ),
    );
  }

  Widget _contactIcon(
    dynamic icon,
    Color color,
    String label,
    BusinessContact contact,
  ) {
    return InkWell(
      onTap: () async {
        Uri? uri;
        // Build the corresponding link based on the contact type
        final type = contact.type.toLowerCase();
        final value = contact.value.trim();

        if (type == 'messenger') {
          String cleanValue = value.trim();

          // 1. If the user pasted a full Facebook URL, extract just the username part
          if (cleanValue.contains('facebook.com/')) {
            cleanValue = cleanValue.split('facebook.com/').last;
          }

          // 2. If they pasted a URL with a profile ID (e.g. profile.php?id=12345)
          if (cleanValue.contains('profile.php?id=')) {
            cleanValue = cleanValue.split('profile.php?id=').last;
            // For numeric IDs, m.me works directly: https://m.me/12345
          }

          // 3. Remove any extra slashes or query parameters
          if (cleanValue.contains('?')) {
            cleanValue = cleanValue.split('?').first;
          }
          if (cleanValue.endsWith('/')) {
            cleanValue = cleanValue.substring(0, cleanValue.length - 1);
          }

          // 4. (Optional) If it still has spaces (like "Saung Thet Ngon Oo"),
          // m.me will fail. But you can try replacing spaces with dots just in case.
          // However, it's better to enforce the database to store the correct username.

          uri = Uri.parse('https://m.me/$cleanValue');

          // DEBUG: Print to see what is happening
          print('Original value: $value');
          print('Cleaned username: $cleanValue');
          print('Generated URL: $uri');
        } else if (type == 'telegram') {
          // Telegram: if value is a phone number (+95...), use t.me/+95...
          // If it's a username, use t.me/username
          if (value.startsWith('+')) {
            uri = Uri.parse('https://t.me/$value');
          } else {
            // Remove possible @ symbol
            final username = value.startsWith('@') ? value.substring(1) : value;
            uri = Uri.parse('https://t.me/$username');
          }
        } else if (type == 'viber') {
          // 1. Clean the phone number: remove spaces, dashes, and the leading '+'
          String cleanPhone = value.replaceAll(RegExp(r'[\s\-\+]'), '');

          // 2. Viber deep link format for mobile
          // Note: The '+' sign is usually removed for the number parameter in Viber links
          uri = Uri.parse('viber://chat?number=$cleanPhone');

          // DEBUG: Print to verify the generated link
          print('Original Viber value: $value');
          print('Cleaned Viber phone: $cleanPhone');
          print('Generated Viber URI: $uri');
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Contact via $label'),
              content: SelectableText(contact.value),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
          return;
        }
        // Launch the link
        try {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication, // Open with external app
            webOnlyWindowName: '_blank', // Open in a new tab on web
          );
          if (!launched) {
            // If launch fails, show a prompt
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Could not open $label')));
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            //  Check if it's FontAwesome or standard Material icon
            icon is FaIconData
                ? FaIcon(icon, color: color, size: 20)
                : Icon(icon as IconData, color: color, size: 20),

            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
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
          style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
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
    final String? userName = product.userName;
    // final int? userId=product.userId;
    // Since the API doesn't send seller name, show a friendly fallback
    final String sellerName = userName != null
        ? 'Seller $userName'
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
                              context.go(
                                '/seller/${product.userId}?name=${Uri.encodeComponent(sellerName)}',
                              );
                            },
                            child: Text(
                              sellerName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
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
                          context.go(
                            '/seller/${product.userId}?name=${Uri.encodeComponent(sellerName)}',
                          );
                        },
                        child: Text(
                          sellerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
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
    // final int? userId = product.userId;
    final String? userName = product.userName;
    final String sellerName = userName != null
        ? 'Seller $userName'
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
      padding: _isMobile
          ? const EdgeInsets.all(1)
          : const EdgeInsets.only(left: 100, right: 100),
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
                  context.pushReplacement(
                    '/product/${sellerProduct.productId}',
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
                            sellerProduct.image,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'MMK${NumberFormat('#,##0').format(sellerProduct.price)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD68247),
                          ),
                          maxLines: 1,
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
}

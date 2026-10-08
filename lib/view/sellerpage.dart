import 'package:flutter/material.dart';

import '../models/sellerpagemodel.dart';
import '../services/sellerpageservice.dart';

import 'common/footer.dart';
import 'common/header.dart';
import 'product_detail_page.dart';
import 'sell.dart';

class SellerStorePage extends StatefulWidget {
  final int? sellerId;
  final String? sellerName;

  const SellerStorePage({super.key, this.sellerId, this.sellerName});

  @override
  State<SellerStorePage> createState() => _SellerStorePageState();
}

class _SellerStorePageState extends State<SellerStorePage> {
  final SellerPageService _service = SellerPageService();
  final TextEditingController _searchController = TextEditingController();
  List<Product> products = [];

  bool loading = true;
  bool isFollowing = false;

  String? errorMessage;

  String selectedCategory = 'By Category';
  String selectedPrice = 'Price';
  String selectedSort = 'Primmys by Price';
  String selectedShipping = 'Shipping & Payment';

  @override
  void initState() {
    super.initState();

    loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> loadProducts() async {
    if (!mounted) {
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final sellerId = widget.sellerId;

      if (sellerId == null) {
        throw Exception('Seller ID is required.');
      }

      debugPrint('');
      debugPrint('==============================================');
      debugPrint('SELLER STORE');
      debugPrint('SELLER ID: $sellerId');
      debugPrint('==============================================');

      final result = await _service.fetchSellerProducts(sellerId.toString());

      if (!mounted) {
        return;
      }

      setState(() {
        products = result;
        loading = false;
        errorMessage = null;
      });

      debugPrint('Seller products loaded: ${products.length}');
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==============================================');
      debugPrint('SELLER STORE PRODUCT ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('==============================================');

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        products = [];
        errorMessage = e.toString();
      });
    }
  }

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  String? getProductImageUrl(String? path) {
    final value = path?.trim() ?? '';

    if (value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

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
                    padding: EdgeInsets.symmetric(
                      horizontal: mobile ? 6 : 20,
                      vertical: mobile ? 5 : 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SELLER HEADER
                        buildSellerHeader(mobile),

                        const SizedBox(height: 5),

                        // SEARCH
                        buildSearchBox(mobile),

                        const SizedBox(height: 4),

                        // FILTERS
                        buildFilters(mobile),

                        const SizedBox(height: 7),

                        if (loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (products.isEmpty)
                          buildEmptyProducts()
                        else ...[
                          // PRODUCT GRID
                          buildProductGrid(mobile),

                          const SizedBox(height: 12),

                          // NEWEST ARRIVALS + BEST SELLERS
                          buildProductSections(mobile),
                        ],

                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ======================================================
          // DESKTOP FOOTER
          // ======================================================
          if (!mobile) const CommonFooter(),
        ],
      ),

      // ==========================================================
      // MOBILE BOTTOM BAR
      // ==========================================================
      bottomNavigationBar: mobile
          ? const CommonBottomBar(currentIndex: 4)
          : null,
    );
  }

  // ============================================================
  // SELLER HEADER
  // ============================================================

  Widget buildSellerHeader(bool mobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 3 : 15,
        vertical: mobile ? 3 : 10,
      ),
      color: Colors.white,
      child: Row(
        children: [
          // ======================================================
          // SELLER IMAGE
          // ======================================================
          Container(
            width: mobile ? 48 : 65,
            height: mobile ? 48 : 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/seller.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      size: mobile ? 30 : 40,
                      color: Colors.grey.shade500,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: mobile ? 8 : 12),

          // ======================================================
          // SELLER NAME + FOLLOW
          // ======================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sellerName ?? "Sarah J.'s Full Store",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 21 : 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff28733D),
                  ),
                ),

                const SizedBox(height: 4),

                // FOLLOW BUTTON
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isFollowing = !isFollowing;
                    });
                  },
                  child: Container(
                    height: mobile ? 20 : 27,
                    padding: EdgeInsets.symmetric(horizontal: mobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: isFollowing
                          ? Colors.grey.shade600
                          : const Color(0xff28733D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFollowing ? Icons.check : Icons.person_add_alt_1,
                          size: mobile ? 11 : 14,
                          color: Colors.white,
                        ),

                        const SizedBox(width: 3),

                        Text(
                          isFollowing ? 'Following' : 'Follow Seller',
                          style: TextStyle(
                            fontSize: mobile ? 9 : 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget buildSearchBox(bool mobile) {
    return SizedBox(
      height: mobile ? 28 : 38,
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: mobile ? 10 : 13),
        decoration: InputDecoration(
          hintText: "Search in Sarah J.'s Store",
          hintStyle: TextStyle(
            fontSize: mobile ? 9 : 12,
            color: Colors.grey.shade600,
          ),

          prefixIcon: Icon(
            Icons.search,
            size: mobile ? 15 : 20,
            color: Colors.grey.shade600,
          ),

          isDense: true,

          contentPadding: EdgeInsets.zero,

          filled: true,

          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xffC77C2E)),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget buildFilters(bool mobile) {
    return SizedBox(
      height: mobile ? 27 : 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // CATEGORY
            buildFilter(
              selectedCategory,
              ['By Category', 'Men', 'Women', 'Accessories'],
              (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              mobile,
            ),

            const SizedBox(width: 4),

            // PRICE
            buildFilter(
              selectedPrice,
              ['Price', 'Under 50,000', '50,000 - 100,000', 'Over 100,000'],
              (value) {
                setState(() {
                  selectedPrice = value;
                });
              },
              mobile,
            ),

            const SizedBox(width: 4),

            // SORT
            buildFilter(
              selectedSort,
              ['Primmys by Price', 'Lowest Price', 'Highest Price'],
              (value) {
                setState(() {
                  selectedSort = value;
                });
              },
              mobile,
            ),

            const SizedBox(width: 4),

            // SHIPPING
            buildFilter(
              selectedShipping,
              ['Shipping & Payment', 'Shipping', 'Payment'],
              (value) {
                setState(() {
                  selectedShipping = value;
                });
              },
              mobile,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FILTER DROPDOWN
  // ============================================================

  Widget buildFilter(
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
    bool mobile,
  ) {
    return Container(
      height: mobile ? 27 : 34,
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,

          isDense: true,

          icon: Icon(Icons.keyboard_arrow_down, size: mobile ? 13 : 17),

          style: TextStyle(color: Colors.black87, fontSize: mobile ? 8.5 : 12),

          dropdownColor: Colors.white,

          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),

          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT GRID
  // ============================================================

  Widget buildProductGrid(bool mobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;

        if (constraints.maxWidth < 500) {
          // PHONE
          columns = 3;
        } else if (constraints.maxWidth < 800) {
          // TABLET
          columns = 4;
        } else if (constraints.maxWidth < 1100) {
          // SMALL LAPTOP
          columns = 5;
        } else {
          // LARGE LAPTOP
          columns = 6;
        }

        const spacing = 5.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,

            // Reduce empty space below buttons
            childAspectRatio: mobile ? 1.08 : 0.95,
          ),
          itemBuilder: (context, index) {
            return buildProductCard(products[index], mobile);
          },
        );
      },
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget buildProductCard(Product product, bool mobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // PRODUCT IMAGE + EDIT BUTTON
          // ======================================================
          SizedBox(
            height: mobile ? 80 : 150,
            width: double.infinity,
            child: Stack(
              children: [
                // ------------------------------------------------
                // PRODUCT IMAGE
                // ------------------------------------------------
                Positioned.fill(
                  child: _buildProductImage(product.imageUrl, mobile),
                ),

                // ------------------------------------------------
                // EDIT BUTTON
                // ------------------------------------------------
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        editProduct(product);
                      },
                      child: SizedBox(
                        width: mobile ? 24 : 30,
                        height: mobile ? 24 : 30,
                        child: Icon(
                          Icons.edit,
                          size: mobile ? 13 : 17,
                          color: const Color(0xff28733D),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // PRODUCT INFORMATION
          // ======================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PRODUCT NAME
                Text(
                  product.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 9 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 2),

                // PRICE
                Text(
                  "${product.price} Kyat",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 9.5 : 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // BUTTONS
          // ======================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
            child: Row(
              children: [
                // =================================================
                // ADD TO FAVORITE
                // =================================================
                Expanded(
                  child: SizedBox(
                    height: mobile ? 18 : 27,
                    child: ElevatedButton(
                      onPressed: () {
                        addToCart(product);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffE88A17),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      child: Text(
                        'Add to Favorite',
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: mobile ? 7 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 3),

                // =================================================
                // VIEW DETAILS
                // =================================================
                Expanded(
                  child: SizedBox(
                    height: mobile ? 18 : 27,
                    child: OutlinedButton(
                      onPressed: () {
                        openProduct(product);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 0.8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: mobile ? 7 : 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT IMAGE WIDGET
  // ============================================================

  Widget _buildProductImage(String? imagePath, bool mobile) {
    final url = getProductImageUrl(imagePath);

    // ----------------------------------------------------------
    // NO VALID URL
    // ----------------------------------------------------------

    if (url == null) {
      return Container(
        color: const Color(0xffF2F2F2),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: mobile ? 25 : 40,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // NETWORK IMAGE
    // ----------------------------------------------------------

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xffF2F2F2),
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              size: mobile ? 25 : 40,
              color: Colors.grey.shade400,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: const Color(0xffF2F2F2),
          child: Center(
            child: SizedBox(
              width: mobile ? 15 : 22,
              height: mobile ? 15 : 22,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // NEWEST ARRIVALS + BEST SELLERS
  // ============================================================

  Widget buildProductSections(bool mobile) {
    final newest = products.take(4).toList();

    final best = products.length > 4
        ? products.skip(4).take(4).toList()
        : products.take(4).toList();

    // ==========================================================
    // MOBILE
    // ==========================================================

    if (mobile) {
      return Column(
        children: [
          buildProductSection(
            title: 'Newest Arrivals',
            items: newest,
            mobile: true,
          ),

          const SizedBox(height: 15),

          buildProductSection(title: 'Sales', items: best, mobile: true),
        ],
      );
    }

    // ==========================================================
    // LAPTOP / DESKTOP
    // ==========================================================

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: buildProductSection(
            title: 'Newest Arrivals',
            items: newest,
            mobile: false,
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: buildProductSection(
            title: 'Sales',
            items: best,
            mobile: false,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SINGLE PRODUCT SECTION
  // ============================================================

  Widget buildProductSection({
    required String title,
    required List<Product> items,
    required bool mobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // TITLE + VIEW ALL
        // ======================================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: mobile ? 20 : 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // VIEW ALL
            TextButton(
              onPressed: () {
                viewAllProducts(title);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 25),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'VIEW ALL',
                style: TextStyle(
                  fontSize: mobile ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff28733D),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // ======================================================
        // HORIZONTAL PRODUCTS
        // ======================================================
        SizedBox(
          height: mobile ? 150 : 205,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) {
              return const SizedBox(width: 5);
            },
            itemBuilder: (context, index) {
              final product = items[index];

              return SizedBox(
                width: mobile ? 135 : 180,
                child: buildSmallProductCard(product, mobile),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SMALL PRODUCT CARD
  // ============================================================

  Widget buildSmallProductCard(Product product, bool mobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // IMAGE
          // ======================================================
          SizedBox(
            height: mobile ? 85 : 125,
            width: double.infinity,
            child: _buildProductImage(product.imageUrl, mobile),
          ),

          // ======================================================
          // NAME + PRICE
          // ======================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 9 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  "${product.price} Kyat",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 9 : 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ======================================================
          // BUTTON
          // ======================================================
          Padding(
            padding: const EdgeInsets.all(3),
            child: SizedBox(
              height: mobile ? 18 : 25,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  openProduct(product);
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: BorderSide(color: Colors.grey.shade400, width: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(fontSize: mobile ? 7 : 9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY PRODUCTS
  // ============================================================

  Widget buildEmptyProducts() {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 50,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 10),

            Text(
              'No products found',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),

            // --------------------------------------------------
            // SHOW RETRY ONLY WHEN API FAILED
            // --------------------------------------------------
            if (errorMessage != null) ...[
              const SizedBox(height: 8),

              TextButton(onPressed: loadProducts, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  void addToCart(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.productName} added to Favorite'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xff28733D),
      ),
    );
  }

  void editProduct(Product product) {
    debugPrint('');
    debugPrint('==============================================');
    debugPrint('EDIT PRODUCT');
    debugPrint('Product ID: ${product.productId}');
    debugPrint('Product Name: ${product.productName}');
    debugPrint('==============================================');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellPage(productId: product.productId),
      ),
    );
  }

  void openProduct(Product product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailPage(
              // IMPORTANT:
              // Product model has productId,
              // not productCode.
              productId: product.productId,
            ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // ============================================================
  // VIEW ALL
  // ============================================================

  void viewAllProducts(String section) {
    debugPrint('View all: $section');

    // TODO:
    // Connect this to your product listing page.
  }
}

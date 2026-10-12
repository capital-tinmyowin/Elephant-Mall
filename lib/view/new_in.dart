import 'package:flutter/material.dart';

import '../models/new_in.dart';
import '../services/new_in_service.dart';
import 'common/header.dart';
import 'common/footer.dart';
import 'package:intl/intl.dart';
import 'common/loading_widget.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'login.dart';

class NewInPage extends StatefulWidget {
  const NewInPage({super.key});

  @override
  State<NewInPage> createState() => _NewInPageState();
}

class _NewInPageState extends State<NewInPage> {
  String selectedCategory = "All Categories";
  String selectedPrice = "All Prices";
  String selectedSort = "Newest";

  final NewInService _newInService = NewInService();

  List<NewInModel> allProducts = [];

  List<String> categories = [];

  bool isLoading = true;
  bool isCategoryLoading = true;

  String? errorMessage;
  String? categoryErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  List<String> get categoryDropdownItems {
    return ["All Categories", ...categories];
  }

  Future<void> _loadCategories() async {
    try {
      final result = await _newInService.getCategories();

      if (!mounted) return;

      setState(() {
        categories = result;
        isCategoryLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCategoryLoading = false;
        categoryErrorMessage = e.toString();
      });
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final products = await _newInService.getNewInProducts();

      if (!mounted) return;

      setState(() {
        allProducts = products;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // RESPONSIVE

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  // FILTER PRODUCTS

  List<NewInModel> get filteredProducts {
    List<NewInModel> result = List.from(allProducts);

    // Category
    if (selectedCategory != "All Categories") {
      result = result
          .where((product) => product.category == selectedCategory)
          .toList();
    }

    // Price
    if (selectedPrice == "Under 50") {
      result = result.where((product) => product.price < 50).toList();
    } else if (selectedPrice == "50 - 100") {
      result = result
          .where((product) => product.price >= 50 && product.price <= 100)
          .toList();
    } else if (selectedPrice == "Over 100") {
      result = result.where((product) => product.price > 100).toList();
    }

    // Sort
    if (selectedSort == "Price: Low to High") {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedSort == "Price: High to Low") {
      result.sort((a, b) => b.price.compareTo(a.price));
    }
    // else if (selectedSort == "Rating") {
    //   result.sort((a, b) => b.rating.compareTo(a.rating));
    // }

    return result;
  }

  Future<void> _showLoginRequiredDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xfffdfaf4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: Color(0xFFC77C2E), size: 28),
              SizedBox(width: 10),
              Text(
                "Login Required",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Your session has expired or you are not logged in.\n\n"
            "Please login to continue.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC77C2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                if (!mounted) return;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
                "Login",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleFavourite(NewInModel product) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    final currentUser = authService.currentUser;
    if (currentUser == null) {
      await _showLoginRequiredDialog();
      return;
    }

    // Already favourited → do nothing for now
    if (product.favourite == 1) {
      // ← compare with 1
      return;
    }

    try {
      final success = await _newInService.addFavourite(
        authService: authService,
        productId: product.productId,
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          product.favourite = 1; 
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Added to favourites'),
        //     backgroundColor: Colors.green,
        //     duration: Duration(seconds: 2),
        //   ),
        // );
      }
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().toLowerCase();

      if (message.contains('401') ||
          message.contains('unauthorized') ||
          message.contains('please login')) {
        await _showLoginRequiredDialog();
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProductError() {
    return SizedBox(
      width: double.infinity,
      height: 240,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 45, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Failed to load products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _loadProducts,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffF28C00),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final products = filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Column(
        children: [
          const CommonHeader(showMobileHeader: true),

          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mobileView ? 12 : 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Banner stays visible during product loading
                        _buildHeroBanner(mobileView),

                        const SizedBox(height: 10),

                        // Filters stay visible during product loading
                        _buildFilterRow(mobileView),

                        const SizedBox(height: 10),

                        if (!isLoading && errorMessage == null) ...[
                          _buildProductCount(products.length),
                          const SizedBox(height: 5),
                        ],

                        // Only the product section reloads
                        if (isLoading)
                          const CommonLoading(
                            size: 42,
                            message: 'Loading products...',
                            height: 240,
                          )
                        else if (errorMessage != null)
                          _buildProductError()
                        else
                          _buildProductGrid(products, mobileView),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (!mobileView) const CommonFooter(),
        ],
      ),
      bottomNavigationBar: mobileView
          ? const CommonBottomBar(currentIndex: 0)
          : null,
    );
  }
  // Widget _buildBreadcrumb() {
  //   return Row(
  //     children: [
  //       const Text(
  //         "Home",
  //         style: TextStyle(
  //           fontSize: 11,
  //           color: Colors.grey,
  //         ),
  //       ),

  //       const Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 6),
  //         child: Icon(
  //           Icons.chevron_right,
  //           size: 14,
  //           color: Colors.grey,
  //         ),
  //       ),

  //       const Text(
  //         "New In",
  //         style: TextStyle(
  //           fontSize: 11,
  //           color: Colors.orange,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // HERO BANNER

  Widget _buildHeroBanner(bool mobileView) {
    return Container(
      height: mobileView ? 150 : 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: AssetImage("assets/newarrival2.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: mobileView ? 20 : 28,
          top: mobileView ? 20 : 25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   "NEW IN THIS WEEK",
            //   style: TextStyle(
            //     color: const Color(0xff3D2116),
            //     fontSize: mobileView ? 24 : 32,
            //     fontWeight: FontWeight.w800,
            //   ),
            // ),
            const SizedBox(height: 3),

            // Text(
            //   "Fresh arrivals, handpicked for you.",
            //   style: TextStyle(
            //     color: const Color(0xff4A3328),
            //     fontSize: mobileView ? 11 : 13,
            //   ),
            // ),

            // Text(
            //   "Stay ahead of the trends in Yangon.",
            //   style: TextStyle(
            //     color: const Color(0xff4A3328),
            //     fontSize: mobileView ? 11 : 13,
            //   ),
            // ),
            const SizedBox(height: 10),

            SizedBox(
              height: 28,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "EXPLORE NEW ARRIVALS",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FILTER ROW

  Widget _buildFilterRow(bool mobileView) {
    if (mobileView) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: selectedCategory,
                  items: categoryDropdownItems,
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildDropdown(
                  value: selectedPrice,
                  items: const [
                    "All Prices",
                    "Under 50",
                    "50 - 100",
                    "Over 100",
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPrice = value!;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          _buildDropdown(
            value: selectedSort,
            items: const [
              "Newest",
              "Price: Low to High",
              "Price: High to Low",
              "Rating",
            ],
            onChanged: (value) {
              setState(() {
                selectedSort = value!;
              });
            },
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 180,
          child: _buildDropdown(
            value: selectedCategory,
            items: categoryDropdownItems,
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedCategory = value;
              });
            },
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 180,
          child: _buildDropdown(
            value: selectedPrice,
            items: const ["All Prices", "Under 50", "50 - 100", "Over 100"],
            onChanged: (value) {
              setState(() {
                selectedPrice = value!;
              });
            },
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 180,
          child: _buildDropdown(
            value: selectedSort,
            items: const [
              "Newest",
              "Price: Low to High",
              "Price: High to Low",
              "Rating",
            ],
            onChanged: (value) {
              setState(() {
                selectedSort = value!;
              });
            },
          ),
        ),

        const Spacer(),

        // Text(
        //   "Showing 1–${filteredProducts.length} of ${allProducts.length} results",
        //   style: const TextStyle(
        //     fontSize: 11,
        //     color: Colors.black54,
        //   ),
        // ),
      ],
    );
  }

  // DROPDOWN

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffD8D8D8)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: const TextStyle(fontSize: 11, color: Colors.black87),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // RESULT COUNT

  Widget _buildProductCount(int count) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        "Showing 1–$count of ${allProducts.length} results",
        style: const TextStyle(fontSize: 15, color: Colors.black54),
      ),
    );
  }

  // PRODUCT GRID

  Widget _buildProductGrid(List<NewInModel> products, bool mobileView) {
    if (products.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 240,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 45,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              const Text(
                'No products found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Try another category or price filter.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mobileView ? 2 : 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: mobileView ? 215 : 230,
      ),
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  // PRODUCT CARD

  Widget _buildProductCard(NewInModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffE1E1E1)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xffF4F4F4),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // NEW BADGE
                // if (product.isNew)
                //   Positioned(
                //     top: 5,
                //     left: 5,
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(
                //         horizontal: 7,
                //         vertical: 3,
                //       ),
                //       decoration: BoxDecoration(
                //         color: const Color(0xff087A24),
                //         borderRadius: BorderRadius.circular(5),
                //       ),
                //       child: const Text(
                //         "NEW",
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 9,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),

                // FAVORITE
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => _toggleFavourite(product),
                    borderRadius: BorderRadius.circular(20),
                    child: Icon(
                      product.favourite == 1
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 22,
                      color: product.favourite == 1 ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PRODUCT NAME
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Text(
              product.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 2),

          // PRICE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Text(
              "${NumberFormat('#,##0').format(product.price)} MMK",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 2),

          // RATING
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),

            // child: Row(
            //   children: [
            //     ...List.generate(5, (index) {
            //       return Icon(
            //         index < product.rating.round()
            //             ? Icons.star
            //             : Icons.star_border,
            //         size: 14,
            //         color: Colors.orange,
            //       );
            //     }),

            //     const SizedBox(width: 3),

            //     Text(
            //       "(${product.reviewCount})",
            //       style: const TextStyle(fontSize: 12, color: Colors.grey),
            //     ),
            //   ],
            // ),
          ),

          const Spacer(),

          // VIEW DETAILS BUTTON
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 1, 7, 6),
            child: SizedBox(
              width: double.infinity,
              height: 28,
              child: OutlinedButton(
                onPressed: () {
                  // TODO:
                  // Navigate to product details page
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "View Details",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

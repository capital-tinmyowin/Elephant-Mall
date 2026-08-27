import 'package:flutter/material.dart';

import '../models/sale.dart';
import '../services/sale_service.dart';
import 'common/header.dart';
import 'common/footer.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  String selectedCategory = "All Categories";
  String selectedDiscount = "Discount %";
  String selectedPrice = "Price Range";
  String selectedSort = "Biggest Savings";

  final SaleService _saleService = SaleService();

  List<SaleModel> allProducts = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // LOAD PRODUCTS

  Future<void> _loadProducts() async {
    try {
      final products = await _saleService.getSaleProducts();

      if (!mounted) return;

      setState(() {
        allProducts = products;
        isLoading = false;
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

  List<SaleModel> get filteredProducts {
    List<SaleModel> result = List.from(allProducts);

    // CATEGORY

    if (selectedCategory != "All Categories") {
      result = result
          .where((product) => product.category == selectedCategory)
          .toList();
    }

    // DISCOUNT

    if (selectedDiscount == "20%+") {
      result = result.where((product) => product.discount >= 20).toList();
    } else if (selectedDiscount == "30%+") {
      result = result.where((product) => product.discount >= 30).toList();
    } else if (selectedDiscount == "40%+") {
      result = result.where((product) => product.discount >= 40).toList();
    }

    // PRICE

    if (selectedPrice == "Under 30") {
      result = result.where((product) => product.salePrice < 30).toList();
    } else if (selectedPrice == "30 - 60") {
      result = result
          .where(
            (product) => product.salePrice >= 30 && product.salePrice <= 60,
          )
          .toList();
    } else if (selectedPrice == "Over 60") {
      result = result.where((product) => product.salePrice > 60).toList();
    }

    // SORT

    if (selectedSort == "Biggest Savings") {
      result.sort(
        (a, b) => (b.originalPrice - b.salePrice).compareTo(
          a.originalPrice - a.salePrice,
        ),
      );
    } else if (selectedSort == "Discount: High to Low") {
      result.sort((a, b) => b.discount.compareTo(a.discount));
    } else if (selectedSort == "Price: Low to High") {
      result.sort((a, b) => a.salePrice.compareTo(b.salePrice));
    } else if (selectedSort == "Price: High to Low") {
      result.sort((a, b) => b.salePrice.compareTo(a.salePrice));
    } else if (selectedSort == "Rating") {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return result;
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Failed to load sale products",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final products = filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),

      body: Column(
        children: [
          // HEADER
          const CommonHeader(),

          // CONTENT
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
                        const SizedBox(height: 8),

                        _buildHeroBanner(mobileView),

                        const SizedBox(height: 10),

                        _buildFilterRow(mobileView),

                        const SizedBox(height: 8),

                        _buildProductCount(products.length),

                        const SizedBox(height: 5),

                        _buildProductGrid(products, mobileView),

                        const SizedBox(height: 20),

                        _buildSaleCategories(mobileView),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // FOOTER
          if (!mobileView) const CommonFooter(),
        ],
      ),

      // ==========================================================
      // MOBILE BOTTOM BAR
      // ==========================================================
      bottomNavigationBar: mobileView
          ? const CommonBottomBar(currentIndex: 2)
          : null,
    );
  }

  // HERO BANNER

  Widget _buildHeroBanner(bool mobileView) {
    return Container(
      height: mobileView ? 150 : 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: const AssetImage("assets/salebanner.jpg"),
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: mobileView ? 20 : 35,
          top: mobileView ? 18 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "MEGA SALE DEALS 🔥",
              style: TextStyle(
                color: Colors.white,
                fontSize: mobileView ? 24 : 34,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              "Hot discounts on Yangon's trending fashion,",
              style: TextStyle(
                color: Colors.white,
                fontSize: mobileView ? 11 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            Text(
              "bags, shoes, and accessories.",
              style: TextStyle(
                color: Colors.white,
                fontSize: mobileView ? 11 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 30,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF28C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "SHOP SALE NOW",
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
                  items: const [
                    "All Categories",
                    "Shoes",
                    "Clothing",
                    "Bags",
                    "Accessories",
                    "Jewelry",
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildDropdown(
                  value: selectedDiscount,
                  items: const ["Discount %", "20%+", "30%+", "40%+"],
                  onChanged: (value) {
                    setState(() {
                      selectedDiscount = value!;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: selectedPrice,
                  items: const [
                    "Price Range",
                    "Under 30",
                    "30 - 60",
                    "Over 60",
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPrice = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildDropdown(
                  value: selectedSort,
                  items: const [
                    "Biggest Savings",
                    "Discount: High to Low",
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
            ],
          ),
        ],
      );
    }

    // DESKTOP

    return Row(
      children: [
        SizedBox(
          width: 180,
          child: _buildDropdown(
            value: selectedCategory,
            items: const [
              "All Categories",
              "Shoes",
              "Clothing",
              "Bags",
              "Accessories",
              "Jewelry",
            ],
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 150,
          child: _buildDropdown(
            value: selectedDiscount,
            items: const ["Discount %", "20%+", "30%+", "40%+"],
            onChanged: (value) {
              setState(() {
                selectedDiscount = value!;
              });
            },
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 150,
          child: _buildDropdown(
            value: selectedPrice,
            items: const ["Price Range", "Under 30", "30 - 60", "Over 60"],
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
              "Biggest Savings",
              "Discount: High to Low",
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

  // PRODUCT COUNT

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

  Widget _buildProductGrid(List<SaleModel> products, bool mobileView) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No sale products found.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // 2 products on mobile
        // 5 products on desktop
        crossAxisCount: mobileView ? 2 : 5,

        crossAxisSpacing: 8,
        mainAxisSpacing: 8,

        mainAxisExtent: mobileView ? 225 : 235,
      ),
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  // PRODUCT CARD

  Widget _buildProductCard(SaleModel product) {
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
            height: 125,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        product.imagePath,
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

                // DISCOUNT BADGE
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffE85B0A),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "-${product.discount}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // NEW BADGE
                if (product.isNew)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffE85B0A),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        "SALE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // FAVORITE
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () {},
                    child: const Icon(
                      Icons.favorite_border,
                      size: 22,
                      color: Colors.grey,
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
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 2),

          // PRICE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Row(
              children: [
                Text(
                  "\$${product.originalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  "\$${product.salePrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // RATING
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Stars
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < product.rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      size: 13,
                      color: Colors.orange,
                    );
                  }),
                ),

                const SizedBox(width: 5),

                // Review count
                Text(
                  "(${product.reviewCount})",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          const Spacer(),

          // VIEW DEAL BUTTON
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 1, 7, 6),
            child: SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                onPressed: () {
                  // TODO:
                  // Navigate to Product Detail
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF28C00),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "VIEW DEAL",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SALE CATEGORY STRIP

  Widget _buildSaleCategories(bool mobileView) {
    final categories = [
      {
        "title": "Fashion Sale",
        "subtitle": "Up to 50% Off",
        "icon": Icons.checkroom,
      },
      {
        "title": "Accessories Sale",
        "subtitle": "Up to 50% Off",
        "icon": Icons.watch,
      },
      {
        "title": "Bags Sale",
        "subtitle": "Up to 50% Off",
        "icon": Icons.shopping_bag,
      },
      {
        "title": "Shoes Sale",
        "subtitle": "Up to 50% Off",
        "icon": Icons.directions_run,
      },
      {
        "title": "Clearance",
        "subtitle": "Extra Discounts",
        "icon": Icons.local_offer,
      },
    ];

    Widget _buildSaleCategoryCard(
      Map<String, Object> category, {
      required double width,
      required double height,
    }) {
      return Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffE1E1E1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // ICON
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xffEEF6EE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category["icon"] as IconData,
                size: 22,
                color: const Color(0xff3A7D44),
              ),
            ),

            const SizedBox(width: 8),

            // TEXT
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category["title"] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    category["subtitle"] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      );
    }

    // MOBILE

    if (mobileView) {
      return SizedBox(
        height: 85,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return _buildSaleCategoryCard(
              categories[index],
              width: 180,
              height: 85,
            );
          },
        ),
      );
    }

    // DESKTOP

    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Row(
        children: List.generate(categories.length, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == categories.length - 1 ? 0 : 8,
              ),
              child: _buildSaleCategoryCard(
                categories[index],
                width: double.infinity,
                height: 70,
              ),
            ),
          );
        }),
      ),
    );
  }
}

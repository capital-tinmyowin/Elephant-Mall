import 'package:flutter/material.dart';
import 'common/header.dart';
import 'common/footer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/seller_service.dart';

int getCrossAxisCount(double width) {
  if (width >= 1600) return 6;
  if (width >= 1400) return 5;
  if (width >= 1100) return 4;
  if (width >= 380) return 3;
  return 2;
}

// Seller Header Widget
class SellerHeaderWidget extends StatefulWidget {
  final String sellerName;
  final int? expandedInfo;
  final Function(int?) onExpandChanged;

  const SellerHeaderWidget({
    super.key,
    required this.sellerName,
    required this.expandedInfo,
    required this.onExpandChanged,
  });

  @override
  State<SellerHeaderWidget> createState() => _SellerHeaderWidgetState();
}

class _SellerHeaderWidgetState extends State<SellerHeaderWidget> {
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isSmall = MediaQuery.of(context).size.width <= 380;
    final isTiny = MediaQuery.of(context).size.width <= 320;

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isMobile ? 25 : 45,
                  backgroundImage: const AssetImage("assets/avatar.jpg"),
                ),

                const SizedBox(width: 20),

                /// Seller Name + Buttons
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.sellerName}'s Full Store",
                        style: TextStyle(
                          fontSize: isSmall ? 16 : (isMobile ? 20 : 28),
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          SizedBox(
                            width: isSmall ? 80 : (isMobile ? 120 : 140),
                            height: isSmall ? 25 : 30,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmall ? 5 : 12,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  isFollowing = !isFollowing;
                                });
                              },
                              icon: isFollowing
                                  ? null
                                  : Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: isSmall ? 14 : 20,
                                    ),
                              label: Text(
                                isFollowing ? "Following" : "Follow",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmall ? 11 : (isMobile ? 14 : 16),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          SizedBox(
                            width: isSmall ? 80 : (isMobile ? 120 : 140),
                            height: isSmall ? 25 : 30,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmall ? 5 : 12,
                                ),
                              ),
                              onPressed: () {},
                              icon: Icon(
                                Icons.chat_bubble_outline,
                                size: isSmall ? 14 : 20,
                              ),
                              label: Text(
                                isMobile ? "Chat" : "Chat Seller",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmall ? 11 : (isMobile ? 14 : 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// Desktop view
                if (!isMobile) ...[
                  const VerticalDivider(width: 40),

                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16),
                            SizedBox(width: 5),
                            Text("Yangon, Myanmar"),
                          ],
                        ),

                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(Icons.people_outline, size: 16),
                            SizedBox(width: 5),
                            Text("1,235 Followers"),
                          ],
                        ),

                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 16),
                            SizedBox(width: 5),
                            Text("124 Products"),
                          ],
                        ),

                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(Icons.schedule, size: 16),
                            SizedBox(width: 5),
                            Text("Usually responds \n within 2 hours"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "assets/store_banner.jpg",
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],

                /// Mobile icons
              ],
            ),

            //Mobile view
            // if (isMobile)
            //   Positioned(
            //     top: -5,
            //     right: -7,
            //     child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: [
            //         Align(
            //           alignment: Alignment.centerRight,
            //           child: infoIcon(
            //             index: 0,
            //             icon: Icons.location_on_outlined,
            //             text: "Yangon, Myanmar",
            //           ),
            //         ),

            //         Align(
            //           alignment: Alignment.centerRight,
            //           child: infoIcon(
            //             index: 1,
            //             icon: Icons.people_outline,
            //             text: "1,235 Followers",
            //           ),
            //         ),

            //         Align(
            //           alignment: Alignment.centerRight,
            //           child: infoIcon(
            //             index: 2,
            //             icon: Icons.inventory_2_outlined,
            //             text: "124 Products",
            //           ),
            //         ),

            //         Align(
            //           alignment: Alignment.centerRight,
            //           child: infoIcon(
            //             index: 3,
            //             icon: Icons.schedule,
            //             text: "Usually responds within 2 hours",
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget infoIcon({
    required int index,
    required IconData icon,
    required String text,
  }) {
    final bool expanded = widget.expandedInfo == index;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        widget.onExpandChanged(expanded ? null : index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: expanded
              ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(icon, size: 16),

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(text),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// Seller Card Widget
class SellerItemWidget extends StatelessWidget {
  final String title;
  final int price;
  final double rating;
  final String description;
  final String image;

  const SellerItemWidget({
    super.key,
    required this.title,
    required this.price,
    required this.rating,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 170;
        return Card(
          elevation: 3,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.asset(image, fit: BoxFit.cover),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isSmall ? 5 : 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmall ? 10 : 14,
                              ),
                            ),
                          ),
                          Text(
                            "⭐ $rating",
                            style: TextStyle(fontSize: isSmall ? 10 : 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        child: Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: isSmall ? 9 : 12,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Price
                      Text(
                        "$price Kyat",
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: isSmall ? 9 : 14,
                        ),
                      ),

                      const SizedBox(height: 10),
                      // Buttons side by side
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: isSmall ? 22 : 32,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  isSmall ? "Add To Fav" : "Add to Favourite",
                                  style: TextStyle(
                                    fontSize: isSmall ? 7 : 11,
                                    color: Colors.white,
                                  ),
                                  key: ValueKey('label'),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),

                          Expanded(
                            child: SizedBox(
                              height: isSmall ? 22 : 32,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  side: const BorderSide(
                                    color: Colors.green,
                                    width: 1.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontSize: isSmall ? 7 : 11,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

double getAspectRatio(double width) {
  if (width >= 1600) return 0.85;
  if (width >= 1400) return 0.80;
  if (width >= 1100) return 0.75;
  if (width >= 800) return 0.68;
  if (width >= 600) return 0.65;
  return 0.62;
}

// Seller Page
class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  int? expandedInfo;

  @override
  Widget build(BuildContext context) {
    final items = sellerData["items"] as List<dynamic>;
    final width = MediaQuery.of(context).size.width;
    final mobile = isMobile(context);
    final desktop = isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xffF3F3F3),
      bottomNavigationBar: mobile
          ? const CommonBottomBar(currentIndex: 2)
          : null,

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (expandedInfo != null) {
            setState(() => expandedInfo = null);
          }
        },
        child: Column(
          children: [
            const CommonHeader(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// Seller Header
                    SellerHeaderWidget(
                      sellerName: sellerData["name"],
                      expandedInfo: expandedInfo,
                      onExpandChanged: (v) {
                        setState(() => expandedInfo = v);
                      },
                    ),

                    const SizedBox(height: 16),

                    /// Body
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Category Menu
                          if (desktop) ...[
                            SizedBox(
                              width: 220,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 220, // fixed desktop width
                                      child: const SellerSideMenu(),
                                    ),
                                    const SizedBox(width: 16, height: 16),

                                    const SellerFilterSidebar(),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),
                          ],

                          /// Right Side
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  /// Seller Items
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),

                                    itemCount: items.length,

                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: getCrossAxisCount(
                                            width,
                                          ),
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 5,
                                          childAspectRatio: getAspectRatio(width,),
                                        ),

                                    itemBuilder: (context, index) {
                                      final item = items[index];

                                      return SellerItemWidget(
                                        title: item["title"],
                                        price: item["price"],
                                        rating: item["rating"],
                                        description: item["description"],
                                        image: item["image"],
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 20),

                                  /// Product Sections
                                  if (desktop)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ProductSection(
                                            title: "Newest Arrivals",
                                            products: newestProducts,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: ProductSection(
                                            title: "Best Sellers",
                                            products: bestSellerProducts,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ProductSection(
                                            title: "Newest Arrivals",
                                            products: newestProducts,
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        Expanded(
                                          child: ProductSection(
                                            title: "Best Sellers",
                                            products: bestSellerProducts,
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (!mobile) const CommonFooter(),
          ],
        ),
      ),
    );
  }
}

bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 450;
bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width > 800;

Widget filterDropdown(String label, List<String> options) {
  String? selectedValue;

  return StatefulBuilder(
    builder: (context, setState) {
      return IntrinsicWidth(
        child: DropdownButtonFormField<String>(
          value: selectedValue,

          isExpanded: false,

          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),

          style: const TextStyle(fontSize: 12, color: Colors.black),

          items: options.map((opt) {
            return DropdownMenuItem(
              value: opt,
              child: Text(
                opt,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            );
          }).toList(),

          onChanged: (val) {
            setState(() {
              selectedValue = val;
            });
          },
        ),
      );
    },
  );
}

class SellerSideMenu extends StatelessWidget {
  const SellerSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          _menuItem(Icons.checkroom, 'Men'),
          _menuItem(Icons.woman, 'Women'),
          _menuItem(Icons.shopping_bag, 'Bags'),
          _menuItem(Icons.watch, 'Watch'),
          _menuItem(Icons.hiking, 'Shoes'),
        ],
      ),
    );
  }

  static Widget _menuItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(text)],
      ),
    );
  }
}

class SearchBars extends StatelessWidget {
  const SearchBars({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search in Sarah J.'s Store",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () {},
          ),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: filterDropdown("By Category", ["Men", "Women", "Shoes"]),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 240,
            child: filterDropdown("Price: 0 to 500,000 Kyats", [
              "0 - 500,000 Kyats",
              "500,000+",
            ]),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 250,
            child: filterDropdown("Sort by Price: Low to High", [
              "Low to High",
              "High to Low",
            ]),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 150,
            child: filterDropdown("Location: All", [
              "All",
              "Yangon",
              "Mandalay",
            ]),
          ),
        ],
      ),
    );
  }
}

class SellerFilterSidebar extends StatelessWidget {
  const SellerFilterSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FILTERS",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 15),

          //CATEGORY
          const Text("Category", style: TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: "All Categories",
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: "All Categories",
                child: Text("All Categories"),
              ),
            ],
            onChanged: (_) {},
          ),

          const SizedBox(height: 15),

          //PRICE
          const Text(
            "Price Range (Kyat)",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Min",
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text("-"),
              ),

              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Max",
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          //---------------- TAGS ----------------
          const Text("Tags", style: TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 10),

          checkbox("New"),
          checkbox("Pre-owned"),
          checkbox("Premium"),
          checkbox("Handmade"),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: const Text("Clear Filters"),
            ),
          ),
        ],
      ),
    );
  }

  Widget checkbox(String title) {
    return Row(
      children: [
        Checkbox(value: false, onChanged: (_) {}),
        Expanded(child: Text(title)),
      ],
    );
  }
}

class ProductSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> products;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 800;

    // Show 1 item per page on mobile, 4 on desktop
    final itemsPerPage = mobile ? 1 : 4;
    final viewportFraction = 1 / itemsPerPage;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          /// HEADER
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: mobile ? 12 : 22,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: Text(
                  "View All",
                  style: TextStyle(fontSize: mobile ? 10 : 18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// CAROUSEL
          /// CONTENT
          if (mobile)
            CarouselSlider(
              options: CarouselOptions(
                height: 120,
                viewportFraction: 1,
                enableInfiniteScroll: true,
                enlargeCenterPage: false,
                autoPlay: false,
              ),
              items: products.map((item) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item["image"],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              }).toList(),
            )
          else
            SizedBox(
              height: 180,
              child: Row(
                children: List.generate(
                  products.length > 4 ? 4 : products.length,
                  (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index == 3 ? 0 : 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            products[index]["image"],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

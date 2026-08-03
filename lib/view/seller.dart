import 'package:flutter/material.dart';
import 'common/header.dart';
import 'common/footer.dart';

final Map<String, dynamic> sellerData = {
  "name": "John Corner",
  "items": [
    {
      "title": "Straw Sun Hat ",
      "price": 45000,
      "rating": 4.7,
      "image": "assets/sunhat.jpg",
    },
    {
      "title": "Straw Sun Hat ",
      "price": 45000,
      "rating": 4.7,
      "image": "assets/sunhat.jpg",
    },
    {
      "title": "Straw Sun Hat ",
      "price": 45000,
      "rating": 4.7,
      "image": "assets/sunhat.jpg",
    },
    {
      "title": "Men's Wool Coat",
      "price": 45000,
      "rating": 4.8,
      "image": "assets/woolhat.jpg",
    },
    {
      "title": "Leather Tote Bag",
      "price": 120000,
      "rating": 4.8,
      "image": "assets/leatherBag.jpg",
    },
    {
      "title": "Leather Tote Bag",
      "price": 120000,
      "rating": 4.8,
      "image": "assets/leatherBag.jpg",
    },
  ],
};

int getCrossAxisCount(double width) {
  if (width >= 1400) return 6;
  if (width >= 1100) return 5;
  if (width >= 850) return 4;
  if (width >= 650) return 3;

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
                        isMobile
                            ? "${widget.sellerName}'s\nFull Store"
                            : "${widget.sellerName}'s Full Store",
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              setState(() {
                                isFollowing = !isFollowing;
                              });
                            },
                            icon: isFollowing
                                ? null
                                : const Icon(Icons.add, color: Colors.white),
                            label: Text(
                              isFollowing ? "Following" : "Follow",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: Text(
                              isMobile ? "Chat" : "Chat Seller",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// Desktop view
                if (!isMobile) ...[
                  const VerticalDivider(width: 40,),

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
                            Text("Usually responds within 2 hours"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),
                ],

                /// Mobile icons
              ],
            ),

            //Mobile view
            if (isMobile)
              Positioned(
                top: -5,
                right: -7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: infoIcon(
                        index: 0,
                        icon: Icons.location_on_outlined,
                        text: "Yangon, Myanmar",
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: infoIcon(
                        index: 1,
                        icon: Icons.people_outline,
                        text: "1,235 Followers",
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: infoIcon(
                        index: 2,
                        icon: Icons.inventory_2_outlined,
                        text: "124 Products",
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: infoIcon(
                        index: 3,
                        icon: Icons.schedule,
                        text: "Usually responds within 2 hours",
                      ),
                    ),
                  ],
                ),
              ),
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
  final String image;

  const SellerItemWidget({
    super.key,
    required this.title,
    required this.price,
    required this.rating,
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
                                fontSize: isSmall ? 11 : 14,
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
                      // Price
                      Text(
                        "$price Kyat",
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: isSmall ? 11 : 14,
                        ),
                      ),

                      const Spacer(),
                      // Buttons side by side
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: isSmall ? 20 : 36,
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
                          SizedBox(width: isSmall ? 4 : 8),

                          Expanded(
                            child: SizedBox(
                              height: isSmall ? 24 : 36,
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
                          const SizedBox(height: 4),
                        ],
                      ),
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

// Seller Page
class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  int? expandedInfo;

  bool menuExpanded = true;

  @override
  Widget build(BuildContext context) {
    final items = sellerData["items"] as List<dynamic>;
    final width = MediaQuery.of(context).size.width;
    final mobile = isMobile(context);

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
                          Align(
                            alignment: Alignment.topLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeInOutCubic,
                              width: menuExpanded ? (mobile ? 150 : 200) : 60,

                              child: SellerSideMenu(
                                expanded: menuExpanded,
                                onMenuPressed: () {
                                  setState(() {
                                    menuExpanded = !menuExpanded;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          /// Right Side
                          Expanded(
                            child: Column(
                              children: [
                                const SearchBars(),

                                const SizedBox(height: 10),

                                const FilterBar(),

                                const SizedBox(height: 16),

                                Expanded(
                                  child: GridView.builder(
                                    itemCount: items.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              (mobile && menuExpanded)
                                              ? 1
                                              : getCrossAxisCount(width),

                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,

                                          childAspectRatio: width < 500
                                              ? .65
                                              : width < 800
                                              ? .72
                                              : .80,
                                        ),
                                    itemBuilder: (context, index) {
                                      final item = items[index];

                                      return SellerItemWidget(
                                        title: item["title"],
                                        price: item["price"],
                                        rating: item["rating"],
                                        image: item["image"],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],
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

bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 430;

Widget filterDropdown(String label, List<String> options) {
  String? selectedValue;

  return StatefulBuilder(
    builder: (context, setState) {
      return SizedBox(
        width: MediaQuery.of(context).size.width < 800 ? 120 : 160,
        child: DropdownButtonFormField<String>(
          value: selectedValue,

          isExpanded: true,

          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),

          style: const TextStyle(fontSize: 12),

          items: options.map((opt) {
            return DropdownMenuItem(
              value: opt,
              child: Text(
                opt,
                overflow: TextOverflow.ellipsis,
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
  final bool expanded;
  final VoidCallback onMenuPressed;

  const SellerSideMenu({
    super.key,
    required this.expanded,
    required this.onMenuPressed,
  });

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
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          child: child,
                        ),
                      );
                    },
                    child: expanded
                        ? const Text(
                            "Categories",
                            key: ValueKey("title"),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox(key: ValueKey("empty")),
                  ),
                ),
                IconButton(
                  onPressed: onMenuPressed,
                  icon: const Icon(Icons.menu),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          _menuItem(Icons.checkroom, "Men"),
          _menuItem(Icons.woman, "Women"),
          _menuItem(Icons.shopping_bag, "Bags"),
          _menuItem(Icons.watch, "Watch"),
          _menuItem(Icons.hiking, "Shoes"),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: expanded ? 1 : 0,
                      child: Text(text, overflow: TextOverflow.ellipsis),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        filterDropdown("By Category", ["Men", "Women", "Shoes"]),

        filterDropdown("Price Range", ["0 - 500,000 Kyat", "500,000+"]),

        filterDropdown("Sort by Price", ["Low to High", "High to Low"]),

        filterDropdown("Location", ["All", "Yangon", "Mandalay"]),
      ],
    );
  }
}

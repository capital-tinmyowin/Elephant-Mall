import 'package:flutter/material.dart';
import 'common/header.dart';
import 'common/footer.dart';

// Example JSON data structure
final Map<String, dynamic> sellerData = {
  "name": "John Corner's Full Store",
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
  return 3;
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
                // Avatar
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
                        widget.sellerName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
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

                /// Desktop only
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
                            Text("Usually responds within 2 hours"),
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

            if (isMobile)
              Positioned(
                top: 0,
                right: 0,
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
            Icon(icon, size: 20),

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
                              height: isSmall ? 28 : 36,
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
                              height: isSmall ? 28 : 36,
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
  @override
  Widget build(BuildContext context) {
    final items = sellerData["items"] as List<dynamic>;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      bottomNavigationBar: isMobile(context)
          ? const CommonBottomBar(currentIndex: 2)
          : null,

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,

        onTap: () {
          if (expandedInfo != null) {
            setState(() {
              expandedInfo = null;
            });
          }
        },

        child: Column(
          children: [
            // Header
            const CommonHeader(),

            // Page Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    SellerHeaderWidget(
                      sellerName: sellerData["name"],
                      expandedInfo: expandedInfo,

                      onExpandChanged: (value) {
                        setState(() {
                          expandedInfo = value;
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: GridView.builder(
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: getCrossAxisCount(
                            MediaQuery.of(context).size.width,
                          ),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: width < 500
                              ? 0.65
                              : width < 800
                              ? 0.72
                              : 0.80,
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
                  ],
                ),
              ),
            ),

            // Footer (desktop only)
            if (!isMobile(context)) const CommonFooter(),
          ],
        ),
      ),
    );
  }
}

bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 800;

Widget filterDropdown(String label, List<String> options) {
  String? selectedValue;

  return StatefulBuilder(
    builder: (context, setState) {
      return SizedBox(
        width: 160,
        child: DropdownButtonFormField<String>(
          initialValue: selectedValue,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: const TextStyle(fontSize: 13), // smaller text
          items: options.map((opt) {
            return DropdownMenuItem(value: opt, child: Text(opt));
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

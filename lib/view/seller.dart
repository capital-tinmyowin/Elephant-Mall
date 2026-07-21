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
  return 2;
}

// Seller Header Widget
class SellerHeaderWidget extends StatefulWidget {
  final String sellerName;

  const SellerHeaderWidget({super.key, required this.sellerName});

  @override
  State<SellerHeaderWidget> createState() => _SellerHeaderWidgetState();
}

class _SellerHeaderWidgetState extends State<SellerHeaderWidget> {
  bool isFollowing = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seller name + follow button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
            ),

            const SizedBox(width: 12),

            // Responsive section for sellerName + follow button
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // Mobile view → stack sellerName above follow button
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.sellerName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isFollowing = !isFollowing;
                            });
                          },
                          child: Text(
                            isFollowing ? "Following" : "Follow",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Desktop view → sellerName and follow button in one row
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.sellerName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isFollowing = !isFollowing;
                            });
                          },
                          child: Text(
                            isFollowing ? "Following" : "Follow",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Search bar
        SizedBox(
          height: 36,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search items...",
              isDense: true,
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Sorting bar (UI only)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            filterChip("Category"),
            filterChip("Price"),
            filterChip("Shipping"),
            filterChip("Sort"),
          ],
        ),
      ],
    );
  }
}

// Seller Item Widget
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
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.asset(image, fit: BoxFit.cover),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Rating in one row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text("⭐ $rating"),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Price
                  Text(
                    "$price Kyat",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),

                  const Spacer(),
                  // Buttons side by side
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Add to Cart",
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "View Details",
                            style: TextStyle(
                              fontSize: 11.0, // Set your desired size here
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
  }
}

// Seller Page
class SellerPage extends StatelessWidget {
  const SellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = sellerData["items"] as List<dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      bottomNavigationBar: isMobile(context)
          ? const CommonBottomBar(currentIndex: 2)
          : null,

      body: Column(
        children: [
          // Header
          const CommonHeader(),

          // Page Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  SellerHeaderWidget(sellerName: sellerData["name"]),

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
                        childAspectRatio: 0.80,
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
    );
  }
}

bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 800;

Widget filterChip(String text) {
  return SizedBox(
    height: 30,
    child: Chip(
      label: Text(text),
      visualDensity: const VisualDensity(vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  );
}

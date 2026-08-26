import 'package:flutter/material.dart';

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

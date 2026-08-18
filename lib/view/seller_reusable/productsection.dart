import 'package:carousel_slider/carousel_slider.dart';              
import 'package:flutter/material.dart';

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

    // final itemsPerPage = mobile ? 1 : 4;
    // final viewportFraction = 1 / itemsPerPage;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
 
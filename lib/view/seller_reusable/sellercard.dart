import 'package:flutter/material.dart';
import 'package:elephant_mall/view/product_detail_page.dart';

class SellerItemWidget extends StatelessWidget {
  final String productName;
  final int productCode;
  final int price;
  final double rating;
  final String description;
  final String image;

  const SellerItemWidget({
    super.key,
    required this.productName,
    required this.productCode,
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
                              productName,
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(
                                        productId: productCode,
                                      ),
                                    ),
                                  );
                                },
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

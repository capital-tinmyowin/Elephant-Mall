import 'package:flutter/material.dart';
import 'package:elephant_mall/view/sell.dart';
import 'package:elephant_mall/view/product_detail_page.dart';

class SellerItemWidget extends StatefulWidget {
  final int userID;
  final int productCode;
  final String productName;
  final int price;
  final double rating;
  final String description;
  final String image;

  const SellerItemWidget({
    super.key,
    required this.userID,
    required this.productCode,
    required this.productName,
    required this.price,
    required this.rating,
    required this.description,
    required this.image,
  });

  @override
  State<SellerItemWidget> createState() => _SellerItemWidgetState();
}

class _SellerItemWidgetState extends State<SellerItemWidget> {
  late String currentTitle;
  late int currentPrice;
  late double currentRating;
  late String currentDescription;
  late String currentImage;

  final int productCodetest = 1001;

  @override
  void initState() {
    super.initState();

    currentTitle = widget.productName;
    currentPrice = widget.price;
    currentRating = widget.rating;
    currentDescription = widget.description;
    currentImage = widget.image;
  }

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
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Product image
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.asset(currentImage, fit: BoxFit.cover),
                  ),

                  /// Product information
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isSmall ? 5 : 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmall ? 10 : 14,
                                  ),
                                ),
                              ),

                              Text(
                                "⭐ $currentRating",
                                style: TextStyle(fontSize: isSmall ? 10 : 12),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            currentDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: isSmall ? 9 : 12,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "$currentPrice Kyat",
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmall ? 9 : 14,
                            ),
                          ),

                          const SizedBox(height: 10),

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
                                      isSmall
                                          ? "Add To Fav"
                                          : "Add to Favourite",
                                      style: TextStyle(
                                        fontSize: isSmall ? 7 : 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: SizedBox(
                                  height: isSmall ? 22 : 32,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      side: const BorderSide(
                                        color: Colors.green,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailPage(
                                                productId: widget.productCode,
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

              /// EDIT BUTTON
              Positioned(
                top: 5,
                right: 5,
                child: Material(
                  color: Colors.white.withOpacity(0.9),
                  shape: const CircleBorder(),
                  child: IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SellPage(productCode: productCodetest),
                        ),
                      );
                    },
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
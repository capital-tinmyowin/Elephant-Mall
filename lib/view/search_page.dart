import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:elephant_mall/models/Category.dart';
import 'package:elephant_mall/models/product.dart';
import 'package:elephant_mall/services/Category_service.dart';
import 'package:elephant_mall/services/auth_service.dart';
import 'package:elephant_mall/view/common/header.dart';
import 'package:elephant_mall/view/common/footer.dart';
import 'package:elephant_mall/view/common/loading_widget.dart';
import 'package:elephant_mall/widgets/app_image.dart';

class SearchPage extends StatefulWidget {
  final String query;
  final String relatedPage;

  const SearchPage({super.key, required this.query, this.relatedPage = 'Home'});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isLoading = true;
  String? _error;

  List<Product> _products = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchSearchResults();
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the query or the related page changed, re-fetch results
    if (oldWidget.query != widget.query ||
        oldWidget.relatedPage != widget.relatedPage) {
      _fetchSearchResults();
    }
  }

  Future<void> _fetchSearchResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _products = [];
      _categories = [];
    });

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final result = await auth.performSearch(
        query: widget.query, 
        relatedPage: widget.relatedPage
      );

      if (result != null) {
        final List<dynamic> productsJson = result['products'] ?? [];
        final List<dynamic> categoriesJson = result['categories'] ?? [];

        setState(() {
          _products = productsJson.map((json) {
            // SAFE PRICE PARSING
            double price = 0.0;
            final rawPrice = json['price'];
            if (rawPrice is num) {
              price = rawPrice.toDouble();
            } else if (rawPrice is String) {
              price = double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
            }

            return Product(
              productId: json['productId'] ?? 0,
              productCode: json['productId'].toString(),
              productName: json['productName'] ?? '',
              price: price,
              category: json['categoryName'] ?? '',
              image: json['imageUrl'] ?? '',
            );
          }).toList();

          _categories = categoriesJson.map((json) {
            return Category(
              categoryId: json['categoryId'] ?? 0,
              categoryName: json['categoryName'] ?? '',
              photoPath: json['categoryImageUrl'] ?? '',
            );
          }).toList();

          _isLoading = false;
          
          // If both are empty, show a friendly message (Not an error)
          if (_products.isEmpty && _categories.isEmpty) {
            _error = 'No results found for "${widget.query}".';
          }
        });
      } else {
        setState(() {
          _error = 'No results found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        // Clean up the error message for display
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CommonHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Results for "${widget.query}"',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_isLoading)
                        const CommonLoading(
                          size: 40,
                          height: 300,
                          message: 'Searching...',
                        )
                      else if (_error != null)
                        CommonError(
                          height: 300,
                          title: 'Search Result',
                          message: _error!,
                        )
                      else ...[
                        // Categories Section
                        if (_categories.isNotEmpty) ...[
                          const Text(
                            'Matching Categories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _categories.map((cat) {
                              return ActionChip(
                                avatar: cat.photoPath.isNotEmpty
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          cat.photoPath,
                                        ),
                                      )
                                    : null,
                                label: Text(cat.categoryName),
                                onPressed: () {
                                  context.go(
                                    '/category/${cat.categoryId}?name=${Uri.encodeComponent(cat.categoryName)}',
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 30),
                        ],

                        // Products Section
                        if (_products.isNotEmpty) ...[
                          const Text(
                            'Matching Products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 220,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 0.7,
                                ),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final p = _products[index];
                              return GestureDetector(
                                onTap: () =>
                                    context.go('/product/${p.productId}'),
                                child: Card(
                                  elevation: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: AppImage(
                                          imageUrl: p.image,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.productName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${NumberFormat('#,##0').format(p.price)} MMK',
                                              style: const TextStyle(
                                                color: Color(0xFF2B6E3B),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],

                        if (_products.isEmpty && _categories.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(50),
                              child: Text('No results found.'),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (MediaQuery.of(context).size.width >= 800) const CommonFooter(),
        ],
      ),
    );
  }
}

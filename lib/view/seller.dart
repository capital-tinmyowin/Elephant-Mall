import 'package:flutter/material.dart';
import 'common/header.dart';
import 'common/footer.dart';
import '../services/seller_service.dart';
import '../view/seller_reusable/sellercard.dart';
import '../view/seller_reusable/sellerheader.dart';
import '../view/seller_reusable/searchbar.dart';
import '../view/seller_reusable/sellersidemenu.dart';
import '../view/seller_reusable/filterbar.dart';
import '../view/seller_reusable/productsection.dart';

int getCrossAxisCount(double width) {
  if (width >= 1600) return 6;
  if (width >= 1400) return 5;
  if (width >= 1100) return 4;
  if (width >= 380) return 3;
  return 2;
}

// Seller Card Widget

double getAspectRatio(double width) {
  if (width >= 1600) return 0.75;
  if (width >= 1400) return 0.70;
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
            const CommonHeader(showMobileHeader: true),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// Seller Header
                    SellerHeaderWidget(
                      sellerName: sellerData["Username"],
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Fixed
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: SearchBars(),
                                ),

                                const SizedBox(height: 12),

                                /// Filter Bar
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: FilterBar(),
                                ),

                                const SizedBox(height: 16),
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
                                                crossAxisCount:
                                                    getCrossAxisCount(width),
                                                crossAxisSpacing: 5,
                                                mainAxisSpacing: 5,
                                                childAspectRatio:
                                                    getAspectRatio(width),
                                              ),

                                          itemBuilder: (context, index) {
                                            final item = items[index];

                                            return SellerItemWidget(
                                              productName: item["productName"],
                                              productCode:item["productCode"],
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

bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 800;
bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width > 800;


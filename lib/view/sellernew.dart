import 'package:flutter/material.dart';

import 'common/header.dart';
import 'common/footer.dart';

import '../services/seller_service.dart';

import '../view/seller_reusable/sellernewcard.dart';
import '../view/seller_reusable/sellerheader.dart';
import '../view/seller_reusable/searchbar.dart';
import '../view/seller_reusable/sellersidemenu.dart';
import '../view/seller_reusable/filterbar.dart';
import '../view/seller_reusable/productsection.dart';

int getCrossAxisCount(double width) {
  if (width >= 1600) return 6;
  if (width >= 1400) return 5;
  if (width >= 1100) return 4;
  if (width >= 800) return 3;
  if (width >= 380) return 3;

  return 2;
}

double getAspectRatio(double width) {
  if (width >= 1600) return 0.75;
  if (width >= 1400) return 0.70;
  if (width >= 1100) return 0.75;
  if (width >= 800) return 0.68;
  if (width >= 600) return 0.65;

  return 0.62;
}

class NewSellerPage extends StatefulWidget {
  const NewSellerPage({super.key});

  @override
  State<NewSellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<NewSellerPage> {
  int? expandedInfo;

  // Local copy of the JSON products.
  late List<dynamic> items;

  @override
  void initState() {
    super.initState();

    // Make a mutable copy of the JSON list.
    items = List<dynamic>.from(
      sellerData["items"] as List<dynamic>,
    );
  }

  void _updateItem(
    int index,
    Map<String, dynamic> updatedItem,
  ) {
    setState(() {
      items[index] = updatedItem;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final mobile = isMobile(context);
    final desktop = isDesktop(context);


    return Scaffold(
      backgroundColor: const Color(0xffF3F3F3),

      bottomNavigationBar: mobile
          ? const CommonBottomBar(
              currentIndex: 2,
            )
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
            const CommonHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [

                    SellerHeaderWidget(
                      sellerName: sellerData["Username"],

                      expandedInfo: expandedInfo,

                      onExpandChanged: (value) {
                        setState(() {
                          expandedInfo = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          if (desktop) ...[
                            SizedBox(
                              width: 220,

                              child: SingleChildScrollView(
                                child: Column(
                                  children: [

                                    const SizedBox(
                                      width: 220,
                                      child: SellerSideMenu(),
                                    ),

                                    const SizedBox(height: 16),

                                    const SellerFilterSidebar(),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),
                          ],

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: SearchBars(),
                                ),
                                const SizedBox(height: 12),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: FilterBar(),
                                ),


                                const SizedBox(height: 16),

                                Expanded(
                                  child: SingleChildScrollView(

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        GridView.builder(
                                          shrinkWrap: true,

                                          physics:
                                              const NeverScrollableScrollPhysics(),

                                          itemCount: items.length,

                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                getCrossAxisCount(width),

                                            crossAxisSpacing: 8,

                                            mainAxisSpacing: 8,

                                            childAspectRatio:
                                                getAspectRatio(width),
                                          ),


                                          itemBuilder:
                                              (context, index) {

                                            final item =
                                                items[index];


                                            return SellerItemWidget(

                                              productName:
                                                  item["productName"],

                                              price:
                                                  item["price"],

                                              rating:
                                                  item["rating"],

                                              description:
                                                  item["description"],

                                              image:
                                                  item["image"],
                                              onUpdate:
                                                  (updatedItem) {

                                                _updateItem(
                                                  index,
                                                  updatedItem,
                                                );
                                              },

                                              onDelete: () {

                                                _deleteItem(
                                                  index,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),

                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [

                                            Expanded(
                                              child: ProductSection(
                                                title:
                                                    "Newest Arrivals",

                                                products:
                                                    newestProducts,
                                              ),
                                            ),


                                            const SizedBox(width: 10),


                                            Expanded(
                                              child: ProductSection(
                                                title:
                                                    "Best Sellers",

                                                products:
                                                    bestSellerProducts,
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

            if (!mobile)
              const CommonFooter(),
          ],
        ),
      ),
    );
  }
}

bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 450;
}


bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width > 800;
}
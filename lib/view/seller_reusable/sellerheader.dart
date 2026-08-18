import 'package:flutter/material.dart';

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
    final isSmall = MediaQuery.of(context).size.width <= 380;

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
                        "${widget.sellerName}'s Full Store",
                        style: TextStyle(
                          fontSize: isSmall ? 16 : (isMobile ? 20 : 28),
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          SizedBox(
                            width: isSmall ? 80 : (isMobile ? 120 : 140),
                            height: isSmall ? 25 : 30,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmall ? 5 : 12,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  isFollowing = !isFollowing;
                                });
                              },
                              icon: isFollowing
                                  ? null
                                  : Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: isSmall ? 14 : 20,
                                    ),
                              label: Text(
                                isFollowing ? "Following" : "Follow",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmall ? 11 : (isMobile ? 14 : 16),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          SizedBox(
                            width: isSmall ? 80 : (isMobile ? 120 : 140),
                            height: isSmall ? 25 : 30,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmall ? 5 : 12,
                                ),
                              ),
                              onPressed: () {},
                              icon: Icon(
                                Icons.chat_bubble_outline,
                                size: isSmall ? 14 : 20,
                              ),
                              label: Text(
                                isMobile ? "Chat" : "Chat Seller",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmall ? 11 : (isMobile ? 14 : 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// Desktop view
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
                            Text("Usually responds \n within 2 hours"),
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

            //Mobile view
            // if (isMobile)
            //   Positioned(
            //     top: -5,
            //     right: -7,
            //     child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: [
            //         Align(
            //           alignment: Alignment.centerRight,
            //           child: infoIcon(
            //             index: 0,
            //             icon: Icons.location_on_outlined,
            //             text: "Yangon, Myanmar",
            //           ),
            //         ),

            //         Align(
            //           alignment: Alignment.centerRight,
            //           child: infoIcon(
            //             index: 1,
            //             icon: Icons.people_outline,
            //             text: "1,235 Followers",
            //           ),
            //         ),

            //         Align(
            //           alignment: Alignment.centerRight,
            //           child: infoIcon(
            //             index: 2,
            //             icon: Icons.inventory_2_outlined,
            //             text: "124 Products",
            //           ),
            //         ),

            //         Align(
            //           alignment: Alignment.centerRight,
            //           child: infoIcon(
            //             index: 3,
            //             icon: Icons.schedule,
            //             text: "Usually responds within 2 hours",
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
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

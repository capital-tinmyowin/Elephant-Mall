import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (isMobile) {
      return const SizedBox.shrink(); // hide desktop header
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showSecondRow = constraints.maxWidth < 1000;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// FIRST ROW
              SizedBox(
                height: 70,
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _menuItem("HOME"),
                            _menuItem("CATEGORIES"),
                            _menuItem("SALE"),
                            _menuItem("NEW IN"),
                            _menuItem("MY ORDERS"),
                            _menuItem("ABOUT US"),
                          ],
                        ),
                      ),
                    ),

                    if (!showSecondRow)
                      SizedBox(
                        width: 320,
                        height: 42,
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: "Search",
                            prefixIcon: const Icon(Icons.search, size: 20),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(width: 15),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC77C2E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        //  Navigate to Sell Page
                      },
                      child: const Text("SELL ITEMS"),
                    ),

                    const SizedBox(width: 10),

                    IconButton(
                      icon: const Icon(Icons.person_outline, size: 28),
                      onPressed: () {
                        //  Open Profile
                      },
                    ),

                    const SizedBox(width: 10),

                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 28),
                      onPressed: () {
                        //  Open Favorite
                      },
                    ),

                    const SizedBox(width: 10),

                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                      onPressed: () {
                        //  Open Cart
                      },
                    ),
                  ],
                ),
              ),

              /// SECOND ROW
              if (showSecondRow)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Spacer(),

                      SizedBox(
                        width: 320,
                        height: 42,
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: "Search",
                            prefixIcon: const Icon(Icons.search, size: 20),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
} // <-- CLOSE CommonHeader HERE

// ===============================
// MOBILE BOTTOM MENU
// ===============================

class CommonBottomBar extends StatelessWidget {
  final int currentIndex;

  const CommonBottomBar({super.key, required this.currentIndex});

  // void _navigate(BuildContext context, int index) {
  //   if (index == currentIndex) return;

  //   Widget page;

  //   switch (index) {
  //     case 0:
  //       page = const HomePage();
  //       break;

  //     case 1:
  //       page = const CategoryPage();
  //       break;

  //     case 2:
  //       page = const SellPage();
  //       break;

  //     case 3:
  //       page = const FavoritePage();
  //       break;

  //     case 4:
  //       page = const ProfilePage();
  //       break;

  //     default:
  //       return;
  //   }

  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (_) => page),
  //   );
  // }

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Page $index is not implemented yet.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _navigate(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view),
          label: "Categories",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, size: 38),
          label: "Sell",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: "Favorite",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ],
    );
  }
}

import 'package:elephant_mall/view/category_page.dart';
import 'package:elephant_mall/view/category_page.dart';
import 'package:flutter/material.dart';
import '../home.dart';
import '../sell.dart';

class CommonHeader extends StatefulWidget {
  const CommonHeader({super.key});

  @override
  State<CommonHeader> createState() => _CommonHeaderState();
}

class _CommonHeaderState extends State<CommonHeader> {
  bool _isMenuOpen = false;
  String _activeMenu = "HOME";

  String _getActiveMenu(BuildContext context) {
    final route = ModalRoute.of(context);

    if (route is MaterialPageRoute) {
      final page = route.builder(context);

      if (page is HomePage) return "HOME";
      if (page is CategoryPage) return "CATEGORIES";
      if (page is SellPage) return "SALE";
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (isMobile) {
      return const SizedBox.shrink(); // hide desktop header
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 1100;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// FIRST ROW
              SizedBox(
                height: 70,
                child: Row(
                  children: [
                    if (!isCompact)
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _menuItem(context, "HOME", const HomePage()),
                              _menuItem(
                                context,
                                "CATEGORIES",
                                const CategoryPage(),
                              ),
                              _menuItem(context, "SALE", const SellPage()),
                              _menuItem(context, "NEW IN", const SellPage()),
                              _menuItem(context, "MY ORDERS", const SellPage()),
                              _menuItem(context, "ABOUT US", const SellPage()),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      IconButton(
                        icon: Icon(
                          _isMenuOpen ? Icons.close : Icons.menu,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _isMenuOpen = !_isMenuOpen;
                          });
                        },
                      ),

                      const Spacer(),
                    ],

                    if (!isCompact) const SizedBox(width: 15),

                    SizedBox(
                      width: 300,
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
              if (isCompact && _isMenuOpen)
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _menuItem(context, "HOME", const HomePage()),
                      _menuItem(context, "CATEGORIES", const CategoryPage()),
                      _menuItem(context, "SALE", const SellPage()),
                      _menuItem(context, "NEW IN", const SellPage()),
                      _menuItem(context, "MY ORDERS", const SellPage()),
                      _menuItem(context, "ABOUT US", const SellPage()),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuItem(BuildContext context, String text, Widget? page) {
    final bool isActive = _getActiveMenu(context) == text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _activeMenu = text;

            // Close the hamburger menu after selecting an item
            if (_isMenuOpen) {
              _isMenuOpen = false;
            }
          });

          if (page == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$text page is not implemented yet')),
            );
            return;
          }

          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFC77C2E) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
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

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const HomePage();
        break;

      case 1:
        page = const CategoryPage();
        page = const CategoryPage();
        break;

      case 2:
        page = const SellPage();
        break;

      case 3:
        page = const SellPage();
        break;

      case 4:
        page = const SellPage();
        break;

      default:
        return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  // void _navigate(BuildContext context, int index) {
  //   if (index == currentIndex) return;

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Page $index is not implemented yet.'),
  //       duration: const Duration(seconds: 1),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _navigate(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFC77C2E),
      unselectedItemColor: const Color.fromARGB(255, 2, 2, 2),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 38),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view, size: 38),
          label: "Categories",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, size: 45),
          label: "Sell",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border, size: 38),
          label: "Favorite",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 38),
          label: "Profile",
        ),
      ],
    );
  }
}

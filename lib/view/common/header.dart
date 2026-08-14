import 'package:elephant_mall/services/auth_service.dart';
import 'package:elephant_mall/view/category_page.dart';
import 'package:elephant_mall/view/category_page.dart';
import 'package:elephant_mall/view/favourite_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home.dart';
import '../sell.dart';
import '../login.dart'; // Change the path if your LoginPage is in another folder
import '../sellernew.dart';

class CommonHeader extends StatefulWidget {
  const CommonHeader({super.key});

  @override
  State<CommonHeader> createState() => _CommonHeaderState();
}

class _CommonHeaderState extends State<CommonHeader> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final authService = Provider.of<AuthService>(context);
    final isLoggedIn = authService.isLoggedIn;
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
          final isCompact = constraints.maxWidth < 1250;
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
                              _menuItem(
                                context,
                                "MY FAVORITE",
                                const SellPage(),
                              ),
                              _menuItem(context, "ABOUT US", const NewSellerPage()),
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

                    // 🔥 PROFILE BUTTON - Shows Login/Logout based on state
                    _buildProfileButton(context, isLoggedIn),

                    const SizedBox(width: 10),

                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 28),
                      onPressed: () {
                        // Open Favorite
                        // if (!isLoggedIn) {
                        //   _showLoginRequiredDialog(context);
                        //   return;
                        // }
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    MyFavouritePage(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 10),

                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                      onPressed: () {
                        //  Open Cart
                      },
                    ),

                    const SizedBox(width: 15),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    LoginPage(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Color(0xff2f6b2f),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                      _menuItem(context, "ABOUT US", const NewSellerPage()),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  bool isCurrentPage(String menuName) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    switch (currentRoute) {
      case "/":
      case "/home":
        return menuName == "HOME";

      case "/category":
        return menuName == "CATEGORIES";

      case "/sell":
        return menuName == "SALE";

      case "/favorite":
        return menuName == "MY FAVORITE";

      case "/about":
        return menuName == "ABOUT US";

      default:
        return false;
    }
  }

  // ============= PROFILE BUTTON =============
  Widget _buildProfileButton(BuildContext context, bool isLoggedIn) {
    return GestureDetector(
      onTap: () {
        if (isLoggedIn) {
          // Show logout dialog
          _showLogoutDialog(context);
        } else {
          // Navigate to login page
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LoginPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isLoggedIn
              ? const Color(0xFF2B6E3B).withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Stack(
          children: [
            const Icon(Icons.person_outline, size: 28),
            if (isLoggedIn)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============= LOGOUT DIALOG =============
  void _showLogoutDialog(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👋 ${user?.fullName ?? user?.username ?? 'User'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildLogoutMenuItem(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile
              },
            ),
            _buildLogoutMenuItem(
              icon: Icons.favorite_border,
              title: 'My Favorites',
              onTap: () {
                Navigator.pop(context);
                // Navigate to favorites
                Navigator.push(
                  context,

                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        MyFavouritePage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            _buildLogoutMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              onTap: () {
                Navigator.pop(context);
                // Navigate to orders
              },
            ),
            const Divider(),
            _buildLogoutMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              isDestructive: true,
              onTap: () async {
                Navigator.pop(context);
                authService.logout();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey[700],
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  // ============= LOGIN REQUIRED DIALOG =============
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Login Required'),
        content: const Text(
          'Please sign in to access this feature.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      LoginPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B6E3B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, String text, Widget? page) {
    final bool isActive = isCurrentPage(text);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      child: InkWell(
        onTap: () {
          if (_isMenuOpen) {
            setState(() {
              _isMenuOpen = false;
            });
          }

          if (page == null) return;

          String routeName;

          switch (text) {
            case "HOME":
              routeName = "/home";
              break;

            case "CATEGORIES":
              routeName = "/category";
              break;

            case "SALE":
              routeName = "/sell";
              break;

            case "MY FAVORITE":
              routeName = "/favorite";
              break;

            case "ABOUT US":
              routeName = "/about";
              break;

            default:
              routeName = "/";
          }

          Navigator.pushReplacement(
            context,

            PageRouteBuilder(
              settings: RouteSettings(name: routeName),

              pageBuilder: (context, animation, secondaryAnimation) => page,

              transitionDuration: Duration.zero,

              reverseTransitionDuration: Duration.zero,
            ),
          );
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
        page = const NewSellerPage();
        break;

      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
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

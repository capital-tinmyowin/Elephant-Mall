import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: isMobile ? _buildMobileHeader(context) : _buildDesktopHeader(context),
        );
      },
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Menu + Nav
        Row(
          children: [
            const SizedBox(width: 24),
            Row(
              children: [
                _buildNavLink(context, 'HOME', '/home'),
                _buildNavLink(context, 'CATEGORIES', '/categories'),
                _buildNavLink(context, 'SALE', '/sell'),
                _buildNavLink(context, 'FAVORITE', '/favorite'),
                _buildNavLink(context, 'ABOUT US', '/about'),
              ],
            ),
          ],
        ),

        // Center: Logo
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/home');
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Image.asset("images/logo.png"),
            ),
          ),
        ),

        // Right: Search + Sell + Icons
        Row(
          children: [
            // Search Box
            Container(
              width: 200,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search in Elephant Mall',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Sell Button
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/sell');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD68247),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SELL ITEMS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Icons
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/profile');
              },
              child: const Icon(Icons.person_outline, size: 22),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/favorite');
              },
              child: const Icon(Icons.favorite_border, size: 22),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                // Navigate to cart
              },
              child: const Icon(Icons.shopping_cart_outlined, size: 22),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menu Icon
        IconButton(
          icon: const Icon(Icons.menu, size: 24),
          onPressed: () {
            // Open drawer or show menu
          },
        ),
        // Logo - Center
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Image.asset("images/logo.png"),
            ),
          ),
        ),
        // Right Icons
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search, size: 22),
              onPressed: () {
                // Show search
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, size: 22),
              onPressed: () {
                // Navigate to cart
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavLink(BuildContext context, String title, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
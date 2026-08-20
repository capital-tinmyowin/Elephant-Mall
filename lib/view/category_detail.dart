import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/Category_service.dart';
import 'common/footer.dart';
import 'common/header.dart';
import 'product_detail_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;

  const CategoryDetailPage({super.key, required this.categoryName});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late ApiService _apiService;
  String _selectedSort = 'Newest First';
  String _selectedSize = 'All';
  String _selectedColor = 'All';
  bool _isSizeExpanded = true;
  bool _isColorExpanded = true;
  bool _isPriceExpanded = true;
  RangeValues _priceRange = const RangeValues(10, 200);
  bool _isFilterOpen = false;
  int _currentPage = 1;
  final int _itemsPerPage = 8;
  bool _isGridView = true;

  final List<String> _sortOptions = [
    'Newest First',
    'Price: Low to High',
    'Price: High to Low',
    'Popularity',
    'Rating',
  ];

  final List<String> _sizeOptions = ['All', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _colorOptions = [
    'Black',
    'White',
    'Gray',
    'Blue',
    'Green',
    'Red',
    'Brown',
  ];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService.loadProductsByCategory(widget.categoryName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return ChangeNotifierProvider.value(
      value: _apiService,
      child: Scaffold(
        body: Column(
          children: [
            const CommonHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCategoryHeader(isMobile),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 40,
                      ),
                      child: isMobile
                          ? _buildMobileLayout()
                          : _buildDesktopLayout(),
                    ),
                    const SizedBox(height: 40),
                    if (!isMobile) const CommonFooter(),
                  ],
                ),
              ),
            ),
            if (isMobile) const CommonBottomBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  // ============= CATEGORY HEADER =============
  Widget _buildCategoryHeader(bool isMobile) {
  return Consumer<ApiService>(
    builder: (context, productController, child) {
      final expandedProducts = productController
          .getProductsWithColorVariations(productController.products);
      final productCount = expandedProducts.length;

      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: isMobile
              ? 16
              : MediaQuery.of(context).size.width * 0.07,
          vertical: 16,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 4,
          vertical: isMobile ? 12 : 2,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: isMobile
            ? Row(
                children: [
                  // Category Info (left side)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${productCount} items',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //  Filter & Sort Button (right side)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFilterOpen = !_isFilterOpen;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Filter & Sort',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  // Category Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B6E3B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Center(
                      child: _getCategoryIconWidget(
                        widget.categoryName,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Category Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2B6E3B),
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getCategoryDescription(widget.categoryName),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/heroslider/category_detail_header.png',
                      height: 130,
                      width: 500,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
      );
    },
  );
}

  Widget _getCategoryIconWidget(
    String category, {
    double size = 30,
    Color color = const Color(0xFF2B6E3B),
  }) {
    switch (category) {
      case 'T-Shirts':
        return FaIcon(FontAwesomeIcons.tshirt, size: size, color: color);
      case 'Blouses':
        return FaIcon(FontAwesomeIcons.vest, size: size, color: color);
      case 'Bags':
        return FaIcon(FontAwesomeIcons.bagShopping, size: size, color: color);
      case 'Hats':
        return FaIcon(FontAwesomeIcons.redhat, size: size, color: color);
      case 'Shoes':
        return FaIcon(FontAwesomeIcons.shoePrints, size: size, color: color);
      case 'Jeans':
        return FaIcon(FontAwesomeIcons.personRunning, size: size, color: color);
      case 'Accessories':
        return FaIcon(FontAwesomeIcons.glasses, size: size, color: color);
      case 'Electronics':
        return FaIcon(FontAwesomeIcons.boltLightning, size: size, color: color);
      case 'Headphones':
        return FaIcon(FontAwesomeIcons.headphones, size: size, color: color);
      case 'PowerBanks':
        return FaIcon(FontAwesomeIcons.powerOff, size: size, color: color);
      case 'Clearance':
        return FaIcon(FontAwesomeIcons.swatchbook, size: size, color: color);
      case 'HomeDecor':
        return FaIcon(FontAwesomeIcons.house, size: size, color: color);
      case 'Appearance':
        return FaIcon(FontAwesomeIcons.kitchenSet, size: size, color: color);
      default:
        return FaIcon(
          FontAwesomeIcons.circleQuestion,
          size: size,
          color: color,
        );
    }
  }

  String _getCategoryDescription(String category) {
    return 'Discover comfortable and stylish ' +
        category +
        '\nfor every casual occasion.';
  }

  // ============= DESKTOP LAYOUT =============
  Widget _buildDesktopLayout() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar - Filters
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.18,
            child: _buildFilters(),
          ),
          const SizedBox(width: 32),
          // Right - Products Grid
          Expanded(
            child: Column(
              children: [
                _buildSortBar(),
                const SizedBox(height: 12),
                _buildProductGrid(),
                const SizedBox(height: 20),
                _buildPagination(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============= MOBILE LAYOUT =============
  Widget _buildMobileLayout() {
    return Column(
      children: [
        //  Scrollable category chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Category chips list
              ...[
                'T-Shirts',
                'Blouses',
                'Bags',
                'Hats',
                'Shoes',
                'Jeans',
                'Accessories',
                'Electronics',
                'Headphones',
                'Power Banks',
                'Clearance',
                'Home Decor',
                'Appliances',
              ].map((category) {
                final isSelected = widget.categoryName == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    // avatarBorder: CircleBorder(eccentricity: 0.9),
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoryDetailPage(categoryName: category),
                          ),
                        );
                      }
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFF2B6E3B).withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? const Color(0xFF2B6E3B)
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        // const SizedBox(height: 8),
        const SizedBox(height: 12),
        if (_isFilterOpen)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: _buildMobileFilters(),
          ),
        _buildProductGrid(),
        const SizedBox(height: 20),
        _buildPagination(),
      ],
    );
  }

  // ============= FILTERS =============
  Widget _buildFilters() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallDesktop = screenWidth < 1100;

    return Container(
      padding: EdgeInsets.all(isSmallDesktop ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCategoryItem('T-Shirts', 12),
          _buildCategoryItem('Blouses', 4),
          _buildCategoryItem('Bags', 6),
          _buildCategoryItem('Hats', 6),
          _buildCategoryItem('Shoes', 8),
          _buildCategoryItem('Jeans', 12),
          _buildCategoryItem('Accessories', 15),
          _buildCategoryItem('Electronics', 4),
          _buildCategoryItem('Headphones', 5),
          _buildCategoryItem('Power Banks', 4),
          _buildCategoryItem('Clearance', 2),
          _buildCategoryItem('Home Decor', 5),
          _buildCategoryItem('Appliances', 5),

          const Divider(height: 24),

          const Text(
            'Filter By',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Size Section with Toggle
          _buildExpandableSection(
            title: 'Size',
            isExpanded: _isSizeExpanded,
            onToggle: () {
              setState(() {
                _isSizeExpanded = !_isSizeExpanded;
              });
            },
            child: Column(
              children: _sizeOptions.map((size) {
                final isSelected = _selectedSize == size;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSize = isSelected ? 'All' : size;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2B6E3B)
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: isSelected
                                ? const Color(0xFF2B6E3B)
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            size,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? const Color(0xFF2B6E3B)
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (size != 'All')
                          Text(
                            '(${_getSizeCount(size)})',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Color Section with Toggle
          _buildExpandableSection(
            title: 'Color',
            isExpanded: _isColorExpanded,
            onToggle: () {
              setState(() {
                _isColorExpanded = !_isColorExpanded;
              });
            },
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getColorValue(color),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2B6E3B)
                            : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: color == 'All'
                        ? Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Price Range Section with Toggle
          _buildExpandableSection(
            title: 'Price Range',
            isExpanded: _isPriceExpanded,
            onToggle: () {
              setState(() {
                _isPriceExpanded = !_isPriceExpanded;
              });
            },
            child: Column(
              children: [
                // Remove the Row with Expanded and use full width
                RangeSlider(
                  values: _priceRange,
                  min: 10,
                  max: 200,
                  divisions: 20,
                  activeColor: const Color(0xFFC77C2E),
                  inactiveColor: Colors.grey[300],
                  labels: RangeLabels(
                    '\$${_priceRange.start.toStringAsFixed(0)}',
                    '\$${_priceRange.end.toStringAsFixed(0)}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                // Show min and max values below the slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${_priceRange.start.toStringAsFixed(0)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    Text(
                      '\$${_priceRange.end.toStringAsFixed(0)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedSize = 'All';
                  _selectedColor = 'All';
                  _priceRange = const RangeValues(10, 200);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey[600],
                size: 24,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (isExpanded) child,
        const SizedBox(height: 4),
      ],
    );
  }
  //  Helper method to get size count (mock data)
  int _getSizeCount(String size) {
    // Mock counts for each size
    switch (size) {
      case 'S':
        return 28;
      case 'M':
        return 56;
      case 'L':
        return 78;
      case 'XL':
        return 64;
      case 'XXL':
        return 32;
      default:
        return 0;
    }
  }

  Color _getColorValue(String colorName) {
    switch (colorName) {
      case 'Black':
        return Colors.black;
      case 'White':
        return Colors.white;
      case 'Grey':
        return Colors.grey;
      case 'Blue':
        return Colors.blue;
      case 'Green':
        return Colors.green;
      case 'Red':
        return Colors.red;
      case 'Brown':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCategoryItem(String name, int count) {
    final isSelected = widget.categoryName == name;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailPage(categoryName: name),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? const Color(0xFF2B6E3B) : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  // ============= MOBILE FILTERS =============
  Widget _buildMobileFilters() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),

      // Mobile Size Filter - Checkbox style
      const Text(
        'Size',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      ..._sizeOptions.map((size) {
        final isSelected = _selectedSize == size;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSize = isSelected ? 'All' : size;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2B6E3B)
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFF2B6E3B)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xFF2B6E3B)
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (size != 'All')
                  Text(
                    '(${_getSizeCount(size)})',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
        );
      }).toList(),

      const SizedBox(height: 16),

      // Mobile Color Filter - Color circles (like desktop)
      const Text(
        'Color',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _colorOptions.map((color) {
          final isSelected = _selectedColor == color;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = color;
              });
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getColorValue(color),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2B6E3B)
                      : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2B6E3B).withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: color == 'All'
                  ? Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),

      // Price Range
      const Text(
        'Price Range',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      RangeSlider(
        values: _priceRange,
        min: 10,
        max: 200,
        divisions: 20,
        activeColor: const Color(0xFF2B6E3B),
        inactiveColor: Colors.grey[300],
        labels: RangeLabels(
          '\$${_priceRange.start.toStringAsFixed(0)}',
          '\$${_priceRange.end.toStringAsFixed(0)}',
        ),
        onChanged: (values) {
          setState(() {
            _priceRange = values;
          });
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${_priceRange.start.toStringAsFixed(0)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            '\$${_priceRange.end.toStringAsFixed(0)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    ],
  );
}

  // ============= SORT BAR =============
  Widget _buildSortBar() {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Sort by :',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 2),
              DropdownButton<String>(
                value: _selectedSort,
                items: _sortOptions.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                },
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Grid View Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isGridView = true;
                  });
                },
                icon: Icon(
                  Icons.grid_view,
                  color: _isGridView
                      ? const Color(0xFFC77C2E)
                      : Colors.grey[400],
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
              // List View Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isGridView = false;
                  });
                },
                icon: Icon(
                  Icons.view_list,
                  color: _isGridView
                      ? Colors.grey[400]
                      : const Color(0xFFC77C2E),
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
              // Showing results count (only on desktop)
              if (!isMobile)
                // Showing results count
                Consumer<ApiService>(
                  builder: (context, productController, child) {
                    final totalProducts = productController
                        .getProductsWithColorVariations(
                          productController.products,
                        )
                        .length;
                    return Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        'Showing 1-${totalProducts > 8 ? 8 : totalProducts} of $totalProducts products',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
  // ============= PRODUCT GRID =============
  Widget _buildProductGrid() {
    return Consumer<ApiService>(
      builder: (context, productController, child) {
        if (productController.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final allProducts = productController.getProductsWithColorVariations(
          productController.products,
        );

        if (allProducts.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No products found in this category'),
            ),
          );
        }

        // Calculate pagination
        final int totalProducts = allProducts.length;
        final int totalPages = (totalProducts / _itemsPerPage).ceil();

        // Ensure current page is valid
        if (_currentPage > totalPages) {
          _currentPage = totalPages;
        }

        // Get products for current page
        final int startIndex = (_currentPage - 1) * _itemsPerPage;
        final int endIndex = startIndex + _itemsPerPage > totalProducts
            ? totalProducts
            : startIndex + _itemsPerPage;
        final List<Product> products = allProducts.sublist(
          startIndex,
          endIndex,
        );

        final bool isMobile = MediaQuery.of(context).size.width < 768;
        // If List View
        if (!_isGridView) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildListProductCard(product, isMobile);
            },
          );
        }
        // Single solution: Auto-adjusts columns and aspect ratio
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: isMobile ? 180 : 250, // 🔥 Only this changes
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
            childAspectRatio: 0.54,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product, isMobile);
          },
        );
      },
    );
  }

  Widget _buildListProductCard(Product product, bool isMobile) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - Smaller in list view
            Container(
              width: isMobile ? 100 : 140,
              height: isMobile ? 100 : 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.proxiedImageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
                    ),
                  ),
                  // Discount Badge
                  if (product.id % 2 == 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B6E3B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${((product.id % 3) + 1) * 5}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 10 : 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2B6E3B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.id % 2 == 0)
                          Text(
                            '\$${(product.price * 1.15).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: const Color(0xFFFFD700),
                          size: isMobile ? 14 : 16,
                        ),
                        Icon(
                          Icons.star,
                          color: const Color(0xFFFFD700),
                          size: isMobile ? 14 : 16,
                        ),
                        Icon(
                          Icons.star,
                          color: const Color(0xFFFFD700),
                          size: isMobile ? 14 : 16,
                        ),
                        Icon(
                          Icons.star,
                          color: const Color(0xFFFFD700),
                          size: isMobile ? 14 : 16,
                        ),
                        Icon(
                          Icons.star,
                          color: const Color(0xFFFFD700),
                          size: isMobile ? 14 : 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.ratingCount})',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: isMobile ? 100 : 120,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(productId: product.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: const Color(0xFF2B6E3B),
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 6 : 8,
                            horizontal: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: Size(
                            isMobile ? 80 : 100,
                            isMobile ? 28 : 32,
                          ),
                        ),
                        child: Text(
                          'View Detail',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ============= PRODUCT CARD =============
  Widget _buildProductCard(Product product, bool isMobile) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Add this
          children: [
            // Product Image - Use AspectRatio for consistent sizing
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.proxiedImageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
                    ),
                  ),
                  // Discount Badge
                  if (product.id % 2 == 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B6E3B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${((product.id % 3) + 1) * 5}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite_border,
                          size: isMobile ? 16 : 20,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Info
            Padding(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Add this
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2B6E3B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (product.id % 2 == 0)
                        Text(
                          '\$${(product.price * 1.15).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 13,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: const Color(0xFFFFD700),
                        size: isMobile ? 12 : 14,
                      ),
                      Icon(
                        Icons.star,
                        color: const Color(0xFFFFD700),
                        size: isMobile ? 12 : 14,
                      ),
                      Icon(
                        Icons.star,
                        color: const Color(0xFFFFD700),
                        size: isMobile ? 12 : 14,
                      ),
                      Icon(
                        Icons.star,
                        color: const Color(0xFFFFD700),
                        size: isMobile ? 12 : 14,
                      ),
                      Icon(
                        Icons.star,
                        color: const Color(0xFFFFD700),
                        size: isMobile ? 12 : 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.ratingCount})',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text('${product.name} added to cart!'),
                        //     duration: const Duration(seconds: 1),
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(productId: product.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                    foregroundColor: const Color(0xFF2B6E3B),
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 10 : 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        minimumSize: Size(double.infinity, isMobile ? 30 : 32),
                      ),
                      child: Text(
                        'View Detail',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============= PAGINATION =============
  Widget _buildPagination() {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Consumer<ApiService>(
      builder: (context, productController, child) {
        final totalProducts = productController
            .getProductsWithColorVariations(productController.products)
            .length;
        final totalPages = (totalProducts / _itemsPerPage).ceil();

        // Calculate current page items
        final int startIndex = (_currentPage - 1) * _itemsPerPage + 1;
        final int endIndex = (_currentPage * _itemsPerPage) > totalProducts
            ? totalProducts
            : _currentPage * _itemsPerPage;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // Previous button
                    IconButton(
                      onPressed: _currentPage > 1
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32),
                      color: _currentPage > 1
                          ? Colors.black87
                          : Colors.grey[400],
                    ),

                    // Page numbers
                    ...List.generate(totalPages > 5 ? 5 : totalPages, (index) {
                      int pageNumber = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentPage = pageNumber;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: _currentPage == pageNumber
                                ? const Color(0xFFC77C2E)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pageNumber.toString(),
                            style: TextStyle(
                              color: _currentPage == pageNumber
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: _currentPage == pageNumber
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),

                    // Next button
                    IconButton(
                      onPressed: _currentPage < totalPages
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32),
                      color: _currentPage < totalPages
                          ? Colors.black87
                          : Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

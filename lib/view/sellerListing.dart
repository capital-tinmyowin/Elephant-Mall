import 'package:elephant_mall/models/business_contact.dart';
import 'package:elephant_mall/services/Category_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/sellerpagemodel.dart';
import '../models/SellerInfo.dart';
import '../models/category.dart';
import '../models/new_in.dart';
import '../services/sellerListing_service.dart';
import '../services/auth_service.dart';
import 'common/footer.dart';
import 'common/header.dart';
import 'common/loading_widget.dart';
import 'product_detail_page.dart';
import 'new_in.dart';
import 'common/favorite_helper.dart';

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerListingPage extends StatefulWidget {
  final int? sellerId;
  final String? sellerName;

  const SellerListingPage({super.key, this.sellerId, this.sellerName});

  @override
  State<SellerListingPage> createState() => _SellerListingPageState();
}

class SellerBusinessContact {
  final int id;
  final int userId;
  final String type;
  final String value;
  final int groupId;
  final bool isPrimary;

  SellerBusinessContact({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    required this.groupId,
    required this.isPrimary,
  });

  factory SellerBusinessContact.fromJson(Map<String, dynamic> json) {
    return SellerBusinessContact(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      type: json['type']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      groupId: int.tryParse(json['groupId']?.toString() ?? '') ?? 0,
      isPrimary: json['isPrimary'] == true,
    );
  }
}

class _SellerListingPageState extends State<SellerListingPage> {
  final SellerListingService _service = SellerListingService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> products = [];
  bool loading = true;
  String? errorMessage;

  bool isFollowing = false;

  final Set<int> favouriteProductIds = {};
  final Set<int> favouriteLoadingIds = {};

  bool chatContactsLoading = false;

  List<Category> categories = [];
  bool categoryLoading = false;

  String selectedCategory = 'By Category';
  int? selectedCategoryId;
  String selectedPrice = 'Price';
  String selectedSort = 'Primmys by Price';

  List<NewInModel> newestArrivals = [];
  bool newestArrivalsLoading = true;
  String? newestArrivalsError;

  SellerInfo? sellerInfo;
  bool sellerInfoLoading = true;

  final ScrollController _newestScrollController = ScrollController();
  final ScrollController _salesScrollController = ScrollController();

  List<NewInModel> salesProducts = [];
  bool salesProductsLoading = true;
  String? salesProductsError;

  bool followLoading = false;
  int followerCount = 0;

  static const int pageSize = 10;
  int _currentPage = 1;
  bool _showContacts = false;
  List<BusinessContact> _sellerContacts = [];
  bool _isLoadingContacts = false;

  @override
  void initState() {
    super.initState();
    loadSellerInfo();
    loadProducts();
    loadCategories();
    loadNewestArrivals();
    loadSalesProducts();
    _currentPage = 1;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newestScrollController.dispose();
    _salesScrollController.dispose();
    super.dispose();
  }

  void _scrollBy(ScrollController controller, double offset) {
    if (!controller.hasClients) return;
    final target = (controller.offset + offset).clamp(
      0.0,
      controller.position.maxScrollExtent,
    );
    controller.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // LOADERS
  Future<void> loadSellerInfo() async {
    setState(() => sellerInfoLoading = true);
    try {
      final authService = context.read<AuthService>();
      final info = await _service.fetchSellerInfo(
        authService: authService,
        sellerId: widget.sellerId?.toString(),
      );
      if (!mounted) return;
      setState(() {
        sellerInfo = info;
        isFollowing = info.isFollowing;
        followerCount = info.followerCount;
        sellerInfoLoading = false;
      });
      debugPrint('API isFollowing: ${info.isFollowing}');
      debugPrint('UI isFollowing: $isFollowing');
    } catch (e) {
      debugPrint('Seller listing info error: $e');
      if (!mounted) return;
      setState(() {
        sellerInfo = null;
        sellerInfoLoading = false;
      });
    }
  }

  Future<void> loadCategories() async {
    if (!mounted) return;
    setState(() => categoryLoading = true);
    try {
      final result = await _service.fetchCategories();
      if (!mounted) return;
      setState(() {
        categories = result;
        categoryLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        categories = [];
        categoryLoading = false;
      });
    }
  }

  Future<void> loadNewestArrivals() async {
    if (!mounted) return;
    setState(() {
      newestArrivalsLoading = true;
      newestArrivalsError = null;
    });
    try {
      final authService = context.read<AuthService>();
      final result = await _service.fetchNewestArrivals(
        authService: authService,
      );
      if (!mounted) return;
      setState(() {
        newestArrivals = result;
        newestArrivalsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        newestArrivals = [];
        newestArrivalsLoading = false;
        newestArrivalsError = e.toString();
      });
    }
  }

  Future<void> _openChatSeller() async {
    if (chatContactsLoading) return;

    final sellerId = widget.sellerId;

    if (sellerId == null) {
      debugPrint('Seller ID is missing.');
      return;
    }

    setState(() => chatContactsLoading = true);

    try {
      final url = Uri.parse(
        'https://www.capital-sys.net/CKMMallAPI/api/User/getbusinesscontactsbyuserid/$sellerId',
      );

      late http.Response response;

      if (kIsWeb) {
        final client = BrowserClient()..withCredentials = true;

        try {
          response = await client.get(
            url,
            headers: {'Accept': 'application/json'},
          );
        } finally {
          client.close();
        }
      } else {
        final authService = context.read<AuthService>();

        final headers = <String, String>{'Accept': 'application/json'};

        final cookie = authService.authCookie;

        if (cookie != null && cookie.isNotEmpty) {
          headers['Cookie'] = cookie;
        }

        response = await http.get(url, headers: headers);
      }

      debugPrint('Business Contacts Status: ${response.statusCode}');
      debugPrint('Business Contacts Response: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load seller contacts: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> ||
          decoded['businessContacts'] is! List) {
        throw Exception('Invalid business contacts response.');
      }

      final List<SellerBusinessContact> contacts =
          (decoded['businessContacts'] as List)
              .whereType<Map<String, dynamic>>()
              .map(SellerBusinessContact.fromJson)
              .where((contact) => contact.value.trim().isNotEmpty)
              .toList();

      if (!mounted) return;

      // Same logic as ProductDetailPage:
      // Show one contact per type, preferring primary contacts.
      final Map<String, SellerBusinessContact> uniqueContacts = {};

      for (final contact in contacts) {
        final type = contact.type.toLowerCase();

        if (type == 'phone' ||
            type == 'messenger' ||
            type == 'telegram' ||
            type == 'viber') {
          if (!uniqueContacts.containsKey(type) || contact.isPrimary) {
            uniqueContacts[type] = contact;
          }
        }
      }

      if (uniqueContacts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No contact information available.')),
        );
        return;
      }

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Contact Seller'),
            content: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (uniqueContacts.containsKey('phone'))
                  _sellerContactIcon(
                    Icons.phone,
                    Colors.green,
                    'Phone',
                    uniqueContacts['phone']!,
                  ),
                if (uniqueContacts.containsKey('messenger'))
                  _sellerContactIcon(
                    FontAwesomeIcons.facebookMessenger,
                    Colors.blue,
                    'Messenger',
                    uniqueContacts['messenger']!,
                  ),
                if (uniqueContacts.containsKey('telegram'))
                  _sellerContactIcon(
                    FontAwesomeIcons.telegram,
                    Colors.blue.shade700,
                    'Telegram',
                    uniqueContacts['telegram']!,
                  ),
                if (uniqueContacts.containsKey('viber'))
                  _sellerContactIcon(
                    FontAwesomeIcons.viber,
                    Colors.purple,
                    'Viber',
                    uniqueContacts['viber']!,
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('Chat Seller Error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load seller contacts: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => chatContactsLoading = false);
      }
    }
  }

  Future<void> loadSalesProducts() async {
    if (!mounted) return;

    setState(() {
      salesProductsLoading = true;
      salesProductsError = null;
    });

    try {
      final authService = context.read<AuthService>();

      final result = await _service.fetchSalesProducts(
        authService: authService,
      );

      if (!mounted) return;

      setState(() {
        salesProducts = result;
        salesProductsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        salesProducts = [];
        salesProductsLoading = false;
        salesProductsError = e.toString();
      });
    }
  }

  Future<void> loadProducts() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final sellerId = widget.sellerId;
      if (sellerId == null) {
        throw Exception('Seller ID is required.');
      }

      final result = await _service.fetchSellerProducts(sellerId.toString());
      result.sort((a, b) => (b.productId ?? 0).compareTo(a.productId ?? 0));

      final existingFavouriteIds = <int>{};
      for (final product in result) {
        final id = product.productId;
        if (id != null && id != 0 && product.favourite == 1) {
          existingFavouriteIds.add(id);
        }
        debugPrint(
          'Product $id favourite=${product.favourite} isEdit=${product.isEdit}',
        );
      }
      debugPrint('Seeded favourite ids: $existingFavouriteIds');

      if (!mounted) return;
      setState(() {
        products = result;
        favouriteProductIds
          ..clear()
          ..addAll(existingFavouriteIds);
        loading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        products = [];
        errorMessage = e.toString();
      });
    }
  }

  // FILTER + PAGING
  List<Product> get filteredProducts {
    List<Product> result = List.from(products);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((p) => p.productName.toLowerCase().contains(query))
          .toList();
    }

    if (selectedCategoryId != null) {
      result = result.where((p) => p.categoryId == selectedCategoryId).toList();
    }

    double priceOf(Product p) {
      if (p.price is num) return (p.price as num).toDouble();
      return double.tryParse(p.price.toString().replaceAll(',', '')) ?? 0;
    }

    if (selectedPrice == 'Under 50,000') {
      result = result.where((p) => priceOf(p) < 50000).toList();
    } else if (selectedPrice == '50,000 - 100,000') {
      result = result
          .where((p) => priceOf(p) >= 50000 && priceOf(p) <= 100000)
          .toList();
    } else if (selectedPrice == 'Over 100,000') {
      result = result.where((p) => priceOf(p) > 100000).toList();
    }

    if (selectedSort == 'Lowest Price') {
      result.sort((a, b) => priceOf(a).compareTo(priceOf(b)));
    } else if (selectedSort == 'Highest Price') {
      result.sort((a, b) => priceOf(b).compareTo(priceOf(a)));
    } else {
      result.sort((a, b) => (b.productId ?? 0).compareTo(a.productId ?? 0));
    }

    return result;
  }

  int get totalPages {
    final total = filteredProducts.length;
    if (total == 0) return 1;
    return (total / pageSize).ceil();
  }

  List<Product> get pagedProducts {
    final list = filteredProducts;
    final start = (_currentPage - 1) * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  String formatPrice(String price) {
    final value = double.tryParse(price);
    if (value == null) return price;
    return NumberFormat('#,##0').format(value);
  }

  String? getProductImageUrl(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return null;
  }

  Future<void> _toggleFollow() async {
    if (followLoading || sellerInfoLoading) return;

    final sellerId = widget.sellerId;
    if (sellerId == null) {
      debugPrint('Seller ID is missing.');
      return;
    }

    final authService = context.read<AuthService>();

    // Not logged in → shared login dialog
    if (!authService.isLoggedIn || authService.currentUser == null) {
      FavoriteHelper.showLoginRequiredDialog(context);
      return;
    }

    final shouldFollow = !isFollowing;

    setState(() => followLoading = true);

    final success = await _service.toggleFollow(
      authService: authService,
      sellerId: sellerId,
      follow: shouldFollow,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        isFollowing = shouldFollow;
        if (shouldFollow) {
          followerCount++;
        } else if (followerCount > 0) {
          followerCount--;
        }
        followLoading = false;
      });
      return;
    }

    // Failed → check for 401
    setState(() => followLoading = false);

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       shouldFollow
    //           ? 'Unable to follow seller.'
    //           : 'Unable to unfollow seller.',
    //     ),
    //   ),
    // );
  }

  Widget _sellerContactIcon(
    dynamic icon,
    Color color,
    String label,
    SellerBusinessContact contact,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final type = contact.type.toLowerCase();
        final value = contact.value.trim();

        // Phone: display the phone number.
        if (type == 'phone') {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Contact via Phone'),
              content: SelectableText(value),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
          return;
        }

        Uri? uri;

        if (type == 'messenger') {
          String cleanValue = value;

          if (cleanValue.contains('facebook.com/')) {
            cleanValue = cleanValue.split('facebook.com/').last;
          }

          if (cleanValue.contains('profile.php?id=')) {
            cleanValue = cleanValue.split('profile.php?id=').last;
          }

          if (cleanValue.contains('?')) {
            cleanValue = cleanValue.split('?').first;
          }

          if (cleanValue.endsWith('/')) {
            cleanValue = cleanValue.substring(0, cleanValue.length - 1);
          }

          uri = Uri.parse('https://m.me/$cleanValue');
        } else if (type == 'telegram') {
          final username = value.startsWith('@') ? value.substring(1) : value;

          uri = Uri.parse('https://t.me/$username');
        } else if (type == 'viber') {
          // If the value is already a URL, open it directly.
          if (value.startsWith('http://') || value.startsWith('https://')) {
            uri = Uri.tryParse(value);
          } else {
            final cleanPhone = value.replaceAll(RegExp(r'[\s\-+]'), '');
            uri = Uri.parse('viber://chat?number=$cleanPhone');
          }
        }

        if (uri == null) return;

        try {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
            webOnlyWindowName: '_blank',
          );

          if (!launched && mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Could not open $label')));
          }
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error opening $label: $e')));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon is FaIconData
                ? FaIcon(icon, color: color, size: 22)
                : Icon(icon as IconData, color: color, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Column(
        children: [
          const CommonHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mobile ? 12 : 20,
                      vertical: mobile ? 10 : 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSellerHeader(mobile),
                        const SizedBox(height: 5),
                        buildSearchBox(mobile),
                        const SizedBox(height: 4),
                        buildFilters(mobile),
                        const SizedBox(height: 7),
                        if (loading)
                          const CommonLoading(
                            size: 42,
                            height: 300,
                            message: 'Loading products...',
                          )
                        else if (errorMessage != null)
                          CommonError(
                            height: 250,
                            onRetry: loadProducts,
                            isRetryEnabled: true,
                          )
                        else if (products.isEmpty) ...[
                          CommonEmpty(onRetry: loadProducts),
                          const SizedBox(height: 12),
                          buildProductSections(mobile),
                        ] else if (filteredProducts.isEmpty) ...[
                          CommonEmpty(
                            message: 'Try another search or filter.',
                            onRetry: () {
                              setState(() {
                                _searchController.clear();
                                selectedCategory = 'By Category';
                                selectedCategoryId = null;
                                selectedPrice = 'Price';
                                selectedSort = 'Primmys by Price';
                                _currentPage = 1;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          buildProductSections(mobile),
                        ] else ...[
                          buildProductGrid(mobile),
                          _buildPagination(),
                          const SizedBox(height: 12),
                          buildProductSections(mobile),
                        ],
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!mobile) const CommonFooter(),
        ],
      ),
      bottomNavigationBar: mobile
          ? const CommonBottomBar(currentIndex: 4)
          : null,
    );
  }

  // HEADER — Follow + Chat Seller (public listing)

  Widget buildSellerHeader(bool mobile) {
    final name = (sellerInfo?.name.trim().isNotEmpty == true)
        ? sellerInfo!.name
        : (sellerInfo?.userName.trim().isNotEmpty == true)
        ? sellerInfo!.userName
        : (widget.sellerName ?? 'Seller Store');

    final location = (sellerInfo?.location?.trim().isNotEmpty == true)
        ? sellerInfo!.location!
        : '—';

    final followers = followerCount;
    final productCount = sellerInfo?.productCount ?? products.length;
    final avatarUrl = sellerInfo?.avatarUrl;
    final coverUrl = sellerInfo?.coverUrl;

    if (sellerInfoLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 8 : 16,
        vertical: mobile ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerLeft(name, avatarUrl, mobile),
                const SizedBox(height: 12),
                _headerStats(location, followers, productCount, mobile),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 4, child: _headerLeft(name, avatarUrl, mobile)),
                Expanded(
                  flex: 3,
                  child: _headerStats(
                    location,
                    followers,
                    productCount,
                    mobile,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildCoverImage(coverUrl),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCoverImage(String? coverUrl) {
    final hasCover =
        coverUrl != null &&
        coverUrl.trim().isNotEmpty &&
        (coverUrl.startsWith('http://') || coverUrl.startsWith('https://'));

    if (!hasCover) {
      return const SizedBox(width: 140, height: 90);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        coverUrl,
        width: 140,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(width: 140, height: 90);
        },
      ),
    );
  }

  Widget _headerLeft(String name, String? avatarUrl, bool mobile) {
    final hasAvatar =
        avatarUrl != null &&
        avatarUrl.trim().isNotEmpty &&
        (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'));

    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: mobile ? 52 : 64,
            height: mobile ? 52 : 64,
            child: hasAvatar
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarPlaceholder(mobile),
                  )
                : _avatarPlaceholder(mobile),
          ),
        ),
        SizedBox(width: mobile ? 10 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: mobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff28733D),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Follow Seller
                  GestureDetector(
                    onTap: (followLoading || sellerInfoLoading)
                        ? null
                        : _toggleFollow,
                    child: Container(
                      height: mobile ? 28 : 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isFollowing
                            ? Colors.grey.shade600
                            : const Color(0xff2E7D32),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (followLoading)
                            const SizedBox(
                              width: 13,
                              height: 13,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          else
                            Icon(
                              isFollowing ? Icons.check : Icons.add,
                              size: 14,
                              color: Colors.white,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            followLoading
                                ? 'Please wait...'
                                : isFollowing
                                ? 'Following'
                                : 'Follow',
                            style: TextStyle(
                              fontSize: mobile ? 11 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  // Chat Seller
                  GestureDetector(
                    onTap: _fetchSellerContacts,
                    child: Container(
                      height: mobile ? 28 : 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xffF28C00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (chatContactsLoading)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 14,
                              color: Colors.white,
                            ),

                          const SizedBox(width: 4),

                          Text(
                            chatContactsLoading ? 'Loading...' : 'Chat Seller',
                            style: TextStyle(
                              fontSize: mobile ? 11 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _buildSellerContactsSection(mobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatarPlaceholder(bool mobile) {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: mobile ? 28 : 36,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _headerStats(
    String location,
    int followers,
    int productCount,
    bool mobile,
  ) {
    final style = TextStyle(fontSize: mobile ? 11 : 13, color: Colors.black87);

    Widget row(IconData icon, String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(icon, size: mobile ? 14 : 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(Icons.location_on_outlined, location),
        row(
          Icons.people_outline,
          '${NumberFormat('#,###').format(followers)} Followers',
        ),
        row(
          Icons.inventory_2_outlined,
          '${NumberFormat('#,###').format(productCount)} Products',
        ),
        row(Icons.schedule, 'Usually responds within 2 hours'),
      ],
    );
  }

  // SEARCH + FILTERS

  Widget buildSearchBox(bool mobile) {
    return SizedBox(
      height: mobile ? 28 : 38,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() => _currentPage = 1),
        style: TextStyle(fontSize: mobile ? 10 : 13),
        decoration: InputDecoration(
          hintText: 'Search Items',
          hintStyle: TextStyle(
            fontSize: mobile ? 9 : 12,
            color: Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: mobile ? 15 : 20,
            color: Colors.grey.shade600,
          ),
          isDense: true,
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xffC77C2E)),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryFilter(bool mobile) {
    return SizedBox(
      width: mobile ? 125 : 170,
      height: mobile ? 27 : 34,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            isDense: true,
            icon: Icon(Icons.keyboard_arrow_down, size: mobile ? 13 : 17),
            style: TextStyle(
              color: Colors.black87,
              fontSize: mobile ? 8.5 : 12,
            ),
            dropdownColor: Colors.white,
            items: [
              const DropdownMenuItem<String>(
                value: 'By Category',
                child: Text(
                  'By Category',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...categories.map(
                (category) => DropdownMenuItem<String>(
                  value: category.categoryName,
                  child: Text(
                    category.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: categoryLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      selectedCategory = value;
                      if (value == 'By Category') {
                        selectedCategoryId = null;
                      } else {
                        final match = categories.firstWhere(
                          (c) => c.categoryName == value,
                        );
                        selectedCategoryId = match.categoryId;
                      }
                      _currentPage = 1;
                    });
                  },
          ),
        ),
      ),
    );
  }

  Widget buildFilters(bool mobile) {
    if (mobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: buildCategoryFilter(mobile)),
              const SizedBox(width: 8),
              Expanded(
                child: _filterDropdown(
                  mobile: mobile,
                  value: selectedPrice,
                  items: const [
                    'Price',
                    'Under 50,000',
                    '50,000 - 100,000',
                    'Over 100,000',
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      selectedPrice = v;
                      _currentPage = 1;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _filterDropdown(
                  mobile: mobile,
                  value: selectedSort,
                  items: const [
                    'Primmys by Price',
                    'Lowest Price',
                    'Highest Price',
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      selectedSort = v;
                      _currentPage = 1;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Desktop — single row
    return Row(
      children: [
        SizedBox(width: 170, child: buildCategoryFilter(mobile)),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          child: _filterDropdown(
            mobile: mobile,
            value: selectedPrice,
            items: const [
              'Price',
              'Under 50,000',
              '50,000 - 100,000',
              'Over 100,000',
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                selectedPrice = v;
                _currentPage = 1;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 180,
          child: _filterDropdown(
            mobile: mobile,
            value: selectedSort,
            items: const ['Primmys by Price', 'Lowest Price', 'Highest Price'],
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                selectedSort = v;
                _currentPage = 1;
              });
            },
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _filterDropdown({
    required bool mobile,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      height: mobile ? 32 : 34,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            icon: Icon(Icons.keyboard_arrow_down, size: mobile ? 16 : 17),
            style: TextStyle(color: Colors.black87, fontSize: mobile ? 11 : 12),
            dropdownColor: Colors.white,
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget buildFilter(
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
    bool mobile,
  ) {
    return SizedBox(
      width: mobile ? 125 : 170,
      height: mobile ? 27 : 34,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            icon: Icon(Icons.keyboard_arrow_down, size: mobile ? 13 : 17),
            style: TextStyle(
              color: Colors.black87,
              fontSize: mobile ? 8.5 : 12,
            ),
            dropdownColor: Colors.white,
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }

  // PRODUCT GRID — NO EDIT BUTTON

  Widget buildProductGrid(bool mobile) {
    final products = pagedProducts;

    if (products.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No products found.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mobile ? 2 : 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        // Tighter height = less empty space under the button
        mainAxisExtent: mobile ? 250 : 260,
      ),
      itemBuilder: (context, index) {
        return buildProductCard(products[index], mobile);
      },
    );
  }

  Widget buildProductCard(Product product, bool mobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          SizedBox(
            height: mobile ? 145 : 155,
            width: double.infinity,
            child: _buildProductImage(product.imageUrl, mobile),
          ),

          // NAME
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
            child: Text(
              product.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: mobile ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          // PRICE
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 2, 6, 0),
            child: Text(
              '${formatPrice(product.price.toString())} Kyat',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: mobile ? 12 : 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Pushes button row to the bottom of the card
          const SizedBox(height: 8),
          // VIEW DETAILS + HEART (tight to bottom)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              6,
              0,
              6,
              6,
            ), // small gap to card border
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: mobile ? 28 : 30,
                    child: ElevatedButton(
                      onPressed: () {
                        if (product.productId != null) {
                          context.go('/product/${product.productId}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF28C00),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: mobile ? 10 : 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: favouriteLoadingIds.contains(product.productId)
                      ? null
                      : () => toggleFavourite(product),
                  child: SizedBox(
                    width: mobile ? 28 : 32,
                    height: mobile ? 28 : 32,
                    child: favouriteLoadingIds.contains(product.productId)
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(strokeWidth: 1.8),
                          )
                        : Icon(
                            favouriteProductIds.contains(product.productId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: mobile ? 20 : 22,
                            color:
                                favouriteProductIds.contains(product.productId)
                                ? Colors.red
                                : Colors.grey.shade600,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imagePath, bool mobile) {
    final url = getProductImageUrl(imagePath);
    if (url == null) {
      return Container(
        color: const Color(0xffF2F2F2),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: mobile ? 25 : 40,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xffF2F2F2),
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              size: mobile ? 25 : 40,
              color: Colors.grey.shade400,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xffF2F2F2),
          child: Center(
            child: SizedBox(
              width: mobile ? 15 : 22,
              height: mobile ? 15 : 22,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Widget _buildPagination() {
    final total = totalPages;
    if (filteredProducts.isEmpty || total <= 1) {
      return const SizedBox.shrink();
    }

    final pages = _visiblePageNumbers(current: _currentPage, total: total);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageArrow(
            icon: Icons.chevron_left,
            enabled: _currentPage > 1,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: 4),
          ...pages.map((page) {
            if (page == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              );
            }
            final isSelected = page == _currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  if (page != _currentPage) {
                    setState(() => _currentPage = page);
                  }
                },
                child: Container(
                  width: 40,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF28C00)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF28C00)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '$page',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          _pageArrow(
            icon: Icons.chevron_right,
            enabled: _currentPage < total,
            onTap: () => setState(() => _currentPage++),
          ),
        ],
      ),
    );
  }

  Widget _pageArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled ? Colors.grey.shade400 : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.black87 : Colors.grey.shade400,
        ),
      ),
    );
  }

  List<int?> _visiblePageNumbers({required int current, required int total}) {
    if (total <= 7) {
      return List<int?>.generate(total, (i) => i + 1);
    }

    final Set<int> set = {1, total, current};
    for (int i = current - 1; i <= current + 1; i++) {
      if (i >= 1 && i <= total) set.add(i);
    }
    if (current <= 3) set.addAll([1, 2, 3, 4]);
    if (current >= total - 2) {
      set.addAll([total - 3, total - 2, total - 1, total]);
    }

    final sorted = set.where((p) => p >= 1 && p <= total).toList()..sort();
    final List<int?> result = [];
    int? prev;
    for (final p in sorted) {
      if (prev != null && p - prev > 1) result.add(null);
      result.add(p);
      prev = p;
    }
    return result;
  }

  // ============================================================
  // NEWEST + SALES SECTIONS
  // ============================================================

  Widget buildProductSections(bool mobile) {
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildNewestArrivalsSection(true),
          const SizedBox(height: 15),
          buildSalesProductsSection(true),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: buildNewestArrivalsSection(false)),
        const SizedBox(width: 20),
        Expanded(child: buildSalesProductsSection(false)),
      ],
    );
  }

  Widget buildNewestArrivalsSection(bool mobile) {
    final itemCount = newestArrivals.length > 4 ? 4 : newestArrivals.length;
    // +1 for the View All card at the end
    final listCount = newestArrivals.isEmpty ? 0 : itemCount + 1;

    return _sectionBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Newest Arrivals',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/new-in'),
                child: Text(
                  'VIEW ALL',
                  style: TextStyle(
                    fontSize: mobile ? 10 : 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff28733D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (newestArrivalsLoading)
            const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (newestArrivalsError != null)
            SizedBox(
              height: 100,
              child: Center(
                child: TextButton(
                  onPressed: loadNewestArrivals,
                  child: const Text('Failed to load. Tap to retry'),
                ),
              ),
            )
          else if (newestArrivals.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(child: Text('No newest arrivals available.')),
            )
          else
            SizedBox(
              height: mobile ? 150 : 205,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ListView.separated(
                    controller: _newestScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: listCount,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      // Last item = View All card
                      if (index == itemCount) {
                        return _viewAllCard(
                          mobile: mobile,
                          onTap: () => context.go('/new-in'),
                        );
                      }
                      final item = newestArrivals[index];
                      return SizedBox(
                        width: mobile ? 135 : 180,
                        child: buildSmallNewInCard(item, mobile),
                      );
                    },
                  ),
                  // Left arrow
                  Positioned(
                    left: 0,
                    child: _scrollArrow(
                      icon: Icons.chevron_left,
                      onTap: () => _scrollBy(_newestScrollController, -200),
                    ),
                  ),
                  // Right arrow
                  Positioned(
                    right: 0,
                    child: _scrollArrow(
                      icon: Icons.chevron_right,
                      onTap: () => _scrollBy(_newestScrollController, 200),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSalesProductsSection(bool mobile) {
    final itemCount = salesProducts.length > 4 ? 4 : salesProducts.length;
    // +1 for the View All card at the end
    final listCount = salesProducts.isEmpty ? 0 : itemCount + 1;

    return _sectionBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sales Products',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/sale'),
                child: Text(
                  'VIEW ALL',
                  style: TextStyle(
                    fontSize: mobile ? 10 : 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff28733D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (salesProductsLoading)
            const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (salesProductsError != null)
            SizedBox(
              height: 100,
              child: Center(
                child: TextButton(
                  onPressed: loadSalesProducts,
                  child: const Text('Failed to load. Tap to retry'),
                ),
              ),
            )
          else if (salesProducts.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(child: Text('No sales products available.')),
            )
          else
            SizedBox(
              height: mobile ? 150 : 205,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ListView.separated(
                    controller: _salesScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: listCount,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      // Last item = View All card
                      if (index == itemCount) {
                        return _viewAllCard(
                          mobile: mobile,
                          onTap: () => context.go('/sale'),
                        );
                      }

                      final item = salesProducts[index];
                      return SizedBox(
                        width: mobile ? 135 : 180,
                        child: buildSmallNewInCard(item, mobile),
                      );
                    },
                  ),

                  // Left arrow
                  Positioned(
                    left: 0,
                    child: _scrollArrow(
                      icon: Icons.chevron_left,
                      onTap: () => _scrollBy(_salesScrollController, -200),
                    ),
                  ),

                  // Right arrow
                  Positioned(
                    right: 0,
                    child: _scrollArrow(
                      icon: Icons.chevron_right,
                      onTap: () => _scrollBy(_salesScrollController, 200),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionBorder({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }

  Widget _scrollArrow({required IconData icon, required VoidCallback? onTap}) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _viewAllCard({required bool mobile, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: mobile ? 135 : 180,
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_forward,
              size: mobile ? 28 : 34,
              color: const Color(0xff28733D),
            ),
            const SizedBox(height: 8),
            Text(
              'VIEW ALL',
              style: TextStyle(
                fontSize: mobile ? 11 : 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xff28733D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSmallNewInCard(NewInModel item, bool mobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: mobile ? 85 : 125,
            width: double.infinity,
            child: _buildProductImage(item.imageUrl, mobile),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 9 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${NumberFormat('#,##0').format(item.price)} Kyat',
                  style: TextStyle(
                    fontSize: mobile ? 9 : 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 1, 7, 6),
            child: SizedBox(
              width: double.infinity,
              height: mobile ? 22 : 28,
              child: ElevatedButton(
                onPressed: () {
                  if (item.productId != 0) {
                    context.go('/product/${item.productId}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF28C00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'VIEW DETAILS',
                  style: TextStyle(
                    fontSize: mobile ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductSection({
    required String title,
    required List<Product> items,
    required bool mobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: mobile ? 20 : 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.go('/sale');
              },
              child: Text(
                'VIEW ALL',
                style: TextStyle(
                  fontSize: mobile ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff28733D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: mobile ? 150 : 205,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 5),
            itemBuilder: (context, index) {
              final product = items[index];
              return SizedBox(
                width: mobile ? 135 : 180,
                child: buildSmallProductCard(product, mobile),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSmallProductCard(Product product, bool mobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: mobile ? 85 : 125,
            width: double.infinity,
            child: _buildProductImage(product.imageUrl, mobile),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: mobile ? 9 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatPrice(product.price.toString())} Kyat',
                  style: TextStyle(
                    fontSize: mobile ? 9 : 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 1, 7, 6),
            child: SizedBox(
              width: double.infinity,
              height: mobile ? 22 : 28,
              child: ElevatedButton(
                onPressed: () {
                  if (product.productId != null) {
                    context.go('/product/${product.productId}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF28C00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'VIEW DETAILS',
                  style: TextStyle(
                    fontSize: mobile ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FAVOURITE

  Future<void> toggleFavourite(Product product) async {
    final productId = product.productId;
    if (productId == 0) return;
    if (favouriteLoadingIds.contains(productId)) return;

    final authService = context.read<AuthService>();

    // Not logged in → same dialog as other pages
    if (!authService.isLoggedIn || authService.currentUser == null) {
      FavoriteHelper.showLoginRequiredDialog(context);
      return;
    }

    final bool isFavourite = favouriteProductIds.contains(productId);

    setState(() => favouriteLoadingIds.add(productId));

    try {
      // Same helper as HomePage
      await FavoriteHelper.toggleFavorite(
        context,
        productId: productId,
        isCurrentlyFavorite: isFavourite,
      );

      if (!mounted) return;

      // Sync local UI set from AuthService if it tracks favourites
      setState(() {
        if (isFavourite) {
          favouriteProductIds.remove(productId);
        } else {
          favouriteProductIds.add(productId);
        }
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
      if (msg.contains('401') ||
          msg.contains('unauthorized') ||
          msg.contains('please login')) {
        FavoriteHelper.showLoginRequiredDialog(context);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => favouriteLoadingIds.remove(productId));
      }
    }
  }

  Future<void> _fetchSellerContacts() async {
    // If already loaded, just toggle visibility
    if (_sellerContacts.isNotEmpty) {
      setState(() => _showContacts = !_showContacts);
      return;
    }

    // If no products, we can't fetch contacts
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No products available to fetch contacts from.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingContacts = true;
      _showContacts = true;
    });

    try {
      final apiService = context.read<ApiService>();
      final firstProductId = products.first.productId;

      if (firstProductId == null) {
        throw Exception('Product ID is null');
      }

      //  Call the new public method
      final detailProduct = await apiService.fetchProductDetail(firstProductId);

      if (detailProduct != null) {
        setState(() {
          _sellerContacts = detailProduct.businessContacts;
          _isLoadingContacts = false;
        });
      } else {
        throw Exception('Failed to load product detail');
      }
    } catch (e) {
      debugPrint('Failed to load seller contacts: $e');
      if (mounted) {
        setState(() {
          _isLoadingContacts = false;
          _showContacts = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load contacts. Please try again.'),
          ),
        );
      }
    }
  }

  Widget _buildSellerContactsSection(bool mobile) {
    if (!_showContacts) return const SizedBox.shrink();

    if (_isLoadingContacts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_sellerContacts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Text('No contact information available.'),
      );
    }

    // Filter unique contacts
    final Map<String, BusinessContact> uniqueContacts = {};
    for (var contact in _sellerContacts) {
      final type = contact.type.toLowerCase();
      if (type == 'phone' ||
          type == 'messenger' ||
          type == 'telegram' ||
          type == 'viber') {
        if (!uniqueContacts.containsKey(type) || contact.isPrimary) {
          uniqueContacts[type] = contact;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        // color: Colors.grey[50],
        // borderRadius: BorderRadius.circular(8),
        // border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          if (uniqueContacts.containsKey('phone'))
            _contactIcon(
              Icons.phone,
              Colors.green,
              'Phone',
              uniqueContacts['phone']!,
            ),
          if (uniqueContacts.containsKey('messenger'))
            _contactIcon(
              FontAwesomeIcons.facebookMessenger,
              Colors.blue,
              'Messenger',
              uniqueContacts['messenger']!,
            ),
          if (uniqueContacts.containsKey('telegram'))
            _contactIcon(
              FontAwesomeIcons.telegram,
              Colors.blue[700]!,
              'Telegram',
              uniqueContacts['telegram']!,
            ),
          if (uniqueContacts.containsKey('viber'))
            _contactIcon(
              FontAwesomeIcons.viber,
              Colors.purple,
              'Viber',
              uniqueContacts['viber']!,
            ),
        ],
      ),
    );
  }

  Widget _contactIcon(
    dynamic icon,
    Color color,
    String label,
    BusinessContact contact,
  ) {
    return InkWell(
      onTap: () async {
        Uri? uri;
        final type = contact.type.toLowerCase();
        final value = contact.value.trim();

        if (type == 'messenger') {
          String cleanValue = value.trim();
          if (cleanValue.contains('facebook.com/')) {
            cleanValue = cleanValue.split('facebook.com/').last;
          }
          if (cleanValue.contains('profile.php?id=')) {
            cleanValue = cleanValue.split('profile.php?id=').last;
          }
          if (cleanValue.contains('?')) {
            cleanValue = cleanValue.split('?').first;
          }
          if (cleanValue.endsWith('/')) {
            cleanValue = cleanValue.substring(0, cleanValue.length - 1);
          }
          uri = Uri.parse('https://m.me/$cleanValue');
        } else if (type == 'telegram') {
          if (value.startsWith('+')) {
            uri = Uri.parse('https://t.me/$value');
          } else {
            final username = value.startsWith('@') ? value.substring(1) : value;
            uri = Uri.parse('https://t.me/$username');
          }
        } else if (type == 'viber') {
          String cleanPhone = value.replaceAll(RegExp(r'[\s\-\+]'), '');
          uri = Uri.parse('viber://chat?number=$cleanPhone');
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Contact via $label'),
              content: SelectableText(contact.value),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
          return;
        }

        try {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
            webOnlyWindowName: '_blank',
          );
          if (!launched && mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Could not open $label')));
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon is FaIconData
                ? FaIcon(icon, color: color, size: 20)
                : Icon(icon as IconData, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

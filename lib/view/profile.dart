import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'common/header.dart';
import 'common/footer.dart';
import '../services/auth_service.dart';
import 'myListing.dart';
import 'package:provider/provider.dart';
import 'sellerListing.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';
import 'package:provider/provider.dart';
import 'common/favorite_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedMenu = 0;
  final ImagePicker _imagePicker = ImagePicker();

  String? _avatarUrl;
  String? _coverUrl;
  bool _isLoadingProfile = false;

  // Profile data starts empty and is populated from the profile API.
  // About Me remains local and is intentionally not bound to the API.
  Map<String, dynamic> profileData = {
    "personal": {
      "fullName": "",
      "email": "",
      "phone": "",
      "dateOfBirth": "",
      "gender": "",
      "joinedOn": "",
      "location": "",
      "accountTypes": <String>[],
    },
    "about": {
      "description":
          "I love fashion, lifestyle products, and finding high-quality items for everyday life.",
    },
    "business": {
      "shopName": "",
      "businessType": "",
      "businessLocation": "",
      "businessDescription": "",
    },
  };

  String _formatDateForDisplay(String? value) {
    if (value == null || value.trim().isEmpty) return '';

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    final existingDate = DateTime.tryParse(dateOfBirthController.text.trim());

    final initialDate = existingDate != null && !existingDate.isAfter(now)
        ? existingDate
        : DateTime(now.year - 18, now.month, now.day);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC77C2E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && mounted) {
      final year = selectedDate.year.toString().padLeft(4, '0');
      final month = selectedDate.month.toString().padLeft(2, '0');
      final day = selectedDate.day.toString().padLeft(2, '0');

      setState(() {
        dateOfBirthController.text = '$year-$month-$day';
      });
    }
  }

  String _dateOfBirthForApi() {
    final value = dateOfBirthController.text.trim();

    if (value.isEmpty) return '';

    final date = DateTime.tryParse(value);

    if (date == null) {
      throw Exception('Please select a valid date of birth.');
    }

    return DateTime.utc(date.year, date.month, date.day).toIso8601String();
  }

  // EDIT STATES
  bool isEditingPersonal = false;
  bool isEditingAbout = false;
  bool isEditingBusiness = false;

  // CONTROLLERS
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController dateOfBirthController;
  late TextEditingController genderController;
  late TextEditingController joinedOnController;
  late TextEditingController locationController;
  late TextEditingController accountTypesController;
  late TextEditingController aboutController;
  late TextEditingController shopNameController;
  late TextEditingController businessTypeController;
  late TextEditingController businessLocationController;
  late TextEditingController businessDescriptionController;

  XFile? _profileImage;
  // PROFILE MENU
  final List<Map<String, dynamic>> profileMenus = [
    {"title": "Profile", "icon": Icons.person_outline},
    {"title": "Account Settings", "icon": Icons.settings_outlined},
    {"title": "Security", "icon": Icons.lock_outline},
    {"title": "Communication Preferences", "icon": Icons.mail_outline},
    {"title": "Addresses", "icon": Icons.location_on_outlined},
    {"title": "Favourite", "icon": Icons.star_border},
    {"title": "My Listings", "icon": Icons.storefront_outlined},
    {"title": "Notifications", "icon": Icons.notifications_none_outlined},
    {"title": "Help Center", "icon": Icons.help_outline},
  ];

  Map<String, dynamic> get personal =>
      profileData["personal"] as Map<String, dynamic>;

  Map<String, dynamic> get about =>
      profileData["about"] as Map<String, dynamic>;

  Map<String, dynamic> get business =>
      profileData["business"] as Map<String, dynamic>;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureAuthenticated();
    });
    final personalData = profileData["personal"];
    final aboutData = profileData["about"];
    final businessData = profileData["business"];
    fullNameController = TextEditingController(
      text: personalData["fullName"] ?? "",
    );
    emailController = TextEditingController(text: personalData["email"] ?? "");
    phoneController = TextEditingController(text: personalData["phone"] ?? "");
    dateOfBirthController = TextEditingController(
      text: personalData["dateOfBirth"] ?? "",
    );
    genderController = TextEditingController(
      text: personalData["gender"] ?? "",
    );
    joinedOnController = TextEditingController(
      text: personalData["joinedOn"] ?? "",
    );
    locationController = TextEditingController(
      text: personalData["location"] ?? "",
    );
    accountTypesController = TextEditingController(
      text: (personalData["accountTypes"] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .join(", "),
    );
    aboutController = TextEditingController(
      text: aboutData["description"] ?? "",
    );
    shopNameController = TextEditingController(
      text: businessData["shopName"] ?? "",
    );
    businessTypeController = TextEditingController(
      text: businessData["businessType"] ?? "",
    );
    businessLocationController = TextEditingController(
      text: businessData["businessLocation"] ?? "",
    );
    businessDescriptionController = TextEditingController(
      text: businessData["businessDescription"] ?? "",
    );

    // _loadProfile();
  }

  Widget buildDateOfBirthInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: dateOfBirthController,
        readOnly: true, // Prevent manual typing
        onTap: _selectDateOfBirth, // Open calendar picker
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          hintText: 'Select your date of birth',
          prefixIcon: const Icon(Icons.calendar_month_outlined),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _selectDateOfBirth,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() => _isLoadingProfile = true);
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final ProfileModel result = await ProfileService(
        authService: authService,
      ).fetchProfile();

      if (!mounted) return;

      final roles = result.roles.map((role) {
        if (role.isEmpty) return role;
        return role[0].toUpperCase() + role.substring(1);
      }).toList();

      final fullName = result.name.trim().isNotEmpty
          ? result.name.trim()
          : result.userName;

      final personalData = <String, dynamic>{
        'fullName': fullName,
        'email': result.email,
        'phone': result.phone,
        'dateOfBirth': _formatDateForDisplay(result.dateOfBirth),
        'gender': result.gender,
        'joinedOn': result.createdDate,
        'location': result.location,
        'accountTypes': roles,
      };

      final businessData = <String, dynamic>{
        'shopName': result.shopName,
        'businessType': result.businessType,
        'businessLocation': result.businessLocation,
        'businessDescription': result.businessDescription,
      };

      setState(() {
        profileData['personal'] = personalData;
        profileData['business'] = businessData;
        _avatarUrl = _imageUrl(result.avatarUrl);
        _coverUrl = _imageUrl(result.coverUrl);

        fullNameController.text = fullName;
        emailController.text = result.email;
        phoneController.text = result.phone;
        dateOfBirthController.text = _formatDateForDisplay(result.dateOfBirth);
        genderController.text = result.gender;
        joinedOnController.text = result.createdDate;
        locationController.text = result.location;
        accountTypesController.text = roles.join(', ');

        shopNameController.text = result.shopName;
        businessTypeController.text = result.businessType;
        businessLocationController.text = result.businessLocation;
        businessDescriptionController.text = result.businessDescription;
        _isLoadingProfile = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Unable to load profile: $e');
      debugPrint('$stackTrace');
      if (!mounted) return;
      setState(() => _isLoadingProfile = false);
      await _handleAuthError(e);
    }
  }

  bool _isUnauthorizedError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('401') ||
        message.contains('unauthorized') ||
        message.contains('session has expired');
  }

  Future<void> _handleAuthError(Object error) async {
    if (!mounted) return;
    if (_isUnauthorizedError(error)) {
      FavoriteHelper.showSessionExpiredDialog(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    genderController.dispose();
    joinedOnController.dispose();
    locationController.dispose();
    accountTypesController.dispose();
    aboutController.dispose();
    shopNameController.dispose();
    businessTypeController.dispose();
    businessLocationController.dispose();
    businessDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _ensureAuthenticated() async {
    if (!mounted) return;

    final authService = context.read<AuthService>();

    if (!authService.isLoggedIn || authService.currentUser == null) {
      FavoriteHelper.showLoginRequiredDialog(context);
      return;
    }

    await _loadProfile();
  }

  // CAMERA / GALLERY
  Future<void> pickProfileImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (image != null) {
        await _uploadProfileImage(image);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unable to select image: $e")));
    }
  }

  Future<void> pickCoverImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1800,
        maxHeight: 1000,
      );
      if (image == null || !mounted) return;

      setState(() => _isLoadingProfile = true);
      final authService = Provider.of<AuthService>(context, listen: false);
      await ProfileService(authService: authService).uploadCover(image);
      if (!mounted) return;
      await _loadProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cover photo uploaded successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to upload cover photo: $e')),
      );
    }
  }

  Future<void> _uploadProfileImage(XFile image) async {
    try {
      setState(() {
        _profileImage = image;
        _isLoadingProfile = true;
      });
      final authService = Provider.of<AuthService>(context, listen: false);
      await ProfileService(authService: authService).uploadAvatar(image);
      if (!mounted) return;
      await _loadProfile();
      if (!mounted) return;
      setState(() => _profileImage = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo uploaded successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to upload profile photo: $e')),
      );
    }
  }

  String? _imageUrl(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty || raw.toLowerCase() == 'null') return null;
    if (raw.startsWith('https://') || raw.startsWith('http://')) return raw;
    if (raw.startsWith('//')) return 'https:$raw';
    if (raw.startsWith('/')) {
      return 'https://www.capital-sys.net/CKMMallAPI$raw';
    }
    return 'https://www.capital-sys.net/CKMMallAPI/$raw';
  }

  void showCoverPickerDialog() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(
              title: Text(
                'Change Cover Photo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                pickCoverImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                pickCoverImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // IMAGE SOURCE DIALOG
  void showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Change Profile Photo",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // CAMERA
                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.orange,
                    ),
                  ),
                  title: const Text("Take Photo"),
                  subtitle: const Text("Use your camera"),
                  onTap: () {
                    Navigator.pop(context);
                    pickProfileImage(ImageSource.camera);
                  },
                ),

                // GALLERY
                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  title: const Text("Choose from Gallery"),
                  subtitle: const Text("Select an existing photo"),
                  onTap: () {
                    Navigator.pop(context);
                    pickProfileImage(ImageSource.gallery);
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
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
                      horizontal: isMobile ? 15 : 48,
                      vertical: 20,
                    ),
                    child: isMobile
                        ? buildMobileLayout()
                        : buildDesktopLayout(),
                  ),
                ),
              ),
            ),
          ),

          if (!isMobile) const CommonFooter(),
        ],
      ),

      bottomNavigationBar: isMobile
          ? const CommonBottomBar(currentIndex: 4)
          : null,
    );
  }

  // DESKTOP LAYOUT
  Widget buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildBreadcrumb(),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 320, child: buildProfileSidebar(false)),
            const SizedBox(width: 40),
            Expanded(child: buildProfileContent()),
          ],
        ),
      ],
    );
  }

  // MOBILE LAYOUT

  Widget buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildBreadcrumb(),
        const SizedBox(height: 15),
        buildProfileSidebar(true),
        const SizedBox(height: 20),
        buildProfileContent(),
      ],
    );
  }

  // BREADCRUMB
  Widget buildBreadcrumb() {
    return Row(
      children: [
        Text(
          "Home",
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ),

        Text(
          "My Account",
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ),

        const Text(
          "Profile",
          style: TextStyle(fontSize: 13, color: Colors.black),
        ),
      ],
    );
  }

  // PROFILE SIDEBAR
  Widget buildProfileSidebar(bool isMobile) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // COVER + PROFILE IMAGE
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: _coverUrl != null && _coverUrl!.isNotEmpty
                    ? Image.network(
                        _coverUrl!,
                        height: 135,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(height: 135, color: Colors.white);
                        },
                      )
                    : Container(
                        height: 135,
                        width: double.infinity,
                        color: Colors.white,
                      ),
              ),

              // PROFILE AVATAR
              // MOBILE = LEFT
              // DESKTOP = CENTER
              Positioned(
                left: 0,
                right: 0,
                bottom: -45,
                child: Align(
                  alignment: Alignment.center,
                  child: buildProfileAvatar(),
                ),
              ),

              // CAMERA BUTTON
              Positioned(
                right: 10,
                top: 10,
                child: buildCameraButton(onPressed: showCoverPickerDialog),
              ),
              Positioned(
                right: 15,
                bottom: -5,
                child: buildCameraButton(onPressed: showImagePickerDialog),
              ),
            ],
          ),

          const SizedBox(height: 55),

          // USER INFO
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  personal["fullName"] ?? "",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  personal["email"] ?? "",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffE9F8ED),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: Colors.green),
                      SizedBox(width: 5),
                      Text(
                        "Verified",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),
          Divider(color: Colors.grey.shade200),

          // MENU
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profileMenus.length,
            itemBuilder: (context, index) {
              final item = profileMenus[index];

              return buildProfileMenuItem(
                index: index,
                title: item["title"],
                icon: item["icon"],
              );
            },
          ),

          Divider(color: Colors.grey.shade200),

          // LOGOUT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                await authService.logout(); // Clear session and cookies

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
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 15),
                    Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PROFILE AVATAR
  Widget buildProfileAvatar() {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: ClipOval(
        child: _profileImage != null
            ? (kIsWeb
                  ? Image.network(_profileImage!.path, fit: BoxFit.cover)
                  : Image.file(File(_profileImage!.path), fit: BoxFit.cover))
            : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
            ? Image.network(
                _avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.expand();
                },
              )
            : const SizedBox.expand(),
      ),
    );
  }
  // CAMERA BUTTON

  Widget buildCameraButton({required VoidCallback onPressed}) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.camera_alt_outlined, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  // PROFILE MENU ITEM

  Widget buildProfileMenuItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = selectedMenu == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedMenu = index;
        });

        if (title == "My Listings") {
          // Get the SAME AuthService instance that was created in main.dart
          final authService = Provider.of<AuthService>(context, listen: false);

          print("========================================");
          print("MY LISTINGS DEBUG");
          print("AuthService isLoggedIn: ${authService.isLoggedIn}");
          print("AuthService currentUser: ${authService.currentUser}");

          final currentUser = authService.currentUser;

          if (currentUser == null) {
            print("❌ CURRENT USER IS NULL");
            print("========================================");

            showUpdateMessage("Please login first.");
            return;
          }

          print(" CURRENT USER FOUND");
          print("User ID: ${currentUser.id}");
          print("Username: ${currentUser.username}");
          print("Email: ${currentUser.email}");
          print("Full Name: ${currentUser.fullName}");

          final currentUserId = currentUser.id;

          print("Passing sellerId to SellerStorePage: $currentUserId");
          debugPrint('current user name: ${currentUser.username}');
          debugPrint('current user name: ${currentUser.email}');

          print("========================================");

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SellerStorePage(
          //       sellerId: currentUserId,
          //       sellerName: currentUser.username,
          //     ),
          //   ),
          // );
          context.go(
            '/my-store/${currentUser.id}?name=${Uri.encodeComponent(currentUser.username)}',
          );
          return;
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffFFF9F3) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? Colors.orange : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 23,
              color: isSelected ? Colors.orange : Colors.grey.shade700,
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.orange : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // RIGHT PROFILE CONTENT
  Widget buildProfileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoadingProfile) const LinearProgressIndicator(),
        const Text(
          "My Profile",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 5),

        Text(
          "Manage your personal information and account details",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),

        const SizedBox(height: 20),

        // PERSONAL
        buildPersonalInformation(),

        const SizedBox(height: 20),

        // ABOUT + BUSINESS
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return Column(
                children: [
                  buildAboutMe(),

                  const SizedBox(height: 20),

                  buildBusinessInformation(),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildAboutMe()),

                const SizedBox(width: 20),

                Expanded(child: buildBusinessInformation()),
              ],
            );
          },
        ),
      ],
    );
  }

  // PERSONAL INFORMATION
  Widget buildPersonalInformation() {
    return profileCard(
      child: Column(
        children: [
          buildCardHeader(
            "Personal Information",
            isEditing: isEditingPersonal,
            onEdit: () {
              setState(() {
                isEditingPersonal = true;
              });
            },
            onUpdate: updatePersonalInformation,
            onCancel: cancelPersonalInformation,
          ),

          const Divider(),

          isEditingPersonal ? buildPersonalEditForm() : buildPersonalDisplay(),
        ],
      ),
    );
  }

  // PERSONAL DISPLAY
  Widget buildPersonalDisplay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              buildPersonalLeftColumn(),
              const SizedBox(height: 15),
              buildPersonalRightColumn(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildPersonalLeftColumn()),

            Container(width: 1, height: 230, color: Colors.grey.shade200),

            Expanded(child: buildPersonalRightColumn()),
          ],
        );
      },
    );
  }

  // PERSONAL EDIT FORM
  Widget buildPersonalEditForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Column(
              children: [
                buildInput(
                  "Full Name",
                  fullNameController,
                  Icons.person_outline,
                ),

                buildInput(
                  "Email Address",
                  emailController,
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                buildInput(
                  "Phone Number",
                  phoneController,
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                buildDateOfBirthInput(),

                buildGenderDropdown(),

                Expanded(
                  child: buildInput(
                    "Joined On",
                    joinedOnController,
                    Icons.access_time_outlined,
                    enabled: false,
                  ),
                ),

                buildInput(
                  "Location",
                  locationController,
                  Icons.language_outlined,
                ),

                buildInput(
                  "Account Type",
                  accountTypesController,
                  Icons.sell_outlined,
                  hintText: "seller, buyer",
                ),
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: buildInput(
                      "Full Name",
                      fullNameController,
                      Icons.person_outline,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(child: buildDateOfBirthInput()),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: buildInput(
                      "Email Address",
                      emailController,
                      Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(child: buildGenderDropdown()),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: buildInput(
                      "Phone Number",
                      phoneController,
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: buildInput(
                      "Joined On",
                      joinedOnController,
                      Icons.access_time_outlined,
                      enabled: false,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: buildInput(
                      "Account Types",
                      accountTypesController,
                      Icons.sell_outlined,
                      hintText: "Seller, User, Purchaser",
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: buildInput(
                      "Location",
                      locationController,
                      Icons.language_outlined,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // GENDER DROPDOWN
  Widget buildGenderDropdown() {
    const genderOptions = ['Male', 'Female', 'Other'];

    // Match API values regardless of capitalization.
    final currentGender = genderOptions.cast<String?>().firstWhere(
      (gender) =>
          gender!.toLowerCase() == genderController.text.trim().toLowerCase(),
      orElse: () => null,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: currentGender,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Gender',
          prefixIcon: const Icon(Icons.person_add_alt_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        items: genderOptions.map((gender) {
          return DropdownMenuItem<String>(value: gender, child: Text(gender));
        }).toList(),
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            genderController.text = value;
          });
        },
      ),
    );
  }

  Future<void> updatePersonalInformation() async {
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      showUpdateMessage('Please login first.');
      return;
    }

    final userId = int.tryParse(currentUser.id.toString());

    if (userId == null || userId <= 0) {
      showUpdateMessage('Invalid user. Please login again.');
      return;
    }

    if (fullNameController.text.trim().isEmpty) {
      showUpdateMessage('Please enter your full name.');
      return;
    }

    try {
      setState(() => _isLoadingProfile = true);

      final role = accountTypesController.text
          .split(',')
          .map((item) => item.trim().toLowerCase())
          .where((item) => item.isNotEmpty)
          .join(', ');

      final dateOfBirth = _dateOfBirthForApi();

      await ProfileService(authService: authService).updatePersonalInfo(
        userId: userId,
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        role: role,
        dateOfBirth: dateOfBirth,
        gender: genderController.text.trim(),
        location: locationController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        personal['fullName'] = fullNameController.text.trim();
        personal['email'] = emailController.text.trim();
        personal['phone'] = phoneController.text.trim();
        personal['dateOfBirth'] = dateOfBirthController.text.trim();
        personal['gender'] = genderController.text.trim();
        personal['location'] = locationController.text.trim();

        personal['accountTypes'] = role
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .map((item) => item[0].toUpperCase() + item.substring(1))
            .toList();

        isEditingPersonal = false;
        _isLoadingProfile = false;
      });

      showUpdateMessage('Personal information updated successfully.');
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoadingProfile = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  // CANCEL PERSONAL
  void cancelPersonalInformation() {
    fullNameController.text = personal["fullName"] ?? "";
    emailController.text = personal["email"] ?? "";
    phoneController.text = personal["phone"] ?? "";
    dateOfBirthController.text = personal["dateOfBirth"] ?? "";
    genderController.text = personal["gender"] ?? "";
    joinedOnController.text = personal["joinedOn"] ?? "";
    locationController.text = personal["location"] ?? "";

    accountTypesController.text =
        (personal["accountTypes"] as List<dynamic>? ?? [])
            .map((item) => item.toString())
            .join(", ");

    setState(() {
      isEditingPersonal = false;
    });
  }

  // PERSONAL LEFT
  Widget buildPersonalLeftColumn() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, top: 10),
      child: Column(
        children: [
          profileInfoRow(
            icon: Icons.person_outline,
            title: "Full Name",
            value: personal["fullName"] ?? "",
          ),

          profileInfoRow(
            icon: Icons.email_outlined,
            title: "Email Address",
            value: personal["email"] ?? "",
          ),

          profileInfoRow(
            icon: Icons.phone_outlined,
            title: "Phone Number",
            value: personal["phone"] ?? "",
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.sell_outlined, size: 25, color: Colors.grey),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Account Type",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (personal["accountTypes"] as List<dynamic>)
                          .map(
                            (type) => accountBadge(
                              type.toString(),
                              const Color(0xffffefe0),
                              Colors.orange,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // PERSONAL RIGHT
  Widget buildPersonalRightColumn() {
    return Padding(
      padding: const EdgeInsets.only(left: 25, top: 10),
      child: Column(
        children: [
          profileInfoRow(
            icon: Icons.calendar_month_outlined,
            title: "Date of Birth",
            value: personal["dateOfBirth"] ?? "",
          ),

          profileInfoRow(
            icon: Icons.person_add_alt_outlined,
            title: "Gender",
            value: personal["gender"] ?? "",
          ),

          profileInfoRow(
            icon: Icons.access_time_outlined,
            title: "Joined On",
            value: personal["joinedOn"] ?? "",
          ),

          profileInfoRow(
            icon: Icons.language_outlined,
            title: "Location",
            value: personal["location"] ?? "",
          ),
        ],
      ),
    );
  }

  // ABOUT ME
  Widget buildAboutMe() {
    return profileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCardHeader(
            "About Me",
            isEditing: isEditingAbout,
            onEdit: () {
              setState(() {
                isEditingAbout = true;
              });
            },
            onUpdate: updateAboutMe,
            onCancel: cancelAboutMe,
          ),

          const Divider(),

          if (isEditingAbout) buildAboutEditForm() else buildAboutDisplay(),
        ],
      ),
    );
  }

  // ABOUT DISPLAY
  Widget buildAboutDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(height: 15),

        // Container(
        //   width: 55,
        //   height: 55,
        //   decoration: const BoxDecoration(
        //     shape: BoxShape.circle,
        //     color: Color(0xfffff2e8),
        //   ),
        //   child: const Icon(
        //     Icons.person_outline,
        //     color: Colors.orange,
        //     size: 30,
        //   ),
        // ),

        // const SizedBox(height: 25),

        // const Text(
        //   "Tell others about yourself and your business.",
        //   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        // ),
        const SizedBox(height: 15),

        // Divider(color: Colors.grey.shade200),

        // const SizedBox(height: 15),
        Text(
          about["description"] ?? "",
          style: const TextStyle(fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

  // ABOUT EDIT
  Widget buildAboutEditForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextField(
        controller: aboutController,
        maxLines: 7,
        decoration: InputDecoration(
          labelText: "About Me",
          hintText: "Tell others about yourself...",
          alignLabelWithHint: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // UPDATE ABOUT
  void updateAboutMe() {
    setState(() {
      about["description"] = aboutController.text.trim();
      isEditingAbout = false;
    });

    showUpdateMessage("About Me updated");
  }

  // CANCEL ABOUT
  void cancelAboutMe() {
    aboutController.text = about["description"] ?? "";

    setState(() {
      isEditingAbout = false;
    });
  }

  // BUSINESS INFORMATION
  Widget buildBusinessInformation() {
    return profileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCardHeader(
            "Business Information",
            isEditing: isEditingBusiness,
            onEdit: () {
              setState(() {
                isEditingBusiness = true;
              });
            },
            onUpdate: updateBusinessInformation,
            onCancel: cancelBusinessInformation,
          ),

          const Divider(),

          if (isEditingBusiness)
            buildBusinessEditForm()
          else
            buildBusinessDisplay(),
        ],
      ),
    );
  }

  // BUSINESS DISPLAY
  Widget buildBusinessDisplay() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          businessInfoRow(
            icon: Icons.storefront_outlined,
            title: "Shop / Business Name",
            value: business["shopName"] ?? "",
          ),

          businessInfoRow(
            icon: Icons.sell_outlined,
            title: "Business Type",
            value: business["businessType"] ?? "",
          ),

          businessInfoRow(
            icon: Icons.language_outlined,
            title: "Business Location",
            value: business["businessLocation"] ?? "",
          ),

          businessInfoRow(
            icon: Icons.info_outline,
            title: "Business Description",
            value: business["businessDescription"] ?? "",
          ),
        ],
      ),
    );
  }

  // BUSINESS EDIT
  Widget buildBusinessEditForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          buildInput(
            "Shop / Business Name",
            shopNameController,
            Icons.storefront_outlined,
          ),

          buildInput(
            "Business Type",
            businessTypeController,
            Icons.sell_outlined,
          ),

          buildInput(
            "Business Location",
            businessLocationController,
            Icons.language_outlined,
          ),

          TextField(
            controller: businessDescriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: "Business Description",
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateBusinessInformation() async {
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      showUpdateMessage('Please login first.');
      return;
    }

    final userId = int.tryParse(currentUser.id.toString()) ?? 0;
    if (userId == 0) {
      showUpdateMessage('Invalid user. Please login again.');
      return;
    }

    setState(() => _isLoadingProfile = true);

    try {
      await ProfileService(authService: authService).updateBusinessInfo(
        userId: userId,
        shopName: shopNameController.text.trim(),
        businessType: businessTypeController.text.trim(),
        businessLocation: businessLocationController.text.trim(),
        businessDescription: businessDescriptionController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        business['shopName'] = shopNameController.text.trim();
        business['businessType'] = businessTypeController.text.trim();
        business['businessLocation'] = businessLocationController.text.trim();
        business['businessDescription'] = businessDescriptionController.text
            .trim();
        isEditingBusiness = false;
        _isLoadingProfile = false;
      });

      showUpdateMessage('Business information updated');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingProfile = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  // CANCEL BUSINESS

  void cancelBusinessInformation() {
    shopNameController.text = business["shopName"] ?? "";
    businessTypeController.text = business["businessType"] ?? "";
    businessLocationController.text = business["businessLocation"] ?? "";
    businessDescriptionController.text = business["businessDescription"] ?? "";

    setState(() {
      isEditingBusiness = false;
    });
  }

  // INPUT FIELD
  Widget buildInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    String? hintText,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, size: 21),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // CARD
  Widget profileCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // CARD HEADER
  Widget buildCardHeader(
    String title, {
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onUpdate,
    required VoidCallback onCancel,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),

        if (!isEditing)
          OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(62, 34),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: 15),
                SizedBox(width: 5),
                Text(
                  "Edit",
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CANCEL
              OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(65, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                ),
              ),

              const SizedBox(width: 8),

              // UPDATE
              ElevatedButton(
                onPressed: onUpdate,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(65, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text("Update", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
      ],
    );
  }

  // PROFILE INFO ROW
  Widget profileInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 25, color: Colors.grey.shade600),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BUSINESS INFO ROW
  Widget businessInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade600),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(value, style: const TextStyle(fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ACCOUNT BADGE
  Widget accountBadge(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // SUCCESS MESSAGE
  void showUpdateMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

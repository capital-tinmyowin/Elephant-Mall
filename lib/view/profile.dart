import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'common/header.dart';
import 'common/footer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedMenu = 0;

  // PROFILE DATA
  Map<String, dynamic> profileData = {
    "personal": {
      "fullName": "Test User",
      "email": "user@example.com",
      "phone": "+95 9 123 456 789",
      "dateOfBirth": "May 12, 1995",
      "gender": "Female",
      "joinedOn": "Aug 10, 2022",
      "location": "Yangon, Myanmar",
      "accountTypes": ["Seller", "User", "Purchaser"],
    },
    "about": {
      "description":
          "I love fashion, lifestyle products, and finding high-quality items for everyday life.",
    },
    "business": {
      "shopName": "User's Collection",
      "businessType": "Individual Seller",
      "businessLocation": "Yangon, Myanmar",
      "businessDescription":
          "We offer carefully selected fashion and lifestyle products with great quality and customer service.",
    },
  };

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

  // IMAGE
  final ImagePicker _imagePicker = ImagePicker();

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
        setState(() {
          _profileImage = image;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unable to select image: $e")));
    }
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
                child: Image.asset(
                  "lib/uploads/logo.png",
                  height: 135,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 135,
                      color: const Color(0xffE5E5E5),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 45,
                        color: Colors.grey,
                      ),
                    );
                  },
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
                  alignment: isMobile ? Alignment.centerLeft : Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(left: isMobile ? 20 : 0),
                    child: buildProfileAvatar(),
                  ),
                ),
              ),

              // CAMERA BUTTON
              Positioned(right: 15, bottom: -5, child: buildCameraButton()),
            ],
          ),

          const SizedBox(height: 55),

          // USER INFO
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 10),
            child: Column(
              crossAxisAlignment: isMobile
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
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
              onTap: () {},
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
            ? kIsWeb
                  ? Image.network(_profileImage!.path, fit: BoxFit.cover)
                  : Image.file(File(_profileImage!.path), fit: BoxFit.cover)
            : Image.asset(
                "assets/avatar.jpg",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xffF5F5F5),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
      ),
    );
  }

  // CAMERA BUTTON

  Widget buildCameraButton() {
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
        onPressed: showImagePickerDialog,
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

                buildInput(
                  "Date of Birth",
                  dateOfBirthController,
                  Icons.calendar_month_outlined,
                ),

                buildInput(
                  "Gender",
                  genderController,
                  Icons.person_add_alt_outlined,
                ),

                buildInput(
                  "Joined On",
                  joinedOnController,
                  Icons.access_time_outlined,
                ),

                buildInput(
                  "Location",
                  locationController,
                  Icons.language_outlined,
                ),

                buildInput(
                  "Account Types",
                  accountTypesController,
                  Icons.sell_outlined,
                  hintText: "Seller, User, Purchaser",
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

                  Expanded(
                    child: buildInput(
                      "Date of Birth",
                      dateOfBirthController,
                      Icons.calendar_month_outlined,
                    ),
                  ),
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

                  Expanded(
                    child: buildInput(
                      "Gender",
                      genderController,
                      Icons.person_add_alt_outlined,
                    ),
                  ),
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

  // UPDATE PERSONAL
  void updatePersonalInformation() {
    final accountTypes = accountTypesController.text
        .split(",")
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    setState(() {
      personal["fullName"] = fullNameController.text.trim();
      personal["email"] = emailController.text.trim();
      personal["phone"] = phoneController.text.trim();
      personal["dateOfBirth"] = dateOfBirthController.text.trim();
      personal["gender"] = genderController.text.trim();
      personal["joinedOn"] = joinedOnController.text.trim();
      personal["location"] = locationController.text.trim();
      personal["accountTypes"] = accountTypes;

      isEditingPersonal = false;
    });

    showUpdateMessage("Personal information updated");
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
        const SizedBox(height: 15),

        Container(
          width: 55,
          height: 55,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xfffff2e8),
          ),
          child: const Icon(
            Icons.person_outline,
            color: Colors.orange,
            size: 30,
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          "Tell others about yourself and your business.",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 15),

        Divider(color: Colors.grey.shade200),

        const SizedBox(height: 15),

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

  // UPDATE BUSINESS
  void updateBusinessInformation() {
    setState(() {
      business["shopName"] = shopNameController.text.trim();
      business["businessType"] = businessTypeController.text.trim();
      business["businessLocation"] = businessLocationController.text.trim();
      business["businessDescription"] = businessDescriptionController.text
          .trim();

      isEditingBusiness = false;
    });

    showUpdateMessage("Business information updated");
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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

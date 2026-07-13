import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../services/product_service.dart';
import '../models/Category.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class ProductVariant {
  String variantName;
  String sku;
  double variant_Price;

  ProductVariant({
    required this.variantName,
    required this.sku,
    required this.variant_Price,
  });
}

class _SellPageState extends State<SellPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final skuController = TextEditingController();
  final qtyController = TextEditingController();

  final phoneController = TextEditingController();
  final messengerController = TextEditingController();
  final telegramController = TextEditingController();
  final viberController = TextEditingController();

  bool telegramVisible = false;
  bool viberVisible = false;

  List<Category> categories = [];
  List<int> selectedCategoryIds = [];
  List<ProductVariant> variants = [];
  List<Uint8List?> images = List.generate(10, (_) => null);
  final ImagePicker picker = ImagePicker();

  String? titleError;
  String? descriptionError;
  String? priceError;
  String? skuError;
  String? qtyError;
  String? phoneError;
  String? messengerError;
  String? categoryError;

  final _variantFormKey = GlobalKey<FormState>();

  final ProductService productService = ProductService();
  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final result = await productService.getCategories();

      setState(() {
        categories = result;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _imageBox(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: images[index] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                images[index]!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          : const Center(child: Icon(Icons.image, color: Colors.grey)),
    );
  }

  Future<void> pickImageFromButton() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Take Photo"),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);

                  final pickedImages = await picker.pickMultiImage();

                  for (final image in pickedImages) {
                    await _addImage(image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addImage(XFile image) async {
    final bytes = await image.readAsBytes();

    setState(() {
      int emptyIndex = images.indexWhere((img) => img == null);

      if (emptyIndex != -1) {
        images[emptyIndex] = bytes;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum number of photos reached')),
        );
      }
    });
  }

  void syncPhoneToField({
    required bool enabled,
    required TextEditingController targetController,
  }) {
    if (enabled) {
      targetController.text = phoneController.text;
    }
  }

  Widget _contactField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required bool sameAsPhone,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        /// ICON (outside input)
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black87),
        ),

        const SizedBox(width: 10),

        /// INPUT
        Expanded(
          child: TextField(controller: controller, decoration: _input(hint)),
        ),

        const SizedBox(width: 10),

        /// CHECKBOX + TEXT (RIGHT SIDE)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(value: sameAsPhone, onChanged: onChanged),
            const Text("Same as Phone"),
          ],
        ),
      ],
    );
  }

  Widget buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: isMobile
          ? Column(
              children: [
                const SizedBox(height: 10),

                /// TOP ROW
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.menu), onPressed: () {}),

                    const Spacer(),

                    const Icon(Icons.person_outline),
                    const SizedBox(width: 10),
                    const Icon(Icons.favorite_border),
                    const SizedBox(width: 10),
                    const Icon(Icons.shopping_cart_outlined),
                  ],
                ),

                const SizedBox(height: 10),

                /// SEARCH BAR
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search in Elephant Mall",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD09A56),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "SELL ITEMS",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            )
          : SizedBox(
              height: 70,
              child: Row(
                children: [
                  Wrap(
                    spacing: 15,
                    children: [
                      _menuItem("HOME"),
                      _menuItem("CATEGORIES"),
                      _menuItem("SALE"),
                      _menuItem("NEW IN"),
                      _menuItem("MY ORDERS"),
                      _menuItem("ABOUT US"),
                    ],
                  ),

                  const Spacer(),

                  SizedBox(
                    width: 320,
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search in Elephant Mall",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD09A56),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "SELL ITEMS",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Icon(Icons.person_outline),
                  const SizedBox(width: 15),

                  const Icon(Icons.favorite_border),
                  const SizedBox(width: 15),

                  const Icon(Icons.shopping_cart_outlined),
                ],
              ),
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

  Widget buildFooter() {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _footerColumn("CUSTOMER CARE", ["Home"])),

          Expanded(child: _footerColumn("ABOUT US", ["About Us"])),

          Expanded(child: _footerColumn("CONNECT WITH US", ["Contact Us"])),

          Expanded(child: _footerColumn("LEGAL", ["Legal"])),

          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              // child: Text(
              //   "Copyright © 2022 Connent on convent Limited",
              //   style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              // ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(e),
          ),
        ),
      ],
    );
  }

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  bool isSmallPhotoLayout(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  Future<void> showAddVariantDialog() async {
    final variantController = TextEditingController();
    final skuController = TextEditingController();
    final priceController = TextEditingController();

    bool _variantSubmitted = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Product Variant"),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _variantFormKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: variantController,
                    decoration: const InputDecoration(
                      labelText: "Variant Name",
                    ),

                    validator: (value) {
                      if (!_variantSubmitted) return null;

                      if (value == null || value.trim().isEmpty) {
                        return "Please enter variant name";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: skuController,
                    decoration: const InputDecoration(labelText: "SKU"),

                    validator: (value) {
                      if (!_variantSubmitted) return null;

                      if (value == null || value.trim().isEmpty) {
                        return "Please enter SKU";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: priceController,

                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),

                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}$'),
                      ),
                    ],

                    decoration: const InputDecoration(labelText: "Price"),

                    validator: (value) {
                      if (!_variantSubmitted) return null;

                      if (value == null || value.trim().isEmpty) {
                        return "Please enter Price";
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _variantSubmitted = true;
                });

                if (!_variantFormKey.currentState!.validate()) {
                  return;
                }

                setState(() {
                  variants.add(
                    ProductVariant(
                      variantName: variantController.text.trim(),
                      sku: skuController.text.trim(),
                      variant_Price: double.parse(priceController.text),
                    ),
                  );
                });
                  _variantSubmitted = false;

                variantController.clear();
                skuController.clear();
                priceController.clear();

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget buildVariantTable() {
    if (variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 220, // Max height for the table
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: SizedBox(width: 180, child: Text("Variant"))),
              DataColumn(label: SizedBox(width: 120, child: Text("SKU"))),
              DataColumn(label: SizedBox(width: 100, child: Text("Price"))),
              DataColumn(label: SizedBox(width: 70, child: Text("Action"))),
            ],
            rows: List.generate(variants.length, (index) {
              final item = variants[index];

              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 180,
                      child: Tooltip(
                        message: item.variantName,
                        child: Text(
                          item.variantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),

                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Tooltip(
                        message: item.sku,
                        child: Text(
                          item.sku,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),

                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Text(item.variant_Price.toStringAsFixed(0)),
                    ),
                  ),

                  DataCell(
                    SizedBox(
                      width: 70,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            variants.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  width: 1200,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      /// TITLE
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              "Create Your Listing",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3C6E2A),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Start Selling in Yangon",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// MAIN LAYOUT
                      isMobile(context)
                          ? Column(
                              children: [
                                _leftSection(),
                                const SizedBox(height: 20),
                                _rightSection(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: _leftSection()),
                                const SizedBox(width: 80),
                                Expanded(flex: 5, child: _rightSection()),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (!isMobile(context)) buildFooter(),
        ],
      ),
    );
  }

  /// ================= LEFT SIDE =================
  Widget _leftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Photos (Up to 10 Photos)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        isSmallPhotoLayout(context)
            ? Column(
                children: [
                  SizedBox(
                    height: 160,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: List.generate(
                              5,
                              (index) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: _imageBox(index),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Expanded(
                          child: Row(
                            children: List.generate(
                              5,
                              (index) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: _imageBox(index + 5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: GestureDetector(
                      onTap: pickImageFromButton,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7D1A8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Colors.brown,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Add Photos",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: 160,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: List.generate(
                                5,
                                (index) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: _imageBox(index),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Expanded(
                            child: Row(
                              children: List.generate(
                                5,
                                (index) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: _imageBox(index + 5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 160,
                        child: DottedBorder(
                          color: Colors.brown,
                          strokeWidth: 2,
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(8),
                          dashPattern: const [6, 4],
                          child: GestureDetector(
                            onTap: pickImageFromButton,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7D1A8), // FULL FILL NOW
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 32,
                                    color: Colors.brown,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Add Photos",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

        const SizedBox(height: 10),

        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open, color: Colors.amber.shade700, size: 22),
              const SizedBox(width: 8),
              const Text(
                "Upload from Gallery",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Item Title",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: titleController,
              maxLength: 200,
              onChanged: (value) {
                if (value.trim().isNotEmpty && titleError != null) {
                  setState(() {
                    titleError = null;
                  });
                }
              },
              decoration: _input("Enter item title", errorText: titleError),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Suggected Category",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,

                itemBuilder: (context, index) {
                  final category = categories[index];

                  final isSelected = selectedCategoryIds.contains(
                    category.categoryId,
                  );

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        categoryError = null;

                        if (isSelected) {
                          selectedCategoryIds.remove(category.categoryId);
                        } else {
                          if (selectedCategoryIds.length >= 3) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange,
                                        size: 30,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Maximum Reached"),
                                    ],
                                  ),
                                  content: const Text(
                                    "You can select up to 3 categories only.",
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          selectedCategoryIds.add(category.categoryId);
                        }
                      });
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2F6B2F)
                            : const Color.fromARGB(255, 174, 246, 174),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2F6B2F)
                              : const Color(0xFFB7DDBA),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 7,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  category.photoPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image, size: 40),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                category.categoryName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        if (categoryError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 8),
            child: Text(
              categoryError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        const SizedBox(height: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Product Description",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: descriptionController,
              maxLines: 5,
              onChanged: (value) {
                if (value.trim().isNotEmpty && descriptionError != null) {
                  setState(() {
                    descriptionError = null;
                  });
                }
              },
              decoration: _input(
                "Describe your item",
                errorText: descriptionError,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ================= RIGHT SIDE =================
  Widget _rightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Price",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                if (value.trim().isNotEmpty && priceError != null) {
                  setState(() {
                    priceError = null;
                  });
                }
              },
              decoration: _input("Price in Kyats", errorText: priceError),
            ),
          ],
        ),

        const SizedBox(height: 10),

        TextField(
          controller: skuController,
          enabled: variants.isEmpty,
          decoration: _input("SKU (Optional)", errorText: skuError),
        ),

        const SizedBox(height: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Product Variants",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: showAddVariantDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add Variant"),
            ),

            const SizedBox(height: 15),

            buildVariantTable(),
          ],
        ),

        const SizedBox(height: 10),

        const Text(
          "Inventory (Stock)",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  if (value.trim().isNotEmpty && qtyError != null) {
                    setState(() {
                      qtyError = null;
                    });
                  }
                },
                decoration: _input("Qty", errorText: qtyError),
              ),
            ),

            const SizedBox(width: 10),

            IconButton(
              onPressed: () {
                int qty = int.tryParse(qtyController.text) ?? 0;

                if (qty > 0) {
                  qty--;
                  qtyController.text = qty.toString();
                }
              },
              icon: const Icon(Icons.remove),
            ),

            IconButton(
              onPressed: () {
                int qty = int.tryParse(qtyController.text) ?? 0;

                qty++;

                qtyController.text = qty.toString();
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        const SizedBox(height: 10),

        const Text(
          "Byer Contact Methods",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 10),

        const Text(
          "Phone Number",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.trim().isNotEmpty && phoneError != null) {
              setState(() {
                phoneError = null;
              });
            }
          },
          decoration: _input("Phone Number", errorText: phoneError),
        ),

        const SizedBox(height: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Telegram",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.telegram,
                    color: Color(0xFF229ED9),
                    size: 22,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: telegramController,
                    decoration: _input("Telegram Username"),
                  ),
                ),

                const SizedBox(width: 10),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: telegramVisible,
                      onChanged: (value) {
                        setState(() {
                          telegramVisible = value ?? false;

                          if (telegramVisible) {
                            telegramController.text = phoneController.text;
                          }
                        });
                      },
                    ),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          telegramVisible = !telegramVisible;

                          if (telegramVisible) {
                            telegramController.text = phoneController.text;
                          }
                        });
                      },
                      child: const Text("Same as Phone"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 6),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Viber", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),

            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.viber,
                    color: Color(0xFF7360F2),
                    size: 22,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: viberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _input("Viber Number"),
                  ),
                ),

                const SizedBox(width: 10),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: viberVisible,
                      onChanged: (value) {
                        setState(() {
                          viberVisible = value ?? false;

                          if (viberVisible) {
                            viberController.text = phoneController.text;
                          }
                        });
                      },
                    ),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          viberVisible = !viberVisible;

                          if (viberVisible) {
                            viberController.text = phoneController.text;
                          }
                        });
                      },
                      child: const Text("Same as Phone"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Messenger",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                /// ICON
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.facebookMessenger,
                    color: Color(0xFF0084FF),
                    size: 22,
                  ),
                ),

                const SizedBox(width: 10),

                /// INPUT ONLY
                Expanded(
                  child: TextField(
                    controller: messengerController,
                    decoration: _input(
                      "Messenger Link",
                      errorText: messengerError,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC77C2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () async {
              setState(() {
                titleError = null;
                descriptionError = null;
                priceError = null;
                skuError = null;
                qtyError = null;
                phoneError = null;
                messengerError = null;
                categoryError = null;
              });

              if (titleController.text.trim().isEmpty) {
                setState(() {
                  titleError = "Item title is required.";
                });
                return;
              }
              if (titleController.text.characters.length > 200) {
                setState(() {
                  titleError = "Maximum 200 characters.";
                });
                return;
              }

              if (selectedCategoryIds.isEmpty) {
                setState(() {
                  categoryError = "Please select at least one category.";
                });
                return;
              }

              if (descriptionController.text.trim().isEmpty) {
                setState(() {
                  descriptionError = "Description is required.";
                });
                return;
              }

              if (descriptionController.text.characters.length > 500) {
                setState(() {
                  descriptionError = "Maximum 500 characters.";
                });
                return;
              }

              if (priceController.text.trim().isEmpty) {
                setState(() {
                  priceError = "Price is required.";
                });
                return;
              }

              if (qtyController.text.trim().isEmpty ||
                  (int.tryParse(qtyController.text) ?? 0) <= 0) {
                setState(() {
                  qtyError = "Quantity is required.";
                });
                return;
              }

              if (skuController.text.characters.length > 500) {
                setState(() {
                  skuError = "Maximum 500 characters.";
                });
                return;
              }

              if (phoneController.text.trim().isEmpty) {
                setState(() {
                  phoneError = "Phone number is required.";
                });
                return;
              }

              if (messengerController.text.characters.length > 300) {
                setState(() {
                  messengerError = "Maximum 300 characters.";
                });
                return;
              }

              bool success = await productService.createProduct(
                title: titleController.text,
                description: descriptionController.text,
                price: priceController.text,
                sku: skuController.text,
                quantity: qtyController.text,
                phoneNumber: phoneController.text,
                messengerLink: messengerController.text,
                telegram: telegramController.text,
                viber: viberController.text,
                images: images,
              );

              if (!mounted) return;

              if (success) {
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 30),
                        SizedBox(width: 10),
                        Text("Success"),
                      ],
                    ),
                    content: const Text("Product created successfully."),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );

                titleController.clear();
                descriptionController.clear();
                priceController.clear();
                skuController.clear();
                qtyController.clear();
                phoneController.clear();
                messengerController.clear();
                telegramController.clear();
                viberController.clear();

                setState(() {
                  images = List.generate(10, (_) => null);
                  selectedCategoryIds.clear();
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to create product')),
                );
              }
            },
            child: const Text(
              "POST YOUR LISTING",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _input(String hint, {String? errorText}) {
    return InputDecoration(
      hintText: hint,

      errorText: errorText,

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: errorText == null ? Colors.grey : Colors.red,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: errorText == null ? Colors.green : Colors.red,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

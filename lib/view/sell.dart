import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../services/product_service.dart';
import '../models/Category.dart';
import '../models/product_variant.dart';
import '../models/sell_product_model.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'common/header.dart';
import 'common/footer.dart';

class SellPage extends StatefulWidget {
  final int? productCode;

  const SellPage({super.key, this.productCode});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _VariantDialog extends StatefulWidget {
  final ProductVariant? existingVariant;
  final bool isEdit;

  const _VariantDialog({this.existingVariant, required this.isEdit});

  @override
  State<_VariantDialog> createState() => _VariantDialogState();
}

class _VariantDialogState extends State<_VariantDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController variantController;
  late final TextEditingController variantqtyController;
  late final TextEditingController variantpriceController;

  @override
  void initState() {
    super.initState();

    variantController = TextEditingController();
    variantqtyController = TextEditingController();
    variantpriceController = TextEditingController();

    // If editing an existing variant, load its values.
    if (widget.existingVariant != null) {
      final item = widget.existingVariant!;

      variantController.text = item.variantName;
      variantqtyController.text = item.quantity.toStringAsFixed(0);
      variantpriceController.text = item.price.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    variantController.dispose();
    variantqtyController.dispose();
    variantpriceController.dispose();

    super.dispose();
  }

  void saveVariant() {
    // Validate form.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(variantpriceController.text.trim());

    final quantity = double.tryParse(variantqtyController.text.trim());

    if (price == null || quantity == null) {
      return;
    }

    final variant = ProductVariant(
      variantName: variantController.text.trim(),
      quantity: quantity,
      price: price,
    );

    // Return the variant to SellPage.
    Navigator.pop(context, variant);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xfffdfaf4),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      titlePadding: EdgeInsets.zero,

      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

        decoration: const BoxDecoration(
          color: Color(0xFFC77C2E),

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 28,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                widget.isEdit ? "Edit Product Variant" : "Add Product Variant",

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

      content: SizedBox(
        width: 400,

        child: Form(
          key: _formKey,

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // VARIANT NAME
              TextFormField(
                controller: variantController,

                decoration: const InputDecoration(
                  labelText: "Variant Name",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter variant name";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // PRICE
              TextFormField(
                controller: variantpriceController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],

                decoration: const InputDecoration(
                  labelText: "Price",
                  suffixText: "Ks",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter Price";
                  }

                  final price = double.tryParse(value.trim());

                  if (price == null) {
                    return "Please enter a valid price";
                  }

                  if (price <= 0) {
                    return "Price must be greater than 0";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // QUANTITY
              TextFormField(
                controller: variantqtyController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],

                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter Quantity";
                  }

                  final quantity = double.tryParse(value.trim());

                  if (quantity == null) {
                    return "Please enter a valid quantity";
                  }

                  if (quantity <= 0) {
                    return "Quantity must be greater than 0";
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),

      actions: [
        // CANCEL
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },

          child: const Text("Cancel"),
        ),

        // SAVE / UPDATE
        ElevatedButton(
          onPressed: saveVariant,

          child: Text(widget.isEdit ? "Update" : "Save"),
        ),
      ],
    );
  }
}

class _SellPageState extends State<SellPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final skuController = TextEditingController();
  final qtyController = TextEditingController();
  // final variantqtyController = TextEditingController();
  // final variantpriceController = TextEditingController();

  final locationController = TextEditingController();
  final phoneController = TextEditingController();
  final messengerController = TextEditingController();
  final telegramController = TextEditingController();
  final viberController = TextEditingController();

  List<BuyerContactMethod> buyerContactMethods = [];

  BuyerContactMethod? selectedBuyerContactMethod;

  bool isLoadingBuyerMethods = false;
  bool isLoadingBuyerDetail = false;

  bool isNewBuyerMethod = false;

  bool isSubmitting = false;

  bool telegramVisible = false;
  bool viberVisible = false;

  bool agreedToTerms = false;

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

  final ProductService productService = ProductService();
  @override
  void initState() {
    super.initState();

    // Always load categories.
    loadCategories();
    loadBuyerContactMethods();

    // Only load product data when productCode is provided.
    if (widget.productCode != null) {
      loadProduct(widget.productCode!);
    }
  }

  void loadProduct(int productCode) {
    final SellProductModel? product = productService.getSellProductByCode(
      productCode,
    );

    // Product code was provided but product was not found.
    if (product == null) {
      debugPrint('Product not found for product code: $productCode');
      return;
    }

    debugPrint('Product found: ${product.productCode}');

    // BIND TEXT FIELDS

    titleController.text = product.title;

    descriptionController.text = product.description;

    priceController.text = product.price;

    skuController.text = product.sku;

    qtyController.text = product.quantity;

    locationController.text = product.location;

    phoneController.text = product.phoneNumber;

    messengerController.text = product.messengerLink;

    telegramController.text = product.telegram;

    viberController.text = product.viber;

    // BIND CATEGORIES + VARIANTS

    setState(() {
      selectedCategoryIds = List<int>.from(product.categoryIds);

      variants = List<ProductVariant>.from(product.variants);

      // Show Telegram if data exists.
      telegramVisible = product.telegram.trim().isNotEmpty;

      // Show Viber if data exists.
      viberVisible = product.viber.trim().isNotEmpty;
    });
  }

  void _removeImage(int index) {
    setState(() {
      images[index] = null;
    });
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

  Future<void> loadBuyerContactMethods() async {
    try {
      setState(() {
        isLoadingBuyerMethods = true;
      });

      final methods = await productService.getBuyerContactMethods();

      if (!mounted) return;

      setState(() {
        buyerContactMethods = methods;
        isLoadingBuyerMethods = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingBuyerMethods = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load buyer contact methods: $e')),
      );
    }
  }

  Future<void> onBuyerContactMethodSelected(BuyerContactMethod? method) async {
    if (method == null) {
      setState(() {
        selectedBuyerContactMethod = null;
      });
      return;
    }

    setState(() {
      selectedBuyerContactMethod = method;
      isNewBuyerMethod = false;
      isLoadingBuyerDetail = true;
    });

    try {
      final detail = await productService.getBuyerContactDetail(
        method.methodId,
      );

      if (!mounted) return;

      setState(() {
        locationController.text = detail.location;
        phoneController.text = detail.phoneNumber;
        telegramController.text = detail.telegram;
        viberController.text = detail.viber;
        messengerController.text = detail.messenger;

        isLoadingBuyerDetail = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingBuyerDetail = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load buyer contact: $e')),
      );
    }
  }

  Widget _imageBox(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: images[index] != null
          ? Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(images[index]!, fit: BoxFit.cover),
                  ),
                ),

                /// Remove button
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => _removeImage(index),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
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
            const Text("Same as Ph"),
          ],
        ),
      ],
    );
  }

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  bool isSmallPhotoLayout(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;
  Future<void> showAddVariantDialog({int? editIndex}) async {
    final ProductVariant? updatedVariant = await showDialog<ProductVariant>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xfffdfaf4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFC77C2E), 
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  "Add Product Variant",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
                  // variants.add(
                  //   ProductVariant(
                  //     variantName: variantController.text.trim(),
                  //     sku: skuController.text.trim(),
                  //     variant_Price: double.parse(priceController.text),
                  //   ),
                  // );
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

    // User pressed Cancel or closed the dialog.
    if (updatedVariant == null) {
      return;
    }

    // Make sure SellPage is still mounted.
    if (!mounted) {
      return;
    }

    // Update the parent list AFTER the dialog has closed.
    setState(() {
      if (editIndex == null) {
        variants.add(updatedVariant);
      } else {
        variants[editIndex] = updatedVariant;
      }
    });
  }

  Widget buildVariantTable() {
    if (variants.isEmpty) {
      return const SizedBox.shrink();
    }

    const double rowHeight = 56;
    const double headingHeight = 56;
    const int maxVisibleRows = 3;

    final double tableHeight =
        headingHeight +
        (variants.length > maxVisibleRows
            ? rowHeight * maxVisibleRows
            : rowHeight * variants.length);

    return SizedBox(
      height: tableHeight,
      child: Scrollbar(
        thumbVisibility: variants.length > maxVisibleRows,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: headingHeight,
              dataRowMinHeight: rowHeight,
              dataRowMaxHeight: rowHeight,
              columnSpacing: 20,

              // Table + cell borders
              border: TableBorder.all(color: Colors.grey.shade400, width: 1),

              columns: const [
                // VARIANT HEADER
                DataColumn(
                  label: SizedBox(
                    width: 180,
                    child: Center(child: Text("Variant")),
                  ),
                ),

                // QUANTITY HEADER
                DataColumn(
                  label: SizedBox(
                    width: 100,
                    child: Center(child: Text("Quantity")),
                  ),
                ),

                // PRICE HEADER
                DataColumn(
                  numeric: true,
                  label: SizedBox(
                    width: 120,
                    child: Center(child: Text("Price")),
                  ),
                ),

                // ACTION HEADER
                DataColumn(
                  label: SizedBox(
                    width: 100,
                    child: Center(
                      child: Text(
                        'Action',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],

              rows: List.generate(variants.length, (index) {
                final item = variants[index];

                return DataRow(
                  cells: [
                    // Variant
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Text(
                          item.variantName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // DataCell(
                    //   SizedBox(
                    //     width: 120,
                    //     child: Text(item.sku, overflow: TextOverflow.ellipsis),
                    //   ),
                    // ),
                    // DataCell(
                    //   SizedBox(
                    //     width: 100,
                    //     child: Text(item.variant_Price.toStringAsFixed(0)),
                    //   ),
                    // ),
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                tooltip: 'Edit',
                                onPressed: () {
                                  showAddVariantDialog(editIndex: index);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                tooltip: 'Delete',
                                onPressed: () {
                                  setState(() {
                                    variants.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xfffdfaf4), Color(0xfff7edd9)],
          ),
        ),
        child: Column(
          children: [
            const CommonHeader(),

            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: 1500,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        /// TITLE
                        /// TITLE
                        Center(
                          child: Column(
                            children: [
                              Text(
                                widget.productCode != null
                                    ? "Edit Your Listing"
                                    : "Create Your Listing",
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3C6E2A),
                                ),
                              ),

                              const SizedBox(height: 5),

                              const Text(
                                "Start Selling in Yangon",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 5),

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
                                  const SizedBox(width: 120),
                                  Expanded(flex: 5, child: _rightSection()),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (!isMobile(context)) const CommonFooter(),
          ],
        ),
      ),
      bottomNavigationBar: isMobile(context)
          ? CommonBottomBar(currentIndex: 2)
          : null,
    );
  }

  // LEFT SIDE 
  Widget _leftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Product Photos ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: "(Up to 10 Photos)",
                style: TextStyle(
                  fontSize: 18, // Smaller
                  fontWeight: FontWeight.w400,
                  color: Colors.black, // Different color
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5),

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
                                color: const Color(0xFFE7D1A8),
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

        const SizedBox(height: 15),

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

        const SizedBox(height: 5),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Item Title",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: " (e.g., Silk Longyi or Teak Bowl)",
                    style: TextStyle(
                      fontSize: 18, // Smaller
                      fontWeight: FontWeight.w400,
                      color: Colors.black, // Different color
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

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
              decoration: _input(
                "ပစ္စည်းအမည် (ဥပမာ - ပိုးလုံချည် သို့မဟုတ် ကျွန်းပန်းကန်)",
                errorText: titleError,
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Myanmar Crafts & Daily Goods",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: " (Suggected Categories)",
                    style: TextStyle(
                      fontSize: 18, // Smaller
                      fontWeight: FontWeight.w400,
                      color: Colors.black, // Different color
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

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
                                  backgroundColor: const Color(0xfffdfaf4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  titlePadding: EdgeInsets.zero,

                                  title: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(
                                        0xFF3C6E2A,
                                      ), // Same green as header
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Maximum Reached",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  content: const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      "You can select up to 3 categories only.",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),

                                  actionsPadding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    20,
                                  ),

                                  actions: [
                                    SizedBox(
                                      width: 100,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFC77C2E,
                                          ), // Gold
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "OK",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
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

        const SizedBox(height: 5),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Product Description",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
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
                "Describe your item. (Material, Condition, Size, etc.)\n"
                "သင့်ပစ္စည်းအကြောင်းဖော်ပြပါ။ (ပစ္စည်း၊ အခြေအနေ၊ အရွယ်အစား စသည်)",
                errorText: descriptionError,
              ),
            ),

            const SizedBox(height: 10),

            /// LOCATION
            const Text(
              "Location",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: locationController,
              maxLength: 200,
              decoration: _input(
                "Enter your location (e.g., Yangon, Mandalay)",
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }

  /// RIGHT SIDE 
  Widget _rightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Price",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _input(
                "Enter Price",
                errorText: priceError,
                suffixText: "Ks",
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        const Text(
          "SKU",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: skuController,
          enabled: variants.isEmpty,
          decoration: _input("SKU (Optional)", errorText: skuError),
        ),

        const SizedBox(height: 10),

        const Text(
          "Inventory (Stock)",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: qtyController,
                enabled: variants.isEmpty,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  if (value.trim().isNotEmpty && qtyError != null) {
                    setState(() {
                      qtyError = null;
                    });
                  }
                },
                decoration: _input(
                  variants.isNotEmpty ? "Qty is managed by variants" : "Qty",
                  errorText: qtyError,
                ),
              ),
            ),

            const SizedBox(width: 10),

            IconButton(
              onPressed: variants.isEmpty
                  ? () {
                      int qty = int.tryParse(qtyController.text) ?? 0;

                      if (qty > 0) {
                        qty--;
                        qtyController.text = qty.toString();
                      }
                    }
                  : null,
              icon: const Icon(Icons.remove),
            ),

            IconButton(
              onPressed: variants.isEmpty
                  ? () {
                      int qty = int.tryParse(qtyController.text) ?? 0;

                      qty++;
                      qtyController.text = qty.toString();
                    }
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Product Variants",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () {
                showAddVariantDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Variant"),
            ),

            const SizedBox(height: 5),

            buildVariantTable(),
          ],
        ),

        const SizedBox(height: 10),

        const Text(
          "Buyer Contact Method",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 6),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // BUYER CONTACT METHOD DROPDOWN
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xffFDF7ED),
                      border: Border.all(color: const Color(0xffD8D8D8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),

                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<BuyerContactMethod>(
                        value: selectedBuyerContactMethod,
                        isExpanded: true,

                        hint: const Text(
                          "Select Buyer Contact Method",
                          overflow: TextOverflow.ellipsis,
                        ),

                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),

                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),

                        dropdownColor: Colors.white,

                        items: buyerContactMethods.map((method) {
                          return DropdownMenuItem<BuyerContactMethod>(
                            value: method,
                            child: Text(
                              method.methodName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),

                        onChanged: isLoadingBuyerMethods
                            ? null
                            : onBuyerContactMethodSelected,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 15),

            // NEW BUYER METHOD
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: isNewBuyerMethod,
                  onChanged: (value) {
                    final newValue = value ?? false;

                    setState(() {
                      isNewBuyerMethod = newValue;

                      if (newValue) {
                        // CLEAR SELECTED BUYER CONTACT METHOD
                        selectedBuyerContactMethod = null;

                        // CLEAR CONTACT INFORMATION
                        locationController.clear();
                        phoneController.clear();
                        telegramController.clear();
                        viberController.clear();
                        messengerController.clear();

                        // RESET OPTIONAL CONTACT CHECKBOXES
                        telegramVisible = false;
                        viberVisible = false;

                        // Detail loading is no longer needed
                        isLoadingBuyerDetail = false;
                      }
                    });
                  },
                ),

                const Text(
                  "New Buyer Method",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        const Text(
          "Phone Number",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
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
                      child: const Text(
                        "Same as Ph",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
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
            const Text(
              "Viber",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
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
                      child: const Text(
                        "Same as Ph",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
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
            onPressed: isSubmitting
                ? null
                : () async {
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

                    // Validate inventory quantity
                    if (variants.isEmpty) {
                      // No variants → normal inventory quantity is required
                      if (qtyController.text.trim().isEmpty ||
                          (int.tryParse(qtyController.text) ?? 0) <= 0) {
                        setState(() {
                          qtyError = "Quantity is required.";
                        });
                        return;
                      }
                    } else {
                      // Variants exist → main inventory quantity is not required.
                      // Validate each variant quantity instead.
                      final hasInvalidVariantQuantity = variants.any(
                        (variant) => variant.quantity <= 0,
                      );

                      if (hasInvalidVariantQuantity) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Each variant must have a quantity greater than 0.",
                            ),
                          ),
                        );
                        return;
                      }
                    }

                    if (skuController.text.characters.length > 500) {
                      setState(() {
                        skuError = "Maximum 500 characters.";
                      });
                      return;
                    }

                    if (locationController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Location is required.')),
                      );
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

                    setState(() {
                      isSubmitting = true;
                    });

                    ProductApiResponse? apiResponse;
                    bool success = false;
                    try {
                      if (widget.productCode != null) {
                        success = await productService.updateProduct(
                          productCode: widget.productCode!,
                          productName: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          location: locationController.text.trim(),
                          price:
                              double.tryParse(priceController.text.trim()) ?? 0,
                          quantity:
                              int.tryParse(qtyController.text.trim()) ?? 0,
                          condition: 'New',
                          status: 'Active',
                          businessContactGroupId: 1,
                          categoryIds: selectedCategoryIds,
                          variants: variants,
                          images: [],
                          businessContacts: [
                            if (telegramVisible &&
                                telegramController.text.trim().isNotEmpty)
                              {
                                'type': 'Telegram',
                                'value': telegramController.text.trim(),
                                'isPrimary': true,
                                'groupId': 2,
                              },

                            if (viberVisible &&
                                viberController.text.trim().isNotEmpty)
                              {
                                'type': 'Viber',
                                'value': viberController.text.trim(),
                                'isPrimary': false,
                                'groupId': 2,
                              },

                            if (phoneController.text.trim().isNotEmpty)
                              {
                                'type': 'Phone',
                                'value': phoneController.text.trim(),
                                'isPrimary': false,
                                'groupId': 2,
                              },

                            if (messengerController.text.trim().isNotEmpty)
                              {
                                'type': 'Messenger',
                                'value': messengerController.text.trim(),
                                'isPrimary': false,
                                'groupId': 2,
                              },
                          ],
                        );
                      } else {
                        apiResponse = await productService.createProduct(
                          productCode:
                              'ELE-${DateTime.now().millisecondsSinceEpoch}',
                          productName: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          location: locationController.text.trim(),
                          price:
                              double.tryParse(priceController.text.trim()) ?? 0,
                          quantity:
                              int.tryParse(qtyController.text.trim()) ?? 0,
                          condition: 'New',
                          status: 'Active',
                          businessContactGroupId: 1,
                          categoryIds: selectedCategoryIds,
                          variants: variants,
                          images: [],

                          // Contacts
                          businessContacts: [
                            if (telegramVisible &&
                                telegramController.text.trim().isNotEmpty)
                              {
                                'type': 'Telegram',
                                'value': telegramController.text.trim(),
                                'isPrimary': true,
                                'groupId': 2,
                              },

                            if (viberVisible &&
                                viberController.text.trim().isNotEmpty)
                              {
                                'type': 'Viber',
                                'value': viberController.text.trim(),
                                'isPrimary': false,
                                'groupId': 2,
                              },

                            if (phoneController.text.trim().isNotEmpty)
                              {
                                'type': 'Phone',
                                'value': phoneController.text.trim(),
                                'isPrimary': false,
                                'groupId': 2,
                              },

                            if (messengerController.text.trim().isNotEmpty)
                              {
                                'type': 'Messenger',
                                'value': messengerController.text.trim(),
                                'isPrimary': false,
                                'groupId': 2,
                              },
                          ],
                        );
                      }
                    } catch (e) {
                      debugPrint("Submit error: $e");

                      apiResponse = ProductApiResponse(
                        success: false,
                        message: e.toString(),
                      );
                    }
                    if (!mounted) return;

                    setState(() {
                      isSubmitting = false;
                    });

                    if (apiResponse?.success == true) {
                      await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          title: const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Text("Success"),
                            ],
                          ),
                          content: Text(
                            widget.productCode != null
                                ? "Product updated successfully."
                                : "Product created successfully.",
                          ),
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
                      locationController.clear();

                      setState(() {
                        images = List.generate(10, (_) => null);
                        selectedCategoryIds.clear();
                        variants.clear();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to create product'),
                        ),
                      );
                    }
                  },

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.productCode != null
                      ? "UPDATE YOUR LISTING"
                      : "POST YOUR LISTING",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 1),
                const Text(
                  "သင့်ပစ္စည်းကိုတင်ပါ။",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: agreedToTerms,
                onChanged: (value) {
                  setState(() {
                    agreedToTerms = value ?? false;
                  });
                },
              ),

              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: "By posting, you agree to our "),
                    TextSpan(
                      text: "Terms & Conditions",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: "."),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _input(String hint, {String? errorText, String? suffixText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,

      hintStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black,
        height: 1.4,
      ),

      suffixIcon: suffixText == null
          ? null
          : Container(
              width: 55,
              decoration: const BoxDecoration(
                color: Color.fromARGB(
                  255,
                  181,
                  179,
                  179,
                ), // Background only for Ks
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                suffixText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

      suffixIconConstraints: const BoxConstraints(minWidth: 45, minHeight: 45),

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

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SellerItemWidget extends StatefulWidget {
  final String title;
  final int price;
  final double rating;
  final String description;
  final String image;

  final Function(Map<String, dynamic>)? onUpdate;
  final VoidCallback? onDelete;

  const SellerItemWidget({
    super.key,
    required this.title,
    required this.price,
    required this.rating,
    required this.description,
    required this.image,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<SellerItemWidget> createState() => _SellerItemWidgetState();
}

class _SellerItemWidgetState extends State<SellerItemWidget> {
  late String currentTitle;
  late int currentPrice;
  late double currentRating;
  late String currentDescription;
  late String currentImage;

  @override
  void initState() {
    super.initState();

    currentTitle = widget.title;
    currentPrice = widget.price;
    currentRating = widget.rating;
    currentDescription = widget.description;
    currentImage = widget.image;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 170;

        return Card(
          elevation: 3,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Product image
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.asset(
                      currentImage,
                      fit: BoxFit.cover,
                    ),
                  ),

                  /// Product information
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isSmall ? 5 : 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmall ? 10 : 14,
                                  ),
                                ),
                              ),

                              Text(
                                "⭐ $currentRating",
                                style: TextStyle(
                                  fontSize: isSmall ? 10 : 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            currentDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: isSmall ? 9 : 12,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "$currentPrice Kyat",
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmall ? 9 : 14,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: isSmall ? 22 : 32,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Text(
                                      isSmall
                                          ? "Add To Fav"
                                          : "Add to Favourite",
                                      style: TextStyle(
                                        fontSize: isSmall ? 7 : 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: SizedBox(
                                  height: isSmall ? 22 : 32,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      side: const BorderSide(
                                        color: Colors.green,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Text(
                                      "View Details",
                                      style: TextStyle(
                                        fontSize: isSmall ? 7 : 11,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              /// EDIT BUTTON
              Positioned(
                top: 5,
                right: 5,
                child: Material(
                  color: Colors.white.withOpacity(0.9),
                  shape: const CircleBorder(),
                  child: IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                    ),
                    onPressed: _showEditDialog,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // EDIT DIALOG
  // ----------------------------------------------------------

  void _showEditDialog() {
    final titleController = TextEditingController(
      text: currentTitle,
    );

    final priceController = TextEditingController(
      text: currentPrice.toString(),
    );

    final ratingController = TextEditingController(
      text: currentRating.toString(),
    );

    final descriptionController = TextEditingController(
      text: currentDescription,
    );

    String editedImage = currentImage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Product"),

              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// IMAGE
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 180,
                              height: 130,
                              child: _buildEditImage(editedImage),
                            ),
                          ),

                          Positioned(
                            right: 5,
                            bottom: 5,
                            child: FloatingActionButton.small(
                              onPressed: () async {
                                final newImage =
                                    await _pickImage();

                                if (newImage != null) {
                                  setDialogState(() {
                                    editedImage = newImage;
                                  });
                                }
                              },
                              child: const Icon(Icons.camera_alt),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// TITLE
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: "Product Name",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// PRICE
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Price",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// RATING
                      TextField(
                        controller: ratingController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Rating",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// DESCRIPTION
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                /// DELETE
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);

                    _confirmDelete();
                  },
                  child: const Text("Delete"),
                ),

                const Spacer(),

                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () {
                    final newProduct = {
                      "title": titleController.text,
                      "price":
                          int.tryParse(priceController.text) ?? currentPrice,
                      "rating":
                          double.tryParse(ratingController.text) ??
                              currentRating,
                      "description": descriptionController.text,
                      "image": editedImage,
                    };

                    setState(() {
                      currentTitle = newProduct["title"] as String;
                      currentPrice = newProduct["price"] as int;
                      currentRating = newProduct["rating"] as double;
                      currentDescription =
                          newProduct["description"] as String;
                      currentImage = newProduct["image"] as String;
                    });

                    widget.onUpdate?.call(newProduct);

                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------------
  // IMAGE PICKER
  // ----------------------------------------------------------

  Future<String?> _pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) {
      return null;
    }

    return pickedFile.path;
  }

  // ----------------------------------------------------------
  // IMAGE PREVIEW
  // ----------------------------------------------------------

  Widget _buildEditImage(String image) {
    // Later when using API, this can become Image.network()
    if (image.startsWith("http")) {
      return Image.network(
        image,
        fit: BoxFit.cover,
      );
    }

    // Picked local image
    if (!kIsWeb && image.startsWith("/")) {
      return Image.file(
        File(image),
        fit: BoxFit.cover,
      );
    }

    // Existing Flutter asset
    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 40,
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // DELETE CONFIRMATION
  // ----------------------------------------------------------

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Product?"),
          content: Text(
            'Are you sure you want to delete "$currentTitle"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);

                widget.onDelete?.call();
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
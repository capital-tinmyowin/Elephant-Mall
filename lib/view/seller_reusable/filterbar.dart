import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: filterDropdown("By Category", ["Men", "Women", "Shoes"]),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 240,
            child: filterDropdown("Price: 0 to 500,000 Kyats", [
              "0 - 500,000 Kyats",
              "500,000+",
            ]),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 250,
            child: filterDropdown("Sort by Price: Low to High", [
              "Low to High",
              "High to Low",
            ]),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 150,
            child: filterDropdown("Location: All", [
              "All",
              "Yangon",
              "Mandalay",
            ]),
          ),
        ],
      ),
    );
  }

  Widget filterDropdown(String label, List<String> options) {
    String? selectedValue;

    return StatefulBuilder(
      builder: (context, setState) {
        return IntrinsicWidth(
          child: DropdownButtonFormField<String>(
            value: selectedValue,

            isExpanded: false,

            decoration: InputDecoration(
              labelText: label,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            style: const TextStyle(fontSize: 12, color: Colors.black),

            items: options.map((opt) {
              return DropdownMenuItem(
                value: opt,
                child: Text(
                  opt,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              );
            }).toList(),

            onChanged: (val) {
              setState(() {
                selectedValue = val;
              });
            },
          ),
        );
      },
    );
  }
}

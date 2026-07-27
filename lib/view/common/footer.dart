import 'package:flutter/material.dart';

class CommonFooter extends StatelessWidget {
  const CommonFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: const Color(0xFFF8F8F8),
        elevation: 4,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 1000 ? 60 : 25,
            vertical: 10,
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 180,
                child: _footerColumn(
                  "CUSTOMER CARE",
                  ["Home"],
                ),
              ),

              SizedBox(
                width: 180,
                child: _footerColumn(
                  "ABOUT US",
                  ["About Us"],
                ),
              ),

              SizedBox(
                width: 180,
                child: _footerColumn(
                  "CONNECT WITH US",
                  ["Contact Us"],
                ),
              ),

              SizedBox(
                width: 180,
                child: _footerColumn(
                  "LEGAL",
                  ["Legal"],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerColumn(String title, List<String> items) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 10),

        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              item,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
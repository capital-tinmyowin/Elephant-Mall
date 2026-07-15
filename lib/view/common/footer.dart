import 'package:flutter/material.dart';

class CommonFooter extends StatelessWidget {
  const CommonFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _footerColumn(
              "CUSTOMER CARE",
              [
                "Home",
              ],
            ),
          ),

          Expanded(
            child: _footerColumn(
              "ABOUT US",
              [
                "About Us",
              ],
            ),
          ),

          Expanded(
            child: _footerColumn(
              "CONNECT WITH US",
              [
                "Contact Us",
              ],
            ),
          ),

          Expanded(
            child: _footerColumn(
              "LEGAL",
              [
                "Legal",
              ],
            ),
          ),

          const Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
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
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(item),
          ),
        ),
      ],
    );
  }
}
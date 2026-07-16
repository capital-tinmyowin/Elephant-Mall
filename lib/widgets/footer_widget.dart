import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFooterColumn('CUSTOMER CARE', ['Home']),
          _buildFooterColumn('ABOUT US', ['About Us', 'Start Selling']),
          _buildFooterColumn('CONNECT WITH US', ['Contact Us']),
          _buildFooterColumn('LEGAL', ['Legal']),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            item,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        )),
      ],
    );
  }
}
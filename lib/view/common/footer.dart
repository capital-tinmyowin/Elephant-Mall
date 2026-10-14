import 'package:flutter/material.dart';
import '../home.dart';

class CommonFooter extends StatelessWidget {
  const CommonFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _buildNavLinks(context),
          ),

          const SizedBox(height: 5),

          const Text(
            'CKM Mall  ·  Yangon, Myanmar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFB0A090),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Copyright © 2026 CKMMall. All Rights Reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFFB0A090)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavLinks(BuildContext context) {
    final links = [
      {
        'label': 'Home',
        'onTap': () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        },
      },
      {'label': 'Products', 'onTap': () {}},
      {'label': 'About Us', 'onTap': () {}},
      {'label': 'Guide', 'onTap': () {}},
      {'label': 'Reviews', 'onTap': () {}},
      {'label': 'Contact', 'onTap': () {}},
      {'label': 'Q&A', 'onTap': () {}},
    ];

    final widgets = <Widget>[];

    for (int i = 0; i < links.length; i++) {
      widgets.add(
        InkWell(
          onTap: links[i]['onTap'] as VoidCallback,
          child: Text(
            links[i]['label'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );

      if (i < links.length - 1) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '|',
              style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

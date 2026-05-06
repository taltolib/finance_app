import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final List<Widget> children;
  final Color cardColor;

  const Section({
    required this.children,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}
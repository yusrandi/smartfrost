import 'package:flutter/material.dart';

/// Official Brand Header Logo for SmartFrost using asset [assets/images/logo-blue.png].
class SmartFrostLogo extends StatelessWidget {
  const SmartFrostLogo({super.key, this.height = 34});

  final double height;

  static const String assetPath = 'assets/images/logo-blue.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox.shrink();
      },
    );
  }
}

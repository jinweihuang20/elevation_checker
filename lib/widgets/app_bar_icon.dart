import 'package:flutter/material.dart';

class AppBarIcon extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const AppBarIcon({
    super.key,
    this.size = 32.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Image.asset(
          'assets/icon/icon_2.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

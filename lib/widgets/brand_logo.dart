import 'package:flutter/material.dart';

/// Logo Sehatku (ikon hati + wordmark) untuk header dan layar brand.
class SehatkuLogo extends StatelessWidget {
  const SehatkuLogo({super.key, this.height = 40});

  /// Tinggi logo dalam logical pixel. Lebar mengikuti rasio asli.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/sehatku_logo_horizontal.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Sehatku',
    );
  }
}

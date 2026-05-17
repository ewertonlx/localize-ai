import 'package:flutter/material.dart';

class CountryFlag extends StatelessWidget {
  const CountryFlag({
    super.key,
    required this.flagUrl,
    this.width = 42,
    this.height = 28,
    this.fit = BoxFit.cover,
  });

  final String flagUrl;
  final double width;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (flagUrl.isEmpty) {
      return CircleAvatar(
        radius: (height / 2),
        child: const Icon(Icons.flag_outlined),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        flagUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: width,
          height: height,
          child: const Center(child: Icon(Icons.flag_outlined)),
        ),
      ),
    );
  }
}

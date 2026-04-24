import 'package:flutter/material.dart';

class CountryFlag extends StatelessWidget {
  const CountryFlag({super.key, required this.flagUrl});

  final String flagUrl;

  @override
  Widget build(BuildContext context) {
    if (flagUrl.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.flag_outlined));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        flagUrl,
        width: 42,
        height: 28,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox(
          width: 42,
          height: 28,
          child: Center(child: Icon(Icons.flag_outlined)),
        ),
      ),
    );
  }
}

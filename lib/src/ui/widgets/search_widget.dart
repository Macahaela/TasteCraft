import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final Function(String) onSubmit; // Callback untuk hasil pencarian
  final TextEditingController controller;

  const SearchWidget({
    super.key,
    required this.onSubmit,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmit, // Callback ketika tombol submit ditekan
      decoration: InputDecoration(
        hintText: 'Search...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onSubmit(''); // Reset hasil pencarian
                },
              )
            : null,
      ),
    );
  }
}

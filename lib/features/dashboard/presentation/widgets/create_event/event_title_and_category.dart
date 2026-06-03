import 'package:flutter/material.dart';

class EventTitleAndCategory extends StatelessWidget {
  final TextEditingController titleController;
  final String selectedCategory;
  final List<String> categories;
  final Function(String?) onCategoryChanged;

  const EventTitleAndCategory({
    super.key,
    required this.titleController,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Title
        const Text(
          'EVENT TITLE',
          style: TextStyle(
            color: Color(0xFF717F8C),
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: titleController,
          decoration: _inputDecoration('e.g. Summer Jazz Night'),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 20),

        // Category
        const Text(
          'CATEGORY',
          style: TextStyle(
            color: Color(0xFF717F8C),
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF717F8C),
          ),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onCategoryChanged,
          decoration: _inputDecoration(''),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B4FEB), width: 2),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AddTierDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AddTierDialog({super.key, this.initialData});

  @override
  State<AddTierDialog> createState() => _AddTierDialogState();
}

class _AddTierDialogState extends State<AddTierDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _capacityController;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController = TextEditingController(text: data?['name'] ?? '');
    _priceController = TextEditingController(
      text: data != null ? (data['price'] as double).toStringAsFixed(0) : '',
    );
    _capacityController = TextEditingController(
      text: data != null ? data['total_capacity'].toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialData != null ? 'Edit Ticket Tier' : 'New Ticket Tier',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF1E293B),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tier Name (e.g. Early Bird, VIP)',
              labelStyle: TextStyle(color: Color(0xFF717F8C)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3B4FEB)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Price (Set 0 for Free)',
              prefixText: '\$ ',
              labelStyle: TextStyle(color: Color(0xFF717F8C)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3B4FEB)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _capacityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Total Available Capacity',
              labelStyle: TextStyle(color: Color(0xFF717F8C)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3B4FEB)),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty ||
                _capacityController.text.isEmpty) {
              return;
            }
            final price = double.tryParse(_priceController.text) ?? 0.0;
            final capacity = int.tryParse(_capacityController.text) ?? 0;

            Navigator.pop(context, {
              'name': _nameController.text.trim(),
              'price': price,
              'total_capacity': capacity,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B4FEB),
          ),
          child: Text(
            widget.initialData != null ? 'Save' : 'Add',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

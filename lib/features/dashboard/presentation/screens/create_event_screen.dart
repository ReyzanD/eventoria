import 'package:eventoria/features/events/data/models/ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../events/data/models/event_model.dart';
import '../controller/organizer_events_controller.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _venueController = TextEditingController();
  final List<Map<String, dynamic>> _localTicketTiers = [];
  final _tierNameController = TextEditingController();
  final _tierPriceController = TextEditingController();
  final _tierCapacityController = TextEditingController();

  String _selectedCategory = 'Conference';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  final DateTime _endDate = DateTime.now().add(
    const Duration(days: 1, hours: 3),
  );
  bool _isPublished = false;
  bool _allowRefunds = false;
  bool _isSaving = false;

  LatLng _pickedLocation = const LatLng(-6.2000, 106.8167);
  bool _hasPickedLocation = false;

  final List<String> _categories = [
    'Conference',
    'Festival',
    'Workshop',
    'Concert',
    'Exhibition',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasPickedLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pin the venue location on the map.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_localTicketTiers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add at least one ticket tier (e.g., Free, VIP).',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final eventPayload = EventModel(
        id: '',
        organizerId: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        category: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
        venueName: _venueController.text.trim(),
        latitude: _pickedLocation.latitude,
        longitude: _pickedLocation.longitude,
        isPublished: _isPublished,
        allowRefunds: _allowRefunds,
        createdAt: DateTime.now(),
      );

      final tiersToSubmit = _localTicketTiers.map((tierMap) {
        return TicketModel(
          id: '',
          eventId: '',
          name: tierMap['name'],
          price: tierMap['price'],
          totalCapacity: tierMap['total_capacity'],
          ticketsSold: 0,
        );
      }).toList();

      final success = await ref
          .read(organizerEventsProvider.notifier)
          .createEvent(eventPayload, tiersToSubmit); // <-- UPDATED HERE

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event & Tickets published successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save event. Please check inputs.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text(
          'List New Event',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalPadding = constraints.maxWidth > 700
                ? (constraints.maxWidth - 650) / 2
                : 16.0;

            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                children: [
                  _buildFormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeading('Event Core Details'),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: _inputDecoration(
                            'Event Title',
                            Icons.title,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Title is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          // FIX: Swapped 'value' for 'initialValue'
                          initialValue: _selectedCategory,
                          items: _categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val!),
                          decoration: _inputDecoration(
                            'Category',
                            Icons.category,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            'Description (Optional)',
                            Icons.description,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeading('Location & Timing'),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _venueController,
                          decoration: _inputDecoration(
                            'Venue Name',
                            Icons.place_rounded,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Venue is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Pin Location on Map',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff64748b),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            // FIX: Wrapped BorderSide inside Border.all() to make it a valid BoxBorder
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: _pickedLocation,
                              initialZoom: 13.0,
                              onTap: (tapPosition, point) {
                                setState(() {
                                  _pickedLocation = point;
                                  _hasPickedLocation = true;
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.venu.app',
                              ),
                              if (_hasPickedLocation)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _pickedLocation,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _hasPickedLocation
                                ? 'Coordinates Saved: [Lat: ${_pickedLocation.latitude.toStringAsFixed(4)}, Lng: ${_pickedLocation.longitude.toStringAsFixed(4)}]'
                                : '💡 Click anywhere on the map grid to set precise coordinates',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const Divider(height: 32),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Starts: ${_startDate.toLocal().toString().substring(0, 16)}',
                          ),
                          trailing: const Icon(
                            Icons.calendar_month,
                            color: Color(0xFF2563EB),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              setState(
                                () => _startDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  _startDate.hour,
                                  _startDate.minute,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTicketTiersSection(),
                  const SizedBox(height: 16),
                  _buildFormCard(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text(
                            'Publish Immediately',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Make this visible to attendees right away',
                          ),
                          value: _isPublished,
                          // FIX: Swapped activeColor for activeThumbColor
                          activeThumbColor: const Color(0xFF2563EB),
                          onChanged: (val) =>
                              setState(() => _isPublished = val),
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text(
                            'Allow Ticket Refunds',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Let ticket buyers request order cancellations',
                          ),
                          value: _allowRefunds,
                          // FIX: Swapped activeColor for activeThumbColor
                          activeThumbColor: const Color(0xFF2563EB),
                          onChanged: (val) =>
                              setState(() => _allowRefunds = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit & Save Event',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormCard({required Widget child}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _buildSectionHeading(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xff1e293b),
      ),
    );
  }

  Widget _buildTicketTiersSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ticket Pricing & Tiers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1e293b),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddTierDialog,
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                  label: const Text(
                    'Add Tier',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (_localTicketTiers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Please add at least one ticket tier (e.g., Free Entry, General Admission, VIP) so attendees can register.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _localTicketTiers.length,
                itemBuilder: (context, index) {
                  final tier = _localTicketTiers[index];
                  final double price = tier['price'];
                  final int capacity = tier['total_capacity'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xfff8fafc),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        tier['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Price: ${price == 0 ? "FREE" : "\$${price.toStringAsFixed(2)}"}  |  Capacity: $capacity slots',
                        style: const TextStyle(color: Color(0xff64748b)),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _localTicketTiers.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddTierDialog() {
    _tierNameController.clear();
    _tierPriceController.clear();
    _tierCapacityController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'New Ticket Tier',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tierNameController,
                decoration: const InputDecoration(
                  labelText: 'Tier Name (e.g. Early Bird, VIP)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tierPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price (Set 0 for Free)',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tierCapacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Available Capacity',
                  border: OutlineInputBorder(),
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
                if (_tierNameController.text.isEmpty ||
                    _tierCapacityController.text.isEmpty)
                  return;

                final price = double.tryParse(_tierPriceController.text) ?? 0.0;
                final capacity =
                    int.tryParse(_tierCapacityController.text) ?? 0;

                setState(() {
                  _localTicketTiers.add({
                    'id': '', // Will be generated by Postgres
                    'event_id': '', // Will be mapped by Controller
                    'name': _tierNameController.text.trim(),
                    'price': price,
                    'total_capacity': capacity,
                    'tickets_sold': 0,
                  });
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.withValues(alpha: 0.7)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
    );
  }
}

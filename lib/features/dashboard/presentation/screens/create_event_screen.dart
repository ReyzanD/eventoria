import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_model.dart';
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

  String _selectedCategory = 'Conference';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  final DateTime _endDate = DateTime.now().add(
    const Duration(days: 1, hours: 3),
  );
  bool _isPublished = false;
  bool _allowRefunds = false;
  bool _isSaving = false;

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

    setState(() => _isSaving = true);

    final mockEvent = EventModel(
      id: '', // Generated automatically by Postgres gen_random_uuid()
      organizerId: '', // Filled in by the repository/controller layer
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      category: _selectedCategory,
      startDate: _startDate,
      endDate: _endDate,
      venueName: _venueController.text.trim(),
      isPublished: _isPublished,
      allowRefunds: _allowRefunds,
      createdAt: DateTime.now(),
      latitude: 0.0,
      longitude: 0.0,
    );

    final success = await ref
        .read(organizerEventsProvider.notifier)
        .createEvent(mockEvent);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Go back to dashboard workspace
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save event. Please check inputs.'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
            // Responsive constraint barrier block
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
                        ListTile(
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

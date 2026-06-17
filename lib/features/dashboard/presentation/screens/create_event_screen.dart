import 'dart:ui' as ui;
import 'package:eventoria/features/dashboard/presentation/controller/organizer_dashboard_controller.dart';
import 'package:eventoria/features/events/data/models/ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../events/data/models/event_model.dart';
import '../controller/organizer_events_controller.dart';
import '../widgets/create_event/add_tier_dialog.dart';
import '../widgets/create_event/event_cover_image_picker.dart';
import '../widgets/create_event/event_date_time_pickers.dart';
import '../widgets/create_event/event_location_map.dart';
import '../widgets/create_event/event_ticket_tiers.dart';
import '../widgets/create_event/event_title_and_category.dart';
import '../../../../core/widgets/shared_app_bar.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  final EventModel? existingEvent;

  const CreateEventScreen({super.key, this.existingEvent});

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

  late String _selectedCategory;
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  String? _coverImageUrl;
  bool _isPublished = true;
  bool _allowRefunds = false;
  bool _isSaving = false;

  late LatLng _pickedLocation;
  bool _hasPickedLocation = false;

  final List<String> _categories = [
    'Festival',
    'Concert',
    'Conference',
    'Workshop',
    'Exhibition',
  ];

  @override
  void initState() {
    super.initState();
    final ev = widget.existingEvent;
    if (ev != null) {
      _titleController.text = ev.title;
      _descController.text = ev.description ?? '';
      _venueController.text = ev.venueName;
      _selectedCategory = ev.category;
      _startDate = ev.startDate;
      _endDate = ev.endDate;
      _startTime = TimeOfDay.fromDateTime(ev.startDate);
      _endTime = TimeOfDay.fromDateTime(ev.endDate);
      _coverImageUrl = ev.coverImageUrl;
      _isPublished = ev.isPublished;
      _allowRefunds = ev.allowRefunds;
      _pickedLocation = LatLng(ev.latitude, ev.longitude);
      _hasPickedLocation = true;
      if (ev.ticketTiers != null) {
        for (final tier in ev.ticketTiers!) {
          _localTicketTiers.add({
            'id': tier.id,
            'event_id': tier.eventId,
            'name': tier.name,
            'price': tier.price,
            'total_capacity': tier.totalCapacity,
            'tickets_sold': tier.ticketsSold,
          });
        }
      }
    } else {
      _selectedCategory = 'Festival';
      _startDate = DateTime.now().add(const Duration(days: 1));
      _endDate = DateTime.now().add(const Duration(days: 1, hours: 3));
      _startTime = const TimeOfDay(hour: 16, minute: 0);
      _endTime = const TimeOfDay(hour: 22, minute: 0);
      _pickedLocation = const LatLng(-6.2000, 106.8167);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _tierNameController.dispose();
    _tierPriceController.dispose();
    _tierCapacityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm({bool forceDraft = false}) async {
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
          content: Text('Please add at least one ticket tier.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final eventPayload = EventModel(
        id: '',
        organizerId: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        category: _selectedCategory,
        startDate: startDateTime,
        endDate: endDateTime,
        venueName: _venueController.text.trim(),
        latitude: _pickedLocation.latitude,
        longitude: _pickedLocation.longitude,
        coverImageUrl: _coverImageUrl,
        isPublished: forceDraft ? false : _isPublished,
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

      final success = widget.existingEvent != null
          ? await ref
              .read(organizerEventsProvider.notifier)
              .updateEvent(eventPayload, tiersToSubmit)
          : await ref
              .read(organizerEventsProvider.notifier)
              .createEvent(eventPayload, tiersToSubmit);

      if (!mounted) return;

      if (success) {
        ref.invalidate(organizerDashboardProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              forceDraft
                  ? 'Draft saved successfully!'
                  : 'Event published successfully! 🎉',
            ),
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

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(hours: 3));
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  void _mockImageUpload() {
    setState(() {
      _coverImageUrl =
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=1600&q=80';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cover image selected!'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SharedAppBar(
        title: widget.existingEvent != null ? 'Edit event' : 'Create event',
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B4FEB)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _submitForm(forceDraft: true),
            child: const Text(
              'Save draft',
              style: TextStyle(
                color: Color(0xFF3B4FEB),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isSaving
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    children: [
                      EventCoverImagePicker(
                        imageUrl: _coverImageUrl,
                        onImagePicked: _mockImageUpload,
                        onImageRemoved: () {
                          setState(() {
                            _coverImageUrl = null;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      EventTitleAndCategory(
                        titleController: _titleController,
                        selectedCategory: _selectedCategory,
                        categories: _categories,
                        onCategoryChanged: (val) {
                          setState(() {
                            _selectedCategory = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      EventDateTimePickers(
                        startDate: _startDate,
                        endDate: _endDate,
                        startTime: _startTime,
                        endTime: _endTime,
                        onSelectStartDate: () => _selectDate(true),
                        onSelectEndDate: () => _selectDate(false),
                        onSelectStartTime: () => _selectTime(true),
                        onSelectEndTime: () => _selectTime(false),
                      ),
                      const SizedBox(height: 20),

                      EventLocationMap(
                        venueController: _venueController,
                        pickedLocation: _pickedLocation,
                        hasPickedLocation: _hasPickedLocation,
                        onMapTapped: (tapPosition, point) {
                          setState(() {
                            _pickedLocation = point;
                            _hasPickedLocation = true;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      EventTicketTiers(
                        tiers: _localTicketTiers,
                        onAddTier: () => _showAddTierDialog(),
                        onEditTier: (index) =>
                            _showAddTierDialog(editIndex: index),
                        onDeleteTier: (index) {
                          setState(() {
                            _localTicketTiers.removeAt(index);
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Toggle Switches
                      SwitchListTile(
                        title: const Text(
                          'Publish immediately',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            fontSize: 15,
                          ),
                        ),
                        value: _isPublished,
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF3B4FEB),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _isPublished = val),
                      ),
                      const Divider(color: Color(0xFFE2E8F0)),
                      SwitchListTile(
                        title: const Text(
                          'Allow refunds',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            fontSize: 15,
                          ),
                        ),
                        value: _allowRefunds,
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF3B4FEB),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _allowRefunds = val),
                      ),

                      const SizedBox(height: 32),

                      // Publish Event Button
                      ElevatedButton(
                        onPressed: () => _submitForm(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF45E65),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Publish event',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _showAddTierDialog({int? editIndex}) async {
    final Map<String, dynamic>? initialData = editIndex != null
        ? _localTicketTiers[editIndex]
        : null;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddTierDialog(initialData: initialData),
    );

    if (result == null) return;

    setState(() {
      final data = {
        'id': editIndex != null ? _localTicketTiers[editIndex]['id'] : '',
        'event_id': editIndex != null
            ? _localTicketTiers[editIndex]['event_id']
            : '',
        'name': result['name'],
        'price': result['price'],
        'total_capacity': result['total_capacity'],
        'tickets_sold': editIndex != null
            ? _localTicketTiers[editIndex]['tickets_sold']
            : 0,
      };

      if (editIndex != null) {
        _localTicketTiers[editIndex] = data;
      } else {
        _localTicketTiers.add(data);
      }
    });
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.dashLength = 6.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final ui.Path path = ui.Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final ui.Path dashedPath = ui.Path();
    double distance = 0.0;
    for (final ui.PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashedPath.addPath(
          measurePath.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

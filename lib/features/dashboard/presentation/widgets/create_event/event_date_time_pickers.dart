import 'package:flutter/material.dart';

class EventDateTimePickers extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;
  final VoidCallback onSelectStartTime;
  final VoidCallback onSelectEndTime;

  const EventDateTimePickers({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
    required this.onSelectStartTime,
    required this.onSelectEndTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Start and End Date side-by-side
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('START DATE'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onSelectStartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: _containerDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${startDate.day}/${startDate.month}/${startDate.year}',
                            style: const TextStyle(color: Color(0xFF1E293B)),
                          ),
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFF717F8C),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('END DATE'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onSelectEndDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: _containerDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${endDate.day}/${endDate.month}/${endDate.year}',
                            style: const TextStyle(color: Color(0xFF1E293B)),
                          ),
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFF717F8C),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Start and End Time side-by-side
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('START TIME'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onSelectStartTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: _containerDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            startTime.format(context),
                            style: const TextStyle(color: Color(0xFF1E293B)),
                          ),
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF717F8C),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('END TIME'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onSelectEndTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: _containerDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            endTime.format(context),
                            style: const TextStyle(color: Color(0xFF1E293B)),
                          ),
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF717F8C),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF717F8C),
        fontWeight: FontWeight.bold,
        fontSize: 11,
        letterSpacing: 1.0,
      ),
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );
  }
}

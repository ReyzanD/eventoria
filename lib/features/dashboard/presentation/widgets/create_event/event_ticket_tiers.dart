import 'package:flutter/material.dart';

class EventTicketTiers extends StatelessWidget {
  final List<Map<String, dynamic>> tiers;
  final VoidCallback onAddTier;
  final Function(int) onEditTier;
  final Function(int) onDeleteTier;

  const EventTicketTiers({
    super.key,
    required this.tiers,
    required this.onAddTier,
    required this.onEditTier,
    required this.onDeleteTier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TICKETS',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 1.0,
              ),
            ),
            ElevatedButton.icon(
              onPressed: onAddTier,
              icon: const Icon(Icons.add, size: 14, color: Colors.white),
              label: const Text(
                'Add tier',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B4FEB),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 20, color: Color(0xFFE2E8F0)),

        if (tiers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Add ticket tiers (e.g. Early Bird, General Admission, VIP) so attendees can purchase tickets.',
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
            itemCount: tiers.length,
            itemBuilder: (context, index) {
              final tier = tiers[index];
              final double price = tier['price'];
              final int capacity = tier['total_capacity'];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B4FEB).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_activity_outlined,
                        color: Color(0xFF3B4FEB),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tier['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '• \$${price.toStringAsFixed(0)} • $capacity available',
                            style: const TextStyle(
                              color: Color(0xFF717F8C),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF717F8C),
                        size: 18,
                      ),
                      onPressed: () => onEditTier(index),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFF45E65),
                        size: 18,
                      ),
                      onPressed: () => onDeleteTier(index),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../domain/entities/ticket_entity.dart'; // Adjust to your actual entity import

class TicketQrScreen extends StatelessWidget {
  final TicketEntity ticket; // The specific ticket the user tapped on

  const TicketQrScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    // A standard event app feature: Make the background dark to make the QR pop!
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Your Ticket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- THE DIGITAL TICKET ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B4FEB).withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // --- TICKET HEADER ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            ticket.eventName ??
                                'Event Name', // Adjust if your entity uses a different name
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ticket.ticketTierName ??
                                'Standard Entry', // Adjust to your entity
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF3B4FEB),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- PERFORATED DIVIDER ---
                    // --- PERFORATED DIVIDER ---
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // The Dashed Line
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final boxWidth = constraints.constrainWidth();
                              const dashWidth = 8.0;
                              const dashHeight = 2.0;
                              final dashCount = (boxWidth / (2 * dashWidth))
                                  .floor();
                              return Flex(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                direction: Axis.horizontal,
                                children: List.generate(dashCount, (_) {
                                  return const SizedBox(
                                    width: dashWidth,
                                    height: dashHeight,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                        // Left cutout
                        Positioned(
                          left: -15,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Right cutout
                        Positioned(
                          right: -15,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --- QR CODE SECTION ---
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: QrImageView(
                              // This is the magic! The scanner will read this exact string
                              data: ticket
                                  .id, // Or ticket.orderCode, whatever you want to scan!
                              version: QrVersions.auto,
                              size: 200.0,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Color(0xFF1E293B),
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Order Number',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.id
                                .toUpperCase(), // Using ID as the order number
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Helper text for the user
              const Text(
                'Present this QR code at the door.\nTurn up your screen brightness for faster scanning.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

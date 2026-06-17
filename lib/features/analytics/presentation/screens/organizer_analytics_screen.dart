import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// Adjust this import path to match where your provider lives!
import '../../../dashboard/presentation/controller/organizer_dashboard_controller.dart';

class OrganizerAnalyticsScreen extends ConsumerWidget {
  const OrganizerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(organizerDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: dashboardState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
        ),
        error: (err, stack) =>
            Center(child: Text('Error loading analytics: $err')),
        data: (state) {
          return RefreshIndicator(
            color: const Color(0xFF3B4FEB),
            onRefresh: () async {
              ref.invalidate(organizerDashboardProvider);
              await ref.read(organizerDashboardProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const Text(
                  'Revenue Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRevenueBarChart(state.totalRevenue),

                const SizedBox(height: 32),

                const Text(
                  'Check-in Conversion',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCheckInPieChart(state.totalTicketsSold),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET: REVENUE BAR CHART ---
  Widget _buildRevenueBarChart(double totalRevenue) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rp ${totalRevenue.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3B4FEB),
            ),
          ),
          const Text(
            'Total Gross Revenue',
            style: TextStyle(color: Color(0xFF717F8C), fontSize: 14),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalRevenue == 0 ? 100 : totalRevenue * 1.2),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        // Mocking recent months for visual effect
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = 'Feb';
                            break;
                          case 1:
                            text = 'Mar';
                            break;
                          case 2:
                            text = 'Apr';
                            break;
                          case 3:
                            text = 'May';
                            break;
                          case 4:
                            text = 'Jun';
                            break;
                          default:
                            text = '';
                            break;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarData(0, totalRevenue * 0.1),
                  _makeBarData(1, totalRevenue * 0.25),
                  _makeBarData(2, totalRevenue * 0.15),
                  _makeBarData(3, totalRevenue * 0.4),
                  _makeBarData(4, totalRevenue * 0.1), // Current Month
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF3B4FEB),
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 0, // Set to max Y in reality if you want a background track
            color: const Color(0xFFF1F5F9),
          ),
        ),
      ],
    );
  }

  // --- WIDGET: CHECK-IN PIE CHART ---
  Widget _buildCheckInPieChart(int totalTickets) {
    // For now, mocking that 65% of sold tickets have checked in.
    final double checkedIn = totalTickets * 0.65;
    final double noShow = totalTickets * 0.35;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF10B981), // Emerald Green
                    value: checkedIn,
                    title: '65%',
                    radius: 25,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFF45E65), // Neon Pink/Red
                    value: noShow,
                    title: '35%',
                    radius: 20,
                    titleStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          const Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Indicator(color: Color(0xFF10B981), text: 'Checked In'),
                SizedBox(height: 12),
                _Indicator(color: Color(0xFFF45E65), text: 'Not Scanned'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

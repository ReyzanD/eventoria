import 'package:flutter/material.dart';
import 'responsive.dart';

class AdaptiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final List<Widget> pages;
  final List<NavigationDestination> destinations;
  final Color? backgroundColor;
  final Color? railBackgroundColor;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final Color? indicatorColor;
  final PreferredSizeWidget? appBar;

  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.pages,
    required this.destinations,
    this.backgroundColor,
    this.railBackgroundColor,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.indicatorColor,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: pages[selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onIndexChanged,
          backgroundColor: railBackgroundColor ?? backgroundColor,
          indicatorColor: indicatorColor ?? Colors.white12,
          destinations: destinations,
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onIndexChanged,
            backgroundColor: railBackgroundColor ?? backgroundColor,
            indicatorColor: indicatorColor ?? Colors.white12,
            leading: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Icon(
                Icons.event_rounded,
                size: 32,
                color: selectedIconColor,
              ),
            ),
            labelType: context.isTablet
                ? NavigationRailLabelType.selected
                : NavigationRailLabelType.all,
            destinations: destinations
                .map((d) => NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: Text(d.label),
                    ))
                .toList(),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}

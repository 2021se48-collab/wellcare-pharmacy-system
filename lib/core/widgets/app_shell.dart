import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppShell extends StatefulWidget {
  final List<Widget> screens;
  const AppShell({super.key, required this.screens});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<NavigationRailDestination> _destinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.point_of_sale_outlined),
      selectedIcon: Icon(Icons.point_of_sale),
      label: Text('POS Billing'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: Text('Inventory (FEFO)'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: Text('Analytics'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.admin_panel_settings_outlined),
      selectedIcon: Icon(Icons.admin_panel_settings),
      label: Text('Staff & RBAC'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_pharmacy, color: AppColors.primaryTeal),
            ),
            const SizedBox(width: 12),
            const Text(
              'WellCare Pharmacy OS',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              extended: MediaQuery.of(context).size.width >= 1100,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              destinations: _destinations,
            ),
          if (isWide) const VerticalDivider(width: 1),
          Expanded(
            child: widget.screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'POS'),
                NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Stock'),
                NavigationDestination(icon: Icon(Icons.analytics), label: 'Reports'),
                NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'RBAC'),
              ],
            ),
    );
  }
}

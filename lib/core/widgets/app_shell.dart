import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppShell extends StatefulWidget {
  final List<Widget> screens;
  final List<String> titles;
  final VoidCallback? onLogout;
  final VoidCallback? onToggleTheme;

  const AppShell({
    super.key,
    required this.screens,
    this.titles = const [
      'POS Billing',
      'Inventory (FEFO)',
      'Analytics & Reports',
      'Staff & RBAC',
    ],
    this.onLogout,
    this.onToggleTheme,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

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
            Text(
              widget.titles[_selectedIndex],
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        actions: [
          if (widget.onToggleTheme != null)
            IconButton(
              tooltip: 'Toggle Theme',
              icon: const Icon(Icons.brightness_6_outlined),
              onPressed: widget.onToggleTheme,
            ),
          if (widget.onLogout != null)
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout, color: AppColors.criticalRed),
              onPressed: widget.onLogout,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              extended: MediaQuery.of(context).size.width >= 1100,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.point_of_sale_outlined),
                  selectedIcon: const Icon(Icons.point_of_sale),
                  label: Text(widget.titles[0]),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.inventory_2_outlined),
                  selectedIcon: const Icon(Icons.inventory_2),
                  label: Text(widget.titles[1]),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.analytics_outlined),
                  selectedIcon: const Icon(Icons.analytics),
                  label: Text(widget.titles[2]),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  selectedIcon: const Icon(Icons.admin_panel_settings),
                  label: Text(widget.titles[3]),
                ),
              ],
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
              destinations: [
                NavigationDestination(icon: const Icon(Icons.point_of_sale), label: widget.titles[0]),
                NavigationDestination(icon: const Icon(Icons.inventory_2), label: widget.titles[1]),
                NavigationDestination(icon: const Icon(Icons.analytics), label: widget.titles[2]),
                NavigationDestination(icon: const Icon(Icons.admin_panel_settings), label: widget.titles[3]),
              ],
            ),
    );
  }
}

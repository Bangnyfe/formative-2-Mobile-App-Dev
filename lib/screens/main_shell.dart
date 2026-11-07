import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'report/new_report_screen.dart';
import 'reports/my_reports_screen.dart';
import 'staff/staff_dashboard_screen.dart';

/// Bottom navigation with the Report button in the middle. Staff get an
/// extra Manage tab.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openReportForm() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const NewReportScreen()));
  }

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final isStaff = context.watch<AuthProvider>().isStaff;
    // If staff access is removed while on the Manage tab, fall back to Home.
    final index = (!isStaff && _index == 3) ? 0 : _index;

    final pages = [
      HomeScreen(onReportTap: _openReportForm, onSeeAllTap: () => _goTo(1)),
      MyReportsScreen(onReportTap: _openReportForm),
      const ProfileScreen(),
      if (isStaff) const StaffDashboardScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: _openReportForm,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Report an issue',
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              selected: index == 0,
              onTap: () => _goTo(0),
            ),
            _NavItem(
              icon: Icons.description_outlined,
              activeIcon: Icons.description,
              label: 'Reports',
              selected: index == 1,
              onTap: () => _goTo(1),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 34),
                child: Text(
                  'Report',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            if (isStaff)
              _NavItem(
                icon: Icons.admin_panel_settings_outlined,
                activeIcon: Icons.admin_panel_settings,
                label: 'Manage',
                selected: index == 3,
                onTap: () => _goTo(3),
              ),
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              selected: index == 2,
              onTap: () => _goTo(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

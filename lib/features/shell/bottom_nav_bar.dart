import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/config/display_config.dart';
import '../../core/services/responsive_service.dart';
import '../../app/constants/app_strings.dart';

/// Bottom navigation restyled to the monochrome reference kit.
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);
    return Container(
      height: r.scaled(78),
      padding: EdgeInsets.symmetric(
        horizontal: r.scaled(6),
        vertical: r.scaled(6),
      ),
      decoration: BoxDecoration(
        color: r.bgDark(),
        border: Border(top: BorderSide(color: r.borderDark(), width: 2)),
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: AppStrings.navHome,
            isSelected: selectedIndex == 0,
            onTap: () => onTap(0),
            r: r,
          ),
          _NavItem(
            icon: Icons.play_circle_outline,
            label: AppStrings.navRun,
            isSelected: selectedIndex == 1,
            onTap: () => onTap(1),
            r: r,
          ),
          _NavItem(
            icon: Icons.science_outlined,
            label: AppStrings.navRecipes,
            isSelected: selectedIndex == 2,
            onTap: () => onTap(2),
            r: r,
          ),
          _NavItem(
            icon: Icons.history,
            label: AppStrings.navHistory,
            isSelected: selectedIndex == 3,
            onTap: () => onTap(3),
            r: r,
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: AppStrings.navSettings,
            isSelected: selectedIndex == 4,
            onTap: () => onTap(4),
            r: r,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Responsive r;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: r.scaled(34),
              height: r.scaled(34),
              decoration: BoxDecoration(
                color: isSelected ? r.accentColor() : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryLight : r.textLight(),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.textOnPrimary : r.textLight(),
                size: r.scaled(18),
              ),
            ),
            SizedBox(height: r.scaled(4)),
            Text(
              label,
              style: TextStyle(
                fontSize: r.scaled(9),
                color: r.textLight(),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

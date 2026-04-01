import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/config/display_config.dart';
import '../../core/services/responsive_service.dart';
import '../../widget/components/ui_components.dart';

class MenuScreen extends StatelessWidget {
  final String username;
  final String title;
  final String description;
  final List<MenuListItem>? items;
  final int? selectedIndex;
  final ValueChanged<int>? onItemTap;

  const MenuScreen({
    required this.username,
    this.title = 'Menu',
    this.description = 'Choose where you want to go next.',
    this.items,
    this.selectedIndex,
    this.onItemTap,
    Key? key,
  }) : super(key: key);

  List<MenuListItem> get _defaultItems => const [
        MenuListItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
          subtitle: 'System preferences, display, and configuration.',
        ),
        MenuListItem(
          icon: Icons.storage_rounded,
          label: 'Log data',
          subtitle: 'Open saved batches and exported machine history.',
        ),
        MenuListItem(
          icon: Icons.info_outline_rounded,
          label: 'Info',
          subtitle: 'Device information and basic application details.',
        ),
        MenuListItem(
          icon: Icons.science_outlined,
          label: 'Tubing',
          subtitle: 'Tubing selection and process preparation tools.',
        ),
        MenuListItem(
          icon: Icons.thermostat_rounded,
          label: 'Temp Valid',
          subtitle: 'Temperature-related validation and monitoring options.',
        ),
        MenuListItem(
          icon: Icons.build_circle_outlined,
          label: 'Service Pos',
          subtitle: 'Service and maintenance assistance shortcuts.',
        ),
        MenuListItem(
          icon: Icons.language_rounded,
          label: 'Language',
          subtitle: 'Language and localization preferences.',
        ),
        MenuListItem(
          icon: Icons.schedule_rounded,
          label: 'Date/Time',
          subtitle: 'Timekeeping and scheduling configuration.',
        ),
        MenuListItem(
          icon: Icons.memory_rounded,
          label: 'Memory',
          subtitle: 'View stored data capacity and related diagnostics.',
        ),
        MenuListItem(
          icon: Icons.network_check_rounded,
          label: 'Network',
          subtitle: 'Connectivity settings and network diagnostics.',
        ),
        MenuListItem(
          icon: Icons.system_update_alt_rounded,
          label: 'Update',
          subtitle: 'Software update tools and package management.',
        ),
        MenuListItem(
          icon: Icons.security_rounded,
          label: 'Secure',
          subtitle: 'Security-related functions and protected actions.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final timestamp =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final menuItems = items ?? _defaultItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.screenBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              r.scaled(14),
              r.scaled(10),
              r.scaled(14),
              r.scaled(14),
            ),
            child: Column(
              children: [
                HeaderBar(
                  timestamp: timestamp,
                  title: title,
                  username: username,
                  r: r,
                  leadingAction: _MenuHeaderBackButton(
                    onTap: () => Navigator.of(context).maybePop(),
                    r: r,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(r.scaled(16)),
                  decoration: BoxDecoration(
                    color: isDarkTheme ? AppColors.cardSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(r.scaled(24)),
                    border: Border.all(
                      color: isDarkTheme ? AppColors.panelBorder : AppColors.divider,
                      width: 1.4,
                    ),
                    boxShadow: AppColors.panelShadow(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.scaled(10),
                          vertical: r.scaled(6),
                        ),
                        decoration: BoxDecoration(
                          color: isDarkTheme
                              ? AppColors.activeAccent.withValues(alpha: 0.12)
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(r.scaled(999)),
                          border: isDarkTheme
                              ? Border.all(
                                  color: AppColors.panelBorderStrong.withValues(alpha: 0.65),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Text(
                          'Quick Navigation',
                          style: TextStyle(
                            color: isDarkTheme ? AppColors.activeAccent : AppColors.primary,
                            fontSize: r.scaled(11),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      SizedBox(height: r.scaled(10)),
                      Text(
                        description,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: r.scaled(13),
                          height: 1.4,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: r.scaled(14)),
                Expanded(
                  child: MenuList(
                    items: menuItems,
                    selectedIndex: selectedIndex,
                    r: r,
                    onItemTap: (index) {
                      if (onItemTap != null) {
                        onItemTap!(index);
                        return;
                      }
                      _handleMenuTap(context, index, r, menuItems[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuTap(
    BuildContext context,
    int index,
    Responsive r,
    MenuListItem item,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${index + 1}. ${item.label}',
          style: TextStyle(fontSize: r.scaled(14)),
        ),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }
}

class _MenuHeaderBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Responsive r;

  const _MenuHeaderBackButton({
    required this.onTap,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    final buttonRadius = BorderRadius.circular(r.scaled(AppSizes.buttonRadius));
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: buttonRadius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.scaled(14),
            vertical: r.scaled(10),
          ),
          decoration: BoxDecoration(
            color: isDarkTheme ? AppColors.selectedSurface : AppColors.primary,
            borderRadius: buttonRadius,
            border: isDarkTheme
                ? Border.all(
                    color: AppColors.panelBorderStrong,
                    width: 1.5,
                  )
                : null,
            boxShadow: AppColors.panelShadow(
              active: true,
              glowColor: isDarkTheme ? AppColors.activeAccent : AppColors.primary,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_rounded,
                size: r.scaled(20),
                color: AppColors.textOnPrimary,
              ),
              SizedBox(width: r.scaled(8)),
              Text(
                'Back',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: r.scaled(13),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

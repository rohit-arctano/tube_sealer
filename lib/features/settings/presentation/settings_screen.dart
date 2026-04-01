import 'package:flutter/material.dart';
import '../../../app/constants/app_sizes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme_controller.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/machine_primary_button.dart';
import '../../../core/config/display_config.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/responsive_service.dart';
import '../controller/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = SettingsController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _logout() {
    AuthService().logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _changePassword() {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Change Password',
          style: AppTextStyles.sectionTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _PasswordField(label: 'Current Password'),
            SizedBox(height: r.scaled(12)),
            const _PasswordField(label: 'New Password'),
            SizedBox(height: r.scaled(12)),
            const _PasswordField(label: 'Confirm Password'),
          ],
        ),
        actions: [
          SizedBox(
            width: r.touchTargetDp(),
            height: r.touchTargetDp(),
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(
                  color: AppColors.isDarkMode ? AppColors.panelBorder : AppColors.divider,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                color: AppColors.isDarkMode
                    ? AppColors.activeAccentSoft
                    : AppColors.textPrimary,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _toggleTheme(bool isDark) {
    AppThemeController.instance.setDarkMode(isDark);
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);
    final themeController = AppThemeController.instance;

    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: themeController,
          builder: (context, __) {
            final isDarkTheme = themeController.isDarkMode;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                r.scaled(10),
                0,
                r.scaled(10),
                r.scaled(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SettingsPanel(
                    title: 'Theme',
                    r: r,
                    child: Row(
                      children: [
                        Expanded(
                          child: _SettingsToggleButton(
                            label: 'Light',
                            selected: !isDarkTheme,
                            onTap: () => _toggleTheme(false),
                          ),
                        ),
                        SizedBox(width: r.scaled(8)),
                        Expanded(
                          child: _SettingsToggleButton(
                            label: 'Dark',
                            selected: isDarkTheme,
                            onTap: () => _toggleTheme(true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: r.scaled(10)),
                  MachinePrimaryButton(
                    label: 'Change Password',
                    icon: Icons.lock,
                    onPressed: _changePassword,
                  ),
                  SizedBox(height: r.scaled(10)),
                  MachinePrimaryButton(
                    label: 'Logout',
                    icon: Icons.logout,
                    onPressed: _logout,
                  ),
                  SizedBox(height: r.scaled(10)),
                  _SettingsPanel(
                    title: 'About',
                    r: r,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ASL Tube Sealer', style: AppTextStyles.bodyLarge),
                        SizedBox(height: r.scaled(6)),
                        Text('Version: ${_ctrl.version}', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final Responsive r;

  const _SettingsPanel({
    required this.title,
    required this.child,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(r.scaled(12)),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColors.cardSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(r.scaled(AppSizes.cardRadius)),
        border: Border.all(
          color: isDarkTheme ? AppColors.panelBorder : AppColors.divider,
          width: 2,
        ),
        boxShadow: isDarkTheme ? AppColors.panelShadow() : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          SizedBox(height: r.scaled(10)),
          child,
        ],
      ),
    );
  }
}

class _SettingsToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SettingsToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppSizes.buttonRadius);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? (isDarkTheme ? AppColors.selectedSurface : AppColors.primary)
                : (isDarkTheme ? AppColors.cardSurfaceRaised : AppColors.surfaceVariant),
            borderRadius: borderRadius,
            border: Border.all(
              color: selected && isDarkTheme
                  ? AppColors.panelBorderStrong
                  : (isDarkTheme ? AppColors.panelBorder : AppColors.divider),
              width: 2,
            ),
            boxShadow: isDarkTheme && selected
                ? AppColors.panelShadow(
                    active: true,
                    glowColor: AppColors.activeAccent,
                  )
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected && !isDarkTheme
                  ? AppColors.textOnPrimary
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;

  const _PasswordField({required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption,
        fillColor: AppColors.isDarkMode ? AppColors.cardSurfaceRaised : AppColors.surfaceVariant,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: BorderSide(
            color: AppColors.isDarkMode ? AppColors.panelBorder : AppColors.divider,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: BorderSide(
            color: AppColors.isDarkMode ? AppColors.activeAccent : AppColors.primaryLight,
            width: 2,
          ),
        ),
      ),
      style: AppTextStyles.bodyMedium,
      keyboardType: TextInputType.number,
      obscureText: true,
    );
  }
}

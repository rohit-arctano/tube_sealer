// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/config/display_config.dart';
import '../../core/services/responsive_service.dart';
import '../../widget/components/ui_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _users = ['Supervis', 'Technician', 'Admin'];
  int _selectedUserIndex = 0;
  String _password = '';
  bool _showPassword = false;

  void _login(Responsive r) {
    if (_password.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed('/shell');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter password',
            style: TextStyle(fontSize: r.scaled(14)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: r.bgDark(),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.screenBackgroundGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = r.scaled(12);
              final verticalPadding = r.scaled(16);
              final contentWidth =
                  (constraints.maxWidth - (horizontalPadding * 2))
                      .clamp(280.0, r.scaled(450))
                      .toDouble();

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding,
                ),
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _BrandLogoCard(r: r),
                          SizedBox(height: r.scaled(18)),
                          _buildAccessPanel(r),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAccessPanel(Responsive r) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(r.scaled(16)),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColors.cardSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(r.scaled(AppSizes.cardRadius)),
        border: Border.all(
          color: isDarkTheme ? AppColors.panelBorder : AppColors.divider,
          width: 1.6,
        ),
        boxShadow: AppColors.panelShadow(
          active: isDarkTheme,
          glowColor: isDarkTheme ? AppColors.activeAccentSoft : AppColors.primaryLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: r.scaled(8)),
          SpinBox(
            label: 'User name',
            options: _users,
            initialIndex: _selectedUserIndex,
            onChanged: (idx) => setState(() => _selectedUserIndex = idx),
            r: r,
          ),
          SizedBox(height: r.scaled(18)),
          _buildPasswordField(r),
          SizedBox(height: r.scaled(22)),
          _LoginButton(
            r: r,
            onTap: () => _login(r),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(Responsive r) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            color: r.textLight(),
            fontSize: r.scaled(14),
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: r.scaled(8)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showPasswordInput(r),
            borderRadius: BorderRadius.circular(r.scaled(AppSizes.inputRadius)),
            child: Ink(
              height: r.scaled(56),
              padding: EdgeInsets.symmetric(horizontal: r.scaled(12)),
              decoration: BoxDecoration(
                color: isDarkTheme ? AppColors.cardSurfaceRaised : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(r.scaled(AppSizes.inputRadius)),
                border: Border.all(
                  color: isDarkTheme ? AppColors.panelBorder : AppColors.divider,
                  width: 2,
                ),
                boxShadow: isDarkTheme
                    ? AppColors.panelShadow(glowColor: AppColors.activeAccentSoft)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.password_rounded,
                    color: isDarkTheme ? AppColors.activeAccentSoft : AppColors.primary,
                    size: r.scaled(22),
                  ),
                  SizedBox(width: r.scaled(10)),
                  Expanded(
                    child: Text(
                      _password.isEmpty
                          ? 'Tap to enter password'
                          : (_showPassword ? _password : '*' * _password.length),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _password.isEmpty
                            ? (isDarkTheme
                                ? AppColors.inactiveAccent
                                : AppColors.textSecondary)
                            : r.textLight(),
                        fontSize: r.scaled(16),
                        fontWeight: _password.isEmpty ? FontWeight.w400 : FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  SizedBox(width: r.scaled(8)),
                  GestureDetector(
                    onTap: () => setState(() => _showPassword = !_showPassword),
                    child: Container(
                      width: r.scaled(36),
                      height: r.scaled(36),
                      decoration: BoxDecoration(
                        color: isDarkTheme
                            ? AppColors.selectedSurfaceSoft
                            : Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(r.scaled(12)),
                        border: Border.all(
                          color: isDarkTheme ? AppColors.panelBorder : AppColors.primaryLight,
                        ),
                      ),
                      child: Icon(
                        _showPassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: isDarkTheme ? AppColors.activeAccentSoft : AppColors.primary,
                        size: r.scaled(18),
                      ),
                    ),
                  ),
                  SizedBox(width: r.scaled(8)),
                  Icon(
                    Icons.dialpad_rounded,
                    color: isDarkTheme ? AppColors.activeAccentSoft : AppColors.primary,
                    size: r.scaled(24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPasswordInput(Responsive r) {
    showDialog(
      context: context,
      builder: (ctx) => _NumericKeyboardDialog(
        title: 'Enter Password',
        initialValue: _password,
        onSubmit: (value) {
          setState(() => _password = value);
          Navigator.pop(ctx);
        },
        r: r,
      ),
    );
  }
}

class _BrandLogoCard extends StatelessWidget {
  final Responsive r;

  const _BrandLogoCard({required this.r});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: r.scaled(16),
        vertical: r.scaled(16),
      ),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColors.cardSurface : AppColors.surface,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkTheme
              ? [
                  AppColors.cardSurfaceRaised,
                  AppColors.cardSurface,
                ]
              : [
                  AppColors.surface,
                  AppColors.surfaceVariant,
                ],
        ),
        borderRadius: BorderRadius.circular(r.scaled(AppSizes.cardRadius)),
        border: Border.all(
          color: isDarkTheme ? AppColors.panelBorder : AppColors.divider,
          width: 1.6,
        ),
        boxShadow: AppColors.panelShadow(
          active: true,
          glowColor: isDarkTheme ? AppColors.activeAccentSoft : AppColors.primaryLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r.scaled(18)),
              border: Border.all(
                color: isDarkTheme ? AppColors.panelBorderStrong : AppColors.primaryLight,
                width: 1.3,
              ),
              boxShadow: isDarkTheme
                  ? AppColors.panelShadow(
                      active: true,
                      glowColor: AppColors.activeAccentSoft,
                    )
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(r.scaled(18)),
              child: AspectRatio(
                aspectRatio: 1.8,
                child: Image.asset(
                  'assests/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: r.scaled(16)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.scaled(10),
              vertical: r.scaled(6),
            ),
            decoration: BoxDecoration(
              color: (isDarkTheme ? AppColors.activeAccent : AppColors.primary).withValues(
                alpha: isDarkTheme ? 0.14 : 0.10,
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDarkTheme ? AppColors.panelBorderStrong : AppColors.primaryLight,
              ),
            ),
            child: Text(
              'ADVANCED ENGINEERING SOLUTION',
              style: TextStyle(
                color: isDarkTheme ? AppColors.activeAccentSoft : AppColors.primary,
                fontSize: r.scaled(10),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                fontFamily: 'monospace',
              ),
            ),
          ),
          // SizedBox(height: r.scaled(12)),
          // Text(
          //   'Tube Sealer Login',
          //   style: TextStyle(
          //     color: r.textLight(),
          //     fontSize: r.scaled(24),
          //     fontWeight: FontWeight.w800,
          //     fontFamily: 'monospace',
          //   ),
          // ),
          // SizedBox(height: r.scaled(6)),
          // Text(
          //   'Access the machine controls with your assigned operator profile.',
          //   style: TextStyle(
          //     color: isDarkTheme ? AppColors.inactiveAccent : AppColors.textSecondary,
          //     fontSize: r.scaled(12),
          //     height: 1.4,
          //     fontFamily: 'monospace',
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final Responsive r;
  final VoidCallback onTap;

  const _LoginButton({
    required this.r,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _LoginTextButton(
        r: r,
        label: 'Login',
        icon: Icons.login_rounded,
        backgroundColor: AppColors.selectedSurface,
        foregroundColor: AppColors.textOnPrimary,
        borderColor: AppColors.panelBorderStrong,
        onTap: onTap,
      ),
    );
  }
}

class _LoginTextButton extends StatelessWidget {
  final Responsive r;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _LoginTextButton({
    required this.r,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(r.scaled(AppSizes.buttonRadius));
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: r.scaled(AppSizes.bigButton),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              border: Border.all(color: borderColor, width: 2),
              boxShadow: isDarkTheme
                  ? AppColors.panelShadow(active: true, glowColor: borderColor)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: r.scaled(22),
                  color: foregroundColor,
                ),
                SizedBox(width: r.scaled(8)),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: r.scaled(16),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Numeric keyboard dialog that keeps its action row visible on shorter screens.
class _NumericKeyboardDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final ValueChanged<String> onSubmit;
  final Responsive r;

  const _NumericKeyboardDialog({
    required this.title,
    required this.initialValue,
    required this.onSubmit,
    required this.r,
  });

  @override
  State<_NumericKeyboardDialog> createState() => _NumericKeyboardDialogState();
}

class _NumericKeyboardDialogState extends State<_NumericKeyboardDialog> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final maxW = widget.r.scaled(480);
    final maxH = MediaQuery.of(context).size.height * 0.9;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final contentPadding =
        MediaQuery.of(context).viewInsets + EdgeInsets.all(widget.r.scaled(12));
    final keySpacing = widget.r.scaled(6);

    return Dialog(
      backgroundColor: isDarkTheme ? AppColors.cardSurface : AppColors.surface,
      insetPadding: EdgeInsets.all(widget.r.scaled(10)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxW,
          maxHeight: maxH,
          minWidth: widget.r.scaled(280),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentHeight =
                (constraints.maxHeight - contentPadding.vertical)
                    .clamp(0.0, constraints.maxHeight)
                    .toDouble();

            return Padding(
              padding: contentPadding,
              child: SizedBox(
                height: contentHeight,
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.r.textLight(),
                        fontSize: widget.r.scaled(18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: widget.r.scaled(12)),
                    Container(
                      width: double.infinity,
                      height: widget.r.scaled(48),
                      decoration: BoxDecoration(
                        color: isDarkTheme ? AppColors.cardSurfaceRaised : AppColors.surfaceVariant,
                        borderRadius:
                            BorderRadius.circular(widget.r.scaled(AppSizes.inputRadius)),
                        border: Border.all(
                          color: isDarkTheme ? AppColors.panelBorder : widget.r.borderDark(),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '*' * _currentValue.length,
                        style: TextStyle(
                          color: widget.r.textLight(),
                          fontSize: widget.r.scaled(18),
                        ),
                      ),
                    ),
                    SizedBox(height: widget.r.scaled(12)),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, keypadConstraints) {
                          final keyHeight =
                              ((keypadConstraints.maxHeight - (keySpacing * 3)) / 4)
                                  .clamp(widget.r.scaled(32), widget.r.scaled(64))
                                  .toDouble();

                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: 12,
                            physics: const ClampingScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: keySpacing,
                              crossAxisSpacing: keySpacing,
                              mainAxisExtent: keyHeight,
                            ),
                            itemBuilder: (context, i) {
                              String label;
                              VoidCallback onTap;

                              if (i < 9) {
                                label = '${i + 1}';
                                onTap = () => setState(() => _currentValue += label);
                              } else if (i == 9) {
                                label = '0';
                                onTap = () => setState(() => _currentValue += label);
                              } else if (i == 10) {
                                label = '<';
                                onTap = () => setState(() {
                                      if (_currentValue.isNotEmpty) {
                                        _currentValue = _currentValue.substring(
                                          0,
                                          _currentValue.length - 1,
                                        );
                                      }
                                    });
                              } else {
                                label = 'Clear';
                                onTap = () => setState(() => _currentValue = '');
                              }

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: onTap,
                                  borderRadius: BorderRadius.circular(
                                    widget.r.scaled(AppSizes.buttonRadius),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDarkTheme ? AppColors.cardSurface : AppColors.surface,
                                      borderRadius: BorderRadius.circular(
                                        widget.r.scaled(AppSizes.buttonRadius),
                                      ),
                                      border: Border.all(
                                        color: isDarkTheme
                                            ? AppColors.panelBorder
                                            : widget.r.borderDark(),
                                        width: 1,
                                      ),
                                      boxShadow: isDarkTheme
                                          ? AppColors.panelShadow(glowColor: AppColors.activeAccent)
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          color: widget.r.textLight(),
                                          fontSize: widget.r.scaled(18),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: widget.r.scaled(12)),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: widget.r.scaled(12),
                      runSpacing: widget.r.scaled(8),
                      children: [
                        _DialogActionButton(
                          r: widget.r,
                          backgroundColor: isDarkTheme
                              ? AppColors.selectedSurface
                              : widget.r.accentColor(),
                          iconColor: AppColors.textOnPrimary,
                          icon: Icons.check,
                          onTap: () => widget.onSubmit(_currentValue),
                        ),
                        _DialogActionButton(
                          r: widget.r,
                          backgroundColor: isDarkTheme
                              ? AppColors.cardSurfaceRaised
                              : AppColors.surfaceVariant,
                          iconColor: isDarkTheme
                              ? AppColors.activeAccentSoft
                              : AppColors.textPrimary,
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  final Responsive r;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;

  const _DialogActionButton({
    required this.r,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: r.touchTargetDp(),
      height: r.touchTargetDp(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(r.scaled(AppSizes.buttonRadius)),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDarkTheme ? AppColors.panelBorder : AppColors.divider,
                width: 2,
              ),
              color: backgroundColor,
              borderRadius: BorderRadius.circular(r.scaled(AppSizes.buttonRadius)),
              boxShadow: isDarkTheme
                  ? AppColors.panelShadow(
                      active: icon != Icons.close_rounded,
                      glowColor: icon == Icons.close_rounded
                          ? AppColors.activeAccentSoft
                          : AppColors.activeAccent,
                    )
                  : null,
            ),
            child: Center(
              child: Icon(
                icon,
                size: r.scaled(28),
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

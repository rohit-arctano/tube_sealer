import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/constants/app_strings.dart';
import '../../app/constants/app_sizes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/config/display_config.dart';
import '../../core/models/machine_ui_state.dart';
import '../../core/services/machine_service.dart';
import '../../core/services/responsive_service.dart';
import '../../widget/components/ui_components.dart';
import '../alarms/presentation/alarm_screen.dart';
import '../history/presentation/history_screen.dart';
import '../home/menu_screen.dart';
import '../home/presentation/home_screen.dart';
import '../recipes/presentation/recipe_screen.dart';
import '../run/presentation/run_screen.dart';
import '../settings/presentation/settings_screen.dart';

/// Root shell that wraps every screen with the shared header and menu-driven navigation.
class MainShellScreen extends StatefulWidget {
  final MachineService machineService;

  const MainShellScreen({super.key, required this.machineService});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;
  MachineUiState _machineState = const MachineUiState();
  StreamSubscription<MachineUiState>? _sub;

  List<MenuListItem> get _menuItems => const [
        MenuListItem(
          icon: Icons.home_rounded,
          label: AppStrings.navHome,
          subtitle: 'Machine overview, cycle counters, and quick actions.',
        ),
        MenuListItem(
          icon: Icons.play_circle_outline_rounded,
          label: AppStrings.navRun,
          subtitle: 'Live sealing progress, parameters, and run controls.',
        ),
        MenuListItem(
          icon: Icons.science_outlined,
          label: AppStrings.navRecipes,
          subtitle: 'Browse, filter, and review available tube recipes.',
        ),
        MenuListItem(
          icon: Icons.history_rounded,
          label: AppStrings.navHistory,
          subtitle: 'View historic cycles, pass/fail records, and operators.',
        ),
        MenuListItem(
          icon: Icons.settings_outlined,
          label: AppStrings.navSettings,
          subtitle: 'Theme, account, and application preferences.',
        ),
      ];

  @override
  void initState() {
    super.initState();
    _sub = widget.machineService.watchMachineState().listen((s) {
      setState(() => _machineState = s);
      if (s.activeAlarm != null && _selectedIndex != 5) {
        setState(() => _selectedIndex = 5);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(service: widget.machineService);
      case 1:
        return RunScreen(service: widget.machineService);
      case 2:
        return const RecipeScreen();
      case 3:
        return const HistoryScreen();
      case 4:
        return const SettingsScreen();
      case 5:
        return AlarmScreen(service: widget.machineService);
      default:
        return HomeScreen(service: widget.machineService);
    }
  }

  String _screenTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Overview';
      case 1:
        return 'Sealing process';
      case 2:
        return 'Recipes';
      case 3:
        return 'Log data';
      case 4:
        return 'Settings';
      case 5:
        return 'Alarm';
      default:
        return '';
    }
  }

  Future<void> _openMenu() async {
    final selected = await Navigator.of(context).push<int>(
      PageRouteBuilder<int>(
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return MenuScreen(
            username: _machineState.userRole.label,
            title: 'Menu',
            description: 'Navigate through the machine app using a clean mobile-style menu.',
            items: _menuItems,
            selectedIndex: _selectedIndex > 4 ? null : _selectedIndex,
            onItemTap: (index) => Navigator.of(context).pop(index),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );

    if (!mounted || selected == null || selected == _selectedIndex) return;
    setState(() => _selectedIndex = selected);
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final timestamp =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: r.bgDark(),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.screenBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  r.scaled(10),
                  r.scaled(10),
                  r.scaled(10),
                  0,
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    r.scaled(14),
                    r.scaled(12),
                    r.scaled(14),
                    0,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkTheme ? AppColors.cardSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(r.scaled(24)),
                    border: Border.all(
                      color: isDarkTheme ? AppColors.panelBorder : AppColors.divider,
                      width: 1.5,
                    ),
                    boxShadow: AppColors.panelShadow(),
                  ),
                  child: HeaderBar(
                    timestamp: timestamp,
                    title: _screenTitle(),
                    username: _machineState.userRole.label,
                    r: r,
                    trailingAction: _ShellMenuButton(
                      onTap: _openMenu,
                      r: r,
                    ),
                  ),
                ),
              ),
              SizedBox(height: r.scaled(10)),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: KeyedSubtree(
                    key: ValueKey(_selectedIndex),
                    child: _buildBody(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  final Responsive r;

  const _ShellMenuButton({
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
            horizontal: r.scaled(12),
            vertical: r.scaled(10),
          ),
          decoration: BoxDecoration(
            color: isDarkTheme ? AppColors.selectedSurface : AppColors.primary,
            borderRadius: buttonRadius,
            border: isDarkTheme
                ? Border.all(color: AppColors.panelBorderStrong, width: 1.5)
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
                Icons.menu_rounded,
                size: r.scaled(18),
                color: AppColors.textOnPrimary,
              ),
              SizedBox(width: r.scaled(8)),
              Text(
                'Menu',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: r.scaled(12),
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

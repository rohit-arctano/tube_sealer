import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/config/display_config.dart';
import '../../core/models/machine_ui_state.dart';
import '../../core/services/machine_service.dart';
import '../../core/services/responsive_service.dart';
import '../../widget/components/ui_components.dart';
import '../alarms/presentation/alarm_screen.dart';
import '../history/presentation/history_screen.dart';
import '../home/presentation/home_screen.dart';
import '../recipes/presentation/recipe_screen.dart';
import '../run/presentation/run_screen.dart';
import '../settings/presentation/settings_screen.dart';
import 'bottom_nav_bar.dart';

/// Root shell that wraps every screen with the reference-style header and nav.
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

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);
    final now = DateTime.now();
    final timestamp =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: r.bgDark(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                r.scaled(10),
                r.scaled(8),
                r.scaled(10),
                0,
              ),
              child: HeaderBar(
                timestamp: timestamp,
                title: _screenTitle(),
                username: _machineState.userRole.label,
                r: r,
              ),
            ),
            Expanded(child: _buildBody()),
            BottomNavBar(
              selectedIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
            ),
          ],
        ),
      ),
    );
  }
}
